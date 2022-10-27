codeunit 4782 "Adjust Manufacturing Data"
{
    procedure AdjustPrice(UnitPrice: Decimal): Decimal
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
    begin
        if UnitPrice = 0 then
            exit(0);

        ManufacturingDemoDataSetup.Get();
        exit(Round(UnitPrice * ManufacturingDemoDataSetup."Price Factor"));
    end;

    procedure AdjustDate(OriginalDate: Date): Date
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        TempDate: Date;
        WeekDay: Integer;
        MonthDay: Integer;
        Week: Integer;
        Month: Integer;
        Year: Integer;
    begin
        if ManufacturingDemoDataSetup.Get() then;
        if OriginalDate <> 0D then begin
            TempDate := CalcDate('<+92Y>', OriginalDate);
            WeekDay := Date2DWY(TempDate, 1);
            MonthDay := Date2DMY(TempDate, 1);
            Month := Date2DMY(TempDate, 2);
            Week := Date2DWY(TempDate, 2);
            Year := Date2DMY(TempDate, 3) + ManufacturingDemoDataSetup."Starting Year" - 1994;
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
}