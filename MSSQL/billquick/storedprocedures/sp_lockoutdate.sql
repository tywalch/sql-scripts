USE [Your Database]
GO

CREATE PROCEDURE [dbo].[sp_LockoutDate]
AS
BEGIN

	DECLARE @day_value date, @FirstOfTheMonth date, @SixteenthOfTheMonth date, @FirstPayPeriodEnd date, @SixteenthPayPeriodEnd date
	DECLARE @day_int int, @lockout_int int, @DaysSinceLastSixteenth int
	DECLARE @lockout_value nvarchar(10)
	SET @day_value = GETDATE()
	SET @day_int = DAY(@day_value)
	SET @FirstOfTheMonth = DATEFROMPARTS(YEAR(GETDATE()),MONTH(@day_value),1)
	SET @SixteenthOfTheMonth = DATEFROMPARTS(YEAR(GETDATE()),MONTH(@day_value),16)
	SET @FirstPayPeriodEnd = @FirstOfTheMonth
	SET @SixteenthPayPeriodEnd = @SixteenthOfTheMonth
	SET @DaysSinceLastSixteenth = DATEDIFF(dd, DATEADD(mm, -1, (DATEFROMPARTS(DATEPART(yyyy, @day_value), DATEPART(mm, @day_value), 16))), @day_value)
 
	WHILE dbo.CheckHoliday(@FirstPayPeriodEnd) = 1
		SET @FirstPayPeriodEnd = DATEADD(dd, 1, @FirstPayPeriodEnd)
 
	WHILE dbo.CheckHoliday(@SixteenthPayPeriodEnd) = 1
		SET @SixteenthPayPeriodEnd = DATEADD(dd, 1, @SixteenthPayPeriodEnd)

	IF dbo.CheckHoliday(@FirstOfTheMonth) = 1 
	and @day_int >= 1
	and @day_int <= DAY(@FirstPayPeriodEnd)
			SET @lockout_int = @DaysSinceLastSixteenth
	ELSE IF dbo.CheckHoliday(@SixteenthOfTheMonth) = 1 
	and @day_int >= 16
	and @day_int <= DAY(@SixteenthPayPeriodEnd)
		SET @lockout_int = DATEDIFF(dd, @FirstOfTheMonth, @SixteenthPayPeriodEnd)
	ELSE IF @day_int = 1 
		SET @lockout_int = @DaysSinceLastSixteenth
	ELSE IF @day_int < 16 and @day_int > 1
		SET @lockout_int = @day_int - 1
	ELSE IF @day_int > 16 
		SET @lockout_int = @day_int - 16

	SET @lockout_value = CAST(CAST(@lockout_int as nvarchar(10)) as ntext) 
	
	UPDATE BQSTable SET ParamValue = @lockout_value
		WHERE ParamName = 'FRMTIMECARD_TEDATELIMIT'
	UPDATE BQSTable SET ParamValue = @lockout_value
		WHERE ParamName = 'FRMEXPLOG_ELDATELIMIT'

	RETURN @lockout_value
END
GO


