const ALLOWED_GENDERS = ["male", "female", "any"] as const;
export type Gender = (typeof ALLOWED_GENDERS)[number];

const ALLOWED_AGE_GROUPS = ["any", "20s", "30s", "40s", "50s"];
export type AgeGroup = (typeof ALLOWED_AGE_GROUPS)[number];

const ALLOWED_CATEGORIES = ["food", "cafe", "drink", "travel", "activity"] as const;
type Category = (typeof ALLOWED_CATEGORIES)[number];

const ALLOWED_REGION = [
  "애월/한담권",
  "협재/한림권",
  "함덕/조천권",
  "성산/우도권",
  "표선/성읍권",
  "중문/안덕권",
  "서귀포시내권",
  "제주시/공항권"
];
type Region = (typeof ALLOWED_REGION)[number];

export function isValidRegion(value: string): value is Region {
  return ALLOWED_REGION.includes(value as Region);
}

export function isValidGender(value: string): value is Gender {
  return ALLOWED_GENDERS.includes(value as Gender);
}

export function isValidCategory(value: unknown): value is Category {
  return ALLOWED_CATEGORIES.includes(value as Category);
}

export function isValidAgeGroups(value: unknown): value is AgeGroup[] {
  if (!Array.isArray(value) || value.length === 0) {
    return false;
  }

  if (!value.every((item) => typeof item === "string")) {
    return false;
  }

  if (!value.every((item) => ALLOWED_AGE_GROUPS.includes(item as AgeGroup))) {
    return false;
  }

  if (value.includes("any") && value.length > 1) {
    return false;
  }

  return true;
}


