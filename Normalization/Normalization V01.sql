
/* CREATE  NORMALIZED TABLES USING EXISTING VALUES AS PRIMARY KEYS */
create table region_tbl as  
select distinct region, region_txt
from GT
order by 1;

create table attacktype1_tbl as  
select distinct attacktype1, attacktype1_txt
from GT
order by 1;

create table country_tbl as  
select distinct country, country_txt
from GT
order by 1;

create table natlty1_tbl as  
select distinct natlty1, natlty1_txt
from GT
order by 1;

create table propextent_tbl as  
select distinct propextent, propextent_txt
from GT
order by 1;

create table targsubtype1_tbl as  
select distinct targsubtype1, targsubtype1_txt
from GT
order by 1;

create table targtype1_tbl as  
select distinct targtype1, targtype1_txt
from GT
order by 1;

create table weapsubtype1_tbl as  
select distinct weapsubtype1, weapsubtype1_txt
from GT
order by 1;

create table weaptype1_tbl as  
select distinct weaptype1, weaptype1_txt
from GT
order by 1;


/*VALIDATE INDIVIDUAL TABLES*/

select GT.eventid, GT.region, R.region_txt
from GT
inner join region_tbl R
on GT.region = R.region;

select GT.eventid, GT.attacktype1, A1.attacktype1_txt
from GT
inner join attacktype1_tbl A1
on GT.attacktype1 = A1.attacktype1;

select GT.eventid, GT.country, C.country_txt
from GT
inner join country_tbl C
on GT.country = C.country;

select GT.eventid, GT.natlty1, N1.natlty1_txt
from GT
inner join natlty1_tbl N1
on GT.natlty1 = N1.natlty1;

select GT.eventid, GT.propextent, P.propextent_txt
from GT
inner join propextent_tbl P
on GT.propextent = P.propextent;

select GT.eventid, GT.targsubtype1, Ts1.targsubtype1_txt
from GT
inner join targsubtype1_tbl Ts1
on GT.targsubtype1 = Ts1.targsubtype1;

select GT.eventid, GT.targtype1, T1.targtype1_txt
from GT
inner join targtype1_tbl T1
on GT.targtype1 = T1.targtype1;

select GT.eventid, GT.weapsubtype1, Ws1.weapsubtype1_txt
from GT
inner join weapsubtype1_tbl Ws1
on GT.weapsubtype1 = Ws1.weapsubtype1;

select GT.eventid, GT.weaptype1, W1.weaptype1_txt
from GT
inner join weaptype1_tbl W1
on GT.weaptype1 = W1.weaptype1;
 
 
 /*DROP COLUMNS FROM ORIGINAL TABLE*/
/*
alter table GT drop column region_txt;
alter table GT drop column attacktype1_txt;
alter table GT drop column country_txt;
alter table GT drop column natlty1_txt;
alter table GT drop column propextent_txt;
alter table GT drop column targsubtype1_txt;
alter table GT drop column targtype1_txt;
alter table GT drop column weapsubtype1_txt;
alter table GT drop column weaptype1_txt;
*/

/*ADD PRIMARY KEYS TO SPEED UP JOIN WITH GT TABLE*/
alter table region_tbl add primary key (region);
alter table attacktype1_tbl add primary key (attacktype1);
alter table country_tbl add primary key (country);
alter table natlty1_tbl add primary key (natlty1);
alter table propextent_tbl add primary key (propextent);
alter table targsubtype1_tbl add primary key (targsubtype1);
alter table targtype1_tbl add primary key (targtype1);
alter table weapsubtype1_tbl add primary key (weapsubtype1);
alter table weaptype1_tbl add primary key (weaptype1);

/*CREATE INDEX ON GT TABLE TO SPEED UP JOINS*/
create index idx_01 on GT (region);
create index idx_02 on GT (attacktype1);
create index idx_03 on GT (country);
create index idx_04 on GT (natlty1);
create index idx_05 on GT (propextent);
create index idx_06 on GT (targsubtype1);
create index idx_07 on GT (targtype1);
create index idx_08 on GT (weapsubtype1);
create index idx_09 on GT (weaptype1);


/*VALIDATE ALL TABLES WITH ORIGINAL USING JOINS*/
select COUNT(*)
from GT
inner join region_tbl R
on GT.region = R.region
inner join attacktype1_tbl A1
on GT.attacktype1 = A1.attacktype1
inner join country_tbl C
on GT.country = C.country
inner join natlty1_tbl N1
on GT.natlty1 = N1.natlty1
inner join propextent_tbl P
on GT.propextent = P.propextent
inner join targsubtype1_tbl Ts1
on GT.targsubtype1 = Ts1.targsubtype1
inner join targtype1_tbl T1
on GT.targtype1 = T1.targtype1
inner join weapsubtype1_tbl Ws1
on GT.weapsubtype1 = Ws1.weapsubtype1
inner join weaptype1_tbl W1
on GT.weaptype1 = W1.weaptype1;