/*
Data source: https://huggingface.co/datasets/fabiochiu/medium-articles/viewer/default/train
Query inspired by: https://github.com/pgvector/pgvector/issues/645
Table "articles" contains jina-embeddings-v3 embeddings of five medium articles;
Table "medium_articles" contains openai text-embedding-3-small embeddings of medium articles.
*/

SELECT
  a.id, 
  (
    SELECT (a.embedding <#> subvector(ma.embedding, 1, 1024)) * -1
    FROM medium_articles ma
    ORDER BY (a.embedding <#> subvector(ma.embedding, 1, 1024)) * -1 DESC
    LIMIT 1
  ) AS similarity
FROM
  articles a;