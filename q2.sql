\set startdate '\'2010-06-01\''
\set enddate '\'2012-07-01\''
\set country_name '\'China\''
with u1 as (
    select
        distinct universityid,
        personid
    from
        person_studyat_university
),
b1 as (
    select
        distinct id,
        date_part('month', birthday) as month
    from
        person
),
c1 as (
    select
        id
    from
        person
    where
        locationcityid in (
            select
                id
            from
                place
            where
                partofplaceid = (
                    select
                        id
                    from
                        place
                    where
                        name = :country_name
                )
        )
        and creationdate > :startdate
        and creationdate < :enddate
),
d1 as (
    select
        distinct person1id,
        person2id
    from
        person_knows_person
    where
        person1id in (
            select
                *
            from
                c1
        )
        and person2id in (
            select
                *
            from
                c1
        )
    union
    select
        distinct person2id,
        person1id
    from
        person_knows_person
    where
        person1id in (
            select
                *
            from
                c1
        )
        and person2id in (
            select
                *
            from
                c1
        )
),
fin as 
(select
    distinct p1.person1id,
    p1.person2id,
    p2.person1id
from
    d1 p1,
    d1 p2,
    u1,
    b1
where
    p1.person1id < p1.person2id
    and p1.person2id < p2.person1id
    and p1.person2id = p2.person2id
    and (
        (p1.person1id, p2.person1id) in (
            select
                *
            from
                d1
        )
        or (p2.person1id, p1.person1id) in (
            select
                *
            from
                d1
        )
    )
    and p1.person1id = u1.personid
    and u1.universityid = (
        select
            universityid
        from
            u1
        where
            u1.personid = p1.person2id
    )
    and u1.universityid = (
        select
            universityid
        from
            u1
        where
            u1.personid = p2.person1id
    )
    and p1.person1id = b1.id
    and b1.month = (
        select
            month
        from
            b1
        where
            b1.id = p1.person2id
    )
    and b1.month = (
        select
            month
        from
            b1
        where
            b1.id = p2.person1id
    )
) 
select count(*) from fin;