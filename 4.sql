with a0 as 
(
    select * from comment where length :varies
),
a1 as 
(
    select * from post_hastag_tag where creationdate :varies
),
a as (
               select parentpostid as parent
                from a0
                where parentpostid is not null
                group by parentpostid
                having count(distinct id) >= 4
            
        )
,
a2 as (
                select parentcommentid as parent
                from a0
                where parentcommentid is not null
                group by parentcommentid
                having count(distinct id) >= 4
),
b as (
                select tagid,count(distinct ct.postid)
                from a,a1 ct
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
