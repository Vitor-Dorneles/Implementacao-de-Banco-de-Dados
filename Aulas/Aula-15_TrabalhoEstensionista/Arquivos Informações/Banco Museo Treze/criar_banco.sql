-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema museutrezemaio2
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema museutrezemaio2
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `museutrezemaio2` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `museutrezemaio2` ;

-- -----------------------------------------------------
-- Table `museutrezemaio2`.`acesso`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`acesso` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `data_hora` DATETIME(6) NULL DEFAULT NULL,
  `ip` VARCHAR(255) NULL DEFAULT NULL,
  `uri` VARCHAR(255) NULL DEFAULT NULL,
  `user_agent` VARCHAR(512) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`assunto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`assunto` (
  `id_assunto` INT NOT NULL AUTO_INCREMENT,
  `ativo` BIT(1) NOT NULL,
  `descricao` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_assunto`),
  UNIQUE INDEX `UKnupysjx8ib2c19dr58llnn3lt` (`descricao` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`colaborador`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`colaborador` (
  `id_colaborador` INT NOT NULL AUTO_INCREMENT,
  `ativo` BIT(1) NOT NULL,
  `nacionalidade` VARCHAR(255) NULL DEFAULT NULL,
  `nome` VARCHAR(255) NOT NULL,
  `sobrenome` VARCHAR(255) NOT NULL,
  `tipo` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_colaborador`),
  UNIQUE INDEX `UK9ob6cfe05ddqxmfqfst4j6vyi` (`nome` ASC, `sobrenome` ASC, `tipo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`editora`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`editora` (
  `id_editora` INT NOT NULL AUTO_INCREMENT,
  `ativo` BIT(1) NOT NULL,
  `cidade` VARCHAR(255) NULL DEFAULT NULL,
  `estado` VARCHAR(255) NULL DEFAULT NULL,
  `pais` VARCHAR(255) NULL DEFAULT NULL,
  `nome` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_editora`),
  UNIQUE INDEX `UK3wsd3r99p0qgpxikwftkcmc55` (`nome` ASC, `cidade` ASC, `estado` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`item_acervo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`item_acervo` (
  `id_item_acervo` INT NOT NULL AUTO_INCREMENT,
  `capa` LONGBLOB NULL DEFAULT NULL,
  `descricao` VARCHAR(2000) NULL DEFAULT NULL,
  `idioma` VARCHAR(255) NOT NULL,
  `localizacao_acervo` VARCHAR(255) NOT NULL,
  `notas` VARCHAR(2000) NULL DEFAULT NULL,
  `numero_paginas` INT NOT NULL,
  `status` VARCHAR(255) NOT NULL,
  `subtitulo` VARCHAR(255) NULL DEFAULT NULL,
  `tipo` VARCHAR(255) NOT NULL,
  `titulo` VARCHAR(255) NOT NULL,
  `visibilidade_notas` BIT(1) NOT NULL,
  `id_editora` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id_item_acervo`),
  INDEX `FKnmiqjx1modhl0m1imxwlitp09` (`id_editora` ASC) VISIBLE,
  CONSTRAINT `FKnmiqjx1modhl0m1imxwlitp09`
    FOREIGN KEY (`id_editora`)
    REFERENCES `museutrezemaio2`.`editora` (`id_editora`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`exemplar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`exemplar` (
  `id_exemplar` INT NOT NULL AUTO_INCREMENT,
  `ativo` BIT(1) NOT NULL,
  `codigo` VARCHAR(255) NOT NULL,
  `id_acervo` INT NOT NULL,
  PRIMARY KEY (`id_exemplar`),
  UNIQUE INDEX `UK30xq74g9k7ftxmystdxms8k3y` (`codigo` ASC, `id_acervo` ASC) VISIBLE,
  UNIQUE INDEX `UK2acqgf1qqyjalmtg1wvq0pnih` (`codigo` ASC) VISIBLE,
  INDEX `FKhg1q12d2u1pjr0b1sbfs7vuov` (`id_acervo` ASC) VISIBLE,
  CONSTRAINT `FKhg1q12d2u1pjr0b1sbfs7vuov`
    FOREIGN KEY (`id_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`item_acervo_assunto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`item_acervo_assunto` (
  `id_item_acervo` INT NOT NULL,
  `id_assunto` INT NOT NULL,
  INDEX `FK7f5q0lmivpt8foqqkfcviblbq` (`id_assunto` ASC) VISIBLE,
  INDEX `FKruv1kltqfk31qeedlsory9tqd` (`id_item_acervo` ASC) VISIBLE,
  CONSTRAINT `FK7f5q0lmivpt8foqqkfcviblbq`
    FOREIGN KEY (`id_assunto`)
    REFERENCES `museutrezemaio2`.`assunto` (`id_assunto`),
  CONSTRAINT `FKruv1kltqfk31qeedlsory9tqd`
    FOREIGN KEY (`id_item_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`item_acervo_colaborador`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`item_acervo_colaborador` (
  `id_item_acervo` INT NOT NULL,
  `id_colaborador` INT NOT NULL,
  INDEX `FKpodgqn7uk9km0mhrwi10ckl59` (`id_colaborador` ASC) VISIBLE,
  INDEX `FKkcrsrdse2fsvbnk9hybo8349b` (`id_item_acervo` ASC) VISIBLE,
  CONSTRAINT `FKkcrsrdse2fsvbnk9hybo8349b`
    FOREIGN KEY (`id_item_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`),
  CONSTRAINT `FKpodgqn7uk9km0mhrwi10ckl59`
    FOREIGN KEY (`id_colaborador`)
    REFERENCES `museutrezemaio2`.`colaborador` (`id_colaborador`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`jornal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`jornal` (
  `ativo` BIT(1) NOT NULL,
  `codigo_jornal` VARCHAR(255) NOT NULL,
  `data` DATETIME(6) NOT NULL,
  `edicao` VARCHAR(255) NOT NULL,
  `cidade` VARCHAR(255) NULL DEFAULT NULL,
  `estado` VARCHAR(255) NULL DEFAULT NULL,
  `pais` VARCHAR(255) NULL DEFAULT NULL,
  `id_item_acervo` INT NOT NULL,
  PRIMARY KEY (`id_item_acervo`),
  UNIQUE INDEX `UKd1u2in12ab1un31kmf77a4yjq` (`codigo_jornal` ASC) VISIBLE,
  CONSTRAINT `FKof6yo5vx1u8vkia8j1nglq8d1`
    FOREIGN KEY (`id_item_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`livro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`livro` (
  `ano_publicacao` INT NOT NULL,
  `ativo` BIT(1) NOT NULL,
  `codigo_livro` VARCHAR(255) NOT NULL,
  `edicao` VARCHAR(255) NOT NULL,
  `ilustrado` BIT(1) NOT NULL,
  `isbn` VARCHAR(255) NULL DEFAULT NULL,
  `id_item_acervo` INT NOT NULL,
  PRIMARY KEY (`id_item_acervo`),
  UNIQUE INDEX `UK5hvgunwa9xtl0hud0pekbu6jc` (`codigo_livro` ASC) VISIBLE,
  UNIQUE INDEX `UKk8si93wtslp275pv65gity1gg` (`isbn` ASC) VISIBLE,
  CONSTRAINT `FKn0evyjwdwbqqaoen7eakwiim7`
    FOREIGN KEY (`id_item_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`revista`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`revista` (
  `issn` VARCHAR(255) NULL DEFAULT NULL,
  `ano` INT NOT NULL,
  `ativo` BIT(1) NOT NULL,
  `codigo_revista` VARCHAR(255) NOT NULL,
  `edicao` VARCHAR(255) NULL DEFAULT NULL,
  `mes` INT NOT NULL,
  `periodicidade` VARCHAR(255) NULL DEFAULT NULL,
  `volume` VARCHAR(255) NULL DEFAULT NULL,
  `id_item_acervo` INT NOT NULL,
  PRIMARY KEY (`id_item_acervo`),
  UNIQUE INDEX `UKe2bucwh78646sgybf6hi6nt8b` (`codigo_revista` ASC) VISIBLE,
  UNIQUE INDEX `UK1pvb4cgrbexqpuxt6nvxwn6ju` (`issn` ASC) VISIBLE,
  CONSTRAINT `FKehhxq4lfqw4ydwrqsupxlbm9w`
    FOREIGN KEY (`id_item_acervo`)
    REFERENCES `museutrezemaio2`.`item_acervo` (`id_item_acervo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `museutrezemaio2`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `museutrezemaio2`.`usuario` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `ativo` BIT(1) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `nome` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(255) NOT NULL,
  `sobrenome` VARCHAR(255) NOT NULL,
  `tipo` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `UK5171l57faosmj8myawaucatdw` (`email` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
