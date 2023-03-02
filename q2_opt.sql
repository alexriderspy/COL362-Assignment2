create index idx_creationdate_person on
person(creationdate);

\set startdate '\'2010-06-01\''
\set enddate '\'2012-07-01\''
\set country_name '\'China\''

with peopletable as(
select Person.id as personid, EXTRACT(MONTH FROM birthday) as month_birth, UniversityId
FROM person, place personplace, place countryplace, person_studyat_university
where countryplace.name = :country_name AND countryplace.id = personplace.partofplaceid AND person.LocationCityId = personplace.id AND person.creationDate < :enddate AND person.creationDate > :startdate AND person.id = Person_studyAt_University.PersonId
),

person_smon_suniv as(
    select p1id.personid as frnd1 , p2id.personid as frnd2, p1id.universityid as univ_id
    FROM peopletable p1id, peopletable p2id, person_knows_person
    where person_knows_person.Person1id=p1id.personid AND person_knows_person.Person2id=p2id.personid AND p1id.month_birth=p2id.month_birth AND p1id.universityid=p2id.universityid
),

friend_triples as(
    select pair1.frnd1 as friend_1 , pair1.frnd2 as friend_2, pair2.frnd2 as friend_3 
    from  person_smon_suniv pair1, person_smon_suniv pair2, person_smon_suniv pair3
    where pair1.frnd2 = pair2.frnd1 AND pair1.univ_id = pair2.univ_id AND pair3.frnd1 = pair1.frnd1 AND pair3.frnd2 = pair2.frnd2
)

select count(*)
FROM friend_triples;

drop index idx_creationdate_person;