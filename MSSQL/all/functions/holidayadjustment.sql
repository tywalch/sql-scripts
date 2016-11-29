USE [Your Database]
GO

CREATE Function [dbo].[HolidayAdjustment] (@ReferenceDate int)
returns date
as
BEGIN
	DECLARE @AdjustedHoliday date

	IF DATEPART(dw, @ReferenceDate) = 1
		SET @AdjustedHoliday = DATEADD(dd,1,@ReferenceDate)
	ELSE IF DATEPART(dw, @ReferenceDate) = 7
		SET @AdjustedHoliday = DATEADD(dd, -1, @ReferenceDate)
	ELSE 
		SET @AdjustedHoliday = @ReferenceDate

	RETURN @AdjustedHoliday
END
GO


