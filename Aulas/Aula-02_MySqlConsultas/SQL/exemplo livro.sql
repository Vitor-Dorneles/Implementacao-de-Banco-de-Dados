-- Criando Banco
CREATE DATABASE biblioteca;
-- Colocar o banco criado em uso
USE BIBLIOTECA;
-- Criar Tabela
CREATE TABLE BIBLIOTECA.AUTOR
(
id INT PRIMARY KEY auto_increment,
nome VARCHAR(50) NOT NULL,
nacionalidade VARCHAR(30) NOT NULL
);

CREATE TABLE LIVRO 
(
id int primary key auto_increment,
titulo text not null,
ano_publicacao year,
fk_id_autor INT,
foreign key (fk_id_autor) references AUTOR(ID)
);
-- A FK PODE SER ADICIONADA POR ALTERAÇÃO TAMBÉM
-- ALTER TABLE LIVRO
-- ADD CONSTRAINT FK_AUTOR --NOME DA RESTRIÇÃO
-- FOREIGN KEY(FK_ID_AUTOR) REFERENCES AUTOR(ID);

-- Adicionando nova coluna
Alter TABLE livro
ADD genero VARCHAR(100);

-- REMOVER UMA COLUNA
ALTER TABLE livro
drop column genero;

-- Modificar tipo de uma coluna
ALTER TABLE autor
MODIFY column NACIONALIDADE char(2);

-- Alterando nome de uma coluna
ALTER TABLE livro
CHANGE ID ISBN VARCHAR(20);

