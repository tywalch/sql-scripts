USE [Your Database]
GO

CREATE Function [dbo].[FloatingDate] (@Order int, @Weekday int, @Month int)
returns date
as
BEGIN
 DECLARE @holiday date
 DECLARE @MonthStart date, @DayModifier int
SET @MonthStart = DATEFROMPARTS(YEAR(GETDATE()), @Month, 1)
SET @DayModifier = (@Order - 1) * 7
IF DATEPART(dw, EOMonth(@MonthStart)) > @Weekday and @Order < 0 
 BEGIN
  SET @DayModifier = @DayModifier - 7
 END
ELSE IF DATEPART(dw, @MonthStart) > @Weekday
 BEGIN
  SET @DayModifier = @DayModifier + 7
 END

IF @Order < 0 
 BEGIN
  SET @Holiday = DATEADD(dd, (@Weekday - DATEPART(dw, EOMONTH(@MonthStart)) + @DayModifier), EOMONTH(@MonthStart))
 END
ELSE
 BEGIN
  SET @Holiday = DATEADD(dd, (@Weekday - DATEPART(dw, @MonthStart) + @DayModifier), @MonthStart)
 END

 RETURN @Holiday
END
GO


