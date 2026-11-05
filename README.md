# Controle de Licitações · Natisa e José Renato

Sistema web (Painel, Editais, Agenda semanal, Clientes, Cidades, Custos e orçamento).
Hospedado no GitHub Pages; os dados ficam no Supabase e só aparecem depois do login (e-mail e senha).

## Como funciona
- `index.html`: o sistema inteiro (uma página só).
- `config.js`: endereço (Project URL) e chave **anon** do Supabase. Essa chave é pública por natureza; a proteção dos dados vem do login e das regras do banco (`supabase/setup.sql`).
- `vendor/`: bibliotecas supabase-js e Chart.js 4.4.1 (cópias locais, sem depender de CDN).
- Tela **Controle de gastos** (`#controle`): contrato de roçada, produção em m², máquinas, gasto total e calendário de contas. Usa a mesma tabela `docs` (coleções `abastecimentos`, `oficina`, `producao`, `contas` e `config/controle`), então não precisa rodar nenhum SQL novo. Funcionários vêm de Custos e orçamento > Equipe.
- `supabase/setup.sql`: cria a tabela, as regras de acesso e o tempo real.
- `supabase/storage.sql`: cria a área privada de arquivos (`contratos`) usada pelos documentos da tela Fechamento.

## Configuração (uma vez)
1. Supabase → SQL Editor → colar `supabase/setup.sql` → Run.
2. Supabase → SQL Editor → colar `supabase/storage.sql` → Run (documentos do Fechamento).
3. Authentication → Sign In / Providers → Email: **desligar "Allow new users to sign up"** (ninguém de fora cria conta).
4. Authentication → Users → Add user → Create new user (e-mail + senha, marcar auto-confirm): um para cada pessoa que vai usar.
5. Project Settings → API: copiar **Project URL** e a chave **anon / publishable** para `config.js`.
6. GitHub → Settings → Pages → Source: *Deploy from a branch* → `main` / `(root)`.

Nunca coloque a chave `service_role` neste repositório.

## Controle de gastos por contrato e Família
- Cada lançamento (abastecimento, oficina, produção, conta avulsa) agora pertence a um contrato. Lançamentos antigos, sem contrato, valem para o contrato padrão (Ajustes).
- Os contratos vêm do Fechamento (em execução). O campo "Valor pago por m²" do contrato alimenta a receita.
- Calendário: Geral, um por contrato e Família. Contas da família ficam fora dos gastos da empresa.
- Menu "Família": calendário, contas fixas e contas avulsas pessoais.
- Menu "Financeiro geral": soma contratos, empresa e família no mês (gasto, já pago, falta pagar e lista do que vence).
- Orçamento dentro da licitação: ao abrir um edital na lista, aparece o orçamento básico dele (equipe, duração, extras, preço mínimo e alvo). Cada edital guarda o seu. A aba "Equipe e custos" ficou com cadastros e a lista de todos os orçamentos.
- Painel: resumo de tudo na tela inicial (financeiro do mês com contratos, empresa e família; contratos; licitações e orçamentos; equipe, equipamentos e clientes), além das metas e da visão das licitações.
