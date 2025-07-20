/*
Source: https://docs.pingcap.com/tidbcloud/vector-search-get-started-using-sql/
*/

SELECT id, document, vec_cosine_distance(embedding, '[1,2,3]') AS distance
FROM embedded_documents
ORDER BY distance;