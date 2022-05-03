codeunit 4775 "Create Mfg Shop Calendar"
{
    Permissions = tabledata "Shop Calendar" = ri,
        tabledata "Work Shift" = ri,
        tabledata "Shop Calendar Working Days" = ri;

    trigger OnRun()
    begin
        // 1 shift
        InserShopCalendar(XOneshiftTok, XOneshiftMondayFridayTok);
        InsertWorkShift('1', X1stshiftTok);

        InsertShopCalendarWorkingDays(XOneshiftTok, 0, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XOneshiftTok, 1, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XOneshiftTok, 2, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XOneshiftTok, 3, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XOneshiftTok, 4, 080000T, 160000T, '1');

        // 2 shifts
        InserShopCalendar(XTwoshiftsTok, XTwoshiftsMondayFridayTok);
        InsertWorkShift('2', X2ndshiftTok);

        InsertShopCalendarWorkingDays(XTwoshiftsTok, 0, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 1, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 2, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 3, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 4, 080000T, 160000T, '1');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 0, 160000T, 230000T, '2');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 1, 160000T, 230000T, '2');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 2, 160000T, 230000T, '2');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 3, 160000T, 230000T, '2');
        InsertShopCalendarWorkingDays(XTwoshiftsTok, 4, 160000T, 230000T, '2');
    end;

    var
        XOneshiftTok: Label 'One shift', MaxLength = 10;
        XOneshiftMondayFridayTok: Label 'One shift Monday-Friday', MaxLength = 50;
        XTwoshiftsTok: Label 'Two shifts', MaxLength = 10;
        XTwoshiftsMondayFridayTok: Label 'Two shifts Monday-Friday', MaxLength = 50;
        X1stshiftTok: Label '1st shift', MaxLength = 50;
        X2ndshiftTok: Label '2nd shift', MaxLength = 50;

    local procedure InserShopCalendar("Code": Code[10]; Name: Text[50])
    var
        ShopCalendar: Record "Shop Calendar";
    begin
        ShopCalendar.Validate(Code, Code);
        ShopCalendar.Validate(Description, Name);
        ShopCalendar.Insert();
    end;

    local procedure InsertWorkShift("Code": Code[10]; Description: Text[50])
    var
        WorkShift: Record "Work Shift";
    begin
        WorkShift.Validate(Code, Code);
        WorkShift.Validate(Description, Description);
        WorkShift.Insert();
    end;

    local procedure InsertShopCalendarWorkingDays(ShopCalendarCode: Code[10]; Day: Option Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday; StartingTime: Time; EndingTime: Time; WorkShiftCode: Code[10])
    var
        ShopCalendarWorkingDays: Record "Shop Calendar Working Days";
    begin
        ShopCalendarWorkingDays.Validate("Shop Calendar Code", ShopCalendarCode);
        ShopCalendarWorkingDays.Validate(Day, Day);
        ShopCalendarWorkingDays.Validate("Starting Time", StartingTime);
        ShopCalendarWorkingDays.Validate("Ending Time", EndingTime);
        ShopCalendarWorkingDays.Validate("Work Shift Code", WorkShiftCode);
        ShopCalendarWorkingDays.Insert();
    end;
}