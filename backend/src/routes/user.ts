import { Router } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { pool } from "../db";
import { ok, fail } from "../utils/response";
import { isValidNickname, validateProfileInput } from "../modules/users/user-invalid";
import { isValidAgeGroup, isValidCategory, isValidGender, isValidRegion } from "../modules/meetings/meetings-invalid";
import { prisma } from "../lib/prisma";
import { randomUUID } from "crypto";

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

  try {
    const profile = await prisma.userProfile.update({
      where: {
        userId: BigInt(userId),
      },
      data: {
        nickname,
        updatedAt: new Date(),
      },
      select: {
        userId: true,
        nickname: true,
      },
    });

    return ok(res, {
      item: {
        id: Number(profile.userId),
        nickname: profile.nickname,
        profile_completed: true,
      },
    });
  } catch (error: any) {
    if (error.code === "P2002") {
      return fail(res, 409, "duplicate nickname");
    }

    if (error.code === "P2025") {
      return fail(res, 404, "profile not found");
    }

    return fail(res, 500, "failed to set nickname", error.message);
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

  try {
    const profile = await prisma.userProfile.update({
      where: {
        userId: BigInt(userId),
      },
      data: {
        nickname,
        bio,
        favoriteTags: category,
        profileImageUrl,
        updatedAt: new Date(),
      },
    });

    return ok(
      res,
      {
        item: {
          nickname: profile.nickname,
          bio: profile.bio,
          category: profile.favoriteTags,
          profileImageUrl: profile.profileImageUrl,
        },
      },
      201,
    );
  } catch (error: any) {
    return fail(res, 400, "falied to set profile", error?.message);
  }
});


router.get("/me", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;

  try {
    const user = await prisma.user.findUnique({
      where: {
        id: BigInt(userId),
      },
      include: {
        profile: true,
      },
    });

    if (!user) {
      return fail(res, 400, "user not found");
    }

    const profileCompleted = !!user.profile?.nickname;

    return ok(res, {
      id: Number(user.id),
      nickname: user.profile?.nickname ?? null,
      gender: user.profile?.gender ?? null,
      age_range: user.profile?.ageRange ?? null,
      profile_completed: profileCompleted,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my profile", error?.message);
  }
});


router.get("/mypage", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;
  const prismaUserId = BigInt(userId);

  try {
    const user = await prisma.user.findUnique({
      where: { id: prismaUserId },
      include: {
        profile: true,
      },
    });

    if (!user) {
      return fail(res, 400, "user not found");
    }

    const [hostCount, totalCount, ingCount] = await Promise.all([
      prisma.meeting.count({
        where: {
          hostUserId: prismaUserId,
          status: {
            not: "cancelled",
          },
        },
      }),

      prisma.meetingMember.count({
        where: {
          userId: prismaUserId,
          status: "joined",
          meeting: {
            status: {
              not: "cancelled",
            },
          },
        },
      }),

      prisma.meetingMember.count({
        where: {
          userId: prismaUserId,
          status: "joined",
          meeting: {
            status: "open",
            scheduledAt: {
              gte: new Date(),
            },
          },
        },
      }),
    ]);

    const ageRange = ageRangeMapper(user.profile?.ageRange ?? "");
    const gender = genderMapper(user.profile?.gender ?? "");

    return ok(res, {
      id: Number(user.id),
      nickname: user.profile?.nickname ?? null,
      gender,
      ageRange,
      bio: user.profile?.bio ?? null,
      favoriteTags: user.profile?.favoriteTags ?? [],
      profileImage: user.profile?.profileImageUrl ?? "",
      meetingCounts: {
        host: hostCount,
        total: totalCount,
        ing: ingCount,
      },
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my profile", error?.message);
  }
});

router.get("/:id/profile", authRequired, async (req: AuthRequest, res) => {
  const userId = Number(req.params.id);
  const prismaUserId = BigInt(userId);

  try {
    const user = await prisma.user.findUnique({
      where: { id: prismaUserId },
      include: {
        profile: true,
      },
    });

    if (!user) {
      return fail(res, 400, "user not found");
    }

    const [hostCount, totalCount, ingCount] = await Promise.all([
      prisma.meeting.count({
        where: {
          hostUserId: prismaUserId,
          status: {
            not: "cancelled",
          },
        },
      }),

      prisma.meetingMember.count({
        where: {
          userId: prismaUserId,
          status: "joined",
          meeting: {
            status: {
              not: "cancelled",
            },
          },
        },
      }),

      prisma.meetingMember.count({
        where: {
          userId: prismaUserId,
          status: "joined",
          meeting: {
            status: "open",
            scheduledAt: {
              gte: new Date(),
            },
          },
        },
      }),
    ]);

    const ageRange = ageRangeMapper(user.profile?.ageRange ?? "");
    const gender = genderMapper(user.profile?.gender ?? "");

    return ok(res, {
      id: Number(user.id),
      nickname: user.profile?.nickname ?? null,
      gender,
      ageRange,
      bio: user.profile?.bio ?? null,
      favoriteTags: user.profile?.favoriteTags ?? [],
      profileImage: user.profile?.profileImageUrl ?? "",
      meetingCounts: {
        host: hostCount,
        total: totalCount,
        ing: ingCount,
      },
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my profile", error?.message);
  }
});

router.get("/map", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;

  const client = await pool.connect();
  try {
    const meetingRes = await client.query(
      `
      select
        m.id,
        m.title,
        m.place_text,
        m.place_lat,
        m.place_lng
      from meetings m
      join meeting_members mm
        on mm.meeting_id = m.id
        and mm.user_id = $1
        and mm.status = 'joined'
      where m.status <> 'cancelled'
      group by
        m.id,
        m.title,
        m.place_text,
        m.place_lat,
        m.place_lng
      `,
      [userId]
    );

    return ok(res, {
      items: meetingRes.rows.map((row) => ({
        id: Number(row.id),
        title: row.title,
        placeText: row.place_text,
        placeLat: row.place_lat,
        placeLng: row.place_lng,
      })),
    });
  } catch (error: any) {
    return fail(res, 500, "failed to get my map", error?.message);
  } finally {
    client.release();
  }
});

router.delete("/me", authRequired, async (req: AuthRequest, res) => {
  const userId = req.user!.userId;
  const prismaUserId = BigInt(userId);
  const deletedAt = new Date();

  try {
    const userRes = await prisma.user.findUnique({
      where: { id: prismaUserId },
      select: {
        id: true,
        status: true,
      },
    });

    if (userRes == null) {
      return fail(res, 404, "user not found");
    }

    if (userRes.status !== "active") {
      return fail(res, 409, "user is not active");
    }

    await prisma.$transaction([
      prisma.refreshToken.updateMany({
        where: {
          userId: prismaUserId,
          revokedAt: null,
        },
        data: {
          revokedAt: deletedAt,
          updatedAt: deletedAt,
        },
      }),

      prisma.socialAccount.deleteMany({
        where: {
          userId: prismaUserId,
        },
      }),

      prisma.userProfile.update({
        where: {
          userId: prismaUserId,
        },
        data: {
          nickname: null,
          gender: null,
          ageRange: null,
          favoriteTags: [],
          bio: null,
          profileImageUrl: process.env.INACTIVE_PROFILE_URL ?? null,
          updatedAt: deletedAt,
        },
      }),

      prisma.user.update({
        where: {
          id: prismaUserId,
        },
        data: {
          status: "deleted",
          naverUserId: `deleted:${userId}:${randomUUID()}`,
          updatedAt: deletedAt,
          deletedAt,
        },
      }),
    ]);

    return ok(res, { deleted: true });
  } catch (error: any) {
    return fail(res, 500, "failed to delete my account", error?.message);
  }
});

export default router;
