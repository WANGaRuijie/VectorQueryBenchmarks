/*
Source: https://dzone.com/articles/using-pgvector-to-locate-similarities-in-enterpris
*/

SELECT id, name, industry 
FROM companies
WHERE industry IN (
	SELECT name 
    FROM industries
    WHERE name != 'information technology'
    ORDER BY embedding <-> (
		SELECT embedding
    	FROM industries 
        WHERE name = 'information technology') 
    )
ORDER BY name