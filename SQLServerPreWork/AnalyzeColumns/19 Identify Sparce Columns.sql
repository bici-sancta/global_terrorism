
select *, cast(percent_of_total as decimal(9,3)) as pct 
from Distribution_table
where cast(percent_of_total as decimal(9,3)) > 80 and DATAVALUES in ('NULL','.')
order by 3 desc;

