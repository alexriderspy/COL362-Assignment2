create index idx_post on
post(id);

create index idx_post_hastag_tag on
post_hastag_tag(postid);

create index idx_post2 on
post(containerforumid);

create index idx_forum on
forum(moderatorpersonid);

\set country_name '\'India\''
\set tagclass '\'TennisPlayer\''


with a as (
    select distinct containerforumid as forumid
    from post,post_hastag_tag p,tag,tagclass
    where
        post.id = p.postid and tag.id = p.tagid and typetagclassid = tagclass.id and containerforumid in (
            select forum.id
            from forum,person,place
            where forum.moderatorpersonid = person.id and locationcityid = place.id and partofplaceid = (
                    select id
                    from place
                    where name = :country_name)
        )
        and tagclass.name = :tagclass
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



drop index idx_post;
drop index idx_post_hastag_tag;
drop index idx_post2;
drop index idx_forum;