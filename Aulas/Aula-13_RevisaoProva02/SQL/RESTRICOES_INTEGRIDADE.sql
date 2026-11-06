-- Restrições de integridade: banco LOJA
CREATE DATABASE LOJA;
GO
USE LOJA;
GO

GO
CREATE TABLE CATEGORIA(
	id INT PRIMARY KEY,
	nome VARCHAR(60) NOT NULL,
	CONSTRAINT uq_categoria_nome UNIQUE (nome) -- nome repetido dá erro
);

CREATE TABLE FORNECEDOR(
	id INT PRIMARY KEY,
	nome VARCHAR(60) NOT NULL,
	telefone VARCHAR(20) NULL -- significa que pode aceitar campos vazios
);
GO
-- IDENTITY (início, incremento): ids 100, 101, 102...
CREATE TABLE PRODUTO(
	id INT IDENTITY (100,1) PRIMARY KEY, -- identity mesma coisa que auto_incrementy
	nome VARCHAR(80) NOT NULL,
	preco DECIMAL (10,2) NOT NULL,
	quantidade INT NOT NULL CONSTRAINT df_prod_qtde DEFAULT 0, -- se cadastrar um produto sem a quantidade vai ser colocado zero automaticamente
	situacao VARCHAR(10) NOT NULL DEFAULT 'Ativo', -- sem CONSTRAINT nome, o banco gera um nome automático (DF__PRODUTO__situa__...); para alterar, precisa descobrir esse nome (consulta no fim)
	id_categoria INT NOT NULL,
	id_fornecedor INT NULL,
	-- restrição para o preço produto: dentro do CHECK pode colocar qualquer operacao logica
	CONSTRAINT ck_produto_preco CHECK (preco > 0),
	CONSTRAINT ck_produto_qtde CHECK (quantidade >= 0),
	CONSTRAINT ck_produto_situacao CHECK (situacao IN ('Ativo','Inativo')),

	-- apagar ou mudar o id da categoria propaga para os produtos
	CONSTRAINT fk_prod_categoria
		FOREIGN KEY (id_categoria) REFERENCES CATEGORIA (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
-- demonstrar que pode adicionar
GO
ALTER TABLE PRODUTO
ADD CONSTRAINT fk_prod_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES FORNECEDOR (id)
	ON DELETE SET NULL -- por isso id_fornecedor aceita NULL
	ON UPDATE CASCADE;
GO

-- Inserir alguns valores
INSERT INTO CATEGORIA (id,nome) VALUES
	(10,'Informática'),
	(20,'Papelaria'),
	(30,'Acessorios');
INSERT INTO FORNECEDOR (id,nome,telefone) VALUES
	(1,'Distribuidora Alfa','555-6666'),
	(2,'Comercial Ltda',NULL);

-- sem o id: quem gera é o IDENTITY
INSERT INTO PRODUTO (nome,preco,quantidade,situacao,id_categoria,id_fornecedor)
VALUES
		('Mouse sem fio',79.99,15,'Ativo',10,1),
		('Teclado USB',120,8,'Ativo',10,2),
		('Caderno',29.90,50,'Ativo',20,2),
		('Caneta',4.50,100,'Ativo',20,2);
-- sem quantidade e situacao: entram os DEFAULT (0 e 'Ativo')
INSERT INTO PRODUTO (nome,preco,id_categoria)
VALUES ('Fone de ouvido',99.90,30)

SELECT * FROM PRODUTO;

INSERT INTO CATEGORIA VALUES (40,'Papelaria');-- vai dar erro, pois já tem papelaria UNIQUE KEY TEM DEFINIDO NA TABELA

-- TESTANDO CASCADE: ON UPDATE CASCADE
UPDATE CATEGORIA
SET id = 11
WHERE id = 10; -- ao executar na mensagem informa que afetou somente um linha, sendo que foi 2, POR ISSO É NECESSÁRIO TER CUIDADO COM CASCADE

-- ON DELETE SET NULL
DELETE FROM FORNECEDOR
WHERE id = 1; -- Mouse sem fio fica com id_fornecedor NULL

-- ON DELETED CASCADE: cuidar a IA gosta de implementar CASCADE nos bancos
DELETE FROM CATEGORIA
WHERE id = 20; -- apaga junto Caderno e Caneta
SELECT * FROM CATEGORIA;
SELECT * FROM PRODUTO;

-- testando CHECK
INSERT INTO PRODUTO (nome,preco,id_categoria)
VALUES ('Brinde',0,30); -- erro: ck_produto_preco
UPDATE PRODUTO
SET situacao = 'Esgotado'
WHERE nome = 'Teclado USB'; -- erro: ck_produto_situacao

-- nome que o banco gerou para o DEFAULT sem nome (situacao)
SELECT name, definition
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('PRODUTO');
