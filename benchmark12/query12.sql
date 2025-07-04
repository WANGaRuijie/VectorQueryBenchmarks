/*
Data source: https://www.architecture-performance.fr/ap_blog/vector-similarity-search-with-pgvector/#the-simple-english-wikipedia-dataset
Query source: https://github.com/pgvector/pgvector
*/
SELECT title, binary_quantize(embedding)::bit(3) AS binary_vector, binary_quantize(embedding)::bit(3) <~> binary_quantize('[1,-2,3]'::vector) AS hamming_similarity
FROM simple_wikipedia 
ORDER BY hamming_similarity 