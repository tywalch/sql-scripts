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
	SET @DaysSinceLastSixteenth = DATEDIFF(dd, DATEADD(mm, -1, (DATEFROMPARTS(DATEPART(yyyy, @day_value), DATEPART(mm, @day_value), 16))), @day_value) --23

	SET @FirstPayPeriodEnd = @FirstOfTheMonth
	WHILE dbo.CheckHoliday(@FirstPayPeriodEnd) = 1
	BEGIN
		SET @FirstPayPeriodEnd = DATEADD(dd, 1, @FirstPayPeriodEnd)
	END

	SET @SixteenthPayPeriodEnd = @SixteenthOfTheMonth
	WHILE dbo.CheckHoliday(@SixteenthPayPeriodEnd) = 1
	BEGIN
		SET @SixteenthPayPeriodEnd = DATEADD(dd, 1, @SixteenthPayPeriodEnd)
	END

	-- give access to prior month's second half
	IF dbo.CheckHoliday(@FirstOfTheMonth) = 1
	and @day_int >= 1
	and @day_int <= DAY(@FirstPayPeriodEnd)
			SET @lockout_int = @DaysSinceLastSixteenth

	-- give access to first half of the month
	ELSE IF dbo.CheckHoliday(@SixteenthOfTheMonth) = 1
	and @day_int >= 16
	and @day_int <= DAY(@SixteenthPayPeriodEnd)
		SET @lockout_int = DATEDIFF(dd, @FirstOfTheMonth, @SixteenthPayPeriodEnd)

	-- give access to prior month's second half
	ELSE IF @day_int = 1
		SET @lockout_int = @DaysSinceLastSixteenth

	-- give access to first half of the month
	ELSE IF @day_int < 16
	and @day_int > 1
		SET @lockout_int = @day_int - 1

	-- give access back to the first of the month
	ELSE IF @day_int >= 16
		SET @lockout_int = 1

	SET @lockout_value = CAST(CAST(@lockout_int as nvarchar(10)) as ntext)

	UPDATE BQSTable SET ParamValue = @lockout_value
		WHERE ParamName = 'FRMTIMECARD_TEDATELIMIT'
	UPDATE BQSTable SET ParamValue = @lockout_value
		WHERE ParamName = 'FRMEXPLOG_ELDATELIMIT'

	RETURN @lockout_value
END
GO
