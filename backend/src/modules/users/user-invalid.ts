type ProfileInput = {
  nickname: string;
  bio: string;
  category: string[];
  profileImageUrl: string;
};

export function validateProfileInput(body: any): ProfileInput | null {
  const { nickname, bio, category, profileImageUrl } = body;

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

  return {
    nickname: nickname.trim(),
    bio: trimmedBio,
    category,
    profileImageUrl,
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