/*
Source: https://github.com/sfoteini/vector-search-azure-cosmos-db-postgresql/tree/main?tab=readme-ov-file
*/

SELECT title, author, subvector(image_vector, 1, 128) <-> (SELECT subvector(image_vector, 1, 128) FROM paintings WHERE title = 'The Persistence of Memory') AS subvector_similarity
FROM paintings
WHERE author = 'Vincent van Gogh' OR author = 'Diego Velázquez'