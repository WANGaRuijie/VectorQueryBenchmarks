/*
Data source: https://www.architecture-performance.fr/ap_blog/vector-similarity-search-with-pgvector/#the-simple-english-wikipedia-dataset
Query source: https://github.com/pgvector/pgvector
Note: first rank by similarity of a sparse vector, then rerank with exact cosine similarity to the first result
*/
WITH sparse_vector_cosine_similarity AS (
    SELECT 
        id, 
        (1 - (embedding <=> '{10:1, 25:1, 150:1}/1536'::sparsevec)) AS cosine_similarity
    FROM 
        simple_wikipedia
)
SELECT
    a.id,
    a.title,
    b.cosine_similarity
FROM
    simple_wikipedia a 
JOIN 
    sparse_vector_cosine_similarity b ON a.id = b.id 
WHERE 
    a.id != 1 
ORDER BY
   (1 - (a.embedding <=> (SELECT embedding FROM simple_wikipedia WHERE id = 1)))
LIMIT 3;