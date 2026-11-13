-- MAGA Application OS v8: two invited members, each owns a private workspace.
-- Run in a dedicated Supabase project's SQL Editor.
begin;
create table if not exists public.maga_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  slot smallint not null unique check (slot between 1 and 2),
  display_name text not null check (length(display_name) between 1 and 120),
  active boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.maga_workspaces (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb check (jsonb_typeof(data) = 'object'),
  updated_at timestamptz not null default now()
);
alter table public.maga_members enable row level security;
alter table public.maga_workspaces enable row level security;
revoke all on public.maga_members from PUBLIC, anon, authenticated;
revoke all on public.maga_workspaces from PUBLIC, anon, authenticated;
grant select on public.maga_members to authenticated;
grant select, insert, update on public.maga_workspaces to authenticated;
drop policy if exists maga_member_own_read on public.maga_members;
create policy maga_member_own_read on public.maga_members
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists maga_workspace_own_read on public.maga_workspaces;
create policy maga_workspace_own_read on public.maga_workspaces
  for select to authenticated using
  (user_id = (select auth.uid()) and exists
   (select 1 from public.maga_members m where m.user_id = (select auth.uid()) and m.active));
drop policy if exists maga_workspace_own_insert on public.maga_workspaces;
create policy maga_workspace_own_insert on public.maga_workspaces
  for insert to authenticated with check
  (user_id = (select auth.uid()) and exists
   (select 1 from public.maga_members m where m.user_id = (select auth.uid()) and m.active));
drop policy if exists maga_workspace_own_update on public.maga_workspaces;
create policy maga_workspace_own_update on public.maga_workspaces
  for update to authenticated using
  (user_id = (select auth.uid()) and exists
   (select 1 from public.maga_members m where m.user_id = (select auth.uid()) and m.active))
  with check
  (user_id = (select auth.uid()) and exists
   (select 1 from public.maga_members m where m.user_id = (select auth.uid()) and m.active));
commit;
-- Admin-only setup after inviting both users in Supabase Authentication > Users:
-- INSERT INTO public.maga_members(user_id,slot,display_name)
-- SELECT id,1,'First participant' FROM auth.users WHERE lower(email)=lower('FIRST_EMAIL');
-- INSERT INTO public.maga_members(user_id,slot,display_name)
-- SELECT id,2,'Second participant' FROM auth.users WHERE lower(email)=lower('SECOND_EMAIL');
