/*
Source: https://aws.amazon.com/cn/blogs/database/building-ai-powered-search-in-postgresql-using-amazon-sagemaker-and-pgvector/
*/
SELECT product_id, embeddings, embeddings <-> '[3,1,2]' AS distance
FROM test_embeddings 
ORDER BY embeddings <-> '[3,1,2]';