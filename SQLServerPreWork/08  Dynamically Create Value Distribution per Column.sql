USE [Global_Terrorism]
GO

/****** Object:  StoredProcedure [dbo].[Show_Column_Distribution]    Script Date: 7/13/17 1:17:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dbo].[Show_Column_Distribution]
(
  @ColumName varchar(220)
)
as
DECLARE @myrowcount as float;
DECLARE @SQLSTMT  as nvarchar(MAX);
set @myRowcount = (select count(*) from GT);


SET @SQLSTMT = 'select  distinct '  + @ColumName + ', round(count(' + @ColumName + ') OVER (PARTITION BY ' + @ColumName + ' ORDER BY ' + @ColumName + ')/ cast(' + cast(@myrowcount as varchar(25)) +' as float),4)*100 AS percent_of_total INTO '+ @ColumName + '_TBL from GT order by 2 desc;'

/* select @SQLSTMT  */

exec sp_executesql @SQLSTMT ; 

/*select  distinct country_txt, round(count(country_txt) OVER (PARTITION BY country_txt order by country_txt)/@myrowcount,8)*100 AS percent_of_total
from GT
order by 2 desc; */

GO

