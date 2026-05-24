create table if not exists public.blocked_users (
  id bigserial primary key,
  blocker_id bigint not null references public.users(id) on delete cascade,
  blocked_user_id bigint not null references public.users(id) on delete cascade,
  reason varchar(50),
  detail text,
  created_at timestamptz(6) not null default now(),
  constraint blocked_users_blocker_blocked_user_key unique (blocker_id, blocked_user_id),
  constraint blocked_users_no_self_block check (blocker_id <> blocked_user_id)
);

create index if not exists blocked_users_blocker_id_idx
  on public.blocked_users(blocker_id);

create index if not exists blocked_users_blocked_user_id_idx
  on public.blocked_users(blocked_user_id);
