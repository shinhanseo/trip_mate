import { Router } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { pool } from "../db";
import { ok, fail } from "../utils/response";
import { isValidNickname, validateProfileInput } from "../modules/users/user-invalid";
import { isValidAgeGroup, isValidCategory, isValidGender, isValidRegion } from "../modules/meetings/meetings-invalid";

const router = Router();

function ageRangeMapper(value: String) {
  switch (value) {
    case '20-29':
      return '20대';
    case '30-39':
      return '30대';
    case '40-49':
      return '40대';
    case '50-59':
      return '50대';
    default:
      return value;
  }
}

function genderMapper(value: String) {
  if (value == 'M' || value == 'm' || value == 'man')
    return '남성'

  if (value == 'F' || value == 'f' || value == 'female')
    return '여성'

  return value;
}

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
        count(mm_all.id) filter (where mm_all.status = 'joined') as current_members
      from meetings m
      join meeting_members mm_me
        on mm_me.meeting_id = m.id
        and mm_me.user_id = $1
        and mm_me.status = 'joined'
      left join meeting_members mm_all
        on mm_all.meeting_id = m.id
      where m.status <> 'cancelled'
        and ($2::text is null or m.category = $2)
        and ($3::text is null or m.gender = $3 or m.gender = 'any')
        and (
          $4::text is null
          or m.age_groups = array['any']::text[]
          or $4 = any(m.age_groups)
        )
        and (
          $5::text is null
          or m.title ilike $5
          or m.place_text ilike $5
          or m.description ilike $5
        )
        and (
          $6::text is null or m.region_primary = $6
        )
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
      [userId, categoryFilter, genderFilter, ageGroupFilter, keywordFilter, regionPrimaryFilter]
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
        and ($2::text is null or m.category = $2)
        and ($3::text is null or m.gender = $3 or m.gender = 'any')
        and (
          $4::text is null
          or m.age_groups = array['any']::text[]
          or $4 = any(m.age_groups)
        )
        and (
          $5::text is null
          or m.title ilike $5
          or m.place_text ilike $5
          or m.description ilike $5
        )
        and (
          $6::text is null or m.region_primary = $6
        )
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
      [userId, categoryFilter, genderFilter, ageGroupFilter, keywordFilter, regionPrimaryFilter]
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
        and ($2::text is null or m.category = $2)
        and ($3::text is null or m.gender = $3 or m.gender = 'any')
        and (
          $4::text is null
          or m.age_groups = array['any']::text[]
          or $4 = any(m.age_groups)
        )
        and (
          $5::text is null
          or m.title ilike $5
          or m.place_text ilike $5
          or m.description ilike $5
        )
        and (
          $6::text is null or m.region_primary = $6
        )
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
      [userId, categoryFilter, genderFilter, ageGroupFilter, keywordFilter, regionPrimaryFilter]
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

  const { nickname, bio, category, profileImageUrl } = profileInput;

  const client = await pool.connect();

  try {
    await client.query(
      `
      update user_profiles
      set nickname = $1,
          bio = $2,
          favorite_tags = $3,
          profile_image_url = $4, 
          updated_now = now()
      where user_id = $5
      `,
      [nickname, bio, category, profileImageUrl, userId]
    );

    return ok(res, {
      item: {
        nickname,
        bio,
        category,
        profileImageUrl,
      }
    }, 201);
  } catch {
    return fail(res, 400, "falied to set profile");
  } finally {
    client.release();
  }
})

router.get("/me", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;

  const client = await pool.connect();
  try {
    const userRes = await client.query(
      `
      select
        u.id,
        up.nickname,
        up.gender,
        up.age_range
      from users u
      left join user_profiles up
        on up.user_id = u.id
      where u.id = $1
      limit 1
      `,
      [userId]
    );

    if (userRes.rowCount === 0) {
      return fail(res, 400, "user not fount");
    }

    const user = userRes.rows[0];
    const profileCompleted = !!user.nickname;

    return ok(res, {
      id: user.id,
      nickname: user.nickname ?? null,
      gender: user.gender ?? null,
      age_range: user.age_range ?? null,
      profile_completed: profileCompleted,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my profile", error?.message);
  } finally {
    client.release();
  }
})

router.get("/mypage", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;

  const client = await pool.connect();
  try {
    const userRes = await client.query(
      `
      select
        u.id,
        up.nickname,
        up.gender,
        up.age_range,
        up.profile_image_url,
        up.favorite_tags,
        up.bio
      from users u
      left join user_profiles up
        on up.user_id = u.id
      where u.id = $1
      limit 1
      `,
      [userId]
    );

    if (userRes.rowCount === 0) {
      return fail(res, 400, "user not found");
    }

    const countRes = await client.query(
      `
      select
        (
          select count(*)
          from meetings m
          where m.host_user_id = $1
            and m.status <> 'cancelled'
        ) as host_count,
        (
          select count(*)
          from meeting_members mm
          join meetings m
            on m.id = mm.meeting_id
          where mm.user_id = $1
            and mm.status = 'joined'
            and m.status <> 'cancelled'
        ) as total_count,
        (
          select count(*)
          from meeting_members mm
          join meetings m
            on m.id = mm.meeting_id
          where mm.user_id = $1
            and mm.status = 'joined'
            and m.status = 'open'
            and m.scheduled_at >= now()
        ) as ing_count
      `,
      [userId]
    );

    const user = userRes.rows[0];
    const counts = countRes.rows[0];
    const ageRange = ageRangeMapper(user.age_range);
    const gender = genderMapper(user.gender);

    return ok(res, {
      id: user.id,
      nickname: user.nickname,
      gender: gender,
      ageRange: ageRange,
      bio: user.bio ?? null,
      favoriteTags: user.favorite_tags ?? [],
      profileImage: user.profile_image_url ?? '',
      meetingCounts: {
        host: Number(counts.host_count),
        total: Number(counts.total_count),
        ing: Number(counts.ing_count),
      },
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my profile", error?.message);
  } finally {
    client.release();
  }
});


export default router;
