codeunit 11151 "Create Acc. Schedule Line AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //ToDo: Need to Check with MS Team why standard Schedule Name are commented in W1

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALEQUITYRESERVES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALSUPPLIES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalTradeReceivables(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalSecurities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalCashAndBank(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.GiroAccount(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalPayablesToVendors(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalLiabilitiesFromTaxes(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                140000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalSocialSecurity(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                150000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalOtherLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALOPERATINGINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalTradeReceivables(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalPayablesToVendors(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALSUPPLIES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000, 60000, 70000, 80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalTradeReceivables(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalPayablesToVendors(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TotalCashAndBank() + '|' + CreateGLAccount.GiroAccount(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALOPERATINGINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALCOSTOFMATERIALS(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '8695', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALFINANCIALINCOMEANDEXPENSES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateATGLAccount.OtherOperationalExpenditure(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, CreateATGLAccount.TOTALOPERATINGINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, CreateATGLAccount.TOTALCOSTOFMATERIALS(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '8695|' + CreateATGLAccount.TOTALFINANCIALINCOMEANDEXPENSES() + '|8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                80000:
                    ValidateRecordFields(Rec, CreateATGLAccount.OtherOperationalExpenditure(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                90000:
                    ValidateRecordFields(Rec, '8995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000, 70000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFieldsRevenue(Rec, '11', CreateATGLAccount.SalesRevenuesTradeDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFieldsRevenue(Rec, '12', CreateATGLAccount.SalesRevenuesTradeEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFieldsRevenue(Rec, '13', CreateATGLAccount.SalesRevenuesTradeExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    ValidateRecordFieldsRevenue(Rec, '14', CreateATGLAccount.ProjectSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                80000:
                    ValidateRecordFieldsRevenue(Rec, '15', CreateATGLAccount.TotalSalesRevenuesTrade(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                100000:
                    ValidateRecordFieldsRevenue(Rec, '', CreateATGLAccount.SalesRevenuesTradeDomestic() + '..' + CreateATGLAccount.TotalSalesRevenuesTrade(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                110000:
                    ValidateRecordFieldsRevenue(Rec, '', CreateATGLAccount.SalesRevenuesTradeDomestic() + '..' + CreateATGLAccount.TotalSalesRevenuesTrade(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFieldsRevenue(Rec, '', CreateATGLAccount.SalesRevenuesTradeDomestic() + '..' + CreateATGLAccount.TotalSalesRevenuesTrade(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                130000:
                    ValidateRecordFieldsRevenue(Rec, '', CreateATGLAccount.SalesRevenuesTradeDomestic() + '..' + CreateATGLAccount.TotalSalesRevenuesTrade(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine:
                                                 Record "Acc. Schedule Line";
    Totaling:
        Text;
    TotalingType:
        Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    local procedure ValidateRecordFieldsRevenue(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
}