import { Router } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired.js";
import { pool } from "../db.js";
import { ok, fail } from "../utils/response.js";
import { isValidNickname, validateProfileInput } from "../modules/users/user-invalid.js";

const router = Router();

router.patch("/nickname", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;
  const rawNickname = req.body.nickname;

  if (typeof rawNickname !== "string") {
    return fail(res, 400, "nickname must be string");
  }

  const nickname = rawNickname.trim();

  if (!isValidNickname(nickname)) {
    return fail(res, 400, "invalid nickname");
  }

  const client = await pool.connect();

  try {
    const nicknameRes = await client.query(
      `
      update user_profiles
      set nickname = $1,
          updated_at = now()
      where user_id = $2
      returning user_id, nickname
      `,
      [nickname, userId]
    );

    if (nicknameRes.rowCount === 0) {
      return fail(res, 404, "profile not found");
    }

    return ok(res, {
      item: {
        id: nicknameRes.rows[0].user_id,
        nickname: nicknameRes.rows[0].nickname,
        profile_completed: true,
      },
    });
  } catch (error: any) {
    if (error.code === "23505") {
      return fail(res, 409, "duplicate nickname");
    }

    return fail(res, 500, "failed to set nickname", error.message);
  } finally {
    client.release();
  }
});

// 내가 참여한 미팅 가져오기
router.get("/meeting/total", authRequired, async (req: AuthRequest, res) => {
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
        count(mm_all.id) filter (where mm_all.status = 'joined') as current_members
      from meetings m
      join meeting_members mm_me
        on mm_me.meeting_id = m.id
        and mm_me.user_id = $1
        and mm_me.status = 'joined'
      left join meeting_members mm_all
        on mm_all.meeting_id = m.id
      where m.status <> 'cancelled'
      group by
        m.id,
        m.title,
        m.place_text,
        m.scheduled_at,
        m.max_members,
        m.gender,
        m.age_groups,
        m.category,
        m.region_primary
      order by m.scheduled_at asc, m.id desc;
      `,
      [userId]
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
    return fail(res, 500, "falied to load meetings");
  } finally {
    client.release();
  }
})

// 내가 호스트인 동행
router.get("/meeting/host", authRequired, async (req: AuthRequest, res) => {
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
        count(mm_all.id) filter (where mm_all.status = 'joined') as current_members
      from meetings m
      join meeting_members mm_host
        on mm_host.meeting_id = m.id
        and mm_host.user_id = $1
        and mm_host.role = 'host'
        and mm_host.status = 'joined'
      left join meeting_members mm_all
        on mm_all.meeting_id = m.id
      where m.status <> 'cancelled'
      group by
        m.id,
        m.title,
        m.place_text,
        m.scheduled_at,
        m.max_members,
        m.gender,
        m.age_groups,
        m.category,
        m.region_primary
      order by m.scheduled_at asc, m.id desc;
      `,
      [userId]
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
    return fail(res, 500, "falied to load meetings");
  } finally {
    client.release();
  }
})

// 내가 현재 참여중인 동행
router.get("/meeting/ing", authRequired, async (req: AuthRequest, res) => {
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
        count(mm_all.id) filter (where mm_all.status = 'joined') as current_members
      from meetings m
      join meeting_members mm_me
        on mm_me.meeting_id = m.id
        and mm_me.user_id = $1
        and mm_me.status = 'joined'
      left join meeting_members mm_all
        on mm_all.meeting_id = m.id
      where m.status = 'open'
        and m.scheduled_at >= now()
      group by
        m.id,
        m.title,
        m.place_text,
        m.scheduled_at,
        m.max_members,
        m.gender,
        m.age_groups,
        m.category,
        m.region_primary
      order by m.scheduled_at asc, m.id desc;
      `,
      [userId]
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
    return fail(res, 500, "falied to load meetings");
  } finally {
    client.release();
  }
})

router.patch("/profile", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;

  const profileInput = validateProfileInput(req.body);

  if (!profileInput) {
    return fail(res, 400, "invalid profile input");
  }

  const { nickname, bio, category } = profileInput;

  const client = await pool.connect();

  try {
    await client.query(
      `
      update user_profiles
      set nickname = $1,
          bio = $2,
          favorite_tags = $3,
          updated_now = now()
      where user_id = $4
      `,
      [nickname, bio, category, userId]
    );

    return ok(res, {
      item: {
        nickname,
        bio,
        category
      }
    }, 201);
  } catch {
    return fail(res, 400, "falied to set profile");
  } finally {
    client.release();
  }
})

export default router;