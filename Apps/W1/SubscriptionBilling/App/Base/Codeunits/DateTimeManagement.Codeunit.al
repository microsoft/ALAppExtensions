namespace Microsoft.SubscriptionBilling;

using System.DateTime;
using System.Globalization;

codeunit 8017 "Date Time Management"
{
    Access = Internal;

    procedure IsSameMonth(Date1: Date; Date2: Date): Boolean
    begin
        exit((Date2DMY(Date1, 3) = Date2DMY(Date2, 3)) and (Date2DMY(Date1, 2) = Date2DMY(Date2, 2)));
    end;

    procedure IsFirstOfMonth(ThisDate: Date; ThisTime: Time): Boolean
    begin
        exit((CalcDate('<-CM>', ThisDate) = ThisDate) and ((ThisTime = 0T) or (ThisTime = 000000T)));
    end;

    procedure GetTotalDurationForMonth(ReferenceDate: Date): BigInteger
    var
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := DMY2Date(1, Date2DMY(ReferenceDate, 2), Date2DMY(ReferenceDate, 3));
        EndDate := CalcDate('<CM+1D>', StartDate);
        exit(GetDurationForRange(StartDate, 0T, EndDate, 0T));
    end;

    procedure GetDurationForRange(FromDate: Date; FromTime: Time; ToDate: Date; ToTime: Time): BigInteger
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;

        DotNet_StartDateTime: DateTime;
        DotNet_EndDateTime: DateTime;
    begin
        DotNet_StartDateTime := ParseDateTimeToDotNetDateTime(Format(CreateDateTime(FromDate, FromTime)));
        DotNet_StartDateTime := DotNet_DateTimeOffset.ConvertToUtcDateTime(DotNet_StartDateTime);
        DotNet_EndDateTime := ParseDateTimeToDotNetDateTime(Format(CreateDateTime(ToDate, ToTime)));
        DotNet_EndDateTime := DotNet_DateTimeOffset.ConvertToUtcDateTime(DotNet_EndDateTime);
        exit(DotNet_EndDateTime - DotNet_StartDateTime);
    end;

    local procedure ParseDateTimeToDotNetDateTime(TextValue: Text): DateTime
    var
        DotNet_DateTime: Codeunit DotNet_DateTime;
        DotNet_CultureInfo: Codeunit DotNet_CultureInfo;
        DotNet_DateTimeStyles: Codeunit DotNet_DateTimeStyles;
        DateTimeValue: DateTime;
    begin
        DateTimeValue := 0DT;
        DotNet_DateTimeStyles.None();
        if not DotNet_DateTime.TryParse(TextValue, DotNet_CultureInfo, DotNet_DateTimeStyles)
        then
            exit(DateTimeValue);
        DateTimeValue := DotNet_DateTime.ToDateTime();
        exit(DateTimeValue);
    end;

    internal procedure CalculateProRatedAmount(Amount: Decimal; FromDate: Date; FromTime: Time; ToDate: Date; ToTime: Time; BillingBasePeriod: DateFormula) ProRatedAmount: Decimal
    var
        ProRatedMilliseconds: BigInteger;
        TotalMilliseconds: BigInteger;
        CompareDate: Date;
        NumberOfMonths: Integer;
    begin
        NumberOfMonths := 0;
        CompareDate := ToDate;
        if IsFirstOfMonth(CompareDate, ToTime) then
            CompareDate -= 1;

        if ToDate = CalcDate(BillingBasePeriod, FromDate) then
            ProRatedAmount := Amount
        else
            if IsSameMonth(FromDate, CompareDate - 1) then begin
                ProRatedMilliseconds := GetDurationForRange(FromDate, FromTime, ToDate, ToTime);
                TotalMilliseconds := GetDurationForRange(FromDate, 0T, CalcDate(BillingBasePeriod, FromDate), 0T);
                ProRatedAmount := Amount * ProRatedMilliseconds / TotalMilliseconds;
            end else begin
                ProRatedMilliseconds := GetDurationToEndOfMonth(FromDate, FromTime);
                TotalMilliseconds := GetTotalDurationForMonth(FromDate);
                ProRatedAmount := Amount * ProRatedMilliseconds / TotalMilliseconds;
                while CalcDate('<+' + Format(NumberOfMonths + 1) + 'M-1D>', FromDate) < CalcDate('<CM-1M>', ToDate) do
                    NumberOfMonths += 1;
                ProRatedAmount += Amount * NumberOfMonths;
                ProRatedMilliseconds := GetDurationFromStartOfMonth(ToDate, ToTime);
                TotalMilliseconds := GetTotalDurationForMonth(ToDate);
                ProRatedAmount += Amount * ProRatedMilliseconds / TotalMilliseconds;
            end;
    end;

    procedure GetDurationToEndOfMonth(FromDate: Date; FromTime: Time): BigInteger
    var
        EndDate: Date;
    begin
        EndDate := CalcDate('<CM+1D>', FromDate);
        exit(GetDurationForRange(FromDate, FromTime, EndDate, 0T));
    end;

    procedure GetDurationFromStartOfMonth(ToDate: Date; ToTime: Time): BigInteger
    var
        StartDate: Date;
    begin
        StartDate := DMY2Date(1, Date2DMY(ToDate, 2), Date2DMY(ToDate, 3));
        exit(GetDurationForRange(StartDate, 0T, ToDate, ToTime));
    end;

    procedure GetMillisecondsForDay(): BigInteger
    begin
        exit(86400000);
    end;

    procedure GetMillisecondsForHour(): BigInteger
    begin
        exit(3600000);
    end;

    internal procedure GetNumberOfDecimals(UnitPrice: Decimal) NoOfDecimals: Integer
    var
        BreakLoop: Boolean;
    begin
        repeat
            if UnitPrice mod 1 = 0 then
                BreakLoop := true
            else begin
                NoOfDecimals += 1;
                UnitPrice *= 10;
            end;
        until BreakLoop;
    end;

    internal procedure GetRoundingPrecision(NoOfDecimals: Integer) RoudingPrecision: Decimal
    var
        i: Integer;
    begin
        RoudingPrecision := 1;
        for i := 1 to NoOfDecimals do
            RoudingPrecision /= 10;
    end;
}
