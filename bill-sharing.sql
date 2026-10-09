-- Run once in Supabase: SQL Editor > New query > paste > Run.
-- Lets anyone with a split's share link see that one split, add their name and tag what they ordered,
-- without signing in. Nothing else on the board can be read this way. "Stop sharing" makes the link dead.
create index if not exists items_bill_token on public.items ((data->>'token')) where id like 'bill:%';

create or replace function public.shared_bill(p_token text) returns jsonb
language sql security definer set search_path = public stable as $$
  select data from items where id like 'bill:%' and length(p_token) >= 20 and data->>'token' = p_token limit 1
$$;

create or replace function public.shared_bill_join(p_token text, p_name text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r items; nm text := left(btrim(coalesce(p_name, '')), 40); pid text;
begin
  if length(p_token) < 20 or nm = '' then return null; end if;
  select * into r from items where id like 'bill:%' and data->>'token' = p_token limit 1 for update;
  if not found then return null; end if;
  select p->>'id' into pid from jsonb_array_elements(coalesce(r.data->'people', '[]'::jsonb)) p where lower(p->>'name') = lower(nm) limit 1;
  if pid is null then
    if jsonb_array_length(coalesce(r.data->'people', '[]'::jsonb)) >= 60 then return null; end if;
    pid := 'g' || substr(md5(random()::text || clock_timestamp()::text), 1, 10);
    update items set data = jsonb_set(data, '{people}', coalesce(data->'people', '[]'::jsonb) || jsonb_build_array(jsonb_build_object('id', pid, 'name', nm)))
      where board_id = r.board_id and id = r.id;
  end if;
  return jsonb_build_object('id', pid);
end $$;

-- Sets exactly which items p_person ordered, across all receipts of the split, and returns the updated split.
create or replace function public.shared_bill_tag(p_token text, p_person text, p_items text[]) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r items; nd jsonb;
begin
  if length(p_token) < 20 then return null; end if;
  select * into r from items where id like 'bill:%' and data->>'token' = p_token limit 1 for update;
  if not found or jsonb_typeof(r.data->'receipts') <> 'array' then return null; end if;
  if not exists (select 1 from jsonb_array_elements(coalesce(r.data->'people', '[]'::jsonb)) p where p->>'id' = p_person) then return null; end if;
  select jsonb_set(r.data, '{receipts}', coalesce(jsonb_agg(
      jsonb_set(rc, '{items}', coalesce((
        select jsonb_agg(jsonb_set(it, '{who}',
          coalesce((select jsonb_agg(w) from jsonb_array_elements_text(coalesce(it->'who', '[]'::jsonb)) w where w <> p_person), '[]'::jsonb)
          || case when (it->>'id') = any(coalesce(p_items, '{}')) then jsonb_build_array(p_person) else '[]'::jsonb end) order by io)
        from jsonb_array_elements(coalesce(rc->'items', '[]'::jsonb)) with ordinality as x(it, io)), '[]'::jsonb))
      order by ro), '[]'::jsonb))
    into nd from jsonb_array_elements(r.data->'receipts') with ordinality as y(rc, ro);
  update items set data = nd where board_id = r.board_id and id = r.id;
  return nd;
end $$;

revoke all on function public.shared_bill(text), public.shared_bill_join(text, text), public.shared_bill_tag(text, text, text[]) from public;
grant execute on function public.shared_bill(text), public.shared_bill_join(text, text), public.shared_bill_tag(text, text, text[]) to anon, authenticated;
