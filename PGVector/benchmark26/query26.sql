/*
Source: inspired by https://github.com/pgvector/pgvector/issues/174
*/

WITH similar_content AS (
  SELECT 
    id, 
	title,
    embedding <=> (SELECT embedding FROM medium_articles WHERE id = 1) AS distance
  FROM medium_articles
  ORDER BY distance
),
medium_article_ids AS (
  SELECT id
  FROM articles
  WHERE author = 'Ryan Fan'
)
SELECT
  sc.id,
  sc.title,
  sc.distance
FROM similar_content AS sc
WHERE sc.id NOT IN (SELECT id FROM medium_article_ids)
ORDER BY distance;