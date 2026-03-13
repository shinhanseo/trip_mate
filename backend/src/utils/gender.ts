const ALLOWED_GENDERS = ["male", "female", "any"] as const;

export type Gender = (typeof ALLOWED_GENDERS)[number];

function isValidGender(value: string): value is Gender {
  return ALLOWED_GENDERS.includes(value as Gender);
}
