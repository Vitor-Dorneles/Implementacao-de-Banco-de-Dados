-- -----------------------------------------------------
-- Popula o banco museutrezemaio2 lendo misc/dados_museu.json
--
-- Ordem: 1. criar_banco.sql  2. popular_banco.sql (este arquivo)
-- Requer leitura de arquivo local habilitada: ver misc/COMO_POPULAR.md
-- Espera o banco vazio: os IDs do JSON são inseridos como estão.
-- -----------------------------------------------------

USE `museutrezemaio2`;
SET NAMES utf8mb4;

-- -----------------------------------------------------
-- Leitura do arquivo JSON para uma tabela temporária (1 linha, 1 coluna)
-- -----------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_json;
CREATE TEMPORARY TABLE tmp_json (conteudo LONGTEXT);

LOAD DATA LOCAL INFILE 'Aulas\Aula-15_TrabalhoEstensionista\Arquivos Informações\Banco Museo Treze\dados_museu.json'
INTO TABLE tmp_json
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '<<sem_separador>>' ESCAPED BY ''
LINES TERMINATED BY '<<fim_do_arquivo>>'
(conteudo);

SET @json = (SELECT conteudo FROM tmp_json LIMIT 1);

-- Interrompe o script com erro se o arquivo não foi lido ou não é um JSON válido
DO JSON_EXTRACT(COALESCE(@json, 'ERRO: arquivo JSON nao foi carregado'), '$');

START TRANSACTION;

-- -----------------------------------------------------
-- assunto
-- -----------------------------------------------------
INSERT INTO assunto (id_assunto, descricao, ativo)
SELECT j.id, j.descricao, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.assuntos[*]' COLUMNS (
    id        INT          PATH '$.idAssunto',
    descricao VARCHAR(255) PATH '$.descricao',
    ativo     VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- colaborador
-- -----------------------------------------------------
INSERT INTO colaborador (id_colaborador, nome, sobrenome, nacionalidade, tipo, ativo)
SELECT j.id, j.nome, j.sobrenome, j.nacionalidade, j.tipo, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.colaboradores[*]' COLUMNS (
    id            INT          PATH '$.idColaborador',
    nome          VARCHAR(255) PATH '$.nome',
    sobrenome     VARCHAR(255) PATH '$.sobrenome',
    nacionalidade VARCHAR(255) PATH '$.nacionalidade',
    tipo          VARCHAR(255) PATH '$.tipo',
    ativo         VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- editora
-- -----------------------------------------------------
INSERT INTO editora (id_editora, nome, cidade, estado, pais, ativo)
SELECT j.id, j.nome, j.cidade, j.estado, j.pais, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.editoras[*]' COLUMNS (
    id     INT          PATH '$.idEditora',
    nome   VARCHAR(255) PATH '$.nome',
    cidade VARCHAR(255) PATH '$.cidade',
    estado VARCHAR(255) PATH '$.estado',
    pais   VARCHAR(255) PATH '$.pais',
    ativo  VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- item_acervo (dados comuns de livros, revistas e jornais)
-- '$.*[*]' percorre todas as listas; só itens de acervo têm idItemAcervo
-- -----------------------------------------------------
INSERT INTO item_acervo (id_item_acervo, titulo, subtitulo, status, idioma, tipo, descricao,
                         notas, visibilidade_notas, numero_paginas, localizacao_acervo, id_editora)
SELECT j.id, j.titulo, j.subtitulo, j.status, j.idioma, j.tipo, j.descricao,
       j.notas, j.visibilidade_notas = 'true', j.numero_paginas, j.localizacao, j.id_editora
FROM JSON_TABLE(@json, '$.*[*]' COLUMNS (
    id                 INT           PATH '$.idItemAcervo',
    titulo             VARCHAR(255)  PATH '$.titulo',
    subtitulo          VARCHAR(255)  PATH '$.subtitulo',
    status             VARCHAR(255)  PATH '$.status',
    idioma             VARCHAR(255)  PATH '$.idioma',
    tipo               VARCHAR(255)  PATH '$.tipo',
    descricao          VARCHAR(2000) PATH '$.descricao',
    notas              VARCHAR(2000) PATH '$.notas',
    visibilidade_notas VARCHAR(5)    PATH '$.visibilidadeNotas',
    numero_paginas     INT           PATH '$.numeroPaginas',
    localizacao        VARCHAR(255)  PATH '$.localizacaoAcervo',
    id_editora         INT           PATH '$.idEditora'
)) AS j
WHERE j.id IS NOT NULL;

-- -----------------------------------------------------
-- livro
-- -----------------------------------------------------
INSERT INTO livro (id_item_acervo, codigo_livro, isbn, edicao, ano_publicacao, ilustrado, ativo)
SELECT j.id, j.codigo, j.isbn, j.edicao, j.ano, j.ilustrado = 'true', j.ativo = 'true'
FROM JSON_TABLE(@json, '$.livros[*]' COLUMNS (
    id        INT          PATH '$.idItemAcervo',
    codigo    VARCHAR(255) PATH '$.codigoLivro',
    isbn      VARCHAR(255) PATH '$.isbn',
    edicao    VARCHAR(255) PATH '$.edicao',
    ano       INT          PATH '$.anoPublicacao',
    ilustrado VARCHAR(5)   PATH '$.ilustrado',
    ativo     VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- revista
-- -----------------------------------------------------
INSERT INTO revista (id_item_acervo, codigo_revista, issn, edicao, volume, periodicidade, ano, mes, ativo)
SELECT j.id, j.codigo, j.issn, j.edicao, j.volume, j.periodicidade, j.ano, j.mes, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.revistas[*]' COLUMNS (
    id            INT          PATH '$.idItemAcervo',
    codigo        VARCHAR(255) PATH '$.codigoRevista',
    issn          VARCHAR(255) PATH '$.issn',
    edicao        VARCHAR(255) PATH '$.edicao',
    volume        VARCHAR(255) PATH '$.volume',
    periodicidade VARCHAR(255) PATH '$.periodicidade',
    ano           INT          PATH '$.ano',
    mes           INT          PATH '$.mes',
    ativo         VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- jornal
-- -----------------------------------------------------
INSERT INTO jornal (id_item_acervo, codigo_jornal, data, edicao, cidade, estado, pais, ativo)
SELECT j.id, j.codigo, j.data, j.edicao, j.cidade, j.estado, j.pais, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.jornais[*]' COLUMNS (
    id     INT          PATH '$.idItemAcervo',
    codigo VARCHAR(255) PATH '$.codigoJornal',
    data   DATE         PATH '$.data',
    edicao VARCHAR(255) PATH '$.edicao',
    cidade VARCHAR(255) PATH '$.cidade',
    estado VARCHAR(255) PATH '$.estado',
    pais   VARCHAR(255) PATH '$.pais',
    ativo  VARCHAR(5)   PATH '$.ativo'
)) AS j;

-- -----------------------------------------------------
-- item_acervo_colaborador / item_acervo_assunto (listas de IDs em cada item)
-- -----------------------------------------------------
INSERT INTO item_acervo_colaborador (id_item_acervo, id_colaborador)
SELECT j.id_item, j.id_colaborador
FROM JSON_TABLE(@json, '$.*[*]' COLUMNS (
    id_item INT PATH '$.idItemAcervo',
    NESTED PATH '$.colaboradores[*]' COLUMNS (id_colaborador INT PATH '$')
)) AS j
WHERE j.id_item IS NOT NULL AND j.id_colaborador IS NOT NULL;

INSERT INTO item_acervo_assunto (id_item_acervo, id_assunto)
SELECT j.id_item, j.id_assunto
FROM JSON_TABLE(@json, '$.*[*]' COLUMNS (
    id_item INT PATH '$.idItemAcervo',
    NESTED PATH '$.assuntos[*]' COLUMNS (id_assunto INT PATH '$')
)) AS j
WHERE j.id_item IS NOT NULL AND j.id_assunto IS NOT NULL;

-- -----------------------------------------------------
-- exemplar
-- -----------------------------------------------------
INSERT INTO exemplar (id_exemplar, codigo, id_acervo, ativo)
SELECT j.id, j.codigo, j.id_acervo, j.ativo = 'true'
FROM JSON_TABLE(@json, '$.exemplares[*]' COLUMNS (
    id        INT          PATH '$.idExemplar',
    codigo    VARCHAR(255) PATH '$.codigo',
    id_acervo INT          PATH '$.idAcervo',
    ativo     VARCHAR(5)   PATH '$.ativo'
)) AS j;

COMMIT;

DROP TEMPORARY TABLE IF EXISTS tmp_json;

-- Resumo
SELECT 'assunto' AS tabela, COUNT(*) AS registros FROM assunto
UNION ALL SELECT 'colaborador', COUNT(*) FROM colaborador
UNION ALL SELECT 'editora', COUNT(*) FROM editora
UNION ALL SELECT 'item_acervo', COUNT(*) FROM item_acervo
UNION ALL SELECT 'livro', COUNT(*) FROM livro
UNION ALL SELECT 'revista', COUNT(*) FROM revista
UNION ALL SELECT 'jornal', COUNT(*) FROM jornal
UNION ALL SELECT 'item_acervo_colaborador', COUNT(*) FROM item_acervo_colaborador
UNION ALL SELECT 'item_acervo_assunto', COUNT(*) FROM item_acervo_assunto
UNION ALL SELECT 'exemplar', COUNT(*) FROM exemplar;
