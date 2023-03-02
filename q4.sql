\set X 4
with a as (
               select parentpostid as parent
                from comment
                where parentpostid is not null
                group by parentpostid
                having count(distinct id) >= :X
            
        )
,
a2 as (
                select parentcommentid as parent
                from comment
                where parentcommentid is not null
                group by parentcommentid
                having count(distinct id) >= :X
),
b as (
                select tagid,count(distinct ct.postid)
                from a,post_hastag_tag ct
                where a.parent = ct.postid
                group by tagid

),
b2 as (
   select tagid,count(distinct ct.commentid)
                from a2,comment_hastag_tag ct
                where a2.parent = ct.commentid
                group by tagid
),
c as (
select * from b union select * from b2     
)
select name as tagname,sum(count) as count
from c,tag
where c.tagid = tag.id
group by tagid,name
order by count desc,tagname
limit 10;
