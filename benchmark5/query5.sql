/*
Source: https://www.architecture-performance.fr/ap_blog/vector-similarity-search-with-pgvector/#the-simple-english-wikipedia-dataset
Note: We select the first five rows from the dataset https://huggingface.co/datasets/rahular/simple-wikipedia/viewer/default/train?views%5B%5D=train&row=45 to be the input example
*/

SELECT b.title, (a.embedding <#> b.embedding) * -1 as similarity
FROM simple_wikipedia a cross join simple_wikipedia b
WHERE b.id != 0 and a.id = 0
ORDER BY similarity desc;