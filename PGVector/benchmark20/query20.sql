/*
Data source: https://huggingface.co/datasets/fabiochiu/medium-articles/viewer/default/train
Query source: https://medium.com/@intuitivedl/the-ultimate-guide-to-using-pgvector-76239864bbfb
Query vector: jina-embeddings-v3 embedding of "COVID-19 pandemic has significantly impacted global health and economies."
*/

WITH first_vec AS (
  SELECT embedding AS query
  FROM articles
  WHERE embedding IS NOT NULL
  LIMIT 1
)
SELECT
  articles.id,
  articles.embedding <#> first_vec.query AS distance
FROM
  articles
  CROSS JOIN first_vec
WHERE
  articles.embedding IS NOT NULL
  AND (articles.embedding <#> first_vec.query) < 0
ORDER BY distance
LIMIT 3;