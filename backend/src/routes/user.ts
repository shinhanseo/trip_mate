import { Router } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired.js";
import { pool } from "../db.js";
import { ok, fail } from "../utils/response.js";

const router = Router();

function isValidNickname(nickname: string) {
  const trimmedNickname = nickname.trim();

  if (trimmedNickname.length < 2) {
    return false;
  }

  if (trimmedNickname.length > 12) {
    return false;
  }

  const nicknameRegex = /^[가-힣a-zA-Z0-9_]+$/;

  if (!nicknameRegex.test(trimmedNickname)) {
    return false;
  }

  return true;
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
    await client.query("begin");

    const nicknameCheckRes = await client.query(
      `
      select user_id
      from user_profiles
      where nickname = $1
        and user_id <> $2
      limit 1
      `,
      [nickname, userId]
    );

    if (nicknameCheckRes.rowCount !== 0) {
      await client.query("rollback");
      return fail(res, 409, "duplicate nickname");
    }

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
      await client.query("rollback");
      return fail(res, 404, "profile not found");
    }

    await client.query("commit");

    return ok(res, {
      user: {
        id: nicknameRes.rows[0].user_id,
        nickname: nicknameRes.rows[0].nickname,
        profile_completed: true,
      },
    });
  } catch (error: any) {
    await client.query("rollback");
    return fail(res, 500, "failed to set nickname", error.message);
  } finally {
    client.release();
  }
});

export default router;