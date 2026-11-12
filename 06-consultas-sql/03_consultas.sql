-- =============================================================
-- Consultas de negócio · base fictícia de ingressos
-- =============================================================

-- -------------------------------------------------------------
-- Q1. Quantos ingressos e quanta receita cada unidade gerou?
--     Conceitos: JOIN, GROUP BY, SUM, ORDER BY
-- -------------------------------------------------------------
SELECT
    u.nome_unidade,
    SUM(v.quantidade)                      AS ingressos,
    SUM(v.valor_bruto - v.valor_desconto)  AS receita_liquida
FROM fato_vendas v
JOIN dim_unidade u ON u.id_unidade = v.id_unidade
GROUP BY u.nome_unidade
ORDER BY ingressos DESC;


-- -------------------------------------------------------------
-- Q2. Qual a participação de cada canal de venda?
--     Conceitos: subconsulta, percentual sobre o total
-- -------------------------------------------------------------
SELECT
    c.nome_canal,
    SUM(v.quantidade) AS ingressos,
    ROUND(100.0 * SUM(v.quantidade)
          / (SELECT SUM(quantidade) FROM fato_vendas), 1) AS participacao_pct
FROM fato_vendas v
JOIN dim_canal c ON c.id_canal = v.id_canal
GROUP BY c.nome_canal
ORDER BY ingressos DESC;


-- -------------------------------------------------------------
-- Q3. Estamos cumprindo a meta de 30% de gratuidade?
--     Conceitos: CASE WHEN dentro de agregação
-- -------------------------------------------------------------
SELECT
    SUM(quantidade)                                         AS total_ingressos,
    SUM(CASE WHEN gratuito = 1 THEN quantidade ELSE 0 END)  AS gratuitos,
    ROUND(100.0 * SUM(CASE WHEN gratuito = 1 THEN quantidade ELSE 0 END)
          / SUM(quantidade), 1)                             AS gratuidade_pct,
    CASE
        WHEN 1.0 * SUM(CASE WHEN gratuito = 1 THEN quantidade ELSE 0 END)
             / SUM(quantidade) >= 0.30 THEN 'Meta atingida'
        ELSE 'Abaixo da meta'
    END AS status_meta
FROM fato_vendas;


-- -------------------------------------------------------------
-- Q4. Taxa de ocupação por linguagem artística
--     Conceitos: CTE, agregação em dois níveis
--     (a capacidade é somada uma única vez por sessão)
-- -------------------------------------------------------------
WITH vendas_por_sessao AS (
    SELECT id_sessao, id_evento, SUM(quantidade) AS vendidos
    FROM fato_vendas
    GROUP BY id_sessao, id_evento
)
SELECT
    e.linguagem,
    SUM(vs.vendidos)    AS ingressos,
    SUM(s.capacidade)   AS capacidade,
    ROUND(100.0 * SUM(vs.vendidos) / SUM(s.capacidade), 1) AS ocupacao_pct
FROM vendas_por_sessao vs
JOIN dim_sessao s ON s.id_sessao = vs.id_sessao
JOIN dim_evento e ON e.id_evento = vs.id_evento
GROUP BY e.linguagem
ORDER BY ocupacao_pct DESC;


-- -------------------------------------------------------------
-- Q5. Evolução mensal de vendas
--     Conceitos: tratamento de datas
--     SQLite: strftime | PostgreSQL: TO_CHAR | SQL Server: FORMAT
-- -------------------------------------------------------------
SELECT
    strftime('%Y-%m', data_venda) AS mes,
    COUNT(*)                      AS transacoes,
    SUM(quantidade)               AS ingressos
FROM fato_vendas
GROUP BY strftime('%Y-%m', data_venda)
ORDER BY mes;


-- -------------------------------------------------------------
-- Q6. Algum evento cadastrado ainda não vendeu nenhum ingresso?
--     Conceitos: LEFT JOIN + IS NULL
-- -------------------------------------------------------------
SELECT e.id_evento, e.titulo, e.linguagem
FROM dim_evento e
LEFT JOIN fato_vendas v ON v.id_evento = e.id_evento
WHERE v.id_venda IS NULL;


-- -------------------------------------------------------------
-- Q7. Quais são os 2 eventos mais vendidos em cada unidade?
--     Conceitos: função de janela RANK() OVER (PARTITION BY) + CTE
-- -------------------------------------------------------------
WITH ranking AS (
    SELECT
        u.nome_unidade,
        e.titulo,
        SUM(v.quantidade) AS ingressos,
        RANK() OVER (PARTITION BY u.nome_unidade
                     ORDER BY SUM(v.quantidade) DESC) AS posicao
    FROM fato_vendas v
    JOIN dim_evento  e ON e.id_evento  = v.id_evento
    JOIN dim_unidade u ON u.id_unidade = v.id_unidade
    GROUP BY u.nome_unidade, e.titulo
)
SELECT nome_unidade, posicao, titulo, ingressos
FROM ranking
WHERE posicao <= 2
ORDER BY nome_unidade, posicao;


-- -------------------------------------------------------------
-- Q8. Quais unidades têm ticket médio acima de R$ 20?
--     Conceitos: HAVING (filtro depois da agregação)
-- -------------------------------------------------------------
SELECT
    u.nome_unidade,
    ROUND(SUM(v.valor_bruto - v.valor_desconto)
          / SUM(CASE WHEN v.gratuito = 0 THEN v.quantidade END), 2) AS ticket_medio
FROM fato_vendas v
JOIN dim_unidade u ON u.id_unidade = v.id_unidade
GROUP BY u.nome_unidade
HAVING SUM(v.valor_bruto - v.valor_desconto)
       / SUM(CASE WHEN v.gratuito = 0 THEN v.quantidade END) > 20
ORDER BY ticket_medio DESC;
