This module provides methods for scheduling the recurrence of an event. Recurrence can be daily, weekly, monthly or yearly. The module also determine when the next occurrence will happen.

Use this module to do the following:

- Schedule the recurrence of an event to be daily, weekly, monthly, or yearly.
- Get the next occurrence of the schedule.

# Public Objects
## Recurrence Schedule (Codeunit 4690)

 Calculates when the next event will occur. Events can recur daily, weekly, monthly or yearly.
 

### SetMinDateTime (Method) <a name="SetMinDateTime"></a> 

 To start calculating recurrence from January 1st, 2000,
 call SetMinDateTime(CREATEDATETIME(DMY2DATE(1, 1, 2000), 0T)).
 


 Sets the earliest date to be returned from CalculateNextOccurrence.
 The default MinDateTime is today at the start time set in recurrence.
 

#### Syntax
```
procedure SetMinDateTime(DateTime: DateTime)
```
#### Parameters
*DateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The minimum datetime.

### CalculateNextOccurrence (Method) <a name="CalculateNextOccurrence"></a> 

 To calculate the first occurrence (this is using the datatime provided in SetMinDateTime as a minimum datetime to return),
 call CalculateNextOccurrence(RecurrenceID, 0DT)), the RecurrenceID is the ID returned from one of the create functions.
 


 Calculates the time and date for the next occurrence.
 

#### Syntax
```
procedure CalculateNextOccurrence(RecurrenceID: Guid; LastOccurrence: DateTime): DateTime
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

*LastOccurrence ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The time of the last scheduled occurrence.

#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

Returns the DateTime value for the next occurrence. If there is no next occurrence, it returns the default value 0DT.
### CreateDaily (Method) <a name="CreateDaily"></a> 

 To create a recurrence that starts today, repeats every third day, and does not have an end date,
 call RecurrenceID := CreateDaily(now, today, 0D , 3).
 


 Creates a daily recurrence.
 

#### Syntax
```
procedure CreateDaily(StartTime: Time; StartDate: Date; EndDate: Date; DaysBetween: Integer): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*DaysBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of days between each occurrence, starting with 1.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateWeekly (Method) <a name="CreateWeekly"></a> 

 To create a weekly recurrence that starts today, repeats every Monday and Wednesday, and does not have an end date,
 call RecurrenceID := CreateWeekly(now, today, 0D , 1, true, false, true, false, false, false, false).
 


 Creates a weekly recurrence.
 

#### Syntax
```
procedure CreateWeekly(StartTime: Time; StartDate: Date; EndDate: Date; WeeksBetween: Integer; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*WeeksBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of weeks between each occurrence, starting with 1.

*Monday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Mondays.

*Tuesday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Tuesdays.

*Wednesday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Wednesdays.

*Thursday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Thursdays.

*Friday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Fridays.

*Saturday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Saturdays.

*Sunday ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Occur on Sundays.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateMonthlyByDay (Method) <a name="CreateMonthlyByDay"></a> 

 To create a monthly recurrence that repeats on the fourth day of every month,
 call RecurrenceID := CreateMonthlyByDay(now, today, 0D , 1, 4).
 


 Creates a monthly recurrence by day.
 

#### Syntax
```
procedure CreateMonthlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; DayOfMonth: Integer): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*MonthsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of months between each occurrence, starting with 1.

*DayOfMonth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The day of the month.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateMonthlyByDayOfWeek (Method) <a name="CreateMonthlyByDayOfWeek"></a> 

 To create a monthly recurrence that calculates every last Friday of every month,
 call RecurrenceID := CreateMonthlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Friday).
 


 Creates a monthly recurrence by the day of the week.
 

#### Syntax
```
procedure CreateMonthlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*MonthsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of months between each occurrence, starting with 1.

*InWeek ([Enum "Recurrence - Ordinal No."]())* 

The week of the month.

*DayOfWeek ([Enum "Recurrence - Day of Week"]())* 

The day of the week.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateYearlyByDay (Method) <a name="CreateYearlyByDay"></a> 

 To create a yearly recurrence that repeats on the first day of December,
 call RecurrenceID := CreateYearlyByDay(now, today, 0D , 1, 1, RecurrenceMonth::December).
 


 Creates a yearly recurrence by day.
 

#### Syntax
```
procedure CreateYearlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; DayOfMonth: Integer; Month: Enum "Recurrence - Month"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*YearsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of years between each occurrence, starting with 1.

*DayOfMonth ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The day of the month.

*Month ([Enum "Recurrence - Month"]())* 

The month of the year.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### CreateYearlyByDayOfWeek (Method) <a name="CreateYearlyByDayOfWeek"></a> 

 To create a yearly recurrence that repeats on the last Friday of every month,
 call RecurrenceID := CreateYearlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Weekday, RecurrenceMonth::December).
 


 Creates a yearly recurrence by day of week of a given month.
 

#### Syntax
```
procedure CreateYearlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"; Month: Enum "Recurrence - Month"): Guid
```
#### Parameters
*StartTime ([Time](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/time/time-data-type))* 

The start time of the recurrence.

*StartDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The start date of the recurrence.

*EndDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The end date of the recurrence.

*YearsBetween ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of years between each occurrence, starting with 1.

*InWeek ([Enum "Recurrence - Ordinal No."]())* 

The week of the month.

*DayOfWeek ([Enum "Recurrence - Day of Week"]())* 

The day of the week.

*Month ([Enum "Recurrence - Month"]())* 

The month of the year.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The ID used to reference this recurrence.
### OpenRecurrenceSchedule (Method) <a name="OpenRecurrenceSchedule"></a> 

 Opens the card for the recurrence.
 

#### Syntax
```
procedure OpenRecurrenceSchedule(var RecurrenceID: Guid)
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

### RecurrenceDisplayText (Method) <a name="RecurrenceDisplayText"></a> 

 Returns a short text description of the recurrence.
 

#### Syntax
```
procedure RecurrenceDisplayText(RecurrenceID: Guid): Text
```
#### Parameters
*RecurrenceID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The recurrence ID.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The short text to display.

## Recurrence Schedule Card (Page 4690)

 Allows users to view and edit existing recurrence schedules.
 


## Recurrence - Day of Week (Enum 4690)

 This enum has the day of the week for which the recurrence will occur.
 

### Monday (value: 1)


 Specifies that the recurrence to occur on Monday.
 

### Tuesday (value: 2)


 Specifies that the recurrence to occur on Tuesday.
 

### Wednesday (value: 3)


 Specifies that the recurrence to occur on Wednesday.
 

### Thursday (value: 4)


 Specifies that the recurrence to occur on Thursday.
 

### Friday (value: 5)


 Specifies that the recurrence to occur on Friday.
 

### Saturday (value: 6)


 Specifies that the recurrence to occur on Saturday.
 

### Sunday (value: 7)


 Specifies that the recurrence to occur on Sunday.
 

### Day (value: 8)


 Specifies that the recurrence to occur every day.
 

### Weekday (value: 9)


 Specifies that the recurrence to occur on all days from Monday to Friday.
 

### Weekend Day (value: 10)


 Specifies that the recurrence to occur on Saturday and Sunday.
 


## Recurrence - Month (Enum 4691)

 This enum has the months during which the recurrence will occur.
 

### January (value: 1)


 Specifies that the recurrence will occur in Janurary.
 

### February (value: 2)


 Specifies that the recurrence will occur in February.
 

### March (value: 3)


 Specifies that the recurrence will occur in March.
 

### April (value: 4)


 Specifies that the recurrence will occur in April.
 

### May (value: 5)


 Specifies that the recurrence will occur in May.
 

### June (value: 6)


 Specifies that the recurrence will occur in June.
 

### July (value: 7)


 Specifies that the recurrence will occur in July.
 

### August (value: 8)


 Specifies that the recurrence will occur in August.
 

### September (value: 9)


 Specifies that the recurrence will occur in September.
 

### October (value: 10)


 Specifies that the recurrence will occur in October.
 

### November (value: 11)


 Specifies that the recurrence will occur in Novemeber.
 

### December (value: 12)


 Specifies that the recurrence will occur in December.
 


## Recurrence - Monthly Pattern (Enum 4694)

 This enum has the monthly occurrence patterns for the recurrence.
 

### Specific Day (value: 0)


 Specifies that the recurrence will occur on a specific day.
 

### By Weekday (value: 1)


 Specifies that the recurrence will occur on a weekday. This is used in conjuction with the "Recurrence - Day Of Week" enums.
 


## Recurrence - Ordinal No. (Enum 4693)

 This enum has the ordinal numbers for which the recurrence will occur.
 

### First (value: 0)


 Specifies that the recurrence will occur in the first week of the month.
 

### Second (value: 1)


 Specifies that the recurrence will occur in the second week of the month.
 

### Third (value: 2)


 Specifies that the recurrence will occur in the third week of the month.
 

### Fourth (value: 3)


 Specifies that the recurrence will occur in the fourth week of the month.
 

### Last (value: 4)


 Specifies that the recurrence will occur in the last week of the month.
 In months with four weeks, the "Last" enum is the same as "Fourth" enum.
 


## Recurrence - Pattern (Enum 4692)

 This enum has the occurrence patterns for the recurrence.
 

### Daily (value: 0)


 Specifies that the recurrence will occur daily.
 

### Weekly (value: 1)


 Specifies that the recurrence will occur weekly.
 

### Monthly (value: 2)


 Specifies that the recurrence will occur monthly.
 

### Yearly (value: 3)


 Specifies that the recurrence will occur yearly.
 

