use semeia;

-- =========================================================
-- SCRIPT DE USO DAS FUNÇÕES E PROCEDURES – SEMEIA
-- =========================================================
-- Este script supõe que:
-- 1) Os INSERTs já foram executados;
-- 2) As funções e procedures do projeto já foram criadas.

-- =========================================================
-- 1) Lotes com total de sacas entregues
--    (usa fn_total_sacas_lote + fn_especie_lote)
--    Mostra quanto de cada lote já saiu em entregas.
-- =========================================================
select l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       fn_especie_lote(l.id_lote) "Espécie",
       l.qtd_sacas "Sacas Recebidas",
       fn_total_sacas_lote(l.id_lote) "Sacas Entregues",
       (l.qtd_sacas - fn_total_sacas_lote(l.id_lote)) "Saldo Estimado"
  from lote l
 order by l.numero_lote;

-- =========================================================
-- 2) Agricultores com total de entregas recebidas
--    (usa fn_qtd_entregas_agricultor)
--    Ajuda a enxergar quem já foi mais atendido pelo programa.
-- =========================================================
select a.id_agricultor "ID Agricultor",
       a.nome "Agricultor",
       m.nome "Município",
       fn_qtd_entregas_agricultor(a.id_agricultor) "Quantidade de Entregas"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio
 order by a.nome;

-- =========================================================
-- 3) Saldo de sacas por armazém
--    (usa fn_saldo_armazem)
--    Visão consolidada de estoque em cada armazém.
-- =========================================================
select a.id_armazem "ID Armazém",
       a.nome_armazem "Armazém",
       m.nome "Município",
       fn_saldo_armazem(a.id_armazem) "Saldo Total de Sacas"
  from armazem a
  inner join municipio m on m.id_municipio = a.id_municipio
 order by a.nome_armazem;

-- =========================================================
-- 4) Cooperativas e volume total recebido
--    (usa fn_sacas_cooperativa)
--    Mostra quantas sacas foram entregues para cada cooperativa.
-- =========================================================
select c.id_cooper "ID Cooperativa",
       c.razao_social "Cooperativa",
       m.nome "Município",
       fn_sacas_cooperativa(c.id_cooper) "Total de Sacas Recebidas"
  from cooperativa c
  inner join municipio m on m.id_municipio = c.id_municipio
 order by c.razao_social;

-- =========================================================
-- 5) Entregas com nome do destinatário por função
--    (usa fn_nome_destinatario)
--    Devolve o nome correto (agricultor ou cooperativa) de cada entrega.
-- =========================================================
select e.id_entrega "ID Entrega",
       date_format(e.data_entrega, '%d/%m/%Y') "Data da Entrega",
       m.nome "Município",
       e.tipo_destinatario "Tipo Destinatário",
       fn_nome_destinatario(e.id_entrega) "Destinatário",
       u.nome "Usuário Responsável"
  from entrega e
  inner join municipio m on m.id_municipio = e.id_municipio
  inner join usuario u on u.id_usuario = e.id_usuario
 order by e.data_entrega desc, m.nome;

-- =========================================================
-- 6) Top 10 lotes mais distribuídos
--    (usa fn_total_sacas_lote)
--    Ordena os lotes por volume já entregue em todo o sistema.
-- =========================================================
select l.numero_lote "Número do Lote",
       fn_especie_lote(l.id_lote) "Espécie",
       fn_total_sacas_lote(l.id_lote) "Total de Sacas Entregues"
  from lote l
 order by fn_total_sacas_lote(l.id_lote) desc
 limit 10;

-- =========================================================
-- 7) Agricultores com entregas em Caruaru
--    (usa fn_qtd_entregas_agricultor + filtro por município)
-- =========================================================
select a.nome "Agricultor",
       m.nome "Município",
       fn_qtd_entregas_agricultor(a.id_agricultor) "Quantidade de Entregas"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio
 where m.nome = 'Caruaru'
 order by a.nome;

-- =========================================================
-- 8) Armazéns em Recife com saldo de estoque
--    (usa fn_saldo_armazem)
-- =========================================================
select a.nome_armazem "Armazém",
       m.nome "Município",
       fn_saldo_armazem(a.id_armazem) "Saldo Total de Sacas"
  from armazem a
  inner join municipio m on m.id_municipio = a.id_municipio
 where m.nome = 'Recife'
 order by a.nome_armazem;

-- =========================================================
-- 9) Cooperativas de Caruaru com volume recebido
--    (usa fn_sacas_cooperativa)
-- =========================================================
select c.razao_social "Cooperativa",
       m.nome "Município",
       fn_sacas_cooperativa(c.id_cooper) "Total de Sacas Recebidas"
  from cooperativa c
  inner join municipio m on m.id_municipio = c.id_municipio
 where m.nome = 'Caruaru'
 order by c.razao_social;

-- =========================================================
-- 10) Conferência de destinatário por entrega
--     (usa fn_nome_destinatario com subselect de exemplo)
-- =========================================================
select e.id_entrega "ID Entrega",
       fn_nome_destinatario(e.id_entrega) "Destinatário",
       e.tipo_destinatario "Tipo",
       m.nome "Município"
  from entrega e
  inner join municipio m on m.id_municipio = e.id_municipio
 order by e.id_entrega
 limit 10;

-- =========================================================
-- CHAMADAS DE PROCEDURES (EXECUÇÃO) COM OS DADOS
-- =========================================================
-- ---------------------------------------------------------
-- 11) Detalhes de um lote específico (MIL-2025-0001)
--     (usa sp_detalhes_lote)
-- ---------------------------------------------------------
set @id_lote_milho := (
  select id_lote
    from lote
   where numero_lote = 'MIL-2025-0001'
   limit 1
);

call sp_detalhes_lote(@id_lote_milho);

-- ---------------------------------------------------------
-- 12) Entregas do município de Caruaru
--     (usa sp_entregas_por_municipio)
-- ---------------------------------------------------------
set @id_mun_caruaru := (
  select id_municipio
    from municipio
   where nome = 'Caruaru'
     and uf = 'PE'
   limit 1
);

call sp_entregas_por_municipio(@id_mun_caruaru);

-- ---------------------------------------------------------
-- 13) Entregas registradas pela usuária "Carla Distribuição"
--     (usa sp_entregas_por_usuario)
-- ---------------------------------------------------------
set @id_usuario_carla := (
  select id_usuario
    from usuario
   where email_login = 'carla.distrib@semeia.local'
   limit 1
);

call sp_entregas_por_usuario(@id_usuario_carla);

-- ---------------------------------------------------------
-- 14) Saldo detalhado de um armazém (Armazém Central Recife)
--     (usa sp_saldo_armazem)
-- ---------------------------------------------------------
set @id_armazem_recife := (
  select id_armazem
    from armazem
   where nome_armazem = 'Armazém Central Recife'
   limit 1
);

call sp_saldo_armazem(@id_armazem_recife);

-- ---------------------------------------------------------
-- 15) Entregas para a cooperativa "CooperAgro Caruaru"
--     (usa sp_entregas_cooperativa)
-- ---------------------------------------------------------
set @id_coop_caruaru := (
  select id_cooper
    from cooperativa
   where razao_social = 'CooperAgro Caruaru'
   limit 1
);

call sp_entregas_cooperativa(@id_coop_caruaru);

-- ---------------------------------------------------------
-- 16) Histórico de movimentações de um lote (SOR-2025-0001)
--     (usa sp_historico_lote)
-- ---------------------------------------------------------
set @id_lote_sorgo := (
  select id_lote
    from lote
   where numero_lote = 'SOR-2025-0001'
   limit 1
);

call sp_historico_lote(@id_lote_sorgo);

-- ---------------------------------------------------------
-- 17) Inserção de um novo agricultor via procedure
--     (usa sp_inserir_agricultor)
--     Exemplo com município Caruaru e um endereço de agricultor existente.
-- ---------------------------------------------------------
set @id_mun_caruaru := (
  select id_municipio
    from municipio
   where nome = 'Caruaru'
     and uf = 'PE'
   limit 1
);

call sp_inserir_agricultor(
  'Agricultor Procedural',
  'agri.procedure@rural.com',
  '999.999.999-99',  
  @id_mun_caruaru
);

-- Conferência do agricultor inserido:
select a.id_agricultor "ID Agricultor",
       a.nome "Agricultor",
       a.cpf "CPF",
       m.nome "Município"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio
 where a.cpf = '999.999.999-99';

-- =========================================================
-- 18) Relatório geral de entregas com funções aplicadas
--     (combina várias funções em um único select)
-- =========================================================
select e.id_entrega "ID Entrega",
       date_format(e.data_entrega, '%d/%m/%Y') "Data",
       m.nome "Município",
       e.tipo_destinatario "Tipo Destinatário",
       fn_nome_destinatario(e.id_entrega) "Destinatário",
       u.nome "Usuário Responsável",
       sum(ie.quant_sacas) "Total de Sacas na Entrega"
  from entrega e
  inner join municipio m on m.id_municipio = e.id_municipio
  inner join usuario u on u.id_usuario = e.id_usuario
  inner join item_entrega ie on ie.id_entrega = e.id_entrega
 group by e.id_entrega, e.data_entrega, m.nome, e.tipo_destinatario, u.nome
 order by e.data_entrega desc;

-- =========================================================
-- 19) Cooperativas x Municípios x Volume
--     (usa fn_sacas_cooperativa em conjunto com joins)
-- =========================================================
select m.nome "Município",
       c.razao_social "Cooperativa",
       fn_sacas_cooperativa(c.id_cooper) "Volume Total Recebido"
  from cooperativa c
  inner join municipio m on m.id_municipio = c.id_municipio
 order by m.nome, c.razao_social;

-- =========================================================
-- 20) Lotes por fornecedor com uso de função
--     (usa fn_total_sacas_lote para cruzar recebimento x saída)
-- =========================================================
select f.razao_social "Fornecedor",
       l.numero_lote "Lote",
       fn_especie_lote(l.id_lote) "Espécie",
       l.qtd_sacas "Sacas Recebidas",
       fn_total_sacas_lote(l.id_lote) "Sacas Entregues"
  from lote l
  inner join fornecedor f on f.id_fornecedor = l.id_fornecedor
 order by f.razao_social, l.numero_lote;
