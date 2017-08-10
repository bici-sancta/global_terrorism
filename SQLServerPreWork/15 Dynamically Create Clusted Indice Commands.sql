
select 'CREATE CLUSTERED INDEX IDX_001 on ' + TABLE_NAME + ' (percent_of_total desc);'
from INFORMATION_SCHEMA.TABLES
order by TABLE_NAME;