type ProfileInput = {
  nickname: string;
  bio: string;
  category: string[];
};

export function validateProfileInput(body: any): ProfileInput | null {
  const { nickname, bio, category } = body;

  if (!isValidNickname(nickname)) {
    return null;
  }

  if (typeof bio !== "string") {
    return null;
  }

  const trimmedBio = bio.trim();

  if (trimmedBio.length > 50) {
    return null;
  }

  if (!Array.isArray(category)) {
    return null;
  }

  if (!category.every((item) => typeof item === "string")) {
    return null;
  }

  if (category.length < 1 || category.length > 3) {
    return null;
  }

  return {
    nickname: nickname.trim(),
    bio: trimmedBio,
    category,
  };
}

export function isValidNickname(nickname: string) {
  const trimmedNickname = nickname.trim();

  if (trimmedNickname.length < 2) {
    return false;
  }

  if (trimmedNickname.length > 12) {
    return false;
  }

  const nicknameRegex = /^[가-힣a-zA-Z0-9_]+$/;

  if (!nicknameRegex.test(trimmedNickname)) {
    return false;
  }

  return true;
}