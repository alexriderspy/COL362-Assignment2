\set X 4

create index idx_tag on 
tag(id);

create index idx_comment_tag on 
comment_hastag_tag(tagid);

create index idx_post_tag on 
post_hastag_tag(tagid);

create index idx_post on 
comment(parentpostid);

create index idx_comment on 
comment(parentcommentid);

with a as (
               select parentpostid as parent
                from comment
                group by parentpostid
                having count(id) >= :X            
        )
,
a2 as (
                select parentcommentid as parent
                from comment
                group by parentcommentid
                having count(id) >= :X
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


drop index idx_tag;
drop index idx_comment;
drop index idx_comment_tag;
drop index idx_post;
drop index idx_post_tag;