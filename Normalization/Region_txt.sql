
create  table region_tbl as  
select   distinct region,region_txt
from GT
order by 1;


alter table GT drop column region_txt;

select  GT.eventid,GT.region,R.region_txt
from  GT 
inner join region_tbl R
 on GT.region = R.region 