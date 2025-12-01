use semeia;

-- =====================================================================
-- 1) LIMPEZA PRÉVIA (EVITA ERRO SE JÁ EXISTIREM TRIGGERS)
-- =====================================================================
drop trigger if exists trg_bfr_insert_movesto;
drop trigger if exists trg_aft_insert_movesto;
drop trigger if exists trg_aft_delete_movesto;

drop trigger if exists trg_bfr_insert_estoque;
drop trigger if exists trg_bfr_update_estoque;
drop trigger if exists trg_bfr_delete_estoque;

drop trigger if exists trg_bfr_insert_entrega_xor;
drop trigger if exists trg_bfr_update_entrega_xor;
drop trigger if exists trg_bfr_delete_entrega;

drop trigger if exists trg_bfr_insert_item_entrega;
drop trigger if exists trg_bfr_update_item_entrega;
drop trigger if exists trg_bfr_delete_item_entrega;

-- =====================================================================
-- 2) TRIGGERS DA TABELA movimentacao_esto
--     - BEFORE INSERT: valida regras de negócio + saldo
--     - AFTER INSERT : atualiza estoque_armazem_lote
--     - AFTER DELETE : reverte impacto no estoque
-- =====================================================================

delimiter $$

-- 2.1) BEFORE INSERT movimentacao_esto
create trigger trg_bfr_insert_movesto
before insert on movimentacao_esto
for each row
begin
	declare v_saldo int default 0;

    -- Quantidade deve ser positiva
	if new.quant_sacas <= 0 then
		signal sqlstate '45000'
			set message_text = 'Quantidade de sacas deve ser maior que zero.';
	end if;

    -- Regras por tipo de movimentação
	if new.tipo = 'ENTRADA' then
		if new.id_armazem_destino is null or new.id_armazem_origem is not null then
			signal sqlstate '45000'
				set message_text = 'Movimentação ENTRADA deve ter apenas armazém de destino informado.';
		end if;
	elseif new.tipo = 'SAIDA' then
		if new.id_armazem_origem is null or new.id_armazem_destino is not null then
			signal sqlstate '45000'
				set message_text = 'Movimentação SAIDA deve ter apenas armazém de origem informado.';
		end if;

        -- verifica saldo para saída
        select coalesce(max(saldo_sacas), 0) into v_saldo
			from estoque_armazem_lote
			where id_armazem = new.id_armazem_origem
			  and id_lote = new.id_lote;

		if v_saldo < new.quant_sacas then
			signal sqlstate '45000'
				set message_text = 'Saldo insuficiente para movimentação de SAIDA.';
		end if;

	elseif new.tipo = 'TRANSFERENCIA' then
		if new.id_armazem_origem is null
		   or new.id_armazem_destino is null
		   or new.id_armazem_origem = new.id_armazem_destino then
			signal sqlstate '45000'
				set message_text = 'TRANSFERENCIA deve ter armazém de origem e destino distintos e preenchidos.';
		end if;

        -- verifica saldo para transferencia
        select coalesce(max(saldo_sacas), 0) into v_saldo
			from estoque_armazem_lote
			where id_armazem = new.id_armazem_origem
			  and id_lote = new.id_lote;

		if v_saldo < new.quant_sacas then
			signal sqlstate '45000'
				set message_text = 'Saldo insuficiente para movimentação de TRANSFERENCIA.';
		end if;
	end if;
end $$
 
-- 2.2) AFTER INSERT movimentacao_esto
delimiter $$
create trigger trg_aft_insert_movesto
after insert on movimentacao_esto
for each row
begin
	-- ENTRADA: soma no destino
	if new.tipo = 'ENTRADA' then
		insert into estoque_armazem_lote (id_armazem, id_lote, saldo_sacas)
		values (new.id_armazem_destino, new.id_lote, new.quant_sacas)
		on duplicate key update saldo_sacas = saldo_sacas + new.quant_sacas;

    -- SAIDA: subtrai do origem
	elseif new.tipo = 'SAIDA' then
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas - new.quant_sacas
			where id_armazem = new.id_armazem_origem
			  and id_lote = new.id_lote;

    -- TRANSFERENCIA: subtrai origem e soma destino
	elseif new.tipo = 'TRANSFERENCIA' then
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas - new.quant_sacas
			where id_armazem = new.id_armazem_origem
			  and id_lote = new.id_lote;

		insert into estoque_armazem_lote (id_armazem, id_lote, saldo_sacas)
		values (new.id_armazem_destino, new.id_lote, new.quant_sacas)
		on duplicate key update saldo_sacas = saldo_sacas + new.quant_sacas;
	end if;
end $$

-- 2.3) AFTER DELETE movimentacao_esto (reverte impacto no estoque)
delimiter $$
create trigger trg_aft_delete_movesto
after delete on movimentacao_esto
for each row
begin
	-- Reverte ENTRADA: tira do destino
	if old.tipo = 'ENTRADA' then
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas - old.quant_sacas
			where id_armazem = old.id_armazem_destino
			  and id_lote = old.id_lote;

    -- Reverte SAIDA: devolve para origem
	elseif old.tipo = 'SAIDA' then
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas + old.quant_sacas
			where id_armazem = old.id_armazem_origem
			  and id_lote = old.id_lote;

    -- Reverte TRANSFERENCIA
	elseif old.tipo = 'TRANSFERENCIA' then
		-- devolve para origem
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas + old.quant_sacas
			where id_armazem = old.id_armazem_origem
			  and id_lote = old.id_lote;

        -- tira do destino
		update estoque_armazem_lote
			set saldo_sacas = saldo_sacas - old.quant_sacas
			where id_armazem = old.id_armazem_destino
			  and id_lote = old.id_lote;
	end if;
end $$

-- =====================================================================
-- 3) TRIGGERS DA TABELA estoque_armazem_lote
--     - BEFORE INSERT: não permite saldo negativo
--     - BEFORE UPDATE: não permite saldo negativo
--     - BEFORE DELETE: impede excluir estoque com saldo > 0
-- =====================================================================

-- 3.1) BEFORE INSERT estoque_armazem_lote

delimiter $$
create trigger trg_bfr_insert_estoque
before insert on estoque_armazem_lote
for each row
begin
	if new.saldo_sacas < 0 then
		signal sqlstate '45000'
			set message_text = 'Saldo de estoque não pode ser negativo (INSERT).';
	end if;
end $$

-- 3.2) BEFORE UPDATE estoque_armazem_lote
delimiter $$
create trigger trg_bfr_update_estoque
before update on estoque_armazem_lote
for each row
begin
	if new.saldo_sacas < 0 then
		signal sqlstate '45000'
			set message_text = 'Saldo de estoque não pode ser negativo (UPDATE).';
	end if;
end $$

-- 3.3) BEFORE DELETE estoque_armazem_lote
delimiter $$
create trigger trg_bfr_delete_estoque
before delete on estoque_armazem_lote
for each row
begin
	if old.saldo_sacas <> 0 then
		signal sqlstate '45000'
			set message_text = 'Não é permitido excluir registro de estoque com saldo diferente de zero.';
	end if;
end $$

-- =====================================================================
-- 4) TRIGGERS DA TABELA entrega
--     - BEFORE INSERT: regra XOR (AGRICULTOR x COOPERATIVA)
--     - BEFORE UPDATE: mantém regra XOR
--     - BEFORE DELETE: impede excluir entrega com comprovante
-- =====================================================================

-- 4.1) BEFORE INSERT entrega (regra XOR)
delimiter $$
create trigger trg_bfr_insert_entrega_xor
before insert on entrega
for each row
begin
	if new.tipo_destinatario = 'AGRICULTOR' then
		if new.id_agricultor is null or new.id_cooper is not null then
			signal sqlstate '45000'
				set message_text = 'Entrega AGRICULTOR deve ter id_agricultor preenchido e id_cooper nulo.';
		end if;
	elseif new.tipo_destinatario = 'COOPERATIVA' then
		if new.id_cooper is null or new.id_agricultor is not null then
			signal sqlstate '45000'
				set message_text = 'Entrega COOPERATIVA deve ter id_cooper preenchido e id_agricultor nulo.';
		end if;
	end if;
end $$

-- 4.2) BEFORE UPDATE entrega (regra XOR também em alterações)
delimiter $$
create trigger trg_bfr_update_entrega_xor
before update on entrega
for each row
begin
	if new.tipo_destinatario = 'AGRICULTOR' then
		if new.id_agricultor is null or new.id_cooper is not null then
			signal sqlstate '45000'
				set message_text = 'Atualização inválida: AGRICULTOR deve ter id_agricultor preenchido e id_cooper nulo.';
		end if;
	elseif new.tipo_destinatario = 'COOPERATIVA' then
		if new.id_cooper is null or new.id_agricultor is not null then
			signal sqlstate '45000'
				set message_text = 'Atualização inválida: COOPERATIVA deve ter id_cooper preenchido e id_agricultor nulo.';
		end if;
	end if;
end $$

-- 4.3) BEFORE DELETE entrega (não permite excluir se tiver comprovante)
delimiter $$
create trigger trg_bfr_delete_entrega
before delete on entrega
for each row
begin
	if old.comprovante_entrega_url is not null then
		signal sqlstate '45000'
			set message_text = 'Não é permitido excluir entrega que já possui comprovante registrado.';
	end if;
end $$

-- =====================================================================
-- 5) TRIGGERS DA TABELA item_entrega
--     - BEFORE INSERT: quant_sacas > 0
--     - BEFORE UPDATE: quant_sacas > 0
--     - BEFORE DELETE: bloqueia remoção se entrega tiver comprovante
-- =====================================================================

-- 5.1) BEFORE INSERT item_entrega
delimiter $$
create trigger trg_bfr_insert_item_entrega
before insert on item_entrega
for each row
begin
	if new.quant_sacas <= 0 then
		signal sqlstate '45000'
			set message_text = 'Quantidade de sacas do item de entrega deve ser maior que zero (INSERT).';
	end if;
end $$

-- 5.2) BEFORE UPDATE item_entrega
delimiter $$
create trigger trg_bfr_update_item_entrega
before update on item_entrega
for each row
begin
	if new.quant_sacas <= 0 then
		signal sqlstate '45000'
			set message_text = 'Quantidade de sacas do item de entrega deve ser maior que zero (UPDATE).';
	end if;
end $$

-- 5.3) BEFORE DELETE item_entrega
delimiter $$
create trigger trg_bfr_delete_item_entrega
before delete on item_entrega
for each row
begin
	declare v_comp varchar(255);

	select comprovante_entrega_url
	  into v_comp
	  from entrega
	 where id_entrega = old.id_entrega;

	if v_comp is not null then
		signal sqlstate '45000'
			set message_text = 'Não é permitido remover itens de entrega que já possuem comprovante.';
	end if;
end $$

delimiter ;

-- =====================================================================
-- 6) SCRIPT DE TESTE DAS TRIGGERS
-- =====================================================================

-- 6.1) Variáveis auxiliares
set @id_usuario_bruno := (select id_usuario from usuario where email_login = 'bruno.operador@semeia.local' limit 1);
set @id_usuario_carla := (select id_usuario from usuario where email_login = 'carla.distrib@semeia.local' limit 1);
set @id_armazem_recife := (select id_armazem from armazem where nome_armazem = 'Armazém Central Recife' limit 1);
set @id_lote_teste := (select id_lote from lote limit 1);
Select a.id_municipio Into @id_mun_agri from agricultor a join municipio m on m.id_municipio = a.id_municipio limit 1;
set @id_agricultor_teste := (select id_agricultor from agricultor limit 1);

-- -------------------------------------------------
-- TESTE 1: movimentacao_esto + estoque_armazem_lote
-- -------------------------------------------------

-- 1.1) ENTRADA válida (deve somar no estoque)
insert into movimentacao_esto
(tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
values
('ENTRADA', @id_lote_teste, null, @id_armazem_recife, 10, @id_usuario_bruno);

-- 1.2) SAIDA válida (deve subtrair do estoque)
insert into movimentacao_esto
(tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
values
('SAIDA', @id_lote_teste, @id_armazem_recife, null, 3, @id_usuario_bruno);

-- 1.3) SAIDA inválida (origem null) → deve disparar erro

insert into movimentacao_esto (tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
values ('SAIDA', @id_lote_teste, null, @id_armazem_recife, 5, @id_usuario_bruno);

-- 1.4) Verificar estoque após as movimentações
select eal.id_armazem "Armazém",
       eal.id_lote "Lote",
       eal.saldo_sacas "Saldo em Sacas"
  from estoque_armazem_lote eal
 where eal.id_armazem = @id_armazem_recife
   and eal.id_lote = @id_lote_teste;

-- 1.5) Teste BEFORE DELETE estoque_armazem_lote (tenta excluir com saldo > 0 → erro)
delete from estoque_armazem_lote
where id_armazem = @id_armazem_recife
and id_lote = @id_lote_teste;

-- -------------------------------------------------
-- TESTE 2: entrega (XOR) + item_entrega
-- -------------------------------------------------

-- 2.1) Entrega AGRICULTOR válida
insert into entrega
(data_entrega, id_municipio, tipo_destinatario, id_agricultor, id_cooper, comprovante_entrega_url, id_usuario)
values
(curdate(), @id_mun_agri, 'AGRICULTOR', @id_agricultor_teste, null, null, @id_usuario_carla);

set @id_entrega_teste := last_insert_id();

-- 2.2) Entrega AGRICULTOR inválida (com cooperativa junto) → erro
insert into entrega (data_entrega, id_municipio, tipo_destinatario, id_agricultor, id_cooper, comprovante_entrega_url, id_usuario)
values (curdate(), @id_mun_agri, 'AGRICULTOR', @id_agricultor_teste, 1, null, @id_usuario_carla);

-- 2.3) Item de entrega válido
insert into item_entrega (id_entrega, id_lote, quant_sacas)
values (@id_entrega_teste, @id_lote_teste, 5);

-- 2.4) Item de entrega inválido (quantidade <= 0) → erro
insert into item_entrega (id_entrega, id_lote, quant_sacas)
values (@id_entrega_teste, @id_lote_teste, 0);

-- 2.5) Marca comprovante na entrega
update entrega
   set comprovante_entrega_url = 'url/comprovante-teste'
 where id_entrega = @id_entrega_teste;

-- 2.6) Tenta remover item da entrega com comprovante → deve dar erro
delete from item_entrega
where id_entrega = @id_entrega_teste
and id_lote = @id_lote_teste
limit 1;

-- 2.7) Tenta excluir a entrega com comprovante → deve dar erro
delete from entrega
where id_entrega = @id_entrega_teste;

-- 2.8) Consulta final para ver entregas e itens criados
select e.id_entrega "Entrega",
       e.data_entrega "Data",
       e.tipo_destinatario "Tipo Destinatário",
       e.id_agricultor "ID Agricultor",
       e.id_cooper "ID Cooperativa",
       e.comprovante_entrega_url "Comprovante"
  from entrega e
 where e.id_entrega = @id_entrega_teste;

select ie.id_item_entrega "Item Entrega",
       ie.id_entrega "Entrega",
       ie.id_lote "Lote",
       ie.quant_sacas "Quantidade de Sacas"
  from item_entrega ie
 where ie.id_entrega = @id_entrega_teste;
