-- Reset public app data before deployment.
-- This keeps the table structure, constraints, and indexes, but deletes all rows
-- and resets bigserial sequences back to 1.
--
-- Run only after taking a backup. This is destructive.

begin;

truncate table
  public.chat_room_members,
  public.chat_messages,
  public.chat_rooms,
  public.meeting_members,
  public.meetings,
  public.reports,
  public.notifications,
  public.user_fcm_tokens,
  public.social_accounts,
  public.refresh_tokens,
  public.login_exchanges,
  public.user_profiles,
  public.users
restart identity cascade;

commit;
