import { Router, Response } from "express";
import { pool } from "../db";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { isValidAgeGroups, isValidCategory, isValidGender, isValidAgeGroup, isValidRegion } from "../modules/meetings/meetings-invalid";
import { meetingMapper } from "../modules/meetings/meetings-mapper";
import { ok, fail } from "../utils/response";

const router = Router();

router.get("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  const category = String(req.query.category || "").trim();
  const gender = String(req.query.gender || "").trim();
  const ageGroup = String(req.query.ageGroup || "").trim();
  const regionPrimary = String(req.query.regionPrimary || "").trim();
  const q = String(req.query.q || "").trim();

  const categoryFilter = category ? category : null;
  const genderFilter = gender && gender !== "any" ? gender : null;
  const ageGroupFilter = ageGroup && ageGroup !== "any" ? ageGroup : null;
  const regionPrimaryFilter = regionPrimary ? regionPrimary : null;
  const keywordFilter = q ? `%${q}%` : null;

  if (category && !isValidCategory(category)) {
    return fail(res, 400, "invalid category");
  }

  if (gender && !isValidGender(gender)) {
    return fail(res, 400, "invalid gender");
  }

  if (ageGroup && !isValidAgeGroup(ageGroup)) {
    return fail(res, 400, "invalid ageGroup");
  }

  if (regionPrimary && !isValidRegion(regionPrimary)) {
    return fail(res, 400, "invalid region");
  }

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
        and ($1::text is null or m.category = $1)
        and ($2::text is null or m.gender = $2 or m.gender = 'any')
        and (
          $3::text is null
          or m.age_groups = array['any']::text[]
          or $3 = any(m.age_groups)
        )
        and (
          $4::text is null
          or m.title ilike $4
          or m.place_text ilike $4
          or m.description ilike $4
        )
        and (
          $5::text is null or m.region_primary = $5
        )
      group by m.id
      order by m.scheduled_at asc, m.id desc
      `,
      [categoryFilter, genderFilter, ageGroupFilter, keywordFilter, regionPrimaryFilter]
    );

    return ok(res, {
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
    });
  } catch (error: any) {
    console.error("GET /meetings error:", error);
    return fail(res, 500, "failed to load meetings");
  } finally {
    client.release();
  }
});

//홈 화면 지도 용 요약해서 보기
router.get("/home", async (_req, res: Response) => {
  const client = await pool.connect();

  try {
    const meetingRes = await client.query(
      `
      select id, category, region_primary
      from meetings
      where status = 'open'
      order by id asc
      `
    );

    const regionGroup = meetingMapper(meetingRes.rows);

    const regionSummary = Object.entries(regionGroup).map(([regionPrimary, items]) => {
      const firstCategory = items[0]?.category ?? null;

      let category = '기타';
      let icon = "📍";
      if (firstCategory === "cafe") {
        icon = "☕";
        category = '카페';
      } else if (firstCategory === "food") {
        icon = "🍜";
        category = '식사';
      }
      else if (firstCategory === "activity") {
        icon = "🏄";
        category = '액티비티';
      }
      else if (firstCategory === "drink") {
        icon = "🍺";
        category = '술';
      }
      else if (firstCategory === "tour") {
        icon = "🚗";
        category = '관광';
      }

      return {
        regionPrimary,
        firstCategory,
        totalCount: items.length,
        summaryText: items.length > 1
          ? `${icon} ${category ?? "기타"} · 외 ${items.length - 1}건`
          : `${icon} ${category ?? "기타"} 1건`,
      };
    });

    return ok(res, {
      item: regionSummary,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to load meetings");
  } finally {
    client.release();
  }
});


// 동행 상세 조회
router.get("/:id", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return fail(res, 400, "invalid meeting id");
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
      return fail(res, 404, "meeting not found");
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

    return ok(res, {
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
    });
  } catch (error: any) {
    console.error("GET /meetings/:id error:", error);
    return fail(res, 500, "failed to load meeting detail");
  } finally {
    client.release();
  }
});

// 동행 생성
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

  if (
    typeof title !== "string" ||
    !title.trim() ||
    typeof placeText !== "string" ||
    !placeText.trim() ||
    typeof regionPrimary !== "string" ||
    !regionPrimary.trim() ||
    typeof regionSecondary !== "string" ||
    !regionSecondary.trim() ||
    typeof scheduledAt !== "string" ||
    !scheduledAt.trim() ||
    typeof description !== "string" ||
    !description.trim()
  ) {
    return fail(res, 400, "invalid text fields");
  }

  const latNum = Number(placeLat);
  const lngNum = Number(placeLng);
  const maxMembersNum = Number(maxMembers);

  if (!Number.isFinite(latNum) || !Number.isFinite(lngNum)) {
    return fail(res, 400, "invalid place coordinates");
  }

  if (!Number.isInteger(maxMembersNum) || maxMembersNum < 2) {
    return fail(res, 400, "invalid maxMembers");
  }

  if (!isValidRegion(regionPrimary)) {
    return fail(res, 400, "invalid regionPrimary");
  }

  if (typeof gender !== "string" || !isValidGender(gender)) {
    return fail(res, 400, "invalid gender");
  }

  if (!isValidAgeGroups(ageGroups)) {
    return fail(res, 400, "invalid ageGroups");
  }

  if (!isValidCategory(category)) {
    return fail(res, 400, "invalid category");
  }

  const scheduledDate = new Date(scheduledAt);
  if (Number.isNaN(scheduledDate.getTime())) {
    return fail(res, 400, "invalid scheduledAt");
  }

  if (!isValidAgeGroups(ageGroups)) {
    return fail(res, 400, "invalid ageGroups");
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

    return ok(
      res,
      {
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
      201
    );
  } catch (error: any) {
    await client.query("rollback");
    return fail(res, 500, "failed to create meeting");
  } finally {
    client.release();
  }
});

// 동행 수정
router.patch("/:id", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return fail(res, 400, "invalid meeting id");
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
    return fail(res, 400, "invalid ageGroups");
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
      return fail(res, 404, "meeting not found");
    }

    if (meetingCheckRes.rows[0].host_user_id !== userId) {
      return fail(res, 403, "forbidden");
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

    return ok(res, {
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
    });
  } catch (error: any) {
    console.error("PATCH /meetings/:id error:", error);
    return fail(res, 500, "failed to update meeting");
  } finally {
    client.release();
  }
});

// 동행 삭제
router.delete("/:id", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return fail(res, 400, "invalid meeting id");
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
      return fail(res, 404, "meeting not found");
    }

    if (meetingCheckRes.rows[0].host_user_id !== userId) {
      return fail(res, 403, "forbidden");
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
      return fail(res, 400, "meeting has members");
    }

    await client.query(
      `
      delete from meetings
      where id = $1
      `,
      [meetingId]
    );

    return ok(res, {
      message: "meeting deleted",
    });
  } catch (error: any) {
    console.error("DELETE /meetings/:id error:", error);
    return fail(res, 500, "failed to delete meeting");
  } finally {
    client.release();
  }
});

// 동행 참가
router.post("/:id/join", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return fail(res, 400, "invalid meeting id");
  }

  const client = await pool.connect();

  try {
    await client.query("begin");

    const joinCheckRes = await client.query(
      `
      select id
      from meeting_members
      where user_id = $1
        and meeting_id = $2
        and status = 'joined'
      `,
      [userId, meetingId]
    );

    if (joinCheckRes.rowCount !== 0) {
      await client.query("rollback");
      return fail(res, 409, "already joined meeting");
    }

    const meetingRes = await client.query(
      `
      select id, max_members, status
      from meetings
      where id = $1
      for update
      `,
      [meetingId]
    );

    if (meetingRes.rowCount === 0) {
      await client.query("rollback");
      return fail(res, 404, "meeting not found");
    }

    const meeting = meetingRes.rows[0];

    if (meeting.status !== "open") {
      await client.query("rollback");
      return fail(res, 409, "meeting status is not open");
    }

    const memberCountRes = await client.query(
      `
      select count(id) as current_member_count
      from meeting_members
      where meeting_id = $1
        and status = 'joined'
      `,
      [meetingId]
    );

    const meetingMaxMember = Number(meeting.max_members);
    const meetingCurrentMember = Number(memberCountRes.rows[0].current_member_count);

    if (meetingCurrentMember >= meetingMaxMember) {
      await client.query("rollback");
      return fail(res, 409, "over capacity meeting");
    }

    const joinRes = await client.query(
      `
      insert into meeting_members (
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
      await client.query("rollback");
      return fail(res, 500, "failed to join meeting");
    }

    if (meetingCurrentMember + 1 === meetingMaxMember) {
      await client.query(
        `
        update meetings
        set status = 'closed'
        where id = $1
          and status = 'open'
        `,
        [meetingId]
      );
    }

    await client.query("commit");

    return ok(
      res,
      {
        item: {
          id: joinRes.rows[0].id,
          meetingId,
        },
      },
      201
    );
  } catch (error: any) {
    await client.query("rollback");
    return fail(res, 500, "failed to join meeting");
  } finally {
    client.release();
  }
});

// 동행 나가기
router.post("/:id/leave", authRequired, async (req: AuthRequest, res: Response) => {
  const meetingId = Number(req.params.id);
  const userId = req.user!.userId;

  if (!Number.isInteger(meetingId) || meetingId <= 0) {
    return fail(res, 400, "invalid meeting id");
  }

  const client = await pool.connect();

  try {
    await client.query("begin");

    const meetingMemberCheckRes = await client.query(
      `
      select id, meeting_id, user_id, role
      from meeting_members
      where meeting_id = $1
        and user_id = $2
        and status = 'joined'
      `,
      [meetingId, userId]
    );

    if (meetingMemberCheckRes.rowCount === 0) {
      await client.query("rollback");
      return fail(res, 400, "meeting_member not found");
    }

    if (meetingMemberCheckRes.rows[0].role === "host") {
      await client.query("rollback");
      return fail(res, 403, "host cannot leave meeting");
    }

    const meetingMemberId = meetingMemberCheckRes.rows[0].id;

    const meetingRes = await client.query(
      `
      select id, max_members, status
      from meetings
      where id = $1
      for update
      `,
      [meetingId]
    );

    if (meetingRes.rowCount === 0) {
      await client.query("rollback");
      return fail(res, 404, "meeting not found");
    }

    await client.query(
      `
      update meeting_members
      set status = 'left'
      where id = $1
      `,
      [meetingMemberId]
    );

    const memberCountRes = await client.query(
      `
      select count(id) as current_member_count
      from meeting_members
      where meeting_id = $1
        and status = 'joined'
      `,
      [meetingId]
    );

    const meetingMaxMember = Number(meetingRes.rows[0].max_members);
    const meetingCurrentMember = Number(memberCountRes.rows[0].current_member_count);

    if (meetingCurrentMember < meetingMaxMember) {
      await client.query(
        `
        update meetings
        set status = 'open'
        where id = $1
          and status = 'closed'
        `,
        [meetingId]
      );
    }

    await client.query("commit");

    return ok(res, {
      message: "meeting left",
    });
  } catch (error: any) {
    await client.query("rollback");
    return fail(res, 500, "failed to leave meeting");
  } finally {
    client.release();
  }
});

export default router;