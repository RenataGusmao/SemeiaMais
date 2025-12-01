-- 1) Relatório de Usuários e seus Papéis de Acesso
--    Lista todos os usuários do sistema, com seus papéis vinculados (Gestor, Operador de Armazém, etc.).
select u.id_usuario "ID Usuário",
       u.nome "Usuário",
       u.email_login "E-mail de Login",
       group_concat(p.nome separator ', ') "Papéis Vinculados"
  from usuario u
  left join usuario_papel up on up.id_usuario = u.id_usuario
  left join papel p on p.id_papel = up.id_papel
 group by u.id_usuario, u.nome, u.email_login
 order by u.nome;


-- 2) Relatório de Gestores Cadastrados
--    Traz apenas os usuários que são gestores, com área de responsabilidade e cargo.
select g.id_gestor "ID Gestor",
       u.nome "Gestor",
       u.email_login "E-mail",
       g.area_respons "Área de Responsabilidade",
       g.cargo "Cargo"
  from gestor g
  inner join usuario u on u.id_usuario = g.id_usuario
 order by u.nome;


-- 3) Agricultores por Município
--    Lista os agricultores com CPF, e-mail e município/UF onde atuam.
select a.id_agricultor "ID Agricultor",
       a.nome "Agricultor",
       a.cpf "CPF",
       a.email "E-mail",
       m.nome "Município",
       m.uf "UF"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio
 order by m.nome, a.nome;


-- 4) Cooperativas por Município
--    Exibe cooperativas com CNPJ, e-mail e localização.
select c.id_cooper "ID Cooperativa",
       c.razao_social "Razão Social",
       c.cnpj_cooper "CNPJ",
       c.email "E-mail",
       m.nome "Município",
       m.uf "UF"
  from cooperativa c
  inner join municipio m on m.id_municipio = c.id_municipio
 order by m.nome, c.razao_social;


-- 5) Fornecedores e seus Endereços
--    Relatório de fornecedores com CNPJ, e-mail e endereço formatado.
select f.id_fornecedor "ID Fornecedor",
       f.razao_social "Fornecedor",
       f.cnpj "CNPJ",
       f.email "E-mail",
       concat(ef.logradouro, ', ', ifnull(ef.numero,'SN'), ' - ', ifnull(ef.bairro,'--')) "Endereço",
       concat(ef.cidade, ' / ', ef.uf) "Cidade/UF"
  from fornecedor f
  left join endereco_fornecedor ef on ef.id_end_fornecedor = f.id_end_fornecedor
 order by f.razao_social;


-- 6) Armazéns e Localização
--    Lista todos os armazéns com município e endereço resumido.
select a.id_armazem "ID Armazém",
       a.nome_armazem "Armazém",
       m.nome "Município",
       m.uf "UF",
       concat(ea.logradouro, ', ', ifnull(ea.numero,'SN')) "Endereço"
  from armazem a
  inner join municipio m on m.id_municipio = a.id_municipio
  left join endereco_armazem ea on ea.id_end_armazem = a.id_end_armazem
 order by m.nome, a.nome_armazem;


-- 7) Lotes com Espécie e Fornecedor
--    Relatório de lotes, mostrando espécie, fornecedor e validade.
select l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       ifnull(e.nome_cientifico, '--') "Nome Científico",
       f.razao_social "Fornecedor",
       date_format(l.validade, '%d/%m/%Y') "Validade",
       l.qtd_sacas "Quantidade de Sacas"
  from lote l
  inner join especie e on e.id_especie = l.id_especie
  inner join fornecedor f on f.id_fornecedor = l.id_fornecedor
 order by e.nome_comum, l.numero_lote;


-- 8) Estoque por Armazém e Lote
--    Mostra o saldo atual de sacas por armazém e lote, com espécie e município.
select a.nome_armazem "Armazém",
       m.nome "Município",
       m.uf "UF",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       e.nome_cientifico "Nome Científico",
       eal.saldo_sacas "Saldo de Sacas"
  from estoque_armazem_lote eal
  inner join armazem a on a.id_armazem = eal.id_armazem
  inner join municipio m on m.id_municipio = a.id_municipio
  inner join lote l on l.id_lote = eal.id_lote
  inner join especie e on e.id_especie = l.id_especie
 order by a.nome_armazem, e.nome_comum, l.numero_lote;


-- 9) Movimentações de Estoque Detalhadas
--    Lista as movimentações (ENTRADA, SAÍDA, TRANSFERÊNCIA) com lotes, armazéns e usuário responsável.
select me.id_mov "ID Movimentação",
       me.tipo "Tipo",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       ao.nome_armazem "Armazém Origem",
       ad.nome_armazem "Armazém Destino",
       me.quant_sacas "Quantidade de Sacas",
       date_format(me.data_mov, '%d/%m/%Y %H:%i') "Data/Hora",
       u.nome "Usuário Responsável"
  from movimentacao_esto me
  inner join lote l on l.id_lote = me.id_lote
  inner join especie e on e.id_especie = l.id_especie
  left join armazem ao on ao.id_armazem = me.id_armazem_origem
  left join armazem ad on ad.id_armazem = me.id_armazem_destino
  inner join usuario u on u.id_usuario = me.id_usuario
 order by me.data_mov desc;


-- 10) Ordens de Expedição por Município
--     Relatório de ordens com município, data prevista, status, cooperativa solicitante e gestor responsável.
select oe.id_expedicao "ID Expedição",
       m.nome "Município",
       m.uf "UF",
       date_format(oe.data_prevista, '%d/%m/%Y') "Data Prevista",
       oe.status "Status",
       c.razao_social "Cooperativa Solicitante",
       u.nome "Gestor Responsável"
  from ordem_expedicao oe
  inner join municipio m on m.id_municipio = oe.id_municipio
  left join cooperativa c on c.id_cooper = oe.id_cooper_solicitante
  left join gestor g on g.id_gestor = oe.id_gestor_resp
  left join usuario u on u.id_usuario = g.id_usuario
 order by m.nome, oe.data_prevista;


-- 11) Itens de Expedição (Lotes enviados em cada Ordem)
--     Mostra, para cada ordem, os lotes e a quantidade de sacas expedidas.
select oe.id_expedicao "ID Expedição",
       date_format(oe.data_prevista, '%d/%m/%Y') "Data Prevista",
       m.nome "Município Destino",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       ie.quant_sacas "Quantidade de Sacas"
  from item_expedicao ie
  inner join ordem_expedicao oe on oe.id_expedicao = ie.id_expedicao
  inner join municipio m on m.id_municipio = oe.id_municipio
  inner join lote l on l.id_lote = ie.id_lote
  inner join especie e on e.id_especie = l.id_especie
 order by oe.id_expedicao, e.nome_comum;


-- 12) Entregas Detalhadas (Agricultor ou Cooperativa)
--     Traz todas as entregas com identificação do tipo de destinatário e município.
select en.id_entrega "ID Entrega",
       date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
       m.nome "Município",
       m.uf "UF",
       en.tipo_destinatario "Tipo Destinatário",
       case 
         when en.tipo_destinatario = 'AGRICULTOR' 
           then a.nome
         else c.razao_social
       end "Nome Destinatário",
       u.nome "Agente de Distribuição"
  from entrega en
  inner join municipio m on m.id_municipio = en.id_municipio
  left join agricultor a on a.id_agricultor = en.id_agricultor
  left join cooperativa c on c.id_cooper = en.id_cooper
  inner join usuario u on u.id_usuario = en.id_usuario
 order by en.data_entrega desc, m.nome;


-- 13) Itens de Entrega (Sementes entregues por lote)
--     Mostra, para cada entrega, os lotes e a quantidade de sacas entregues.
select en.id_entrega "ID Entrega",
       date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
       m.nome "Município",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       ie.quant_sacas "Quantidade de Sacas"
  from item_entrega ie
  inner join entrega en on en.id_entrega = ie.id_entrega
  inner join municipio m on m.id_municipio = en.id_municipio
  inner join lote l on l.id_lote = ie.id_lote
  inner join especie e on e.id_especie = l.id_especie
 order by en.id_entrega, e.nome_comum;


-- 14) Entregas Vinculadas a Ordens de Expedição
--     Relaciona cada entrega com a ordem de expedição correspondente (via tabela entrega_ordem).
select en.id_entrega "ID Entrega",
       date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
       oe.id_expedicao "ID Expedição",
       date_format(oe.data_prevista, '%d/%m/%Y') "Data Prevista",
       m.nome "Município",
       oe.status "Status Expedição"
  from entrega_ordem eo
  inner join entrega en on en.id_entrega = eo.id_entrega
  inner join ordem_expedicao oe on oe.id_expedicao = eo.id_expedicao
  inner join municipio m on m.id_municipio = oe.id_municipio
 order by en.id_entrega, oe.id_expedicao;


-- 15) Total de Sacas Expedidas por Município
--     Soma a quantidade de sacas nas ordens de expedição, agrupando por município.
select m.nome "Município",
       m.uf "UF",
       sum(ie.quant_sacas) "Total de Sacas Expedidas"
  from item_expedicao ie
  inner join ordem_expedicao oe on oe.id_expedicao = ie.id_expedicao
  inner join municipio m on m.id_municipio = oe.id_municipio
 group by m.id_municipio, m.nome, m.uf
 order by sum(ie.quant_sacas) desc;


-- 16) Total de Sacas Entregues por Município e Espécie
--     Agrega dados de entrega por município e espécie (similar à view de transparência).
select m.nome "Município",
       m.uf "UF",
       e.nome_comum "Espécie",
       date_format(en.data_entrega, '%Y-%m') "Período (Ano-Mês)",
       sum(ie.quant_sacas) "Total de Sacas Entregues"
  from entrega en
  inner join municipio m on m.id_municipio = en.id_municipio
  inner join item_entrega ie on ie.id_entrega = en.id_entrega
  inner join lote l on l.id_lote = ie.id_lote
  inner join especie e on e.id_especie = l.id_especie
 group by m.id_municipio, m.nome, m.uf, e.id_especie, e.nome_comum, date_format(en.data_entrega, '%Y-%m')
 order by m.nome, e.nome_comum, date_format(en.data_entrega, '%Y-%m');


-- 17) Município com Maior Volume Entregue
--     Encontra o município que mais recebeu sacas, usando subselect (tabela derivada) + order by/limit.

select t.municipio "Município",
       t.uf "UF",
       t.total_sacas "Total de Sacas Entregues"
  from (
        select m.nome "municipio",
               m.uf "uf",
               sum(ie.quant_sacas) "total_sacas"
          from entrega en
          inner join municipio m on m.id_municipio = en.id_municipio
          inner join item_entrega ie on ie.id_entrega = en.id_entrega
         group by m.id_municipio, m.nome, m.uf
       ) t
 order by t.total_sacas desc
 limit 1;



-- 18) Saldo Total por Lote (todos os Armazéns)
--     Mostra o saldo consolidado por lote somando todos os armazéns.
select l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       sum(eal.saldo_sacas) "Saldo Total de Sacas"
  from lote l
  inner join especie e on e.id_especie = l.id_especie
  inner join estoque_armazem_lote eal on eal.id_lote = l.id_lote
 group by l.id_lote, l.numero_lote, e.nome_comum
 order by e.nome_comum, l.numero_lote;


-- 19) Lotes com Sacas Remanescentes (qtd_sacas - já entregues)
--     Calcula quanto ainda resta de cada lote considerando as entregas já realizadas.
select l.id_lote "ID Lote",
       l.numero_lote "Número do Lote",
       e.nome_comum "Espécie",
       l.qtd_sacas "Quantidade Original",
       ifnull(entregues.total_entregue, 0) "Total Entregue",
       (l.qtd_sacas - ifnull(entregues.total_entregue, 0)) "Saldo Estimado"
  from lote l
  inner join especie e on e.id_especie = l.id_especie
  left join (
              select ie.id_lote,
                     sum(ie.quant_sacas) "total_entregue"
                from item_entrega ie
               group by ie.id_lote
            ) entregues on entregues.id_lote = l.id_lote
 order by e.nome_comum, l.numero_lote;


-- 20) Usuários com Quantidade de Movimentações de Estoque
--     Mostra quantas movimentações de estoque cada usuário registrou.
select u.id_usuario "ID Usuário",
       u.nome "Usuário",
       u.email_login "E-mail",
       count(me.id_mov) "Quantidade de Movimentações"
  from usuario u
  left join movimentacao_esto me on me.id_usuario = u.id_usuario
 group by u.id_usuario, u.nome, u.email_login
 order by count(me.id_mov) desc, u.nome;


-- 21) Entregas por Agricultor (Resumo)
--     Para cada agricultor, quantas entregas ele recebeu e o total de sacas.
select a.id_agricultor "ID Agricultor",
       a.nome "Agricultor",
       m.nome "Município",
       count(distinct en.id_entrega) "Quantidade de Entregas",
       ifnull(sum(ie.quant_sacas), 0) "Total de Sacas Recebidas"
  from agricultor a
  inner join municipio m on m.id_municipio = a.id_municipio
  left join entrega en on en.id_agricultor = a.id_agricultor
  left join item_entrega ie on ie.id_entrega = en.id_entrega
 group by a.id_agricultor, a.nome, m.nome
 order by a.nome;



