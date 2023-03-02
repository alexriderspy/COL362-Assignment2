\set begindate '\'2010-02-03\'' 
\set middate '\'2010-12-03\'' 
\set enddate '\'2011-05-03\'' 

with a as (
            select
                tagid
            from
                comment_hastag_tag
            where
                (creationdate >= :begindate
                and creationdate <= :middate) or 
                (creationdate >= :middate
                and creationdate <= :enddate)
            union
            select
                tagid
            from
                post_hastag_tag
            where
                (creationdate >= :begindate
                and creationdate <= :middate) or
                (creationdate >= :middate
                and creationdate <= :enddate)
    ),
    d as (
        (select
            a.tagid,
            count(distinct commentid)
        from
            comment_hastag_tag t1,
            a
        where
            a.tagid = t1.tagid
            and creationdate >= :begindate
            and creationdate <= :middate
        group by
            a.tagid)
        union all
        (select
            a.tagid,
            count(distinct postid)
        from
            post_hastag_tag p1,
            a
        where
            a.tagid = p1.tagid
            and creationdate >= :begindate
            and creationdate <= :middate
        group by
            a.tagid)
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
    d2 as (
        (select
            a.tagid,
            count(distinct commentid)
        from
            comment_hastag_tag t1,
            a
        where
            a.tagid = t1.tagid
            and creationdate >= :middate
            and creationdate <= :enddate
        group by
            a.tagid)
        union all
        (select
            a.tagid,
            count(distinct postid)
        from
            post_hastag_tag p1,
            a
        where
            a.tagid = p1.tagid
            and creationdate >= :middate
            and creationdate <= :enddate
        group by
            a.tagid)
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
    )
        select
            tc.name as tagclassname,
            count(distinct tag.id)
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
        group by tc.name
order by
    count desc,
    tagclassname;
