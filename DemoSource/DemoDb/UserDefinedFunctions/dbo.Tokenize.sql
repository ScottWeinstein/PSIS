USE [DemoDB]
GO

/****** Object:  UserDefinedFunction [dbo].[Tokenize]    Script Date: 11/05/2010 14:28:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tokenize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Tokenize]
GO

USE [DemoDB]
GO

/****** Object:  UserDefinedFunction [dbo].[Tokenize]    Script Date: 11/05/2010 14:28:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[Tokenize](@text nvarchar(256), @separator nvarchar(1)) 
returns @tokens table (
 token nvarchar(256)
)
begin
 
 --declare @tokens table(token nvarchar(256))
 declare @token nvarchar(256) = ''
 declare @rest nvarchar(256)
 
 set @rest = @text
 while (not (@token is null)) -- repeat as long as a token is found
 begin
 
  set @token = SUBSTRING(@rest, 0, CHARINDEX(@separator, @rest))
  set @rest = SUBSTRING(@rest, CHARINDEX(@separator, @rest)+1, len(@rest))
  
  if (@token = '') 
  begin
   set @token=NULL
   if (@rest <> '') insert into @tokens select @rest -- add last token
  end
  else insert into @tokens select @token -- add token
 end
  
 return
 
end

GO

