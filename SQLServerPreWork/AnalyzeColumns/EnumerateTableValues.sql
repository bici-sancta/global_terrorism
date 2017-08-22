DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EnumerateTableValues`(IN rowstoskip INT)
BEGIN
 
        DECLARE v_finished INTEGER DEFAULT 0;
        DECLARE v_tablename  varchar(255) DEFAULT "";
 
 -- declare cursor for employee email
 DECLARE t_cursor CURSOR FOR 
 SELECT  DISTINCT TABLENAME 
 FROM distribution_table  LIMIT rowstoskip,50;
 
 -- declare NOT FOUND handler
 DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET v_finished = 1;
 
 OPEN t_cursor;
 
 get_tbl: LOOP
 
 FETCH t_cursor INTO v_tablename;

 IF v_finished = 1 THEN 
 LEAVE get_tbl;
 END IF;
 
 call   SHOWTOP5  (v_tablename);
 
 END LOOP get_tbl;
 
 CLOSE t_cursor;
 
END$$
DELIMITER ;
