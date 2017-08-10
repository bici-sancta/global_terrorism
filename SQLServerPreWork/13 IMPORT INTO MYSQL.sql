select 'LOAD DATA LOCAL INFILE ''' + table_name +'.csv'' INTO TABLE TABLE_NAME
FIELDS TERMINATED BY  ","
LINES TERMINATED BY "\r\n"
(column1, percent_of_total)'
from INFORMATION_SCHEMA.TABLES

