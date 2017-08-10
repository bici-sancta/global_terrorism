select  'Select '''+ table_name + ''', * from ' + TABLE_NAME + ' union all '
from INFORMATION_SCHEMA.TABLES
where table_name like '%TBL'
order by TABLE_NAME