USE [Global_Terrorism]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[GENERATE_DIST_TABLES]

SELECT	'Return Value' = @return_value

GO
