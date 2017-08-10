/* UPDATE YourTable
SET CountryName = REPLACE(CountryName, '"', ''); */


select   'UPDATE GT SET [' + column_name + '] =REPLACE(['+ column_name +'], ''"""'', ''''); '
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='GT'