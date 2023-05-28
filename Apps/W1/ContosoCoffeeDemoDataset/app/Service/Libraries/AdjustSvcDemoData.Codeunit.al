codeunit 5109 "Adjust Svc Demo Data"
{
    procedure AdjustPrice(UnitPrice: Decimal): Decimal
    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
    begin
        if UnitPrice = 0 then
            exit(0);

        SvcDemoDataSetup.Get();
        exit(Round(UnitPrice * SvcDemoDataSetup."Price Factor", SvcDemoDataSetup."Rounding Precision"));
    end;

    procedure AdjustDate(OriginalDate: Date): Date
    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        TempDate: Date;
        WeekDay: Integer;
        MonthDay: Integer;
        Week: Integer;
        Month: Integer;
        Year: Integer;
    begin
        if SvcDemoDataSetup.Get() then;
        if OriginalDate <> 0D then begin
            TempDate := CalcDate('<+92Y>', OriginalDate);
            WeekDay := Date2DWY(TempDate, 1);
            MonthDay := Date2DMY(TempDate, 1);
            Month := Date2DMY(TempDate, 2);
            Week := Date2DWY(TempDate, 2);
            Year := Date2DMY(TempDate, 3) + SvcDemoDataSetup."Starting Year" - 1994;
            case Month of
                1, 3, 5, 7, 8, 10, 12:
                    if (MonthDay = 31) or (MonthDay = 1) then
                        exit(DMY2Date(MonthDay, Month, Year));
                2:
                    if (MonthDay = 28) or (MonthDay = 1) then
                        exit(DMY2Date(MonthDay, Month, Year));
                4, 6, 9, 11:
                    if (MonthDay = 30) or (MonthDay = 1) then
                        exit(DMY2Date(MonthDay, Month, Year));
            end;

            exit(DWY2Date(WeekDay, Week, Year))
        end;

        exit(0D);
    end;

    procedure TitleCase(SourceText: Text) Result: Text[100]
    var
        ResultTextBuilder: TextBuilder;
        i: Integer;
    begin
        ResultTextBuilder.Clear();
        for i := 1 to StrLen(SourceText) do
            if (i = 1) then
                ResultTextBuilder.Append(UpperCase(SourceText[i]))
            else
                if (SourceText[i - 1] = ' ') then
                    ResultTextBuilder.Append(UpperCase(SourceText[i]))
                else
                    ResultTextBuilder.Append(SourceText[i]);
        Result := CopyStr(ResultTextBuilder.ToText(), 1, MaxStrLen(Result));
    end;
}