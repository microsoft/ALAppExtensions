namespace Microsoft.SubscriptionBilling;

codeunit 8017 "Date Time Management"
{
    procedure IsLastDayOfMonth(ThisDate: Date): Boolean
    begin
        exit(CalcDate('<CM>', ThisDate) = ThisDate);
    end;

    procedure MoveDateToLastDayOfMonth(var ThisDate: Date)
    begin
        ThisDate := CalcDate('<CM>', ThisDate)
    end;

    procedure GetNumberOfDecimals(UnitPrice: Decimal) NoOfDecimals: Integer
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

    procedure GetRoundingPrecision(NoOfDecimals: Integer) RoundingPrecision: Decimal
    var
        i: Integer;
    begin
        RoundingPrecision := 1;
        for i := 1 to NoOfDecimals do
            RoundingPrecision /= 10;
    end;

    procedure GetMaxDate(DateList: List of [Date]) MaxDate: Date
    var
        CurrentDate: Date;
    begin
        if DateList.Count() = 0 then
            exit(0D);

        MaxDate := DateList.Get(1);
        foreach CurrentDate in DateList do
            if CurrentDate > MaxDate then
                MaxDate := CurrentDate;
        exit(MaxDate);
    end;
}
