with a0 as (
    select * from comment_hastag_tag
    where creationdate :varies
),
a01 as (
    select * from post_hastag_tag
    where creationdate :varies
),
a as (
            select
                distinct tagid
            from
                a0
            where
                (creationdate >= '2010-02-03'
                and creationdate <= '2010-12-03')
                or 
                (creationdate >= '2010-12-03'
                and creationdate <= '2011-05-03')
            union
            select
                distinct tagid
            from
                a01
            where
                (creationdate >= '2010-02-03'
                and creationdate <= '2010-12-03') or
                (creationdate >= '2010-12-03'
                and creationdate <= '2011-05-03')
    ),
    b as (
        select
            a.tagid,
            count(distinct commentid)
        from
            a0 t1,
            a
        where
            a.tagid = t1.tagid
            and creationdate >= '2010-02-03'
            and creationdate <= '2010-12-03'
        group by
            a.tagid
    ),
    c as (
        select
            a.tagid,
            count(distinct postid)
        from
            a01 p1,
            a
        where
            a.tagid = p1.tagid
            and creationdate >= '2010-02-03'
            and creationdate <= '2010-12-03'
        group by
            a.tagid
    ),
    d as (
        select
            *
        from
            b
        union all
        select
            *
        from
            c
    ),
    e as (
        select
            tagid,
            sum(count)
        from
            d
        group by
            tagid
    ),
    b2 as (
        select
            a.tagid,
            count(distinct commentid)
        from
            a0 t1,
            a
        where
            a.tagid = t1.tagid
            and creationdate >= '2010-12-03'
            and creationdate <= '2011-05-03'
        group by
            a.tagid
    ),
    c2 as (
        select
            a.tagid,
            count(distinct postid)
        from
            a01 p1,
            a
        where
            a.tagid = p1.tagid
            and creationdate >= '2010-12-03'
            and creationdate <= '2011-05-03'
        group by
            a.tagid
    ),
    d2 as (
        select
            *
        from
            b2
        union all
        select
            *
        from
            c2
    ),
    e2 as (
        select
            tagid,
            sum(count)
        from
            d2
        group by
            tagid
    ),
    f as (
        select
            distinct e.tagid
        from
            e,
            e2
        where
            e.tagid = e2.tagid
            and e.sum >= 5 * e2.sum
    ),
    g as (
        select
            tag.id,
            tc.name
        from
            tag,
            tagclass tc
        where
            tag.id in (
                select
                    *
                from
                    f
            )
            and tag.typetagclassid = tc.id
    )
select
    name as tagclassname,
    count(*)
from
    g
group by
    name
order by
    count desc,
    tagclassname;