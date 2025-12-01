-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema semeia
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema semeia
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `semeia` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `semeia` ;

-- -----------------------------------------------------
-- Table `semeia`.`endereco_agricultor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`endereco_agricultor` (
  `id_end_agricultor` BIGINT NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(180) NOT NULL,
  `numero` VARCHAR(20) NULL DEFAULT NULL,
  `bairro` VARCHAR(120) NULL DEFAULT NULL,
  `cep` VARCHAR(12) NULL DEFAULT NULL,
  `cidade` VARCHAR(120) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `complemento` VARCHAR(180) NULL DEFAULT NULL,
  PRIMARY KEY (`id_end_agricultor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`municipio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`municipio` (
  `id_municipio` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(120) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  PRIMARY KEY (`id_municipio`),
  UNIQUE INDEX `uk_municipio` (`nome` ASC, `uf` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`usuario` (
  `id_usuario` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(120) NOT NULL,
  `email_login` VARCHAR(160) NOT NULL,
  `senha_hash` VARCHAR(255) NOT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `email_login` (`email_login` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`agricultor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`agricultor` (
  `id_agricultor` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(160) NOT NULL,
  `email` VARCHAR(160) NULL DEFAULT NULL,
  `cpf` VARCHAR(20) NOT NULL,
  `id_municipio` BIGINT NOT NULL,
  `id_end_agricultor` BIGINT NULL DEFAULT NULL,
  `id_usuario` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id_agricultor`),
  UNIQUE INDEX `cpf` (`cpf` ASC) VISIBLE,
  UNIQUE INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `fk_agri_mun` (`id_municipio` ASC) VISIBLE,
  INDEX `fk_agri_endagri` (`id_end_agricultor` ASC) VISIBLE,
  INDEX `idx_agri_email` (`email` ASC) VISIBLE,
  CONSTRAINT `fk_agri_endagri`
    FOREIGN KEY (`id_end_agricultor`)
    REFERENCES `semeia`.`endereco_agricultor` (`id_end_agricultor`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_agri_mun`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `semeia`.`municipio` (`id_municipio`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_agri_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`endereco_armazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`endereco_armazem` (
  `id_end_armazem` BIGINT NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(180) NOT NULL,
  `numero` VARCHAR(20) NULL DEFAULT NULL,
  `bairro` VARCHAR(120) NULL DEFAULT NULL,
  `cep` VARCHAR(12) NULL DEFAULT NULL,
  `cidade` VARCHAR(120) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `complemento` VARCHAR(180) NULL DEFAULT NULL,
  PRIMARY KEY (`id_end_armazem`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`armazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`armazem` (
  `id_armazem` BIGINT NOT NULL AUTO_INCREMENT,
  `nome_armazem` VARCHAR(160) NOT NULL,
  `id_municipio` BIGINT NOT NULL,
  `id_end_armazem` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id_armazem`),
  INDEX `fk_ar_mun` (`id_municipio` ASC) VISIBLE,
  INDEX `fk_ar_endarmazem` (`id_end_armazem` ASC) VISIBLE,
  CONSTRAINT `fk_ar_endarmazem`
    FOREIGN KEY (`id_end_armazem`)
    REFERENCES `semeia`.`endereco_armazem` (`id_end_armazem`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ar_mun`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `semeia`.`municipio` (`id_municipio`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`endereco_cooperativa`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`endereco_cooperativa` (
  `id_end_cooper` BIGINT NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(180) NOT NULL,
  `numero` VARCHAR(20) NULL DEFAULT NULL,
  `bairro` VARCHAR(120) NULL DEFAULT NULL,
  `cep` VARCHAR(12) NULL DEFAULT NULL,
  `cidade` VARCHAR(120) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `complemento` VARCHAR(180) NULL DEFAULT NULL,
  PRIMARY KEY (`id_end_cooper`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`cooperativa`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`cooperativa` (
  `id_cooper` BIGINT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(160) NOT NULL,
  `cnpj_cooper` VARCHAR(20) NOT NULL,
  `email` VARCHAR(160) NULL DEFAULT NULL,
  `id_municipio` BIGINT NOT NULL,
  `id_end_cooper` BIGINT NULL DEFAULT NULL,
  `id_usuario` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id_cooper`),
  UNIQUE INDEX `cnpj_cooper` (`cnpj_cooper` ASC) VISIBLE,
  UNIQUE INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `fk_coop_mun` (`id_municipio` ASC) VISIBLE,
  INDEX `fk_coop_endcooper` (`id_end_cooper` ASC) VISIBLE,
  INDEX `idx_coop_email` (`email` ASC) VISIBLE,
  CONSTRAINT `fk_coop_endcooper`
    FOREIGN KEY (`id_end_cooper`)
    REFERENCES `semeia`.`endereco_cooperativa` (`id_end_cooper`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_coop_mun`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `semeia`.`municipio` (`id_municipio`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_coop_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`endereco_fornecedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`endereco_fornecedor` (
  `id_end_fornecedor` BIGINT NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(180) NOT NULL,
  `numero` VARCHAR(20) NULL DEFAULT NULL,
  `bairro` VARCHAR(120) NULL DEFAULT NULL,
  `cep` VARCHAR(12) NULL DEFAULT NULL,
  `cidade` VARCHAR(120) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `complemento` VARCHAR(180) NULL DEFAULT NULL,
  PRIMARY KEY (`id_end_fornecedor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`entrega`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`entrega` (
  `id_entrega` BIGINT NOT NULL AUTO_INCREMENT,
  `data_entrega` DATE NOT NULL,
  `id_municipio` BIGINT NOT NULL,
  `tipo_destinatario` ENUM('AGRICULTOR', 'COOPERATIVA') NOT NULL,
  `id_agricultor` BIGINT NULL DEFAULT NULL,
  `id_cooper` BIGINT NULL DEFAULT NULL,
  `comprovante_entrega_url` VARCHAR(255) NULL DEFAULT NULL,
  `id_usuario` BIGINT NOT NULL,
  PRIMARY KEY (`id_entrega`),
  INDEX `fk_ent_mun` (`id_municipio` ASC) VISIBLE,
  INDEX `fk_ent_agri` (`id_agricultor` ASC) VISIBLE,
  INDEX `fk_ent_coop` (`id_cooper` ASC) VISIBLE,
  INDEX `fk_ent_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_ent_agri`
    FOREIGN KEY (`id_agricultor`)
    REFERENCES `semeia`.`agricultor` (`id_agricultor`)
    ON DELETE SET NULL
    ON UPDATE SET NULL,
  CONSTRAINT `fk_ent_coop`
    FOREIGN KEY (`id_cooper`)
    REFERENCES `semeia`.`cooperativa` (`id_cooper`)
    ON DELETE SET NULL
    ON UPDATE SET NULL,
  CONSTRAINT `fk_ent_mun`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `semeia`.`municipio` (`id_municipio`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_ent_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`gestor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`gestor` (
  `id_gestor` BIGINT NOT NULL AUTO_INCREMENT,
  `id_usuario` BIGINT NOT NULL,
  `area_respons` VARCHAR(160) NULL DEFAULT NULL,
  `cargo` VARCHAR(120) NULL DEFAULT NULL,
  PRIMARY KEY (`id_gestor`),
  UNIQUE INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_gestor_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`ordem_expedicao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`ordem_expedicao` (
  `id_expedicao` BIGINT NOT NULL AUTO_INCREMENT,
  `id_municipio` BIGINT NOT NULL,
  `data_prevista` DATE NOT NULL,
  `status` ENUM('PLANEJADA', 'EXPEDIDA', 'CONCLUIDA', 'CANCELADA') NOT NULL DEFAULT 'PLANEJADA',
  `comprovante_exped_url` VARCHAR(255) NULL DEFAULT NULL,
  `id_gestor_resp` BIGINT NULL DEFAULT NULL,
  `id_cooper_solicitante` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id_expedicao`),
  INDEX `fk_oe_mun` (`id_municipio` ASC) VISIBLE,
  INDEX `fk_oe_gestor_resp` (`id_gestor_resp` ASC) VISIBLE,
  INDEX `fk_oe_coop_solic` (`id_cooper_solicitante` ASC) VISIBLE,
  CONSTRAINT `fk_oe_coop_solic`
    FOREIGN KEY (`id_cooper_solicitante`)
    REFERENCES `semeia`.`cooperativa` (`id_cooper`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_oe_gestor_resp`
    FOREIGN KEY (`id_gestor_resp`)
    REFERENCES `semeia`.`gestor` (`id_gestor`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_oe_mun`
    FOREIGN KEY (`id_municipio`)
    REFERENCES `semeia`.`municipio` (`id_municipio`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`entrega_ordem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`entrega_ordem` (
  `id_entrega` BIGINT NOT NULL,
  `id_expedicao` BIGINT NOT NULL,
  PRIMARY KEY (`id_entrega`, `id_expedicao`),
  INDEX `fk_eo_exp` (`id_expedicao` ASC) VISIBLE,
  CONSTRAINT `fk_eo_ent`
    FOREIGN KEY (`id_entrega`)
    REFERENCES `semeia`.`entrega` (`id_entrega`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_eo_exp`
    FOREIGN KEY (`id_expedicao`)
    REFERENCES `semeia`.`ordem_expedicao` (`id_expedicao`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`especie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`especie` (
  `id_especie` BIGINT NOT NULL AUTO_INCREMENT,
  `nome_comum` VARCHAR(120) NOT NULL,
  `nome_cientifico` VARCHAR(160) NULL DEFAULT NULL,
  PRIMARY KEY (`id_especie`),
  UNIQUE INDEX `uk_especie` (`nome_comum` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`fornecedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`fornecedor` (
  `id_fornecedor` BIGINT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(160) NOT NULL,
  `cnpj` VARCHAR(20) NOT NULL,
  `email` VARCHAR(160) NULL DEFAULT NULL,
  `telefone` VARCHAR(30) NULL DEFAULT NULL,
  `id_end_fornecedor` BIGINT NULL DEFAULT NULL,
  `id_usuario` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id_fornecedor`),
  UNIQUE INDEX `cnpj` (`cnpj` ASC) VISIBLE,
  UNIQUE INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `fk_forn_endforn` (`id_end_fornecedor` ASC) VISIBLE,
  INDEX `idx_forn_email` (`email` ASC) VISIBLE,
  CONSTRAINT `fk_forn_endforn`
    FOREIGN KEY (`id_end_fornecedor`)
    REFERENCES `semeia`.`endereco_fornecedor` (`id_end_fornecedor`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_forn_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`lote`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`lote` (
  `id_lote` BIGINT NOT NULL AUTO_INCREMENT,
  `numero_lote` VARCHAR(80) NOT NULL,
  `id_especie` BIGINT NOT NULL,
  `id_fornecedor` BIGINT NOT NULL,
  `validade` DATE NULL DEFAULT NULL,
  `qtd_sacas` INT NOT NULL,
  `qr_code` VARCHAR(200) NULL DEFAULT NULL,
  PRIMARY KEY (`id_lote`),
  UNIQUE INDEX `numero_lote` (`numero_lote` ASC) VISIBLE,
  INDEX `fk_lote_especie` (`id_especie` ASC) VISIBLE,
  INDEX `fk_lote_fornecedor` (`id_fornecedor` ASC) VISIBLE,
  CONSTRAINT `fk_lote_especie`
    FOREIGN KEY (`id_especie`)
    REFERENCES `semeia`.`especie` (`id_especie`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_lote_fornecedor`
    FOREIGN KEY (`id_fornecedor`)
    REFERENCES `semeia`.`fornecedor` (`id_fornecedor`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`estoque_armazem_lote`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`estoque_armazem_lote` (
  `id_armazem` BIGINT NOT NULL,
  `id_lote` BIGINT NOT NULL,
  `saldo_sacas` INT NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_armazem`, `id_lote`),
  INDEX `fk_eal_lote` (`id_lote` ASC) VISIBLE,
  CONSTRAINT `fk_eal_armazem`
    FOREIGN KEY (`id_armazem`)
    REFERENCES `semeia`.`armazem` (`id_armazem`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_eal_lote`
    FOREIGN KEY (`id_lote`)
    REFERENCES `semeia`.`lote` (`id_lote`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`item_entrega`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`item_entrega` (
  `id_item_entrega` BIGINT NOT NULL AUTO_INCREMENT,
  `id_entrega` BIGINT NOT NULL,
  `id_lote` BIGINT NOT NULL,
  `quant_sacas` INT NOT NULL,
  PRIMARY KEY (`id_item_entrega`),
  INDEX `fk_itent_entrega` (`id_entrega` ASC) VISIBLE,
  INDEX `fk_itent_lote` (`id_lote` ASC) VISIBLE,
  CONSTRAINT `fk_itent_entrega`
    FOREIGN KEY (`id_entrega`)
    REFERENCES `semeia`.`entrega` (`id_entrega`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_itent_lote`
    FOREIGN KEY (`id_lote`)
    REFERENCES `semeia`.`lote` (`id_lote`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`item_expedicao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`item_expedicao` (
  `id_item_expedicao` BIGINT NOT NULL AUTO_INCREMENT,
  `id_expedicao` BIGINT NOT NULL,
  `id_lote` BIGINT NOT NULL,
  `quant_sacas` INT NOT NULL,
  PRIMARY KEY (`id_item_expedicao`),
  INDEX `fk_ie_exped` (`id_expedicao` ASC) VISIBLE,
  INDEX `fk_ie_lote` (`id_lote` ASC) VISIBLE,
  CONSTRAINT `fk_ie_exped`
    FOREIGN KEY (`id_expedicao`)
    REFERENCES `semeia`.`ordem_expedicao` (`id_expedicao`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_ie_lote`
    FOREIGN KEY (`id_lote`)
    REFERENCES `semeia`.`lote` (`id_lote`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`movimentacao_esto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`movimentacao_esto` (
  `id_mov` BIGINT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('ENTRADA', 'SAIDA', 'TRANSFERENCIA') NOT NULL,
  `id_lote` BIGINT NOT NULL,
  `id_armazem_origem` BIGINT NULL DEFAULT NULL,
  `id_armazem_destino` BIGINT NULL DEFAULT NULL,
  `quant_sacas` INT NOT NULL,
  `data_mov` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_usuario` BIGINT NOT NULL,
  PRIMARY KEY (`id_mov`),
  INDEX `fk_me_lote` (`id_lote` ASC) VISIBLE,
  INDEX `fk_me_ar_origem` (`id_armazem_origem` ASC) VISIBLE,
  INDEX `fk_me_ar_destino` (`id_armazem_destino` ASC) VISIBLE,
  INDEX `fk_me_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_me_ar_destino`
    FOREIGN KEY (`id_armazem_destino`)
    REFERENCES `semeia`.`armazem` (`id_armazem`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_me_ar_origem`
    FOREIGN KEY (`id_armazem_origem`)
    REFERENCES `semeia`.`armazem` (`id_armazem`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_me_lote`
    FOREIGN KEY (`id_lote`)
    REFERENCES `semeia`.`lote` (`id_lote`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_me_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`papel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`papel` (
  `id_papel` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` ENUM('GESTOR', 'OPERADOR_ARMAZEM', 'AGENTE_DISTRIBUICAO', 'CIDADAO') NOT NULL,
  PRIMARY KEY (`id_papel`),
  UNIQUE INDEX `uk_papel` (`nome` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`rastro_lote`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`rastro_lote` (
  `id_rastro` BIGINT NOT NULL AUTO_INCREMENT,
  `id_lote` BIGINT NOT NULL,
  `evento` ENUM('ENTRADA_ARMAZEM', 'EXPEDICAO', 'TRANSFERENCIA', 'ENTREGA') NOT NULL,
  `timestamp_evento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_referencia` BIGINT NULL DEFAULT NULL,
  `observacao` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_rastro`),
  INDEX `idx_rl_lote_evento` (`id_lote` ASC, `evento` ASC, `timestamp_evento` ASC) VISIBLE,
  CONSTRAINT `fk_rl_lote`
    FOREIGN KEY (`id_lote`)
    REFERENCES `semeia`.`lote` (`id_lote`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `semeia`.`usuario_papel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`usuario_papel` (
  `id_usuario` BIGINT NOT NULL,
  `id_papel` BIGINT NOT NULL,
  PRIMARY KEY (`id_usuario`, `id_papel`),
  INDEX `fk_up_papel` (`id_papel` ASC) VISIBLE,
  CONSTRAINT `fk_up_papel`
    FOREIGN KEY (`id_papel`)
    REFERENCES `semeia`.`papel` (`id_papel`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_up_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `semeia`.`usuario` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `semeia` ;

-- -----------------------------------------------------
-- Placeholder table for view `semeia`.`vw_transparencia_distribuicao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `semeia`.`vw_transparencia_distribuicao` (`id_municipio` INT, `municipio` INT, `uf` INT, `id_especie` INT, `especie` INT, `periodo_yyyy_mm` INT, `total_sacas` INT);

-- -----------------------------------------------------
-- View `semeia`.`vw_transparencia_distribuicao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `semeia`.`vw_transparencia_distribuicao`;
USE `semeia`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `semeia`.`vw_transparencia_distribuicao` AS select `en`.`id_municipio` AS `id_municipio`,`m`.`nome` AS `municipio`,`m`.`uf` AS `uf`,`l`.`id_especie` AS `id_especie`,`s`.`nome_comum` AS `especie`,date_format(`en`.`data_entrega`,'%Y-%m') AS `periodo_yyyy_mm`,sum(`it`.`quant_sacas`) AS `total_sacas` from ((((`semeia`.`entrega` `en` join `semeia`.`item_entrega` `it` on((`it`.`id_entrega` = `en`.`id_entrega`))) join `semeia`.`lote` `l` on((`l`.`id_lote` = `it`.`id_lote`))) join `semeia`.`especie` `s` on((`s`.`id_especie` = `l`.`id_especie`))) join `semeia`.`municipio` `m` on((`m`.`id_municipio` = `en`.`id_municipio`))) group by `en`.`id_municipio`,`m`.`nome`,`m`.`uf`,`l`.`id_especie`,`s`.`nome_comum`,date_format(`en`.`data_entrega`,'%Y-%m');
USE `semeia`;

DELIMITER $$
USE `semeia`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `semeia`.`trg_entrega_xor_bi`
BEFORE INSERT ON `semeia`.`entrega`
FOR EACH ROW
BEGIN
  IF NEW.tipo_destinatario = 'AGRICULTOR' THEN
    IF NEW.id_agricultor IS NULL OR NEW.id_cooper IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entrega: se AGRICULTOR, informar id_agricultor e manter id_cooper = NULL.';
    END IF;
  ELSEIF NEW.tipo_destinatario = 'COOPERATIVA' THEN
    IF NEW.id_cooper IS NULL OR NEW.id_agricultor IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entrega: se COOPERATIVA, informar id_cooper e manter id_agricultor = NULL.';
    END IF;
  END IF;
END$$

USE `semeia`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `semeia`.`trg_entrega_xor_bu`
BEFORE UPDATE ON `semeia`.`entrega`
FOR EACH ROW
BEGIN
  IF NEW.tipo_destinatario = 'AGRICULTOR' THEN
    IF NEW.id_agricultor IS NULL OR NEW.id_cooper IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entrega: se AGRICULTOR, informar id_agricultor e manter id_cooper = NULL.';
    END IF;
  ELSEIF NEW.tipo_destinatario = 'COOPERATIVA' THEN
    IF NEW.id_cooper IS NULL OR NEW.id_agricultor IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entrega: se COOPERATIVA, informar id_cooper e manter id_agricultor = NULL.';
    END IF;
  END IF;
END$$

USE `semeia`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `semeia`.`trg_eal_chk_saldo_bi`
BEFORE INSERT ON `semeia`.`estoque_armazem_lote`
FOR EACH ROW
BEGIN
  IF NEW.saldo_sacas < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo_sacas não pode ser negativo';
  END IF;
END$$

USE `semeia`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `semeia`.`trg_eal_chk_saldo_bu`
BEFORE UPDATE ON `semeia`.`estoque_armazem_lote`
FOR EACH ROW
BEGIN
  IF NEW.saldo_sacas < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo_sacas não pode ser negativo';
  END IF;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
