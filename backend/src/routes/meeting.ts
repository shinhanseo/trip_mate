import { Router, Request, Response } from "express";
import { pool } from "../db.js";
import { authRequired, AuthRequest } from "../middleware/authRequired.js";
import { isValidAgeGroups } from "../utils/ageGroup.js";

const router = Router();

// 동행 목록 조회
router.get("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  const client = await pool.connect();

  try {
    const meetingRes = await client.query(
      `
      select
        m.id,
        m.title,
        m.place_text,
        m.scheduled_at,
        m.max_members,
        m.gender,
        m.age_groups,
        m.category,
        m.region_primary,
        count(mm.id) filter (where mm.status = 'joined') as current_members
      from meetings m
      left join meeting_members mm
        on mm.meeting_id = m.id
      where m.status = 'open'
      group by m.id
      order by m.scheduled_at asc, m.id desc
      `
    );

    return res.json({
      success: true,
      data: {
        userId,
        items: meetingRes.rows.map((row) => ({
          id: row.id,
          title: row.title,
          placeText: row.place_text,
          scheduledAt: row.scheduled_at,
          maxMembers: row.max_members,
          currentMembers: Number(row.current_members),
          gender: row.gender,
          ageGroups: row.age_groups,
          category: row.category,
          regionPrimary: row.region_primary,
        })),
      },
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: "failed to load meetings"
    });
  } finally {
    client.release();
  }
});

// 동행 목록 자세히 보기
router.get("/:id", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return res.status(400).json({ message: "invalid meeting id" });
  }

  const client = await pool.connect();

  try {
    const meetingRes = await client.query(
      `
      select
        m.id,
        m.host_user_id,
        m.title,
        m.place_text,
        m.region_primary,
        m.region_secondary,
        m.scheduled_at,
        m.max_members,
        m.gender,
        m.age_groups,
        m.category,
        m.description,
        m.status,
        count(mm.id) filter (where mm.status = 'joined') as current_members
      from meetings m
      left join meeting_members mm
        on mm.meeting_id = m.id
      where m.id = $1
      group by m.id
      `,
      [meetingId]
    );

    if (meetingRes.rowCount === 0) {
      return res.status(404).json({ message: "meeting not found" });
    }

    const membersRes = await client.query(
      `
      select
        mm.user_id,
        mm.role,
        mm.joined_at,
        u.nickname,
        u.profile_image_url
      from meeting_members mm
      join users u
        on u.id = mm.user_id
      where mm.meeting_id = $1
        and mm.status = 'joined'
      order by
        case when mm.role = 'host' then 0 else 1 end,
        mm.joined_at asc
      `,
      [meetingId]
    );

    const row = meetingRes.rows[0];

    return res.json({
      success: true,
      data: {
        item: {
          id: row.id,
          hostUserId: row.host_user_id,
          title: row.title,
          placeText: row.place_text,
          regionPrimary: row.region_primary,
          regionSecondary: row.region_secondary,
          scheduledAt: row.scheduled_at,
          maxMembers: row.max_members,
          currentMembers: Number(row.current_members),
          gender: row.gender,
          ageGroups: row.age_groups,
          category: row.category,
          description: row.description,
          status: row.status,
          members: membersRes.rows.map((member) => ({
            userId: member.user_id,
            nickname: member.nickname,
            profileImageUrl: member.profile_image_url,
            role: member.role,
            joinedAt: member.joined_at,
          })),
        },
      },
    });
  } catch (error: any) {
    console.error("GET /meetings/:id error:", error);
    return res.status(500).json({
      success: false,
      message: "failed to load meeting detail",
    });
  } finally {
    client.release();
  }
});

router.post("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  const {
    title,
    placeText,
    placeLat,
    placeLng,
    regionPrimary,
    regionSecondary,
    scheduledAt,
    maxMembers,
    gender,
    ageGroups,
    category,
    description,
  } = req.body;

  if (!isValidAgeGroups(ageGroups)) {
    return res.status(400).json({
      success: false,
      message: "invalid ageGroups",
    });
  }

  const client = await pool.connect();

  try {
    await client.query("begin");

    const meetingRes = await client.query(
      `
      insert into meetings (
        host_user_id,
        title,
        place_text,
        place_lat,
        place_lng,
        region_primary,
        region_secondary,
        scheduled_at,
        max_members,
        gender,
        age_groups,
        category,
        description,
        status
      )
      values (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, $11, $12, $13, 'open'
      )
      returning id, host_user_id, title, place_text, place_lat, place_lng,
                region_primary, region_secondary, scheduled_at, max_members,
                gender, age_groups, category, description, status, created_at, updated_at
      `,
      [
        userId,
        title,
        placeText,
        placeLat ?? null,
        placeLng ?? null,
        regionPrimary,
        regionSecondary ?? null,
        scheduledAt,
        maxMembers,
        gender,
        ageGroups,
        category,
        description,
      ]
    );

    const meeting = meetingRes.rows[0];

    await client.query(
      `
      insert into meeting_members (
        meeting_id,
        user_id,
        role,
        status
      )
      values ($1, $2, 'host', 'joined')
      `,
      [meeting.id, userId]
    );

    await client.query("commit");

    return res.json({
      success: true,
      data: {
        item: {
          id: meeting.id,
          hostUserId: meeting.host_user_id,
          title: meeting.title,
          placeText: meeting.place_text,
          placeLat: meeting.place_lat,
          placeLng: meeting.place_lng,
          regionPrimary: meeting.region_primary,
          regionSecondary: meeting.region_secondary,
          scheduledAt: meeting.scheduled_at,
          maxMembers: meeting.max_members,
          currentMembers: 1,
          gender: meeting.gender,
          ageGroups: meeting.age_groups,
          category: meeting.category,
          description: meeting.description,
          status: meeting.status,
          createdAt: meeting.created_at,
          updatedAt: meeting.updated_at,
        },
      },
    });

  } catch (error: any) {
    await client.query("rollback");
    return res.status(500).json({
      success: false,
      message: "failed to create meeting"
    });

  } finally {
    client.release();
  }
});

// 동행 수정
router.patch("/:id", authRequired, async (req: AuthRequest, res) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return res.status(400).json({ message: "invalid meeting id" });
  }

  const {
    title,
    placeText,
    placeLat,
    placeLng,
    regionPrimary,
    regionSecondary,
    scheduledAt,
    maxMembers,
    gender,
    ageGroups,
    category,
    description,
    status,
  } = req.body;

  if (!isValidAgeGroups(ageGroups)) {
    return res.status(400).json({
      success: false,
      message: "invalid ageGroups",
    });
  }

  const client = await pool.connect();

  try {
    const meetingCheckRes = await client.query(
      `
      select id, host_user_id
      from meetings
      where id = $1
      `,
      [meetingId]
    );

    if (meetingCheckRes.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "meeting not found",
      });
    }

    if (meetingCheckRes.rows[0].host_user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: "forbidden",
      });
    }

    const updateRes = await client.query(
      `
      update meetings
      set
        title = $1,
        place_text = $2,
        place_lat = $3,
        place_lng = $4,
        region_primary = $5,
        region_secondary = $6,
        scheduled_at = $7,
        max_members = $8,
        gender = $9,
        age_groups = $10,
        category = $11,
        description = $12,
        status = $13,
        updated_at = now()
      where id = $14
      returning
        id,
        host_user_id,
        title,
        place_text,
        place_lat,
        place_lng,
        region_primary,
        region_secondary,
        scheduled_at,
        max_members,
        gender,
        age_groups,
        category,
        description,
        status,
        created_at,
        updated_at
      `,
      [
        title,
        placeText,
        placeLat ?? null,
        placeLng ?? null,
        regionPrimary,
        regionSecondary ?? null,
        scheduledAt,
        maxMembers,
        gender,
        ageGroups,
        category,
        description,
        status,
        meetingId,
      ]
    );

    const meeting = updateRes.rows[0];

    const memberCountRes = await client.query(
      `
      select count(*) filter (where status = 'joined') as current_members
      from meeting_members
      where meeting_id = $1
      `,
      [meetingId]
    );

    return res.json({
      success: true,
      data: {
        item: {
          id: meeting.id,
          hostUserId: meeting.host_user_id,
          title: meeting.title,
          placeText: meeting.place_text,
          placeLat: meeting.place_lat,
          placeLng: meeting.place_lng,
          regionPrimary: meeting.region_primary,
          regionSecondary: meeting.region_secondary,
          scheduledAt: meeting.scheduled_at,
          maxMembers: meeting.max_members,
          currentMembers: Number(memberCountRes.rows[0].current_members),
          gender: meeting.gender,
          ageGroups: meeting.age_groups,
          category: meeting.category,
          description: meeting.description,
          status: meeting.status,
          createdAt: meeting.created_at,
          updatedAt: meeting.updated_at,
        },
      },
    });
  } catch (error: any) {
    console.error("PATCH /meetings/:id error:", error);
    return res.status(500).json({
      success: false,
      message: "failed to update meeting",
    });
  } finally {
    client.release();
  }
});

// 동행 삭제
router.delete("/:id", authRequired, async (req: AuthRequest, res) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return res.status(400).json({ message: "invalid meeting id" });
  }

  const client = await pool.connect();

  try {
    const meetingCheckRes = await client.query(
      `
      select id, host_user_id
      from meetings
      where id = $1
      `,
      [meetingId]
    );

    if (meetingCheckRes.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "meeting not found",
      });
    }

    if (meetingCheckRes.rows[0].host_user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: "forbidden",
      });
    }

    const meetingMemberCheckRes = await client.query(
      `
      select count(id) as member_count
      from meeting_members
      where meeting_id = $1
      and role <> 'host'
      and status = 'joined'
      `,
      [meetingId]
    );

    if (Number(meetingMemberCheckRes.rows[0].member_count) > 0) {
      return res.status(400).json({
        success: false,
        message: "meeting has members",
      });
    }

    await client.query(
      `
      delete from meetings
      where id = $1
      `,
      [meetingId]
    );

    return res.json({
      success: true,
      message: "meeting deleted",
    });
  } catch (error: any) {
    console.error("DELETE /meetings/:id error:", error);
    return res.status(500).json({
      success: false,
      message: "failed to delete meeting",
    });
  } finally {
    client.release();
  }
});

router.post("/:id/join", authRequired, async (req: AuthRequest, res) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return res.status(400).json({
      success: false,
      message: "invalid meeting id",
    });
  }

  const client = await pool.connect();

  try {
    await client.query("begin");

    const joinCheckRes = await client.query(
      `
        select id
        from meeting_members
        where user_id = $1 and meeting_id = $2 and status = 'joined'
      `,
      [userId, meetingId]
    );

    if (joinCheckRes.rowCount !== 0) {
      await client.query("rollback");
      return res.status(409).json({ message: "already joined meeting" });
    }

    const memberCountCheckRes = await client.query(
      `
        select
          m.max_members,
          count(mm.id) as current_member_count,
          m.status
        from meetings m
        left join meeting_members mm
          on mm.meeting_id = m.id
          and mm.status = 'joined'
        where m.id = $1
        group by m.id, m.max_members, m.status
      `,
      [meetingId]
    );


    if (memberCountCheckRes.rowCount === 0) {
      await client.query("rollback");
      return res.status(404).json({
        success: false,
        message: "meeting not found",
      });
    }

    if (memberCountCheckRes.rows[0].status !== 'open') {
      await client.query("rollback");
      return res.status(409).json({
        message: "meeting status is not open"
      });
    }

    const meetingMaxMember = memberCountCheckRes.rows[0].max_members;
    const meetingCurrentMember = memberCountCheckRes.rows[0].current_member;

    if (Number(meetingCurrentMember) >= Number(meetingMaxMember)) {
      await client.query("rollback");
      return res.status(409).json({ message: "over capacity meeting" });
    }

    const joinRes = await client.query(
      `
      insert into meeting_members(
        meeting_id,
        user_id,
        role,
        status
      )
      values ($1, $2, 'member', 'joined')
      returning id
      `,
      [meetingId, userId]
    );


    if (joinRes.rowCount === 0) {
      return res.status(500).json({ message: "failed to join meeting" });
    }

    await client.query("commit");

    return res.status(201).json({
      success: true,
      data: {
        item: {
          id: joinRes.rows[0].id
        }
      }
    })

  } catch (error: any) {
    await client.query("rollback");
    return res.status(500).json({
      success: false,
      message: "failed to join meeting",
    })
  } finally {
    client.release();
  }
});

router.post("/:id/leave", authRequired, async (req: AuthRequest, res) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return res.status(400).json({
      success: false,
      message: "invalid meeting id",
    });
  }

  const client = await pool.connect();

  try {
    await client.query("begin");

    const meetingMemberCheckRes = await client.query(
      `
      select id, meeting_id, user_id
      from meeting_members
      where meeting_id = $1 and user_id = $2 and status = 'joined'
      `,
      [meetingId, userId]
    );

    if (meetingMemberCheckRes.rowCount === 0) {
      return res.status(400).json({ message: "not found meeting_member" });
    }

    const meetingMemberId = meetingMemberCheckRes.rows[0].id;

    await client.query(
      `
      update meeting_members
      set status = 'left'
      where id = $1
      `,
      [meetingMemberId]
    );

    await client.query("commit");

    return res.json({
      success: true,
      message: "meeting leaved"
    });

  } catch (error: any) {
    await client.query("rollback");

    return res.status(500).json({
      success: false,
      message: "failed to leave meeting"
    });
  } finally {
    client.release();
  }
})

export default router;