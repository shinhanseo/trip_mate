import { Router } from "express";
import { pool } from "../db.js";
import crypto from "crypto";
import axios from "axios";
import jwt from "jsonwebtoken";

const router = Router();

const NAVER_CLIENT_ID = process.env.NAVER_CLIENT_ID!;
const NAVER_CLIENT_SECRET = process.env.NAVER_CLIENT_SECRET!;
const NAVER_REDIRECT_URI = process.env.NAVER_REDIRECT_URI!;
const APP_DEEP_LINK = process.env.APP_DEEP_LINK || "mohaeng://login-callback";

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;
const JWT_ACCESS_EXPIRES_IN = process.env.JWT_ACCESS_EXPIRES_IN || "1h";
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || "30d";

function buildDeepLink(params: Record<string, string>) { // 앱 딥링크 생성
  const query = new URLSearchParams(params).toString();
  return `${APP_DEEP_LINK}?${query}`;
}

function hashToken(token: string) { // 토큰 해시 생성
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createAccessToken(userId: number) { // 액세스 토큰 생성
  return jwt.sign(
    { userId, type: "access" },
    JWT_ACCESS_SECRET,
    {
      expiresIn: JWT_ACCESS_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    }
  );
}

function createRefreshToken(userId: number) { // 리프레시 토큰 생성
  return jwt.sign(
    { userId, type: "refresh" },
    JWT_REFRESH_SECRET,
    {
      expiresIn: JWT_REFRESH_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    }
  );
}

function getRefreshTokenExpiresAt() { // 리프레시 토큰 만료 시간 계산
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  return expiresAt;
}

/**
 * 1) 네이버 로그인 시작
 * GET /auth/naver
 */
router.get("/naver", (req, res) => {
  const state = crypto.randomBytes(32).toString("hex");
  req.session.naverState = state;

  return res.redirect(
    `https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=${NAVER_CLIENT_ID}&redirect_uri=${encodeURIComponent(
      NAVER_REDIRECT_URI
    )}&state=${state}`
  );
});

/**
 * 2) 네이버 콜백
 * GET /auth/naver/callback
 *
 * 성공 시 앱으로 access/refresh 토큰을 직접 보내지 않고
 * 일회용 exchangeCode만 딥링크로 전달
 * 이후에 exchangeCode를 사용하여 액세스/리프레시 토큰을 발급받음
 */
router.get("/naver/callback", async (req, res) => {
  const code = String(req.query.code || "");
  const state = String(req.query.state || "");
  const oauthError = String(req.query.error || "");
  const oauthErrorDescription = String(req.query.error_description || "");

  if (oauthError) {
    return res.redirect(
      buildDeepLink({
        success: "false",
        message: oauthErrorDescription || oauthError,
      })
    );
  }

  if (!code || !state) {
    return res.redirect(
      buildDeepLink({
        success: "false",
        message: "code / state missing",
      })
    );
  }

  if (state !== req.session.naverState) {
    return res.redirect(
      buildDeepLink({
        success: "false",
        message: "invalid state",
      })
    );
  }

  delete req.session.naverState;

  try {
    // 네이버 토큰 발급
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
        timeout: 5000,
      }
    );

    const naverAccessToken = tokenRes.data?.access_token;
    const naverRefreshToken = tokenRes.data?.refresh_token ?? null;
    const naverExpiresIn = Number(tokenRes.data?.expires_in || 0);

    if (!naverAccessToken) {
      return res.redirect(
        buildDeepLink({
          success: "false",
          message: "naver access token missing",
        })
      );
    }

    // 네이버 프로필 조회
    const profileRes = await axios.get("https://openapi.naver.com/v1/nid/me", {
      headers: {
        Authorization: `Bearer ${naverAccessToken}`,
      },
      timeout: 5000,
    });

    const profile = profileRes.data?.response;

    if (!profile) {
      return res.redirect(
        buildDeepLink({
          success: "false",
          message: "profile missing",
        })
      );
    }

    const naverUserId = String(profile.id || "");
    const gender = profile.gender ?? "";
    const ageRange = profile.age ?? "";

    if (!naverUserId) {
      return res.redirect(
        buildDeepLink({
          success: "false",
          message: "naver user id missing",
        })
      );
    }

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // 기존 유저 조회
      const userResult = await client.query(
        `select id from users where naver_user_id = $1`,
        [naverUserId]
      );

      let userId: number;

      if (userResult.rows.length === 0) {
        // users 생성
        const insertUserResult = await client.query(
          `insert into users (naver_user_id)
           values ($1)
           returning id`,
          [naverUserId]
        );

        userId = insertUserResult.rows[0].id;

        // user_profiles 생성
        await client.query(
          `insert into user_profiles (user_id, gender, age_range)
           values ($1, $2, $3)`,
          [userId, gender || null, ageRange || null]
        );
      } else {
        userId = userResult.rows[0].id;

        // 기존 프로필 업데이트
        await client.query(
          `update user_profiles
           set gender = $1,
               age_range = $2,
               updated_at = now()
           where user_id = $3`,
          [gender || null, ageRange || null, userId]
        );
      }

      // 네이버 토큰 social_accounts 저장
      const socialExpiresAt =
        naverExpiresIn > 0
          ? new Date(Date.now() + naverExpiresIn * 1000)
          : null;

      await client.query(
        `insert into social_accounts
         (user_id, provider, provider_user_id, access_token, refresh_token, expires_at)
         values ($1, $2, $3, $4, $5, $6)
         on conflict (provider, provider_user_id)
         do update set
           user_id = excluded.user_id,
           access_token = excluded.access_token,
           refresh_token = excluded.refresh_token,
           expires_at = excluded.expires_at,
           updated_at = now()`,
        [
          userId,
          "naver",
          naverUserId,
          naverAccessToken,
          naverRefreshToken,
          socialExpiresAt,
        ]
      );

      // 일회용 exchange code 생성
      const exchangeCode = crypto.randomBytes(32).toString("hex");
      const exchangeCodeHash = hashToken(exchangeCode);
      const exchangeExpiresAt = new Date(Date.now() + 1000 * 60 * 5); // 5분

      await client.query(
        `insert into login_exchanges
         (user_id, exchange_code_hash, expires_at)
         values ($1, $2, $3)`,
        [userId, exchangeCodeHash, exchangeExpiresAt]
      );

      await client.query("COMMIT");

      return res.redirect( // 회원가입 성공 시 앱으로 exchageCode, gender, ageRange 전달
        buildDeepLink({
          success: "true",
          exchangeCode,
          gender,
          ageRange,
        })
      );
    } catch (dbError: any) {
      await client.query("ROLLBACK");

      return res.redirect(
        buildDeepLink({
          success: "false",
          message: dbError.message || "db save failed",
        })
      );
    } finally {
      client.release();
    }
  } catch (error: any) {
    const message =
      error.response?.data?.error_description ||
      error.response?.data?.error ||
      error.message ||
      "naver oauth failed";

    return res.redirect(
      buildDeepLink({
        success: "false",
        message: String(message),
      })
    );
  }
});

/**
 * 3) 일회용 exchange code로 우리 서비스 토큰 발급
 * POST /auth/session/exchange
 *
 * body:
 * {
 *   "exchange_code": "..."
 * }
 */
router.post("/session/exchange", async (req, res) => {
  const exchangeCode = String(req.body.exchange_code || "").trim();

  if (!exchangeCode) {
    return res.status(400).json({ message: "exchange_code is required" });
  }

  const exchangeCodeHash = hashToken(exchangeCode);
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const exchangeResult = await client.query(
      `select user_id, expires_at, used_at
       from login_exchanges
       where exchange_code_hash = $1
       limit 1`,
      [exchangeCodeHash]
    );

    if (exchangeResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "invalid exchange code" });
    }

    const exchangeRow = exchangeResult.rows[0];

    if (exchangeRow.used_at) {
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "exchange code already used" });
    }

    if (new Date(exchangeRow.expires_at).getTime() < Date.now()) {
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "exchange code expired" });
    }

    const userId = Number(exchangeRow.user_id);

    // exchageCode 기반으로 인증 성공 시 액세스/리프레시 토큰 발급
    const accessToken = createAccessToken(userId);
    const refreshToken = createRefreshToken(userId);

    const refreshTokenHash = hashToken(refreshToken);
    const refreshExpiresAt = getRefreshTokenExpiresAt();

    await client.query( // 리프레시 토큰 저장
      `insert into refresh_tokens
       (user_id, token_hash, device_name, device_id, expires_at)
       values ($1, $2, $3, $4, $5)`,
      [
        userId,
        refreshTokenHash,
        req.headers["user-agent"] || "flutter-app",
        req.headers["x-device-id"] || null,
        refreshExpiresAt,
      ]
    );

    await client.query( // 일회용 exchange code 사용 처리
      `update login_exchanges
       set used_at = now()
       where exchange_code_hash = $1`,
      [exchangeCodeHash]
    );

    const profileResult = await client.query( // 프로필 조회
      `select gender, age_range
       from user_profiles
       where user_id = $1
       limit 1`,
      [userId]
    );

    await client.query("COMMIT");

    const profile = profileResult.rows[0] || {};

    return res.json({
      success: true,
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        user: {
          id: userId,
          gender: profile.gender ?? null,
          age_range: profile.age_range ?? null,
        },
      },
    });
  } catch (error: any) {
    await client.query("ROLLBACK");
    return res.status(500).json({
      message: "session exchange failed",
      error: error.message,
    });
  } finally {
    client.release();
  }
});

/**
 * 4) refresh token으로 access token 재발급
 * POST /auth/refresh
 *
 * body:
 * {
 *   "refresh_token": "..."
 * }
 */
router.post("/refresh", async (req, res) => {
  const refreshToken = String(req.body.refresh_token || "").trim();

  if (!refreshToken) {
    return res.status(400).json({ message: "refresh_token is required" });
  }

  let payload: any;

  try {
    payload = jwt.verify(refreshToken, JWT_REFRESH_SECRET);

    if (payload.type !== "refresh") {
      return res.status(401).json({ message: "invalid token type" });
    }
  } catch (error: any) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ message: "refresh token expired" });
    }
    return res.status(401).json({ message: "invalid refresh token" });
  }

  const refreshTokenHash = hashToken(refreshToken);
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const tokenResult = await client.query( // 리프레시 토큰 조회
      `select id, user_id, expires_at, revoked_at
       from refresh_tokens
       where token_hash = $1
       limit 1`,
      [refreshTokenHash]
    );

    if (tokenResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "refresh token not found" });
    }

    const tokenRow = tokenResult.rows[0];

    if (tokenRow.revoked_at) { // 리프레시 토큰 폐기 처리
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "refresh token revoked" });
    }

    if (new Date(tokenRow.expires_at).getTime() < Date.now()) {
      await client.query("ROLLBACK");
      return res.status(401).json({ message: "refresh token expired" });
    }

    const userId = Number(tokenRow.user_id);

    const newAccessToken = createAccessToken(userId);
    const newRefreshToken = createRefreshToken(userId);
    const newRefreshTokenHash = hashToken(newRefreshToken);
    const newRefreshExpiresAt = getRefreshTokenExpiresAt();

    // 기존 refresh token 폐기
    await client.query(
      `update refresh_tokens
       set revoked_at = now()
       where id = $1`,
      [tokenRow.id]
    );

    // 새 refresh token 저장
    await client.query(
      `insert into refresh_tokens
       (user_id, token_hash, device_name, device_id, expires_at)
       values ($1, $2, $3, $4, $5)`,
      [
        userId,
        newRefreshTokenHash,
        req.headers["user-agent"] || "flutter-app",
        req.headers["x-device-id"] || null,
        newRefreshExpiresAt,
      ]
    );

    await client.query("COMMIT");

    return res.json({
      success: true,
      data: {
        access_token: newAccessToken,
        refresh_token: newRefreshToken,
      },
    });
  } catch (error: any) {
    await client.query("ROLLBACK");
    return res.status(500).json({
      message: "token refresh failed",
      error: error.message,
    });
  } finally {
    client.release();
  }
});

export default router;