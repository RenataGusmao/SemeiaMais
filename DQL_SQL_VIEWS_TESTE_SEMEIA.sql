use semeia;

-- ===================================================================
-- VIEW 1 - Usuários e Papéis
-- ===================================================================
drop view if exists vw_usuarios_papeis;

create view vw_usuarios_papeis as
select u.id_usuario "ID Usuário",
       u.nome "Usuário",
       u.email_login "E-mail de Login",
       group_concat(distinct p.nome separator ', ') "Papéis Vinculados"
  from usuario u
  left join usuario_papel up on up.id_usuario = u.id_usuario
  left join papel p on p.id_papel = up.id_papel
 group by u.id_usuario, u.nome, u.email_login;


-- ===================================================================
-- VIEW 2 - Gestores
-- ===================================================================
drop view if exists vw_gestores;

create view vw_gestores as
select g.id_gestor "ID Gestor",
       u.id_usuario "ID Usuário",
       u.nome "Gestor",
       u.email_login "E-mail",
       g.area_respons "Área de Responsabilidade",
       g.cargo "Cargo"
  from gestor g
  inner join usuario u on u.id_usuario = g.id_usuario;


-- ===================================================================
-- VIEW 3 - Agricultores por Município
-- ===================================================================
drop view if exists vw_agricultores_municipio;

create view vw_agricultores_municipio as
select a.id_agricultor "ID Agricultor",
       a.nome "Agricultor",
       a.cpf "CPF",
       a.email "E-mail",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio;


-- ===================================================================
-- VIEW 4 - Cooperativas por Município
-- ===================================================================
drop view if exists vw_cooperativas_municipio;

create view vw_cooperativas_municipio as
select c.id_cooper "ID Cooperativa",
       c.razao_social "Razão Social",
       c.cnpj_cooper "CNPJ",
       c.email "E-mail",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF"
  from cooperativa c
  inner join municipio m on m.id_municipio = c.id_municipio;


-- ===================================================================
-- VIEW 5 - Armazéns e Localização
-- ===================================================================
drop view if exists vw_armazens_localizacao;

create view vw_armazens_localizacao as
select a.id_armazem "ID Armazém",
       a.nome_armazem "Armazém",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF",
       ea.logradouro "Logradouro",
       ea.numero "Número",
       ea.bairro "Bairro",
       ea.cep "CEP",
       ea.cidade "Cidade Endereço",
       ea.uf "UF Endereço"
  from armazem a
  inner join municipio m on m.id_municipio = a.id_municipio
  left join endereco_armazem ea on ea.id_end_armazem = a.id_end_armazem;


-- ===================================================================
-- VIEW 6 - Lotes, Espécies e Fornecedores
-- ===================================================================
drop view if exists vw_lotes_especie_fornecedor;

create view vw_lotes_especie_fornecedor as
select l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.id_especie "ID Espécie",
       e.nome_comum "Espécie",
       e.nome_cientifico "Nome Científico",
       f.id_fornecedor "ID Fornecedor",
       f.razao_social "Fornecedor",
       date_format(l.validade, '%d/%m/%Y') "Validade",
       l.qtd_sacas "Quantidade de Sacas",
       l.qr_code "QR Code"
  from lote l
  inner join especie e on e.id_especie = l.id_especie
  inner join fornecedor f on f.id_fornecedor = l.id_fornecedor;


-- ===================================================================
-- VIEW 7 - Estoque por Armazém e Lote
-- ===================================================================
drop view if exists vw_estoque_armazem_lote;

create view vw_estoque_armazem_lote as
select a.id_armazem "ID Armazém",
       a.nome_armazem "Armazém",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF",
       l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       eal.saldo_sacas "Saldo de Sacas"
  from estoque_armazem_lote eal
  inner join armazem a on a.id_armazem = eal.id_armazem
  inner join municipio m on m.id_municipio = a.id_municipio
  inner join lote l on l.id_lote = eal.id_lote
  inner join especie e on e.id_especie = l.id_especie;


-- ===================================================================
-- VIEW 8 - Movimentações de Estoque Detalhadas
-- ===================================================================
drop view if exists vw_movimentacoes_estoque_detalhe;

create view vw_movimentacoes_estoque_detalhe as
select me.id_mov "ID Movimentação",
       me.tipo "Tipo",
       l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       ao.id_armazem "ID Armazém Origem",
       ao.nome_armazem "Armazém Origem",
       ad.id_armazem "ID Armazém Destino",
       ad.nome_armazem "Armazém Destino",
       me.quant_sacas "Quantidade de Sacas",
       date_format(me.data_mov, '%d/%m/%Y %H:%i') "Data/Hora",
       u.id_usuario "ID Usuário",
       u.nome "Usuário Responsável"
  from movimentacao_esto me
  inner join lote l on l.id_lote = me.id_lote
  inner join especie e on e.id_especie = l.id_especie
  left join armazem ao on ao.id_armazem = me.id_armazem_origem
  left join armazem ad on ad.id_armazem = me.id_armazem_destino
  inner join usuario u on u.id_usuario = me.id_usuario;


-- ===================================================================
-- VIEW 9 - Ordens de Expedição Detalhadas
-- ===================================================================
drop view if exists vw_ordens_expedicao_detalhe;

create view vw_ordens_expedicao_detalhe as
select oe.id_expedicao "ID Expedição",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF",
       date_format(oe.data_prevista, '%d/%m/%Y') "Data Prevista",
       oe.status "Status",
       c.id_cooper "ID Cooperativa",
       c.razao_social "Cooperativa Solicitante",
       g.id_gestor "ID Gestor",
       u.nome "Gestor Responsável"
  from ordem_expedicao oe
  inner join municipio m on m.id_municipio = oe.id_municipio
  left join cooperativa c on c.id_cooper = oe.id_cooper_solicitante
  left join gestor g on g.id_gestor = oe.id_gestor_resp
  left join usuario u on u.id_usuario = g.id_usuario;


-- ===================================================================
-- VIEW 10 - Entregas Detalhadas (Agricultor ou Cooperativa)
-- ===================================================================
drop view if exists vw_entregas_detalhe;

create view vw_entregas_detalhe as
select en.id_entrega "ID Entrega",
       date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
       m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF",
       en.tipo_destinatario "Tipo Destinatário",
       a.id_agricultor "ID Agricultor",
       a.nome "Nome Agricultor",
       c.id_cooper "ID Cooperativa",
       c.razao_social "Nome Cooperativa",
       case
         when en.tipo_destinatario = 'AGRICULTOR'
           then a.nome
         else c.razao_social
       end "Nome Destinatário",
       u.id_usuario "ID Usuário",
       u.nome "Agente de Distribuição",
       en.comprovante_entrega_url "Comprovante URL"
  from entrega en
  inner join municipio m on m.id_municipio = en.id_municipio
  left join agricultor a on a.id_agricultor = en.id_agricultor
  left join cooperativa c on c.id_cooper = en.id_cooper
  inner join usuario u on u.id_usuario = en.id_usuario;


-- ===================================================================
-- VIEW 11 - Resumo de Entregas por Município, Espécie e Período
--          (Visão de Transparência da Distribuição)
-- ===================================================================
drop view if exists vw_transparencia_distribuicao;

create view vw_transparencia_distribuicao as
select m.id_municipio "ID Município",
       m.nome "Município",
       m.uf "UF",
       e.id_especie "ID Espécie",
       e.nome_comum "Espécie",
       date_format(en.data_entrega, '%Y-%m') "Período (Ano-Mês)",
       sum(ie.quant_sacas) "Total de Sacas Entregues"
  from entrega en
  inner join municipio m on m.id_municipio = en.id_municipio
  inner join item_entrega ie on ie.id_entrega = en.id_entrega
  inner join lote l on l.id_lote = ie.id_lote
  inner join especie e on e.id_especie = l.id_especie
 group by m.id_municipio,
          m.nome,
          m.uf,
          e.id_especie,
          e.nome_comum,
          date_format(en.data_entrega, '%Y-%m');
