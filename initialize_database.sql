-- Project part 4: SQL script to create the database
drop table if exists base_mvitali.publication_facts;
drop table if exists base_mvitali.product_facts;
drop table if exists base_mvitali.contributor_dim;
drop table if exists base_mvitali.product_dim;

create table base_mvitali.product_dim
(
  barcode                   varchar(30) not null,
  product_name              varchar(255) null,
  product_group             varchar(255) null,
  nutrition_letter          varchar(1) null,
  nutrition_score           int null,
  nova_group                varchar(1) null,
  date_created              datetime not null,
  date_modified             datetime not null,
  primary key (barcode)
);

create table base_mvitali.contributor_dim
(
  contributor_name          varchar(30) not null,
  primary key (contributor_name)
);

create table base_mvitali.publication_facts
(
  id                        int auto_increment not null,
  contributor               varchar(30) not null,
  product                   varchar(30) not null,
  date_created              datetime not null,
  date_modified             datetime not null,
  has_nutrition_score       int,
  primary key (id),
  foreign key (contributor) references contributor_dim(contributor_name),
  foreign key (product)     references product_dim(barcode)
);

create table base_mvitali.product_facts
(
  id                        int auto_increment not null,
  contributor               varchar(30) not null,
  product                   varchar(30) not null,
  date_created              datetime not null,
  date_modified             datetime not null,
  score                     float,
  primary key (id),
  foreign key (contributor) references contributor_dim(contributor_name),
  foreign key (product)     references product_dim(barcode)
);

-- Project part 5: Filling the dimensional and fact tables. I.e. 'Kettle part'
-- Product dimension (is shared)
insert into base_mvitali.product_dim(barcode, product_name, product_group, date_created, date_modified, nutrition_score, nutrition_letter, nova_group)
select 
  pv.barcode,
  pv.product_name,
  coalesce(pv.pnns2, '') as product_group,
  pv.date_creation as date_created,
  pv.date_modification as date_modified,
  pv.nutrition_score_fr as nutrition_score,
  pv.nutriscore_lettre as nutrition_letter,
  pv.nova_group
from base_bousse.OFF_2_version_produit as pv
inner join (
  select barcode, max(date_modification_int) as latest_modification
  from base_bousse.OFF_2_version_produit
  group by barcode
) as le on pv.barcode = le.barcode and pv.date_modification_int = le.latest_modification;

-- Contributor dimension (is shared)
insert into base_mvitali.contributor_dim(contributor_name)
select c.pseudo as contributor_name
from base_bousse.OFF_2_contributeur as c left join base_bousse.OFF_2_version_produit as pv on c.pseudo = pv.pseudo
group by c.pseudo;

-- Publication fact table
insert into base_mvitali.publication_facts(contributor, product, date_created, date_modified, has_nutrition_score)
select
  pv.pseudo as contributor,
  pv.barcode as product,
  pv.date_creation as date_created,
  pv.date_modification as date_modified,
  if(pv.nutrition_score_fr is null, 0, 1) as has_nutrition_score
from base_bousse.OFF_2_version_produit as pv;

-- Product fact table
insert into base_mvitali.product_facts(contributor, product, date_created, date_modified, score)
select
  le.contributor,
  p.barcode,
  p.date_created,
  p.date_modified,
  p.nutrition_score as score
from base_mvitali.product_dim as p
inner join (
  select barcode, pseudo as contributor, max(date_modification) as latest_modification
  from base_bousse.OFF_2_version_produit
  group by barcode, pseudo
) as le on p.barcode = le.barcode and p.date_modified = le.latest_modification
where p.nutrition_score is not null;