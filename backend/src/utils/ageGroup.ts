const ALLOWED_AGE_GROUPS = ["any", "20s", "30s", "40s", "50s"];

export type AgeGroup = (typeof ALLOWED_AGE_GROUPS)[number];

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