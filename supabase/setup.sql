-- Controle de Licitações (Natisa · José Renato) — configuração do banco no Supabase
-- Cole tudo no SQL Editor do Supabase e clique em RUN. Pode rodar de novo sem problema.

-- 1) Uma tabela guarda todos os registros (editais, clientes, tarefas, cidades, custos...).
create table if not exists public.docs (
  collection text        not null,
  id         text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);

-- 2) Segurança: só quem fez login (usuário autenticado) lê e grava. Visitantes sem login não veem nada.
alter table public.docs enable row level security;
revoke all on public.docs from anon;
grant select, insert, update, delete on public.docs to authenticated;

drop policy if exists "membros leem"     on public.docs;
drop policy if exists "membros inserem"  on public.docs;
drop policy if exists "membros alteram"  on public.docs;
drop policy if exists "membros apagam"   on public.docs;
create policy "membros leem"    on public.docs for select to authenticated using (true);
create policy "membros inserem" on public.docs for insert to authenticated with check (true);
create policy "membros alteram" on public.docs for update to authenticated using (true) with check (true);
create policy "membros apagam"  on public.docs for delete to authenticated using (true);

-- 3) Atualização parcial de um registro sem perder campos que outra pessoa mudou ao mesmo tempo.
create or replace function public.doc_merge(c text, i text, patch jsonb)
returns jsonb
language sql
security invoker
as $$
  update public.docs
     set data = data || patch, updated_at = now()
   where collection = c and id = i
  returning data;
$$;
revoke execute on function public.doc_merge(text, text, jsonb) from public, anon;
grant  execute on function public.doc_merge(text, text, jsonb) to authenticated;

-- 4) Tempo real: quando um muda algo, o outro vê na hora sem recarregar a página.
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs') then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;
