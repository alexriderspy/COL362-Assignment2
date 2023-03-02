with a0 as (
    select * from forum where
    forum.creationdate :varies
),
a1 as (
    select * from person where
    person.creationdate :varies
),
a as (
    select distinct containerforumid as forumid
    from post,post_hastag_tag p,tag,tagclass
    where
        post.id = p.postid and tag.id = p.tagid and typetagclassid = tagclass.id and containerforumid in (
            select a0.id
            from a0,a1,place
            where a0.moderatorpersonid = a1.id and locationcityid = place.id and partofplaceid = (
                    select id
                    from place
                    where name = 'China')
        )
        and tagclass.name = 'TennisPlayer'
),
b as (
    select count(distinct post.id),containerforumid as forumid ,tagid
    from post,post_hastag_tag p
    where post.containerforumid in (
            select * from a)
        and post.id = p.postid
    group by
        forumid,tagid
),
c as (
    select
        forumid,max(count) as m
    from b
    group by forumid
),
d as (
    select
        c.forumid,tagid,m
    from c,b
    where c.m = b.count and c.forumid = b.forumid
)
select
    forumid,title as forumtitle,tagid as mostpopulartag,m as count
from
    d,forum
where forum.id = d.forumid
order by
    count desc,forumid,forumtitle,mostpopulartag;