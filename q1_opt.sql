create index idx_p1id on person_knows_person(person1id);
create index idx_p2id on person_knows_person(person2id);
create index idx_post on post(creationdate);
create index idx_comment on comment(length);

\set K 2
\set X 10
\set taglist '(\'Frank_Sinatra\',\'William_Shakespeare\',\'Elizabeth_II\',\'Adolf_Hitler\',\'George_W._Bush\')'
\set commentlength 100
\set lastdate '\'2011-07-19\''


--explain analyze 


with a as (select id from tag where name in :taglist),
b as (select personid, tagid from person_hasinterest_tag where tagid in (select * from a)), 

postmsg as (select id, creatorpersonid from post where creationdate < :lastdate), 
commmsg as (select id, creatorpersonid from comment where length > :commentlength), 

post_like as (select distinct personid, postid from person_likes_post plp where postid in (select distinct id from postmsg)),
comment_like as (select distinct personid, commentid from person_likes_comment plc where commentid in (select distinct id from commmsg)),


e as (
  select b1.personid as p1id, b2.personid as p2id
  from b b1, b b2
  where :K=0 and b1.personid < b2.personid
  union ALL
  select b1.personid as p1id, b2.personid as p2id
  from b b1, b b2 
  where :K>0 and b1.tagid = b2.tagid and b1.personid < b2.personid 
  group by p1id, p2id having count(distinct b1.tagid) >= :K
),

f as (select * from e except select person1id, person2id from person_knows_person),

g as (select p1id, p2id, person2id as p3id from f, person_knows_person pkp where f.p1id = pkp.person1id),

g2 as (select p1id, p2id, p3id from g where (p2id, p3id) in (select person1id, person2id from person_knows_person)),

g3 as (select p1id, p2id, p3id from g where (p3id, p2id) in (select person1id, person2id from person_knows_person)),

g1 as (select p1id, p2id, person1id as p3id from f, person_knows_person pkp where f.p1id = pkp.person2id),


g12 as (select p1id, p2id, p3id from g1 where (p3id, p2id) in (select person1id, person2id from person_knows_person)),
h as (select * from g2 union select * from g3 union select * from g12),
p1id_h as (select distinct p1id from h),
p2id_h as (select distinct p2id from h),
post_like_p1id as (select distinct p1id, postid from p1id_h, post_like where post_like.personid = p1id_h.p1id),
post_like_p2id as (select distinct p2id, postid from p2id_h, post_like where post_like.personid = p2id_h.p2id),
i as (select h.p1id, p2id, p3id, postid from h, post_like_p1id where h.p1id = post_like_p1id.p1id),
j as (select p1id, i.p2id, p3id, i.postid from i, post_like_p2id where i.p2id = post_like_p2id.p2id and i.postid = post_like_p2id.postid),
k as (select p1id, p2id, p3id, postid as msgid from j where (postid,p3id) in (select * from postmsg)),
com_like_p1id as (select distinct p1id, commentid from p1id_h, comment_like where comment_like.personid = p1id_h.p1id),
com_like_p2id as (select distinct p2id, commentid from p2id_h, comment_like where comment_like.personid = p2id_h.p2id),
i2 as (select h.p1id, p2id, p3id, commentid from h, com_like_p1id where h.p1id = com_like_p1id.p1id),
j2 as (select p1id, i2.p2id, p3id, i2.commentid from i2, com_like_p2id where i2.p2id = com_like_p2id.p2id and i2.commentid = com_like_p2id.commentid),
k2 as (select p1id, p2id, p3id, commentid as msgid from j2, commmsg where commmsg.id = j2.commentid and commmsg.creatorpersonid = j2.p3id),
k12 as (select * from k union select * from k2),

l as(
  select p1id, p2id from h
  where :X<1
  UNION ALL
  SELECT p1id, p2id FROM k12
  WHERE :X>0
  GROUP BY p1id, p2id
  HAVING COUNT(DISTINCT msgid) >= :X
),
m as (select h.p1id, h.p2id, p3id from l,h where l.p1id = h.p1id and l.p2id = h.p2id)
select p1id as person1sid, p2id as person2sid, count(p3id) as mutualfriendcount from m group by p1id, p2id order by p1id, mutualfriendcount desc, p2id;


drop index idx_p1id;
drop index idx_p2id;
drop index idx_post;
drop index idx_comment;