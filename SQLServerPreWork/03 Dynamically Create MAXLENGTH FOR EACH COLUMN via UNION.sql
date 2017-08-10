select  'select max(len([' +column_name+ '])) from GT UNION ALL'
from   INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='GT'
order by ORDINAL_POSITION