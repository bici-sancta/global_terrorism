select 'ALTER TABLE GT  ALTER COLUMN [' +  COLUMN_NAME +']  VARCHAR('+ cast(ColumSize as varchar(5)) +');'
from NewFileSize N
inner join  INFORMATION_SCHEMA.COLUMNS C
on N.ID= C.ORDINAL_POSITION
where TABLE_NAME = 'GT'


