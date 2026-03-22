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
  console.log("[NAVER START] 1. /naver 진입");

  const state = crypto.randomBytes(32).toString("hex");
  req.session.naverState = state;

  const authUrl = `https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=${NAVER_CLIENT_ID}&redirect_uri=${encodeURIComponent(
    NAVER_REDIRECT_URI
  )}&state=${state}`;

  console.log("[NAVER START] 2. state 생성:", state);
  console.log("[NAVER START] 3. redirect_uri:", NAVER_REDIRECT_URI);
  console.log("[NAVER START] 4. authUrl:", authUrl);

  return res.redirect(authUrl);
});

/**
 * 2) 네이버 콜백
 * GET /auth/naver/callback
 */
router.get("/naver/callback", async (req, res) => {
  console.log("[NAVER CALLBACK] 1. callback 진입");

  const code = String(req.query.code || "");
  const state = String(req.query.state || "");
  const oauthError = String(req.query.error || "");
  const oauthErrorDescription = String(req.query.error_description || "");

  console.log("[NAVER CALLBACK] 2. query:", req.query);
  console.log("[NAVER CALLBACK] 3. session.naverState:", req.session.naverState);
  console.log("[NAVER CALLBACK] 4. code 존재 여부:", !!code);
  console.log("[NAVER CALLBACK] 5. state:", state);
  console.log("[NAVER CALLBACK] 6. oauthError:", oauthError);
  console.log("[NAVER CALLBACK] 7. oauthErrorDescription:", oauthErrorDescription);

  if (oauthError) {
    console.log("[NAVER CALLBACK] 8. oauthError 분기 진입");
    return res.redirect(
      buildDeepLink({
        success: "false",
        message: oauthErrorDescription || oauthError,
      })
    );
  }

  if (!code || !state) {
    console.log("[NAVER CALLBACK] 9. code/state missing 분기 진입");
    return res.redirect(
      buildDeepLink({
        success: "false",
        message: "code / state missing",
      })
    );
  }

  if (state !== req.session.naverState) {
    console.log("[NAVER CALLBACK] 10. invalid state");
    console.log("[NAVER CALLBACK] 10-1. request state:", state);
    console.log("[NAVER CALLBACK] 10-2. session state:", req.session.naverState);

    return res.redirect(
      buildDeepLink({
        success: "false",
        message: "invalid state",
      })
    );
  }

  console.log("[NAVER CALLBACK] 11. state 검증 통과");

  delete req.session.naverState;
  console.log("[NAVER CALLBACK] 12. session.naverState 삭제 완료");

  try {
    console.log("[NAVER CALLBACK] 13. 네이버 토큰 요청 시작");

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

    console.log("[NAVER CALLBACK] 14. 네이버 토큰 요청 성공");
    console.log("[NAVER CALLBACK] 15. tokenRes.data:", tokenRes.data);

    const naverAccessToken = tokenRes.data?.access_token;
    const naverRefreshToken = tokenRes.data?.refresh_token ?? null;
    const naverExpiresIn = Number(tokenRes.data?.expires_in || 0);

    console.log("[NAVER CALLBACK] 16. naverAccessToken 존재:", !!naverAccessToken);
    console.log("[NAVER CALLBACK] 17. naverRefreshToken 존재:", !!naverRefreshToken);
    console.log("[NAVER CALLBACK] 18. naverExpiresIn:", naverExpiresIn);

    if (!naverAccessToken) {
      console.log("[NAVER CALLBACK] 19. access token missing");
      return res.redirect(
        buildDeepLink({
          success: "false",
          message: "naver access token missing",
        })
      );
    }

    console.log("[NAVER CALLBACK] 20. 네이버 프로필 요청 시작");

    const profileRes = await axios.get("https://openapi.naver.com/v1/nid/me", {
      headers: {
        Authorization: `Bearer ${naverAccessToken}`,
      },
      timeout: 5000,
    });

    console.log("[NAVER CALLBACK] 21. 네이버 프로필 요청 성공");
    console.log("[NAVER CALLBACK] 22. profileRes.data:", profileRes.data);

    const profile = profileRes.data?.response;

    console.log("[NAVER CALLBACK] 23. profile:", profile);

    if (!profile) {
      console.log("[NAVER CALLBACK] 24. profile missing");
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

    console.log("[NAVER CALLBACK] 25. naverUserId:", naverUserId);
    console.log("[NAVER CALLBACK] 26. gender:", gender);
    console.log("[NAVER CALLBACK] 27. ageRange:", ageRange);

    if (!naverUserId) {
      console.log("[NAVER CALLBACK] 28. naver user id missing");
      return res.redirect(
        buildDeepLink({
          success: "false",
          message: "naver user id missing",
        })
      );
    }

    console.log("[NAVER CALLBACK] 29. DB connect 시작");
    const client = await pool.connect();
    console.log("[NAVER CALLBACK] 30. DB connect 성공");

    try {
      console.log("[NAVER CALLBACK] 31. BEGIN 시작");
      await client.query("BEGIN");
      console.log("[NAVER CALLBACK] 32. BEGIN 성공");

      console.log("[NAVER CALLBACK] 33. 기존 user 조회 시작");
      const userResult = await client.query(
        `select id from users where naver_user_id = $1`,
        [naverUserId]
      );
      console.log("[NAVER CALLBACK] 34. 기존 user 조회 결과:", userResult.rows);

      let userId: number;

      if (userResult.rows.length === 0) {
        console.log("[NAVER CALLBACK] 35. 신규 회원 분기 진입");

        const insertUserResult = await client.query(
          `insert into users (naver_user_id)
           values ($1)
           returning id`,
          [naverUserId]
        );

        console.log("[NAVER CALLBACK] 36. users insert result:", insertUserResult.rows);

        userId = insertUserResult.rows[0].id;
        console.log("[NAVER CALLBACK] 37. 신규 userId:", userId);

        console.log("[NAVER CALLBACK] 38. user_profiles insert 시작");
        const defaultProfileImageUrl =
          gender === "F" || gender === "female"
            ? process.env.DEFAULT_WOMAN_PROFILE_URL
            : process.env.DEFAULT_MAN_PROFILE_URL;

        const insertProfileResult = await client.query(
          `insert into user_profiles (user_id, gender, age_range, profile_image_url)
           values ($1, $2, $3, $4)
           returning user_id, gender, age_range, profile_image_url`,
          [userId, gender || null, ageRange || null, defaultProfileImageUrl]
        );
        console.log("[NAVER CALLBACK] 39. user_profiles insert result:", insertProfileResult.rows);
      } else {
        console.log("[NAVER CALLBACK] 40. 기존 회원 분기 진입");

        userId = userResult.rows[0].id;
        console.log("[NAVER CALLBACK] 41. 기존 userId:", userId);

        console.log("[NAVER CALLBACK] 42. user_profiles update 시작");
        const updateProfileResult = await client.query(
          `update user_profiles
           set gender = $1,
               age_range = $2,
               updated_at = now()
           where user_id = $3
           returning user_id, gender, age_range, updated_at`,
          [gender || null, ageRange || null, userId]
        );
        console.log("[NAVER CALLBACK] 43. user_profiles update result:", updateProfileResult.rows);
      }

      const socialExpiresAt =
        naverExpiresIn > 0
          ? new Date(Date.now() + naverExpiresIn * 1000)
          : null;

      console.log("[NAVER CALLBACK] 44. socialExpiresAt:", socialExpiresAt);

      console.log("[NAVER CALLBACK] 45. social_accounts upsert 시작");
      const socialAccountResult = await client.query(
        `insert into social_accounts
         (user_id, provider, provider_user_id, access_token, refresh_token, expires_at)
         values ($1, $2, $3, $4, $5, $6)
         on conflict (provider, provider_user_id)
         do update set
           user_id = excluded.user_id,
           access_token = excluded.access_token,
           refresh_token = excluded.refresh_token,
           expires_at = excluded.expires_at,
           updated_at = now()
         returning user_id, provider, provider_user_id, expires_at`,
        [
          userId,
          "naver",
          naverUserId,
          naverAccessToken,
          naverRefreshToken,
          socialExpiresAt,
        ]
      );
      console.log("[NAVER CALLBACK] 46. social_accounts result:", socialAccountResult.rows);

      const exchangeCode = crypto.randomBytes(32).toString("hex");
      const exchangeCodeHash = hashToken(exchangeCode);
      const exchangeExpiresAt = new Date(Date.now() + 1000 * 60 * 5);

      console.log("[NAVER CALLBACK] 47. exchangeCode 생성");
      console.log("[NAVER CALLBACK] 48. exchangeCodeHash:", exchangeCodeHash);
      console.log("[NAVER CALLBACK] 49. exchangeExpiresAt:", exchangeExpiresAt);

      console.log("[NAVER CALLBACK] 50. login_exchanges insert 시작");
      const exchangeResult = await client.query(
        `insert into login_exchanges
         (user_id, exchange_code_hash, expires_at)
         values ($1, $2, $3)
         returning user_id, expires_at`,
        [userId, exchangeCodeHash, exchangeExpiresAt]
      );
      console.log("[NAVER CALLBACK] 51. login_exchanges result:", exchangeResult.rows);

      console.log("[NAVER CALLBACK] 52. COMMIT 시작");
      await client.query("COMMIT");
      console.log("[NAVER CALLBACK] 53. COMMIT 성공");

      const successDeepLink = buildDeepLink({
        success: "true",
        exchangeCode,
        gender,
        ageRange,
      });

      console.log("[NAVER CALLBACK] 54. success deepLink:", successDeepLink);
      console.log("[NAVER CALLBACK] 55. callback 성공 종료");

      return res.redirect(successDeepLink);
    } catch (dbError: any) {
      console.error("[NAVER CALLBACK] DB ERROR 발생:", dbError);
      console.error("[NAVER CALLBACK] DB ERROR message:", dbError?.message);
      console.error("[NAVER CALLBACK] DB ERROR detail:", dbError?.detail);
      console.error("[NAVER CALLBACK] DB ERROR code:", dbError?.code);
      console.error("[NAVER CALLBACK] DB ERROR constraint:", dbError?.constraint);

      await client.query("ROLLBACK");
      console.log("[NAVER CALLBACK] ROLLBACK 완료");

      return res.redirect(
        buildDeepLink({
          success: "false",
          message: dbError.message || "db save failed",
        })
      );
    } finally {
      console.log("[NAVER CALLBACK] client.release()");
      client.release();
    }
  } catch (error: any) {
    console.error("[NAVER CALLBACK] OUTER ERROR 발생:", error);
    console.error("[NAVER CALLBACK] OUTER ERROR message:", error?.message);
    console.error("[NAVER CALLBACK] OUTER ERROR response data:", error?.response?.data);

    const message =
      error.response?.data?.error_description ||
      error.response?.data?.error ||
      error.message ||
      "naver oauth failed";

    console.log("[NAVER CALLBACK] 실패 deepLink로 이동:", message);

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
  console.log("[SESSION EXCHANGE] 1. /session/exchange 진입");
  console.log("[SESSION EXCHANGE] 2. body:", req.body);

  const exchangeCode = String(req.body.exchange_code || "").trim();
  console.log("[SESSION EXCHANGE] 3. exchangeCode 존재:", !!exchangeCode);

  if (!exchangeCode) {
    console.log("[SESSION EXCHANGE] 4. exchange_code missing");
    return fail(res, 400, "exchange_code is required");
  }

  const exchangeCodeHash = hashToken(exchangeCode);
  console.log("[SESSION EXCHANGE] 5. exchangeCodeHash:", exchangeCodeHash);

  const client = await pool.connect();
  console.log("[SESSION EXCHANGE] 6. DB connect 성공");

  try {
    await client.query("BEGIN");
    console.log("[SESSION EXCHANGE] 7. BEGIN 성공");

    const exchangeResult = await client.query(
      `select user_id, expires_at, used_at
       from login_exchanges
       where exchange_code_hash = $1
       limit 1`,
      [exchangeCodeHash]
    );

    console.log("[SESSION EXCHANGE] 8. exchange 조회 result:", exchangeResult.rows);

    if (exchangeResult.rows.length === 0) {
      console.log("[SESSION EXCHANGE] 9. invalid exchange code");
      await client.query("ROLLBACK");
      return fail(res, 401, "invalid exchange code");
    }

    const exchangeRow = exchangeResult.rows[0];
    console.log("[SESSION EXCHANGE] 10. exchangeRow:", exchangeRow);

    if (exchangeRow.used_at) {
      console.log("[SESSION EXCHANGE] 11. exchange code already used");
      await client.query("ROLLBACK");
      return fail(res, 401, "exchange code already used");
    }

    if (new Date(exchangeRow.expires_at).getTime() < Date.now()) {
      console.log("[SESSION EXCHANGE] 12. exchange code expired");
      await client.query("ROLLBACK");
      return fail(res, 401, "exchange code expired");
    }

    const userId = Number(exchangeRow.user_id);
    console.log("[SESSION EXCHANGE] 13. userId:", userId);

    const accessToken = createAccessToken(userId);
    const refreshToken = createRefreshToken(userId);
    console.log("[SESSION EXCHANGE] 14. accessToken 생성 완료");
    console.log("[SESSION EXCHANGE] 15. refreshToken 생성 완료");

    const refreshTokenHash = hashToken(refreshToken);
    const refreshExpiresAt = getRefreshTokenExpiresAt();
    console.log("[SESSION EXCHANGE] 16. refreshTokenHash:", refreshTokenHash);
    console.log("[SESSION EXCHANGE] 17. refreshExpiresAt:", refreshExpiresAt);

    const refreshInsertResult = await client.query(
      `insert into refresh_tokens
       (user_id, token_hash, device_name, device_id, expires_at)
       values ($1, $2, $3, $4, $5)
       returning user_id, expires_at`,
      [
        userId,
        refreshTokenHash,
        req.headers["user-agent"] || "flutter-app",
        req.headers["x-device-id"] || null,
        refreshExpiresAt,
      ]
    );
    console.log("[SESSION EXCHANGE] 18. refresh_tokens insert result:", refreshInsertResult.rows);

    const exchangeUpdateResult = await client.query(
      `update login_exchanges
       set used_at = now()
       where exchange_code_hash = $1
       returning user_id, used_at`,
      [exchangeCodeHash]
    );
    console.log("[SESSION EXCHANGE] 19. login_exchanges update result:", exchangeUpdateResult.rows);

    const profileResult = await client.query(
      `select gender, age_range, nickname
       from user_profiles
       where user_id = $1
       limit 1`,
      [userId]
    );
    console.log("[SESSION EXCHANGE] 20. profileResult:", profileResult.rows);

    await client.query("COMMIT");
    console.log("[SESSION EXCHANGE] 21. COMMIT 성공");

    const profile = profileResult.rows[0] || {};
    const nickname = profile.nickname ?? null;
    const profileCompleted = !!nickname;

    console.log("[SESSION EXCHANGE] 22. nickname:", nickname);
    console.log("[SESSION EXCHANGE] 23. profileCompleted:", profileCompleted);

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
    console.error("[SESSION EXCHANGE] ERROR:", error);
    console.error("[SESSION EXCHANGE] ERROR message:", error?.message);

    await client.query("ROLLBACK");
    return fail(res, 500, "session exchange failed", error.message);
  } finally {
    console.log("[SESSION EXCHANGE] client.release()");
    client.release();
  }
});

/**
 * 4) refresh token으로 access token 재발급
 * POST /auth/refresh
 */
router.post("/refresh", async (req, res) => {
  console.log("[REFRESH] 1. /refresh 진입");
  console.log("[REFRESH] 2. body:", req.body);

  const refreshToken = String(req.body.refresh_token || "").trim();
  console.log("[REFRESH] 3. refreshToken 존재:", !!refreshToken);

  if (!refreshToken) {
    console.log("[REFRESH] 4. refresh_token missing");
    return fail(res, 400, "refresh_token is required");
  }

  let payload: any;

  try {
    payload = jwt.verify(refreshToken, JWT_REFRESH_SECRET);
    console.log("[REFRESH] 5. jwt verify 성공:", payload);

    if (payload.type !== "refresh") {
      console.log("[REFRESH] 6. invalid token type:", payload.type);
      return fail(res, 401, "invalid token type");
    }
  } catch (error: any) {
    console.error("[REFRESH] JWT ERROR:", error);

    if (error.name === "TokenExpiredError") {
      return fail(res, 401, "refresh token expired");
    }
    return fail(res, 401, "invalid refresh token");
  }

  const refreshTokenHash = hashToken(refreshToken);
  console.log("[REFRESH] 7. refreshTokenHash:", refreshTokenHash);

  const client = await pool.connect();
  console.log("[REFRESH] 8. DB connect 성공");

  try {
    await client.query("BEGIN");
    console.log("[REFRESH] 9. BEGIN 성공");

    const tokenResult = await client.query(
      `select id, user_id, expires_at, revoked_at
       from refresh_tokens
       where token_hash = $1
       limit 1`,
      [refreshTokenHash]
    );

    console.log("[REFRESH] 10. tokenResult:", tokenResult.rows);

    if (tokenResult.rows.length === 0) {
      console.log("[REFRESH] 11. refresh token not found");
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token not found");
    }

    const tokenRow = tokenResult.rows[0];
    console.log("[REFRESH] 12. tokenRow:", tokenRow);

    if (tokenRow.revoked_at) {
      console.log("[REFRESH] 13. refresh token revoked");
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token revoked");
    }

    if (new Date(tokenRow.expires_at).getTime() < Date.now()) {
      console.log("[REFRESH] 14. refresh token expired");
      await client.query("ROLLBACK");
      return fail(res, 401, "refresh token expired");
    }

    const userId = Number(tokenRow.user_id);
    console.log("[REFRESH] 15. userId:", userId);

    const newAccessToken = createAccessToken(userId);
    const newRefreshToken = createRefreshToken(userId);
    const newRefreshTokenHash = hashToken(newRefreshToken);
    const newRefreshExpiresAt = getRefreshTokenExpiresAt();

    console.log("[REFRESH] 16. 새 access token 생성");
    console.log("[REFRESH] 17. 새 refresh token 생성");
    console.log("[REFRESH] 18. newRefreshTokenHash:", newRefreshTokenHash);
    console.log("[REFRESH] 19. newRefreshExpiresAt:", newRefreshExpiresAt);

    const revokeResult = await client.query(
      `update refresh_tokens
       set revoked_at = now()
       where id = $1
       returning id, revoked_at`,
      [tokenRow.id]
    );
    console.log("[REFRESH] 20. 기존 refresh revoke result:", revokeResult.rows);

    const newRefreshInsertResult = await client.query(
      `insert into refresh_tokens
       (user_id, token_hash, device_name, device_id, expires_at)
       values ($1, $2, $3, $4, $5)
       returning user_id, expires_at`,
      [
        userId,
        newRefreshTokenHash,
        req.headers["user-agent"] || "flutter-app",
        req.headers["x-device-id"] || null,
        newRefreshExpiresAt,
      ]
    );
    console.log("[REFRESH] 21. 새 refresh insert result:", newRefreshInsertResult.rows);

    await client.query("COMMIT");
    console.log("[REFRESH] 22. COMMIT 성공");

    return ok(res, {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
    });
  } catch (error: any) {
    console.error("[REFRESH] ERROR:", error);
    console.error("[REFRESH] ERROR message:", error?.message);

    await client.query("ROLLBACK");
    return fail(res, 500, "token refresh failed", error.message);
  } finally {
    console.log("[REFRESH] client.release()");
    client.release();
  }
});

/**
 * 5) 로그아웃
 * POST /auth/logout
 */
router.post("/logout", async (req, res) => {
  console.log("[LOGOUT] 1. /logout 진입");
  console.log("[LOGOUT] 2. body:", req.body);

  const refreshToken = String(req.body.refresh_token || "").trim();
  console.log("[LOGOUT] 3. refreshToken 존재:", !!refreshToken);

  if (!refreshToken) {
    console.log("[LOGOUT] 4. refresh_token missing");
    return fail(res, 400, "refresh_token is required");
  }

  try {
    jwt.verify(refreshToken, JWT_REFRESH_SECRET);
    console.log("[LOGOUT] 5. jwt verify 성공");
  } catch (error) {
    console.error("[LOGOUT] 6. invalid refresh token:", error);
    return fail(res, 400, "invalid refresh token");
  }

  const refreshTokenHash = hashToken(refreshToken);
  console.log("[LOGOUT] 7. refreshTokenHash:", refreshTokenHash);

  const logoutResult = await pool.query(
    `update refresh_tokens
     set revoked_at = now()
     where token_hash = $1
       and revoked_at is null
     returning id, user_id, revoked_at`,
    [refreshTokenHash]
  );

  console.log("[LOGOUT] 8. revoke result:", logoutResult.rows);

  return ok(res, {
    message: "logged out",
  });
});

export default router;