DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SHOWTOP5`(in v_tablename varchar(255))
BEGIN
 
	
      /*  DECLARE v_tablename  varchar(255) DEFAULT ""; */
 
 SELECT TABLENAME,DATAVALUES,percent_of_total 
 FROM distribution_table
 WHERE  TABLENAME=v_tablename
 ORDER BY percent_of_total  desc limit 5;
 
 
END$$
DELIMITER ;
