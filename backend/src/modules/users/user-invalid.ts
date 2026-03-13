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