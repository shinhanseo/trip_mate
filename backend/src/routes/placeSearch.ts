import { Router } from "express";
import axios from "axios";
import { ok, fail } from "../utils/response";
import type { PlaceItem } from "../modules/place/place-type";
import { buildPlaceItem } from "../modules/place/place-mapper";

const router = Router();

router.get("/search", async (req, res) => {
  const q = String(req.query.q || "").trim();

  if (!q) {
    return fail(res, 400, "q is required");
  }

  const apiKey = process.env.KAKAO_REST_API_KEY;
  if (!apiKey) {
    return fail(res, 500, "KAKAO_REST_API_KEY missing");
  }

  const headers = {
    Authorization: `KakaoAK ${apiKey}`,
  };

  try {
    const [kw, addr] = await Promise.all([
      axios.get("https://dapi.kakao.com/v2/local/search/keyword.json", {
        headers,
        params: { query: q, size: 15 },
        timeout: 5000,
      }),
      axios.get("https://dapi.kakao.com/v2/local/search/address.json", {
        headers,
        params: { query: q, size: 15 },
        timeout: 5000,
      }),
    ]);

    const kwPlaces: PlaceItem[] = (kw.data.documents || [])
      .map((d: any) => {
        const lat = Number(d.y);
        const lng = Number(d.x);

        if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;

        return buildPlaceItem({
          name: d.place_name || "이름 없음",
          address: d.road_address_name || d.address_name || "",
          lat,
          lng,
          source: "keyword",
          buildingName: d.place_name || undefined,
          placeId: d.id ? String(d.id) : undefined,
        });
      })
      .filter(Boolean) as PlaceItem[];

    const addrPlaces: PlaceItem[] = (addr.data.documents || [])
      .map((d: any) => {
        const lat = Number(d.y);
        const lng = Number(d.x);

        if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;

        return buildPlaceItem({
          name: d.address_name || "주소 결과",
          address: d.road_address?.address_name || d.address_name || "",
          lat,
          lng,
          source: "address",
        });
      })
      .filter(Boolean) as PlaceItem[];

    const seen = new Set<string>();
    const merged = [...kwPlaces, ...addrPlaces].filter((p) => {
      const key = `${p.name}|${p.address}|${p.lat.toFixed(5)}|${p.lng.toFixed(5)}`;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });

    return ok(res, { items: merged });
  } catch (err: any) {
    const status = err?.response?.status ?? 0;

    return fail(res, 502, "kakao api error", {
      status,
      detail: err?.response?.data || String(err),
    });
  }
});

router.get("/map-pick", async (req, res) => {
  const apiKey = process.env.KAKAO_REST_API_KEY;
  if (!apiKey) {
    return fail(res, 500, "KAKAO_REST_API_KEY missing");
  }

  const latNum = Number(req.query.lat);
  const lngNum = Number(req.query.lng);

  if (!Number.isFinite(latNum) || !Number.isFinite(lngNum)) {
    return fail(res, 400, "invalid lat/lng");
  }

  try {
    const kakaoRes = await axios.get(
      "https://dapi.kakao.com/v2/local/geo/coord2address.json",
      {
        headers: {
          Authorization: `KakaoAK ${apiKey}`,
        },
        params: {
          x: lngNum,
          y: latNum,
        },
        timeout: 5000,
      }
    );

    const doc = kakaoRes.data?.documents?.[0];
    if (!doc) {
      return fail(res, 404, "주소 결과가 없습니다.");
    }

    const road = doc.road_address?.address_name || "";
    const jibun = doc.address?.address_name || "";
    const address = road || jibun;

    const buildingName = doc.road_address?.building_name || "";
    const roadName = doc.road_address?.road_name || "";
    const region3Depth = doc.address?.region_3depth_name || "";

    const name =
      buildingName ||
      roadName ||
      region3Depth ||
      (address ? address.split(" ").slice(-2).join(" ") : "선택한 위치");

    const place = buildPlaceItem({
      name,
      address,
      buildingName: buildingName || undefined,
      lat: latNum,
      lng: lngNum,
      source: "map_pick",
    });

    return ok(res, { item: place });
  } catch (err: any) {
    const status = err?.response?.status ?? 0;

    return fail(res, 502, "reverse-geocode failed", {
      status,
      detail: err?.response?.data || String(err),
    });
  }
});

router.get("/mylocation", async (req, res) => {
  const apiKey = process.env.KAKAO_REST_API_KEY;
  if (!apiKey) {
    return fail(res, 500, "KAKAO_REST_API_KEY missing");
  }

  const latNum = Number(req.query.lat);
  const lngNum = Number(req.query.lng);

  if (!Number.isFinite(latNum) || !Number.isFinite(lngNum)) {
    return fail(res, 400, "invalid lat/lng");
  }

  try {
    const kakaoRes = await axios.get(
      "https://dapi.kakao.com/v2/local/geo/coord2address.json",
      {
        headers: {
          Authorization: `KakaoAK ${apiKey}`,
        },
        params: {
          x: lngNum,
          y: latNum,
        },
        timeout: 5000,
      }
    );

    const doc = kakaoRes.data?.documents?.[0];
    const region1 = doc?.address?.region_1depth_name ?? null;
    const region2 = doc?.address?.region_2depth_name ?? null;

    const isJejuCity = region1 === "제주특별자치도" && region2 === "제주시";

    return ok(res, {
      item: {
        region1,
        region2,
        isJejuCity,
      },
    });
  } catch (error: any) {
    return fail(res, 500, "failed to gecode my location");
  }
});
export default router;