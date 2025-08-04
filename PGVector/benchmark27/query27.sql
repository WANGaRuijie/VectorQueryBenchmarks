SELECT
    s1.id AS s_id,
    s1.title AS s_title,
    m1.id AS m_id,
    m1.title AS m_title,
	(1 - (s1.embedding <=> m1.embedding)) AS similarity
FROM
    simple_wikipedia s1
CROSS JOIN 
    medium_articles m1
WHERE
    (1 - (s1.embedding <=> m1.embedding)) = (
        SELECT
            MAX(1 - (s2.embedding <=> m2.embedding))
        FROM
            simple_wikipedia s2
        CROSS JOIN
            medium_articles m2
        WHERE
            s1.id = s2.id
    );