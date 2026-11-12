-- =============================================================
-- Base fictícia de vendas de ingressos · esquema estrela
-- Compatível com SQLite, PostgreSQL e SQL Server (com ajustes mínimos)
-- =============================================================

CREATE TABLE dim_unidade (
    id_unidade    INTEGER PRIMARY KEY,
    nome_unidade  VARCHAR(60) NOT NULL,
    regiao        VARCHAR(30),
    cidade        VARCHAR(40)
);

CREATE TABLE dim_evento (
    id_evento      INTEGER PRIMARY KEY,
    titulo         VARCHAR(100) NOT NULL,
    linguagem      VARCHAR(30),
    classificacao  VARCHAR(10)
);

CREATE TABLE dim_sessao (
    id_sessao   INTEGER PRIMARY KEY,
    data_hora   TIMESTAMP NOT NULL,
    capacidade  INTEGER NOT NULL
);

CREATE TABLE dim_canal (
    id_canal    INTEGER PRIMARY KEY,
    nome_canal  VARCHAR(30) NOT NULL
);

CREATE TABLE fato_vendas (
    id_venda        INTEGER PRIMARY KEY,
    id_sessao       INTEGER NOT NULL REFERENCES dim_sessao (id_sessao),
    id_evento       INTEGER NOT NULL REFERENCES dim_evento (id_evento),
    id_unidade      INTEGER NOT NULL REFERENCES dim_unidade (id_unidade),
    id_canal        INTEGER NOT NULL REFERENCES dim_canal (id_canal),
    data_venda      DATE NOT NULL,
    quantidade      INTEGER NOT NULL,
    valor_bruto     DECIMAL(10, 2) NOT NULL,
    valor_desconto  DECIMAL(10, 2) DEFAULT 0,
    gratuito        SMALLINT DEFAULT 0      -- 1 = ingresso gratuito
);
