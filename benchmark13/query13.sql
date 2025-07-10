/*
Data source: https://www.architecture-performance.fr/ap_blog/vector-similarity-search-with-pgvector/#the-simple-english-wikipedia-dataset
Query source: https://github.com/pgvector/pgvector
Note: Rerank candidates with exact cosine similarity after initial approximate ranking using binary quantization
*/
WITH initial_candidates AS (
    SELECT id, title, embedding
    FROM simple_wikipedia
    ORDER BY
        binary_quantize(embedding) <~> (SELECT binary_quantize(embedding) FROM simple_wikipedia WHERE title = 'Art')
    LIMIT 4
) SELECT id, title, embedding <=> (
	SELECT embedding FROM simple_wikipedia WHERE title = 'Art') AS cosine_distance
  FROM initial_candidates
  ORDER BY cosine_distance
  LIMIT 3;
