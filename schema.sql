-- Run once in Supabase: SQL Editor > New query > paste > Run.
create table if not exists public.items (
  board_id uuid not null default auth.uid(),
  id text not null,
  data jsonb not null,
  primary key (board_id, id)
);
alter table public.items enable row level security;
alter table public.items replica identity full;
grant select, insert, update, delete on public.items to authenticated;
drop policy if exists "own board read" on public.items;
drop policy if exists "own board insert" on public.items;
drop policy if exists "own board update" on public.items;
drop policy if exists "own board delete" on public.items;
create policy "own board read" on public.items for select to authenticated using (board_id = auth.uid());
create policy "own board insert" on public.items for insert to authenticated with check (board_id = auth.uid());
create policy "own board update" on public.items for update to authenticated using (board_id = auth.uid()) with check (board_id = auth.uid());
create policy "own board delete" on public.items for delete to authenticated using (board_id = auth.uid());
do $$ begin
  alter publication supabase_realtime add table public.items;
exception when duplicate_object then null;
end $$;
