/*
Query source: https://www.crunchydata.com/blog/pgvector-performance-for-developers
Data source: https://huggingface.co/datasets/timescale/wikipedia-22-12-simple-embeddings/
The query embedding is extracted from the embedding of the tuple with id 19 in the dataset
*/

SELECT
    w1.id AS id1, w2.id AS id2
FROM wiki2 w1, wiki2 w2
WHERE w1.id != w2.id AND w1.id < w2.id
ORDER BY w1.embedding <-> w2.embedding
LIMIT 5;