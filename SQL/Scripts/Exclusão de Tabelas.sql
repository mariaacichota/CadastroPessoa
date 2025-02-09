IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PESSOA]') AND type in (N'U'))
BEGIN
	DROP TABLE PESSOA;
END
