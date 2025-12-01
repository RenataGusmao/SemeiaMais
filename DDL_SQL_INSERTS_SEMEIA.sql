USE semeia;

START TRANSACTION;

-- ====================================================================
-- SEÇÃO 1: DADOS INICIAIS (BASE DO PROJETO)
-- ====================================================================

-- 1) Municípios (Total 20)
INSERT INTO municipio (nome, uf) VALUES ('Recife','PE') ON DUPLICATE KEY UPDATE uf=VALUES(uf);
INSERT INTO municipio (nome, uf) VALUES ('Caruaru','PE') ON DUPLICATE KEY UPDATE uf=VALUES(uf);
INSERT INTO municipio (nome, uf) VALUES ('Garanhuns','PE') ON DUPLICATE KEY UPDATE uf=VALUES(uf);
INSERT INTO municipio (nome, uf) VALUES ('Petrolina','PE') ON DUPLICATE KEY UPDATE uf=VALUES(uf);

-- EXPANSÃO MUNICÍPIOS (16 NOVOS)
INSERT INTO municipio (nome, uf) VALUES
('Serra Talhada','PE'),
('Araripina','PE'),
('Cabo de Santo Agostinho','PE'),
('Olinda','PE'),
('Jaboatão dos Guararapes','PE'),
('Pesqueira','PE'),
('Afogados da Ingazeira','PE'),
('Belo Jardim','PE'),
('Pombos','PE'),
('Palmares','PE'),
('Goiana','PE'),
('São Lourenço da Mata','PE'),
('Limoeiro','PE'),
('Igarassu','PE'),
('Moreno','PE'),
('Vicência','PE')
ON DUPLICATE KEY UPDATE uf=VALUES(uf);

-- 2) Usuários (Total 20)
INSERT INTO usuario (nome, email_login, senha_hash, ativo) VALUES 
('Ana Gestora','ana.gestora@semeia.local','$2y$10$hashAna',1),
('Bruno Operador','bruno.operador@semeia.local','$2y$10$hashBru',1),
('Carla Distribuição','carla.distrib@semeia.local','$2y$10$hashCar',1);

-- EXPANSÃO USUÁRIOS (17 NOVOS)
INSERT INTO usuario (nome, email_login, senha_hash, ativo) VALUES 
('Carlos Gestor II','carlos.gestor2@semeia.local','$2y$10$hashCar2',1),
('Daniel Gestor III','daniel.gestor3@semeia.local','$2y$10$hashDan',1),
('Erica Gestora IV','erica.gestora4@semeia.local','$2y$10$hashEri',1),
('Felipe Armazem','felipe.armazem@semeia.local','$2y$10$hashFel',1),
('Giovana Armazem','giovana.armazem@semeia.local','$2y$10$hashGio',1),
('Helio Armazem','helio.armazem@semeia.local','$2y$10$hashHel',1),
('Igor Armazem','igor.armazem@semeia.local','$2y$10$hashIgo',1),
('Julia Armazem','julia.armazem@semeia.local','$2y$10$hashJul',1),
('Kleber Distrib','kleber.distrib@semeia.local','$2y$10$hashKle',1),
('Laura Distrib','laura.distrib@semeia.local','$2y$10$hashLau',1),
('Marcelo Distrib','marcelo.distrib@semeia.local','$2y$10$hashMar',1),
('Nadia Distrib','nadia.distrib@semeia.local','$2y$10$hashNad',1),
('Osvaldo Distrib','osvaldo.distrib@semeia.local','$2y$10$hashOsv',1),
('Paty Distrib','paty.distrib@semeia.local','$2y$10$hashPat',1),
('Roberto Gestor V','roberto.gestor5@semeia.local','$2y$10$hashRob',1),
('Silvia Operador VI','silvia.operador6@semeia.local','$2y$10$hashSil',1);

-- 3) Papéis + vínculos (Total Usuário_Papel: 20+)
INSERT INTO papel (nome) VALUES ('GESTOR'), ('OPERADOR_ARMAZEM'), ('AGENTE_DISTRIBUICAO'), ('CIDADAO')
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT IGNORE INTO usuario_papel (id_usuario, id_papel)
SELECT u.id_usuario, p.id_papel
FROM usuario u JOIN papel p ON p.nome = 
  CASE 
    WHEN u.email_login LIKE '%gestor%' THEN 'GESTOR'
    WHEN u.email_login LIKE '%operador%' THEN 'OPERADOR_ARMAZEM'
    WHEN u.email_login LIKE '%armazem%' THEN 'OPERADOR_ARMAZEM'
    WHEN u.email_login LIKE '%distrib%' THEN 'AGENTE_DISTRIBUICAO'
    ELSE 'CIDADAO'
  END
WHERE u.id_usuario > 0;


-- 4) Gestor (Total 5)
INSERT IGNORE INTO gestor (id_usuario, area_respons, cargo)
SELECT u.id_usuario, 'Logística Regional', 'Gestor Regional'
FROM usuario u
WHERE u.email_login IN ('ana.gestora@semeia.local', 'carlos.gestor2@semeia.local', 'daniel.gestor3@semeia.local', 'erica.gestora4@semeia.local', 'roberto.gestor5@semeia.local');

-- 5) Endereços (Total 20+ em cada tipo)
INSERT INTO endereco_armazem (logradouro,numero,bairro,cep,cidade,uf,complemento) VALUES
('Av. Norte','1000','Tamarineira','52000-000','Recife','PE',NULL),
('Av. Agreste','500','Centro','55290-000','Caruaru','PE',NULL),
('BR-407 Km 5','SN','Atrás da Banca','56300-000','Petrolina','PE',NULL);
-- Expansão Endereços Armazém (17 NOVOS)
INSERT INTO endereco_armazem (logradouro,numero,bairro,cep,cidade,uf,complemento)
SELECT CONCAT('Rua Armazem Teste ', id), '10', 'Testes', CONCAT('500', LPAD(id, 2, '0'), '-000'), 'Recife', 'PE', NULL
FROM (SELECT @rn := @rn + 1 AS id FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1, (SELECT @rn := 3 UNION ALL SELECT 1) t2 LIMIT 17) sub;

INSERT INTO endereco_fornecedor (logradouro,numero,bairro,cep,cidade,uf,complemento) VALUES
('BR-232 Km 12','SN','Zona Rural','55000-000','Caruaru','PE',NULL),
('Rod. PE-60','100','Industrial','55500-000','Ipojuca','PE',NULL),
('Rua das Veredas','120','Galpões','51000-000','Recife','PE',NULL);
-- Expansão Endereços Fornecedor (17 NOVOS)
INSERT INTO endereco_fornecedor (logradouro,numero,bairro,cep,cidade,uf,complemento)
SELECT CONCAT('Rua Forn Teste ', id), '20', 'Testes', CONCAT('510', LPAD(id, 2, '0'), '-000'), 'Recife', 'PE', NULL
FROM (SELECT @rn2 := @rn2 + 1 AS id FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1, (SELECT @rn2 := 3 UNION ALL SELECT 1) t2 LIMIT 17) sub;

INSERT INTO endereco_cooperativa (logradouro,numero,bairro,cep,cidade,uf,complemento) VALUES
('Rua das Sementes','200','Centro','55010-000','Caruaru','PE','Sala 3'),
('Av. Juazeiro','900','Centro','56310-000','Petrolina','PE',NULL);
-- Expansão Endereços Cooperativa (18 NOVOS)
INSERT INTO endereco_cooperativa (logradouro,numero,bairro,cep,cidade,uf,complemento)
SELECT CONCAT('Av Coop Teste ', id), '30', 'Testes', CONCAT('550', LPAD(id, 2, '0'), '-000'), 'Caruaru', 'PE', NULL
FROM (SELECT @rn3 := @rn3 + 1 AS id FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1, (SELECT @rn3 := 2 UNION ALL SELECT 1) t2 LIMIT 18) sub;

INSERT INTO endereco_agricultor (logradouro,numero,bairro,cep,cidade,uf,complemento) VALUES
('Sítio Boa Vista','SN','Zona Rural','55100-000','Caruaru','PE',NULL),
('Sítio Várzea Alegre','SN','Zona Rural','55295-000','Garanhuns','PE',NULL),
('Loteamento Mandacaru','45','João de Deus','56308-000','Petrolina','PE',NULL);
-- Expansão Endereços Agricultor (17 NOVOS)
INSERT INTO endereco_agricultor (logradouro,numero,bairro,cep,cidade,uf,complemento)
SELECT CONCAT('Sitio Agri Teste ', id), 'SN', 'Zona Rural', CONCAT('551', LPAD(id, 2, '0'), '-000'), 'Caruaru', 'PE', NULL
FROM (SELECT @rn4 := @rn4 + 1 AS id FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1, (SELECT @rn4 := 3 UNION ALL SELECT 1) t2 LIMIT 17) sub;


-- 6) Armazéns (Total 20)
INSERT IGNORE INTO armazem (nome_armazem, id_municipio, id_end_armazem)
SELECT 'Armazém Central Recife', m.id_municipio, ea.id_end_armazem
FROM municipio m JOIN endereco_armazem ea ON ea.cidade='Recife' AND ea.logradouro='Av. Norte' WHERE m.nome='Recife' AND m.uf='PE';

INSERT IGNORE INTO armazem (nome_armazem, id_municipio, id_end_armazem)
SELECT 'Armazém Agreste Caruaru', m.id_municipio, ea.id_end_armazem
FROM municipio m JOIN endereco_armazem ea ON ea.cidade='Caruaru' AND ea.logradouro='Av. Agreste' WHERE m.nome='Caruaru' AND m.uf='PE';

INSERT IGNORE INTO armazem (nome_armazem, id_municipio, id_end_armazem)
SELECT 'Armazém Sertão Petrolina', m.id_municipio, ea.id_end_armazem
FROM municipio m JOIN endereco_armazem ea ON ea.cidade='Petrolina' AND ea.logradouro='BR-407 Km 5' WHERE m.nome='Petrolina' AND m.uf='PE';

-- Expansão Armazéns (17 NOVOS)
INSERT IGNORE INTO armazem (nome_armazem, id_municipio, id_end_armazem)
SELECT CONCAT('Armazem Regional ', M.nome, ' ', LPAD(EA.id_end_armazem, 2, '0')), M.id_municipio, EA.id_end_armazem
FROM endereco_armazem EA
JOIN municipio M ON EA.cidade = M.nome AND EA.uf = M.uf
WHERE EA.id_end_armazem > 3
LIMIT 17;


-- 7) Cooperativa / Fornecedor / Agricultor (Total 20+ cada)
INSERT IGNORE INTO cooperativa (razao_social, cnpj_cooper, email, id_municipio, id_end_cooper, id_usuario)
SELECT 'CooperAgro Caruaru', '12.345.678/0001-90', 'contato@cooperagro.pe', m.id_municipio, ec.id_end_cooper, NULL
FROM municipio m JOIN endereco_cooperativa ec ON ec.cidade='Caruaru' AND ec.logradouro='Rua das Sementes' WHERE m.nome='Caruaru' AND m.uf='PE';

INSERT IGNORE INTO cooperativa (razao_social, cnpj_cooper, email, id_municipio, id_end_cooper, id_usuario)
SELECT 'CoopSertão Petrolina', '33.333.333/0001-33', 'contato@coopsertao.org', m.id_municipio, ec.id_end_cooper, NULL
FROM municipio m JOIN endereco_cooperativa ec ON ec.cidade='Petrolina' AND ec.logradouro='Av. Juazeiro' WHERE m.nome='Petrolina' AND m.uf='PE';

-- Expansão Cooperativas (18 NOVAS)
INSERT IGNORE INTO cooperativa (razao_social, cnpj_cooper, email, id_municipio, id_end_cooper, id_usuario)
SELECT CONCAT('Cooperativa Teste ', EC.id_end_cooper), CONCAT(LPAD(EC.id_end_cooper, 2, '4'), '.000.000/0001-', LPAD(EC.id_end_cooper, 2, '0')), CONCAT('contato', EC.id_end_cooper, '@cooptest.org'), M.id_municipio, EC.id_end_cooper, NULL
FROM endereco_cooperativa EC
JOIN municipio M ON EC.cidade = M.nome AND EC.uf = M.uf
WHERE EC.id_end_cooper > 2
LIMIT 18;


INSERT IGNORE INTO fornecedor (razao_social, cnpj, email, telefone, id_end_fornecedor, id_usuario)
SELECT 'Sementes Nordeste Ltda', '98.765.432/0001-10', 'vendas@sementesne.com', '(81) 3333-0000', ef.id_end_fornecedor, NULL
FROM endereco_fornecedor ef WHERE ef.cidade='Caruaru' AND ef.logradouro='BR-232 Km 12';

INSERT IGNORE INTO fornecedor (razao_social, cnpj, email, telefone, id_end_fornecedor, id_usuario)
SELECT 'AgriSeed Brasil S.A.', '11.111.111/0001-11', 'contato@agriseed.com.br', '(81) 4000-1111', ef.id_end_fornecedor, NULL
FROM endereco_fornecedor ef WHERE ef.cidade='Ipojuca' AND ef.logradouro='Rod. PE-60';

INSERT IGNORE INTO fornecedor (razao_social, cnpj, email, telefone, id_end_fornecedor, id_usuario)
SELECT 'Campos Verdes Sementes', '22.222.222/0001-22', 'vendas@camposverdes.com', '(81) 4000-2222', ef.id_end_fornecedor, NULL
FROM endereco_fornecedor ef WHERE ef.cidade='Recife' AND ef.logradouro='Rua das Veredas';

-- Expansão Fornecedores (17 NOVOS)
INSERT IGNORE INTO fornecedor (razao_social, cnpj, email, telefone, id_end_fornecedor, id_usuario)
SELECT CONCAT('Forn Teste ', EF.id_end_fornecedor), CONCAT(LPAD(EF.id_end_fornecedor, 2, '5'), '.000.000/0001-', LPAD(EF.id_end_fornecedor, 2, '0')), CONCAT('contato', EF.id_end_fornecedor, '@forn.net'), '(81) 9000-1000', EF.id_end_fornecedor, NULL
FROM endereco_fornecedor EF
WHERE EF.id_end_fornecedor > 3
LIMIT 17;


INSERT IGNORE INTO agricultor (nome, email, cpf, id_municipio, id_end_agricultor, id_usuario)
SELECT 'José da Silva', 'jose.silva@exemplo.com', '123.456.789-00', m.id_municipio, ea.id_end_agricultor, NULL
FROM municipio m JOIN endereco_agricultor ea ON ea.cidade='Caruaru' AND ea.logradouro='Sítio Boa Vista' WHERE m.nome='Caruaru' AND m.uf='PE';

INSERT IGNORE INTO agricultor (nome, email, cpf, id_municipio, id_end_agricultor, id_usuario)
SELECT 'Maria Oliveira','maria.oliveira@exemplo.com','987.654.321-00', m.id_municipio, ea.id_end_agricultor, NULL
FROM municipio m JOIN endereco_agricultor ea ON ea.cidade='Garanhuns' AND ea.logradouro='Sítio Várzea Alegre' WHERE m.nome='Garanhuns' AND m.uf='PE';

INSERT IGNORE INTO agricultor (nome, email, cpf, id_municipio, id_end_agricultor, id_usuario)
SELECT 'Pedro Santos','pedro.santos@exemplo.com','111.222.333-44', m.id_municipio, ea.id_end_agricultor, NULL
FROM municipio m JOIN endereco_agricultor ea ON ea.cidade='Petrolina' AND ea.logradouro='Loteamento Mandacaru' WHERE m.nome='Petrolina' AND m.uf='PE';

-- Expansão Agricultores (17 NOVOS)
INSERT IGNORE INTO agricultor (nome, email, cpf, id_municipio, id_end_agricultor, id_usuario)
SELECT CONCAT('Agricultor Teste ', EA.id_end_agricultor), CONCAT('agri', EA.id_end_agricultor, '@rural.com'), CONCAT(LPAD(EA.id_end_agricultor, 3, '2'), '.', LPAD(EA.id_end_agricultor, 3, '2'), '.', LPAD(EA.id_end_agricultor, 3, '2'), '-', LPAD(EA.id_end_agricultor, 2, '2')), M.id_municipio, EA.id_end_agricultor, NULL
FROM endereco_agricultor EA
JOIN municipio M ON EA.cidade = M.nome AND EA.uf = M.uf
WHERE EA.id_end_agricultor > 3
LIMIT 17;


-- 8) Espécies (Total 20)
INSERT INTO especie (nome_comum, nome_cientifico) VALUES 
('Milho','Zea mays'), ('Feijão','Phaseolus vulgaris'), 
('Sorgo','Sorghum bicolor'), ('Arroz','Oryza sativa');
-- Expansão Espécies (16 NOVAS)
INSERT INTO especie (nome_comum, nome_cientifico) VALUES
('Mandioca','Manihot esculenta'), ('Algodão','Gossypium hirsutum'), 
('Soja','Glycine max'), ('Gergelim','Sesamum indicum'), 
('Abóbora','Cucurbita moschata'), ('Cumaru','Dipteryx odorata'), 
('Pinhão Manso','Jatropha curcas'), ('Girassol','Helianthus annuus'), 
('Canola','Brassica napus'), ('Aveia','Avena sativa'), 
('Centeio','Secale cereale'), ('Triticale','X Triticosecale'), 
('Linhaça','Linum usitatissimum'), ('Amendoim','Arachis hypogaea'), 
('Guandu','Cajanus cajan'), ('Vaca Verde','Phaseolus spp.')
ON DUPLICATE KEY UPDATE nome_cientifico=VALUES(nome_cientifico);


-- 9) Lotes (Total 20)
INSERT IGNORE INTO lote (numero_lote, id_especie, id_fornecedor, validade, qtd_sacas, qr_code)
SELECT 'MIL-2025-0001', e.id_especie, f.id_fornecedor, '2026-06-30', 120, 'QR-MIL-2025-0001'
FROM especie e, fornecedor f WHERE e.nome_comum='Milho' AND f.cnpj='98.765.432/0001-10' LIMIT 1;
INSERT IGNORE INTO lote (numero_lote, id_especie, id_fornecedor, validade, qtd_sacas, qr_code)
SELECT 'FEI-2025-0001', e.id_especie, f.id_fornecedor, '2026-12-31', 80, 'QR-FEI-2025-0001'
FROM especie e, fornecedor f WHERE e.nome_comum='Feijão' AND f.cnpj='98.765.432/0001-10' LIMIT 1;
INSERT IGNORE INTO lote (numero_lote, id_especie, id_fornecedor, validade, qtd_sacas, qr_code)
SELECT 'SOR-2025-0001', e.id_especie, f.id_fornecedor, '2027-03-31', 200, 'QR-SOR-2025-0001'
FROM especie e, fornecedor f WHERE e.nome_comum='Sorgo' AND f.cnpj='22.222.222/0001-22' LIMIT 1;
INSERT IGNORE INTO lote (numero_lote, id_especie, id_fornecedor, validade, qtd_sacas, qr_code)
SELECT 'ARR-2025-0001', e.id_especie, f.id_fornecedor, '2027-04-30', 120, 'QR-ARR-2025-0001'
FROM especie e, fornecedor f WHERE e.nome_comum='Arroz' AND f.cnpj='22.222.222/0001-22' LIMIT 1;

-- Expansão Lotes (16 NOVOS)
INSERT IGNORE INTO lote (numero_lote, id_especie, id_fornecedor, validade, qtd_sacas, qr_code)
SELECT CONCAT(LEFT(e.nome_comum, 3), '-2026-', LPAD(e.id_especie, 4, '0')), e.id_especie, f.id_fornecedor, DATE_ADD('2026-08-31', INTERVAL e.id_especie DAY), 100, CONCAT('QR-', e.nome_comum, e.id_especie)
FROM especie e, fornecedor f
WHERE e.id_especie > 4 AND f.cnpj='11.111.111/0001-11'
LIMIT 16;


-- 10) Estoque por armazém/lote (saldo 0 para começar)
-- Cria pares de estoque para lotes 1-4 nos 3 armazéns principais
INSERT IGNORE INTO estoque_armazem_lote (id_armazem, id_lote, saldo_sacas)
SELECT A.id_armazem, L.id_lote, 0
FROM armazem A, lote L
WHERE A.nome_armazem IN ('Armazém Central Recife', 'Armazém Agreste Caruaru', 'Armazém Sertão Petrolina') 
AND L.id_lote BETWEEN 1 AND 4;

-- Cria pares de estoque para lotes 5-20 no Armazém Central Recife
INSERT IGNORE INTO estoque_armazem_lote (id_armazem, id_lote, saldo_sacas)
SELECT A.id_armazem, L.id_lote, 0
FROM armazem A, lote L
WHERE A.nome_armazem = 'Armazém Central Recife' 
AND L.id_lote > 4;


-- 11) Movimentações de ENTRADA (Total 20)
-- 4 Entradas Iniciais + 16 Entradas de Lotes Novos
INSERT INTO movimentacao_esto
  (tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
SELECT 'ENTRADA', l.id_lote, NULL, a.id_armazem, l.qtd_sacas, u.id_usuario
FROM lote l
JOIN armazem a ON a.nome_armazem = 'Armazém Central Recife'
JOIN usuario u ON u.email_login = 'bruno.operador@semeia.local'
WHERE l.id_lote BETWEEN 1 AND 2;

INSERT INTO movimentacao_esto
  (tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
SELECT 'ENTRADA', l.id_lote, NULL, a.id_armazem, l.qtd_sacas, u.id_usuario
FROM lote l
JOIN armazem a ON a.nome_armazem = 'Armazém Sertão Petrolina'
JOIN usuario u ON u.email_login = 'bruno.operador@semeia.local'
WHERE l.id_lote BETWEEN 3 AND 4;

-- Entradas dos 16 Lotes Novos no Recife (Movimentações 5-20)
INSERT INTO movimentacao_esto (tipo, id_lote, id_armazem_origem, id_armazem_destino, quant_sacas, id_usuario)
SELECT 'ENTRADA', l.id_lote, NULL, a.id_armazem, l.qtd_sacas, u.id_usuario
FROM lote l
JOIN armazem a ON a.nome_armazem = 'Armazém Central Recife'
JOIN usuario u ON u.email_login = 'bruno.operador@semeia.local'
WHERE l.id_lote > 4;


-- 12) Ordens de Expedição (Total 20)
-- OE 1: Caruaru
INSERT INTO ordem_expedicao
  (id_municipio, data_prevista, status, id_gestor_resp, id_cooper_solicitante)
SELECT m.id_municipio, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'PLANEJADA', g.id_gestor, c.id_cooper
FROM municipio m LEFT JOIN gestor g ON g.id_usuario = (SELECT id_usuario FROM usuario WHERE email_login='ana.gestora@semeia.local' LIMIT 1)
LEFT JOIN cooperativa c ON c.cnpj_cooper='12.345.678/0001-90' WHERE m.nome='Caruaru' AND m.uf='PE';

-- OE 2: Garanhuns
INSERT INTO ordem_expedicao 
(id_municipio, data_prevista, status, id_gestor_resp, id_cooper_solicitante)
SELECT m.id_municipio, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'PLANEJADA', g.id_gestor, c.id_cooper
FROM municipio m LEFT JOIN gestor g ON g.id_usuario=(SELECT id_usuario FROM usuario WHERE email_login='ana.gestora@semeia.local' LIMIT 1)
LEFT JOIN cooperativa c ON c.cnpj_cooper='12.345.678/0001-90' WHERE m.nome='Garanhuns' AND m.uf='PE';

-- OE 3: Petrolina
INSERT INTO ordem_expedicao 
(id_municipio, data_prevista, status, id_gestor_resp, id_cooper_solicitante)
SELECT m.id_municipio, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'PLANEJADA', g.id_gestor, c.id_cooper
FROM municipio m LEFT JOIN gestor g ON g.id_usuario=(SELECT id_usuario FROM usuario WHERE email_login='ana.gestora@semeia.local' LIMIT 1)
LEFT JOIN cooperativa c ON c.cnpj_cooper='33.333.333/0001-33' WHERE m.nome='Petrolina' AND m.uf='PE';

-- Expansão Ordens de Expedição (17 NOVAS OEs)
INSERT INTO ordem_expedicao
  (id_municipio, data_prevista, status, id_gestor_resp, id_cooper_solicitante)
SELECT M.id_municipio, DATE_ADD(CURDATE(), INTERVAL 15 + SEQ.id_seq DAY), 'PLANEJADA', G.id_gestor, C.id_cooper
FROM (SELECT @s := @s + 1 AS id_seq FROM municipio, (SELECT @s := 0) AS init LIMIT 17) SEQ
JOIN municipio M ON M.id_municipio = (SEQ.id_seq % 20) + 1 -- Cicla nos 20 municípios
JOIN gestor G ON G.id_gestor = (SEQ.id_seq % 5) + 1 -- Cicla nos 5 gestores
LEFT JOIN cooperativa C ON C.id_cooper = (SEQ.id_seq % 20) + 1; -- Cicla nas 20 cooperativas

-- 13) Itens da OE (Total 20+)
-- Itens Iniciais (OE 1, 2, 3)
INSERT INTO item_expedicao (id_expedicao, id_lote, quant_sacas)
VALUES
(1, (SELECT id_lote FROM lote WHERE numero_lote='MIL-2025-0001'), 40),
(1, (SELECT id_lote FROM lote WHERE numero_lote='FEI-2025-0001'), 20),
(2, (SELECT id_lote FROM lote WHERE numero_lote='MIL-2025-0001'), 20),
(2, (SELECT id_lote FROM lote WHERE numero_lote='FEI-2025-0001'), 8),
(3, (SELECT id_lote FROM lote WHERE numero_lote='SOR-2025-0001'), 50),
(3, (SELECT id_lote FROM lote WHERE numero_lote='ARR-2025-0001'), 30);

-- Expansão Itens OE (4 itens por OE 4-20)
INSERT INTO item_expedicao (id_expedicao, id_lote, quant_sacas)
SELECT OE.id_expedicao, L.id_lote, 10
FROM ordem_expedicao OE
JOIN lote L ON L.id_lote = (OE.id_expedicao % 4) + 5 -- Usa lotes de 5 a 8
WHERE OE.id_expedicao >= 4;


-- 14) Entregas (Total 20)
-- 4 Entregas Iniciais (EN1-EN4)
INSERT INTO entrega (data_entrega, id_municipio, tipo_destinatario, id_agricultor, id_cooper, comprovante_entrega_url, id_usuario)
VALUES
(CURDATE(), (SELECT id_municipio FROM municipio WHERE nome='Caruaru'), 'AGRICULTOR', (SELECT id_agricultor FROM agricultor WHERE cpf='123.456.789-00'), NULL, 'url/en1', (SELECT id_usuario FROM usuario WHERE email_login='carla.distrib@semeia.local')),
(CURDATE(), (SELECT id_municipio FROM municipio WHERE nome='Garanhuns'), 'COOPERATIVA', NULL, (SELECT id_cooper FROM cooperativa WHERE cnpj_cooper='12.345.678/0001-90'), 'url/en2', (SELECT id_usuario FROM usuario WHERE email_login='carla.distrib@semeia.local')),
(CURDATE(), (SELECT id_municipio FROM municipio WHERE nome='Garanhuns'), 'AGRICULTOR', (SELECT id_agricultor FROM agricultor WHERE cpf='987.654.321-00'), NULL, 'url/en3', (SELECT id_usuario FROM usuario WHERE email_login='carla.distrib@semeia.local')),
(CURDATE(), (SELECT id_municipio FROM municipio WHERE nome='Petrolina'), 'AGRICULTOR', (SELECT id_agricultor FROM agricultor WHERE cpf='111.222.333-44'), NULL, 'url/en4', (SELECT id_usuario FROM usuario WHERE email_login='carla.distrib@semeia.local'));

-- Expansão Entregas (16 NOVAS Entregas)
INSERT INTO entrega (data_entrega, id_municipio, tipo_destinatario, id_agricultor, id_cooper, id_usuario)
SELECT CURDATE(), M.id_municipio, 'AGRICULTOR', A.id_agricultor, NULL, U.id_usuario
FROM (SELECT @e := @e + 1 AS id_seq FROM municipio, (SELECT @e := 4) AS init LIMIT 16) SEQ
JOIN municipio M ON M.id_municipio = (SEQ.id_seq % 20) + 1
JOIN agricultor A ON A.id_agricultor = (SEQ.id_seq % 20) + 1
JOIN usuario U ON U.email_login = 'carla.distrib@semeia.local'
WHERE SEQ.id_seq < 20;


-- 15) Itens da entrega (Total 20+)
-- Itens Iniciais (EN1 - EN4)
INSERT INTO item_entrega (id_entrega, id_lote, quant_sacas)
VALUES
(1, (SELECT id_lote FROM lote WHERE numero_lote='MIL-2025-0001'), 30),
(1, (SELECT id_lote FROM lote WHERE numero_lote='FEI-2025-0001'), 15),
(2, (SELECT id_lote FROM lote WHERE numero_lote='MIL-2025-0001'), 15),
(2, (SELECT id_lote FROM lote WHERE numero_lote='FEI-2025-0001'), 5),
(3, (SELECT id_lote FROM lote WHERE numero_lote='MIL-2025-0001'), 5),
(4, (SELECT id_lote FROM lote WHERE numero_lote='SOR-2025-0001'), 40),
(4, (SELECT id_lote FROM lote WHERE numero_lote='ARR-2025-0001'), 20);

-- Expansão Itens Entrega (2 itens por EN 5-20)
INSERT INTO item_entrega (id_entrega, id_lote, quant_sacas)
SELECT E.id_entrega, L.id_lote, 5
FROM entrega E
JOIN lote L ON L.id_lote = (E.id_entrega % 4) + 1 
WHERE E.id_entrega > 4;


-- 16) Vínculo N:N entrega <-> ordem (Total 20+)
INSERT INTO entrega_ordem (id_entrega, id_expedicao)
SELECT E.id_entrega, OE.id_expedicao
FROM entrega E
JOIN ordem_expedicao OE ON OE.id_expedicao = E.id_entrega;

COMMIT;