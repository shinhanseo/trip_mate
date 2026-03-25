export function getJejuRegionInfo(address: string) {
  const normalized = address.replace(/\s+/g, " ").trim();

  let regionPrimary: string | null = null;
  let regionSecondary: string | null = null;

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