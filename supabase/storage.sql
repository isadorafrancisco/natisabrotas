-- Controle de Licitações — armazenamento dos documentos dos contratos (Fechamento)
-- Cole no SQL Editor do Supabase e clique em RUN. Pode rodar de novo sem problema.

-- Área privada ("bucket") chamada contratos: nada é público, limite de 50 MB por arquivo.
insert into storage.buckets (id, name, public, file_size_limit)
values ('contratos', 'contratos', false, 52428800)
on conflict (id) do update set public = false, file_size_limit = 52428800;

-- Só quem fez login lê, envia, troca e apaga arquivos desta área.
drop policy if exists "contratos leitura"  on storage.objects;
drop policy if exists "contratos envio"    on storage.objects;
drop policy if exists "contratos troca"    on storage.objects;
drop policy if exists "contratos exclusao" on storage.objects;
create policy "contratos leitura"  on storage.objects for select to authenticated using (bucket_id = 'contratos');
create policy "contratos envio"    on storage.objects for insert to authenticated with check (bucket_id = 'contratos');
create policy "contratos troca"    on storage.objects for update to authenticated using (bucket_id = 'contratos') with check (bucket_id = 'contratos');
create policy "contratos exclusao" on storage.objects for delete to authenticated using (bucket_id = 'contratos');
