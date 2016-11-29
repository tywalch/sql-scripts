USE [Your Database]
GO

CREATE Function [dbo].[CheckHoliday] (@ReferenceDate date)
returns bit
as
BEGIN
 DECLARE @Holiday bit
 DECLARE @Year int = YEAR(@ReferenceDate)
        ,@Month int = MONTH(@ReferenceDate)
        ,@Day int = DAY(@ReferenceDate)
        ,@Weekday int = DatePart(dw,@ReferenceDate)
 DECLARE @PresidentsDay date = dbo.FloatingDate(3,1,2)
        ,@MemorialDay date = dbo.FloatingDate(-1,2,5)
        ,@July4th date = dbo.HolidayAdjustment(DATEFROMPARTS(@Year,7,4))
        ,@LaborDay date = dbo.FloatingDate(1,1,9)
        ,@Thanksgiving date = dbo.FloatingDate(2,2,10)
        ,@ThanksgivingFriday date = dbo.FloatingDate(2,5,10)
        ,@Christmas date = dbo.HolidayAdjustment(DATEFROMPARTS(@Year,12,25))
        ,@ChristmasEve date = dbo.HolidayAdjustment(DATEFROMPARTS(@Year,12,24))
        ,@NewYearsEve date = dbo.HolidayAdjustment(DATEFROMPARTS(@Year,12,31))
        ,@NewYears date = dbo.HolidayAdjustment(DATEFROMPARTS(@Year,1,1))

 IF @ReferenceDate = @PresidentsDay
    or @ReferenceDate = @MemorialDay 
    or @ReferenceDate = @July4th 
    or @ReferenceDate = @LaborDay
    or @ReferenceDate = @Thanksgiving 
    or @ReferenceDate = @ThanksgivingFriday 
    or @ReferenceDate = @Christmas 
    or @ReferenceDate = @ChristmasEve 
    or @ReferenceDate = @NewYearsEve 
    or @ReferenceDate = @NewYears 
    or DATEPART(dw,@ReferenceDate) = 7
    or DATEPART(dw,@ReferenceDate) = 1
  BEGIN
   SET @Holiday = 1
  END
 ELSE
  BEGIN
   SET @Holiday = 0
  END

 return @Holiday
END

/* Holiday Definitions
Presidents Day: Third Monday of Febuary
Memorial Day: Last Monday of May
Independence Day: July 4th
Labor Day: First Monday of September
Thanksgiving: Second Monday of October
Friday after Thanksgiving: Second Friday of October
Christmas Eve: December 24th
Christmas: December 25th
New Years Eve: December 31st
New Years Eve: January 1st
*/

GO


