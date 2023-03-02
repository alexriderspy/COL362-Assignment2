CREATE INDEX idx_comment_hasTag_creationdate ON Comment_hasTag_Tag (creationdate);
CREATE INDEX idx_post_hasTag_creationdate ON Post_hasTag_Tag (creationdate);

\set begindate '\'2010-02-03\''
\set middate '\'2010-12-03\''
\set enddate '\'2011-05-03\''

WITH comment_counts_first AS (
    SELECT
        tagid,
        COUNT(*) AS count
    FROM
        Comment_hasTag_Tag
    WHERE 
        creationdate >= :begindate AND creationdate <= :middate 
    GROUP BY
        tagid
    HAVING count(*)>0
),
post_counts_first AS (
    SELECT
        tagid,
        COUNT(*) AS count
    FROM
        Post_hasTag_Tag
    WHERE
        creationdate >= :begindate AND creationdate <= :middate
    GROUP BY
        tagid
    HAVING count(*)>0
),

comment_counts_second AS (
    SELECT
        tagid,
        COUNT(*) AS count
    FROM
        Comment_hasTag_Tag
    WHERE 
        creationdate >= :middate AND creationdate <= :enddate 
    GROUP BY
        tagid
    HAVING count(*)>0

),
post_counts_second AS (
    SELECT
        tagid,
        COUNT(*) AS count
    FROM
        Post_hasTag_Tag
    WHERE
        creationdate >= :middate AND creationdate <= :enddate
    GROUP BY
        tagid
    HAVING count(*)>0
),

uniontags_first AS (
    SELECT tagid, SUM(count) AS first_sum
    FROM (
        SELECT tagid, count FROM comment_counts_first
        UNION ALL
        SELECT tagid, count FROM post_counts_first
    ) AS combined_tables1
    GROUP BY tagid
),


uniontags_second AS (
    SELECT tagid, SUM(count) AS second_sum
    FROM (
        SELECT tagid, count FROM comment_counts_second
        UNION ALL
        SELECT tagid, count FROM post_counts_second
    ) AS combined_tables2
    GROUP BY tagid
),


unionfirst_second AS (
    SELECT uniontags_first.tagid
    FROM uniontags_first, uniontags_second
    WHERE (uniontags_first.tagid = uniontags_second.tagid) AND (uniontags_second.second_sum*5 <= uniontags_first.first_sum)
)

SELECT tagclass.name as tagclassname, count(*) as count
FROM unionfirst_second, tag, tagclass
WHERE unionfirst_second.tagid = tag.id AND tag.typetagclassid = tagclass.id
GROUP by tagclass.name
ORDER BY count desc, tagclassname;

drop index idx_post_hasTag_creationdate;
drop index idx_comment_hasTag_creationdate;