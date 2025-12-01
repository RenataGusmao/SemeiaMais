use semeia;

-- ================================================================
-- FUNÇÃO 1 - Calcula o total de sacas entregues para um Lote
-- ================================================================
drop function if exists fn_total_sacas_lote;

delimiter //
create function fn_total_sacas_lote(p_id_lote int)
returns int
deterministic
begin
  declare v_total int;
  select coalesce(sum(ie.quant_sacas), 0)
    into v_total
    from item_entrega ie
   where ie.id_lote = p_id_lote;
  return v_total;
end //
delimiter ;

-- ================================================================
-- FUNÇÃO 2 - Conta quantas entregas um Agricultor já recebeu
-- ================================================================
drop function if exists fn_qtd_entregas_agricultor;

delimiter //
create function fn_qtd_entregas_agricultor(p_id_agricultor int)
returns int
deterministic
begin
  declare v_qtd int;
  select count(*)
    into v_qtd
    from entrega en
   where en.id_agricultor = p_id_agricultor;
  return v_qtd;
end //
delimiter ;

-- ================================================================
-- FUNÇÃO 3 - Retorna o nome formatado do destinatário da Entrega
-- ================================================================
drop function if exists fn_nome_destinatario;

delimiter //
create function fn_nome_destinatario(p_id_entrega int)
returns varchar(200)
deterministic
begin
  declare v_tipo varchar(20);
  declare v_nome varchar(200);

  select tipo_destinatario
    into v_tipo
    from entrega
   where id_entrega = p_id_entrega;

  if v_tipo = 'AGRICULTOR' then
     select a.nome into v_nome
       from entrega en
       inner join agricultor a on a.id_agricultor = en.id_agricultor
      where en.id_entrega = p_id_entrega;
  else
     select c.razao_social into v_nome
       from entrega en
       inner join cooperativa c on c.id_cooper = en.id_cooper
      where en.id_entrega = p_id_entrega;
  end if;

  return v_nome;
end //
delimiter ;

-- ================================================================
-- FUNÇÃO 4 - Calcula total de sacas em um Armazém (por todos os Lotes)
-- ================================================================
drop function if exists fn_saldo_armazem;

delimiter //
create function fn_saldo_armazem(p_id_armazem int)
returns int
deterministic
begin
  declare v_saldo int;
  select coalesce(sum(saldo_sacas), 0)
    into v_saldo
    from estoque_armazem_lote
   where id_armazem = p_id_armazem;
  return v_saldo;
end //
delimiter ;

-- ================================================================
-- FUNÇÃO 5 - Retorna a descrição da Espécie pelo Lote
-- ================================================================
drop function if exists fn_especie_lote;

delimiter //
create function fn_especie_lote(p_id_lote int)
returns varchar(150)
deterministic
begin
  declare v_especie varchar(150);
  select e.nome_comum
    into v_especie
    from lote l
    inner join especie e on e.id_especie = l.id_especie
   where l.id_lote = p_id_lote;
  return v_especie;
end //
delimiter ;

-- ================================================================
-- FUNÇÃO 6 - Soma todas as sacas entregues por Cooperativa
-- ================================================================
drop function if exists fn_sacas_cooperativa;

delimiter //
create function fn_sacas_cooperativa(p_id_cooper int)
returns int
deterministic
begin
  declare v_total int;
  select coalesce(sum(ie.quant_sacas), 0)
    into v_total
    from entrega en
    inner join item_entrega ie on ie.id_entrega = en.id_entrega
   where en.id_cooper = p_id_cooper;
  return v_total;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 1 - Listar todas as entregas de um Município
-- ================================================================
drop procedure if exists sp_entregas_por_municipio;

delimiter //
create procedure sp_entregas_por_municipio(in p_id_municipio int)
begin
  select en.id_entrega "ID Entrega",
         date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
         fn_nome_destinatario(en.id_entrega) "Destinatário",
         sum(ie.quant_sacas) "Total de Sacas"
    from entrega en
    inner join item_entrega ie on ie.id_entrega = en.id_entrega
   where en.id_municipio = p_id_municipio
   group by en.id_entrega, en.data_entrega;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 2 - Inserir uma nova Movimentação de Estoque
-- ================================================================
drop procedure if exists sp_registrar_movimentacao;

delimiter //
create procedure sp_registrar_movimentacao(
  in p_tipo varchar(20),
  in p_id_usuario int,
  in p_id_lote int,
  in p_id_armazem_origem int,
  in p_id_armazem_destino int,
  in p_quant_sacas int
)
begin
  insert into movimentacao_esto
         (tipo, id_usuario, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, data_mov)
  values (p_tipo, p_id_usuario, p_id_lote, p_id_armazem_origem, p_id_armazem_destino, p_quant_sacas, now());
end //
delimiter ;

-- ================================================================
-- PROCEDURE 3 - Buscar Detalhes de Lote
-- ================================================================
drop procedure if exists sp_detalhes_lote;

delimiter //
create procedure sp_detalhes_lote(in p_id_lote int)
begin
  select l.id_lote "ID Lote",
         l.numero_lote "Número do Lote",
         fn_especie_lote(l.id_lote) "Espécie",
         f.razao_social "Fornecedor",
         date_format(l.validade, '%d/%m/%Y') "Validade",
         l.qtd_sacas "Sacas Originais",
         fn_total_sacas_lote(l.id_lote) "Sacas Entregues"
    from lote l
    inner join fornecedor f on f.id_fornecedor = l.id_fornecedor
   where l.id_lote = p_id_lote;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 4 - Relatório de Entregas por Usuário
-- ================================================================
drop procedure if exists sp_entregas_por_usuario;

delimiter //
create procedure sp_entregas_por_usuario(in p_id_usuario int)
begin
  select en.id_entrega "ID Entrega",
         date_format(en.data_entrega, '%d/%m/%Y') "Data da Entrega",
         fn_nome_destinatario(en.id_entrega) "Destinatário",
         sum(ie.quant_sacas) "Total de Sacas"
    from entrega en
    inner join item_entrega ie on ie.id_entrega = en.id_entrega
   where en.id_usuario = p_id_usuario
   group by en.id_entrega, en.data_entrega;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 5 - Relatório de Estoque por Armazém
-- ================================================================
drop procedure if exists sp_saldo_armazem;

delimiter //
create procedure sp_saldo_armazem(in p_id_armazem int)
begin
  select a.nome_armazem "Armazém",
         fn_saldo_armazem(a.id_armazem) "Saldo Total de Sacas"
    from armazem a
   where a.id_armazem = p_id_armazem;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 6 - Inserir novo Agricultor
-- ================================================================
drop procedure if exists sp_inserir_agricultor;

delimiter //
create procedure sp_inserir_agricultor(
  in p_nome varchar(150),
  in p_cpf varchar(14),
  in p_email varchar(150),
  in p_id_municipio int
)
begin
  insert into agricultor(nome, cpf, email, id_municipio)
  values (p_nome, p_cpf, p_email, p_id_municipio);
end //
delimiter ;

-- ================================================================
-- PROCEDURE 7 - Entregas por Cooperativa
-- ================================================================
drop procedure if exists sp_entregas_cooperativa;

delimiter //
create procedure sp_entregas_cooperativa(in p_id_cooper int)
begin
  select en.id_entrega "ID Entrega",
         date_format(en.data_entrega, '%d/%m/%Y') "Data",
         sum(ie.quant_sacas) "Total Sacas",
         fn_sacas_cooperativa(p_id_cooper) "Sacas Totais Cooperativa"
    from entrega en
    inner join item_entrega ie on ie.id_entrega = en.id_entrega
   where en.id_cooper = p_id_cooper
   group by en.id_entrega, en.data_entrega;
end //
delimiter ;

-- ================================================================
-- PROCEDURE 8 - Histórico de Movimentações de um Lote
-- ================================================================
drop procedure if exists sp_historico_lote;

delimiter //
create procedure sp_historico_lote(in p_id_lote int)
begin
  select me.id_mov "ID Movimentação",
         me.tipo "Tipo Movimento",
         date_format(me.data_mov, '%d/%m/%Y %H:%i') "Data/Hora",
         ao.nome_armazem "Origem",
         ad.nome_armazem "Destino",
         me.quant_sacas "Quantidade",
         u.nome "Usuário Responsável"
    from movimentacao_esto me
    inner join usuario u on u.id_usuario = me.id_usuario
    left join armazem ao on ao.id_armazem = me.id_armazem_origem
    left join armazem ad on ad.id_armazem = me.id_armazem_destino
   where me.id_lote = p_id_lote;
end //
delimiter ;


use semeia;
-- ================================================================
-- TESTES DE EXECUÇÃO
-- ================================================================

select fn_total_sacas_lote(1);
select fn_qtd_entregas_agricultor(1);
select fn_nome_destinatario(1);
select fn_saldo_armazem(1);
select fn_especie_lote(1);
select fn_sacas_cooperativa(1);

call sp_entregas_por_municipio(1);
call sp_registrar_movimentacao('SAIDA', 1, 2, 1, 2, 15);
call sp_detalhes_lote(1);
call sp_entregas_por_usuario(1);
call sp_saldo_armazem(1);
call sp_inserir_agricultor('Maria Silva', '123.456.789-00', 'maria@email.com', 2);
call sp_entregas_cooperativa(1);
call sp_historico_lote(1);


