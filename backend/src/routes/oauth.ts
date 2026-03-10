import { Router } from "express";
import { pool } from "../db.js";
import crypto from "crypto";
import axios from "axios";

const router = Router();
const NAVER_CLIENT_ID = process.env.NAVER_CLIENT_ID;
const NAVER_CLIENT_SECRET = process.env.NAVER_CLIENT_SECRET;
const NAVER_REDIRECT_URI = process.env.NAVER_REDIRECT_URI;

router.get("/", (req, res) => {
  const state = crypto.randomBytes(32).toString("hex");
  req.session.naverState = state;

  res.redirect(
    `https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=${NAVER_CLIENT_ID}&redirect_uri=${encodeURIComponent(NAVER_REDIRECT_URI || "")}&state=${state}`
  );
});

router.get("/callback", async (req, res) => {
  const code = String(req.query.code || "");
  const state = String(req.query.state || "");

  if (!code || !state) {
    return res.status(400).json({ message: "code / state missing" });
  }

  if (state !== req.session.naverState) {
    return res.status(400).json({ message: "invalid state" });
  }

  delete req.session.naverState;

  try {
    const tokenRes = await axios.post(
      "https://nid.naver.com/oauth2.0/token",
      null,
      {
        params: {
          grant_type: "authorization_code",
          client_id: NAVER_CLIENT_ID,
          client_secret: NAVER_CLIENT_SECRET,
          code,
          state,
        },
      }
    );

    const accessToken = tokenRes.data.access_token;
    const refreshToken = tokenRes.data.refresh_token;
    const expiresIn = Number(tokenRes.data.expires_in || 0);

    if (!accessToken) {
      return res.status(500).json({
        message: "access token missing",
        tokenRes: tokenRes.data,
      });
    }

    const profileRes = await axios.get("https://openapi.naver.com/v1/nid/me", {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const profile = profileRes.data?.response;

    if (!profile) {
      return res.status(500).json({
        message: "profile missing",
        profileRes: profileRes.data,
      });
    }

    const naverUserId = String(profile.id || "");
    const gender = profile.gender ?? null;
    const ageRange = profile.age ?? null;

    if (!naverUserId) {
      return res.status(500).json({
        message: "naver user id missing",
        profileRes: profileRes.data,
      });
    }

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // 1. 기존 유저 조회
      const userResult = await client.query(
        `select id from users where naver_user_id = $1`,
        [naverUserId]
      );

      let userId: number;

      if (userResult.rows.length === 0) {
        // 2. users 생성
        const insertUserResult = await client.query(
          `insert into users (naver_user_id)
           values ($1)
           returning id`,
          [naverUserId]
        );

        userId = insertUserResult.rows[0].id;

        // 3. user_profiles 생성
        await client.query(
          `insert into user_profiles (user_id, gender, age_range)
           values ($1, $2, $3)`,
          [userId, gender, ageRange]
        );
      } else {
        userId = userResult.rows[0].id;

        // 4. 기존 프로필 업데이트
        await client.query(
          `update user_profiles
           set gender = $1,
               age_range = $2,
               updated_at = now()
           where user_id = $3`,
          [gender, ageRange, userId]
        );
      }

      // 5. refresh token 저장
      const tokenHash = crypto
        .createHash("sha256")
        .update(String(refreshToken || ""))
        .digest("hex");

      const expiresAt = new Date(Date.now() + expiresIn * 1000);

      await client.query(
        `insert into refresh_tokens
         (user_id, token_hash, device_name, device_id, expires_at)
         values ($1, $2, $3, $4, $5)`,
        [
          userId,
          tokenHash,
          req.headers["user-agent"] || null,
          req.headers["x-device-id"] || null,
          expiresAt,
        ]
      );

      await client.query("COMMIT");

      return res.json({
        success: true,
        user: {
          id: userId,
          naverUserId,
          gender,
          ageRange,
        },
      });
    } catch (dbError: any) {
      await client.query("ROLLBACK");
      return res.status(500).json({
        message: "db save failed",
        error: dbError.message,
      });
    } finally {
      client.release();
    }
  } catch (error: any) {
    return res.status(500).json({
      message: "naver token request failed",
      error: error.response?.data || error.message,
    });
  }
});

export default router;