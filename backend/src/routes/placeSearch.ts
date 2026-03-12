import { Router } from "express";
import axios from "axios";
import { ok, fail } from "../utils/response.js";

const router = Router();

type PlaceItem = {
  name: string;
  address: string;
  lat: number;
  lng: number;
  source: "keyword" | "address" | "map_pick";
  buildingName?: string;
  placeId?: string;
  regionPrimary?: string;
  regionSecondary?: string;
};

function getJejuRegionInfo(address: string) {
  const normalized = address.replace(/\s+/g, " ").trim();

  let regionPrimary = "기타 제주";
  let regionSecondary = "";

  if (normalized.includes("애월읍")) {
    regionPrimary = "애월/한담권";
    regionSecondary = "애월읍";
  } else if (normalized.includes("한림읍")) {
    regionPrimary = "협재/한림권";
    regionSecondary = "한림읍";
  } else if (normalized.includes("조천읍")) {
    regionPrimary = "함덕/조천권";
    regionSecondary = "조천읍";
  } else if (normalized.includes("구좌읍")) {
    regionPrimary = "성산/우도권";
    regionSecondary = "구좌읍";
  } else if (normalized.includes("성산읍")) {
    regionPrimary = "성산/우도권";
    regionSecondary = "성산읍";
  } else if (normalized.includes("표선면")) {
    regionPrimary = "표선/성읍권";
    regionSecondary = "표선면";
  } else if (normalized.includes("안덕면")) {
    regionPrimary = "중문/안덕권";
    regionSecondary = "안덕면";
  } else if (normalized.includes("대정읍")) {
    regionPrimary = "중문/안덕권";
    regionSecondary = "대정읍";
  } else if (
    normalized.includes("서귀포시") ||
    normalized.includes("천지동") ||
    normalized.includes("중앙동") ||
    normalized.includes("정방동") ||
    normalized.includes("송산동") ||
    normalized.includes("동홍동") ||
    normalized.includes("서홍동")
  ) {
    regionPrimary = "서귀포시내권";
    regionSecondary = "서귀포시";
  } else if (
    normalized.includes("제주시") ||
    normalized.includes("용담") ||
    normalized.includes("이도") ||
    normalized.includes("연동") ||
    normalized.includes("노형") ||
    normalized.includes("도두")
  ) {
    regionPrimary = "제주시/공항권";
    regionSecondary = "제주시";
  }

  return { regionPrimary, regionSecondary };
}

function buildPlaceItem(params: {
  name: string;
  address: string;
  lat: number;
  lng: number;
  source: "keyword" | "address" | "map_pick";
  buildingName?: string;
  placeId?: string;
}): PlaceItem {
  const { regionPrimary, regionSecondary } = getJejuRegionInfo(params.address);

  return {
    ...params,
    regionPrimary,
    regionSecondary,
  };
}

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

    return ok(res, { places: merged });
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

    return ok(res, { place });
  } catch (err: any) {
    const status = err?.response?.status ?? 0;

    return fail(res, 502, "reverse-geocode failed", {
      status,
      detail: err?.response?.data || String(err),
    });
  }
});

export default router;