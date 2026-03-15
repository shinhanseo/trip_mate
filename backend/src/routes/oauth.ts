import { Router } from "express";
import { pool } from "../db";
import crypto from "crypto";
import axios from "axios";
import jwt from "jsonwebtoken";
import { ok, fail } from "../utils/response";

const router = Router();

const NAVER_CLIENT_ID = process.env.NAVER_CLIENT_ID!;
const NAVER_CLIENT_SECRET = process.env.NAVER_CLIENT_SECRET!;
const NAVER_REDIRECT_URI = process.env.NAVER_REDIRECT_URI!;
const APP_DEEP_LINK = process.env.APP_DEEP_LINK || "mohaeng://login-callback";

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;
const JWT_ACCESS_EXPIRES_IN = process.env.JWT_ACCESS_EXPIRES_IN || "1h";
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || "30d";

function buildDeepLink(params: Record<string, string>) {
  const query = new URLSearchParams(params).toString();
  return `${APP_DEEP_LINK}?${query}`;
}

function hashToken(token: string) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createAccessToken(userId: number) {
  return jwt.sign(
    { userId, type: "access" },
    JWT_ACCESS_SECRET,
    {
      expiresIn: JWT_ACCESS_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    }
  );
}

function createRefreshToken(userId: number) {
  return jwt.sign(
    { userId, type: "refresh" },
    JWT_REFRESH_SECRET,
    {
      expiresIn: JWT_REFRESH_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    }
  );
}

function getRefreshTokenExpiresAt() {
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

      const userResult = await client.query(
        `select id from users where naver_user_id = $1`,
        [naverUserId]
      );

      let userId: number;

      if (userResult.rows.length === 0) {
        const insertUserResult = await client.query(
          `insert into users (naver_user_id)
           values ($1)
           returning id`,
          [naverUserId]
        );

        userId = insertUserResult.rows[0].id;

        await client.query(
          `insert into user_profiles (user_id, gender, age_range)
           values ($1, $2, $3)`,
          [userId, gender || null, ageRange || null]
        );
      } else {
        userId = userResult.rows[0].id;

        await client.query(
          `update user_profiles
           set gender = $1,
               age_range = $2,
               updated_at = now()
           where user_id = $3`,
          [gender || null, ageRange || null, userId]
        );
      }

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

      const exchangeCode = crypto.randomBytes(32).toString("hex");
      const exchangeCodeHash = hashToken(exchangeCode);
      const exchangeExpiresAt = new Date(Date.now() + 1000 * 60 * 5);

      await client.query(
        `insert into login_exchanges
         (user_id, exchange_code_hash, expires_at)
         values ($1, $2, $3)`,
        [userId, exchangeCodeHash, exchangeExpiresAt]
      );

      await client.query("COMMIT");

      return res.redirect(
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
 */
router.post("/session/exchange", async (req, res) => {
  const exchangeCode = String(req.body.exchange_code || "").trim();

  if (!exchangeCode) {
    return fail(res, 400, "exchange_code is required");
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
      return fail(res, 401, "invalid exchange code");
    }

    const exchangeRow = exchangeResult.rows[0];

    if (exchangeRow.used_at) {
      await client.query("ROLLBACK");
      return fail(res, 401, "exchange code already used");
    }

    if (new Date(exchangeRow.expires_at).getTime() < Date.now()) {
      await client.query("ROLLBACK");
      return fail(res, 401, "exchange code expired");
    }

    const userId = Number(exchangeRow.user_id);

    const accessToken = createAccessToken(userId);
    const refreshToken = createRefreshToken(userId);

    const refreshTokenHash = hashToken(refreshToken);
    const refreshExpiresAt = getRefreshTokenExpiresAt();

    await client.query(
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

    await client.query(
      `update login_exchanges
       set used_at = now()
       where exchange_code_hash = $1`,
      [exchangeCodeHash]
    );

    const profileResult = await client.query(
      `select gender, age_range, nickname
       from user_profiles
       where user_id = $1
       limit 1`,
      [userId]
    );

    await client.query("COMMIT");

    const profile = profileResult.rows[0] || {};
    const nickname = profile.nickname ?? null;
    const profileCompleted = !!nickname;

    return ok(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: userId,
        nickname,
        gender: profile.gender ?? null,
        age_range: profile.age_range ?? null,
        profile_completed: profileCompleted,
      },
    });
  } catch (error: any) {
    await client.query("ROLLBACK");
    return fail(res, 500, "session exchange failed", error.message);
  } finally {
    client.release();
  }
});

/**
 * 4) refresh token으로 access token 재발급
 * POST /auth/refresh
 */
router.post("/refresh", async (req, res) => {
  const refreshToken = String(req.body.refresh_token || "").trim();

  if (!refreshToken) {
    return fail(res, 400, "refresh_token is required");
  }

  let payload: any;

  try {
    payload = jwt.verify(refreshToken, JWT_REFRESH_SECRET);

    if (payload.type !== "refresh") {
      return fail(res, 401, "invalid token type");
    }
  } catch (error: any) {
    if (error.name === "TokenExpiredError") {
      return fail(res, 401, "refresh token expired");
    }
    return fail(res, 401, "invalid refresh token");
  }

  const refreshTokenHash = hashToken(refreshToken);
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const tokenResult = await client.query(
      `select id, user_id, expires_at, revoked_at
       from refresh_tokens
       where token_hash = $1
       limit 1`,
      [refreshTokenHash]
    );

    if (tokenResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token not found");
    }

    const tokenRow = tokenResult.rows[0];

    if (tokenRow.revoked_at) {
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token revoked");
    }

    if (new Date(tokenRow.expires_at).getTime() < Date.now()) {
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token expired");
    }

    const userId = Number(tokenRow.user_id);

    const newAccessToken = createAccessToken(userId);
    const newRefreshToken = createRefreshToken(userId);
    const newRefreshTokenHash = hashToken(newRefreshToken);
    const newRefreshExpiresAt = getRefreshTokenExpiresAt();

    await client.query(
      `update refresh_tokens
       set revoked_at = now()
       where id = $1`,
      [tokenRow.id]
    );

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

    return ok(res, {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
    });
  } catch (error: any) {
    await client.query("ROLLBACK");
    return fail(res, 500, "token refresh failed", error.message);
  } finally {
    client.release();
  }
});

/**
 * 5) 로그아웃
 * POST /auth/logout
 */
router.post("/logout", async (req, res) => {
  const refreshToken = String(req.body.refresh_token || "").trim();

  if (!refreshToken) {
    return fail(res, 400, "refresh_token is required");
  }

  try {
    jwt.verify(refreshToken, JWT_REFRESH_SECRET);
  } catch {
    return fail(res, 400, "invalid refresh token");
  }

  const refreshTokenHash = hashToken(refreshToken);

  await pool.query(
    `update refresh_tokens
     set revoked_at = now()
     where token_hash = $1
       and revoked_at is null`,
    [refreshTokenHash]
  );

  return ok(res, {
    message: "logged out",
  });
});

export default router;