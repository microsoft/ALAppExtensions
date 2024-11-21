codeunit 11359 "Create Acc. Schedule Line BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, '8', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.InventoryAndOrders(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivable(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.Securities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssets(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.TransitAccounts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayable(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.TaxesSalariesSocCharges(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                140000:
                    ValidateRecordFields(Rec, CreateGLAccount.PersonnelrelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                150000:
                    ValidateRecordFields(Rec, '47|48', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.ProcessingOfResultDeferred(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '2190', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000, 60000, 70000, 80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '2990' + '|' + CreateBEGLAccount.BankProcessing(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.ProcessingOfResultDeferred(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.ProcessingOfResultTransfer(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '8695', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.IncomeStatement(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.MiscCostsOfOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, CreateBEGLAccount.ProcessingOfResultDeferred(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.ProcessingOfResultTransfer(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '8695|7|8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                80000:
                    ValidateRecordFields(Rec, CreateBEGLAccount.MiscCostsOfOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                90000:
                    ValidateRecordFields(Rec, '9495', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000, 70000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    begin
                        ValidateRecordFields(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                        Rec.Validate("Row No.", '');
                        Rec.Validate(Description, '');
                    end;
                80000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                        Rec.Validate("Row No.", '');
                        Rec.Validate(Description, RevenueArea1030TotalLbl);
                    end;
                90000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                        Rec.Validate(Description, RevenueArea4085TotalLbl);
                    end;
                100000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                        Rec.Validate(Description, RevenuenoAreacodeTotalLbl);
                    end;
                110000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                        Rec.Validate(Bold, true);
                        Rec.Validate(Description, RevenueTotalLbl);
                    end;
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    var
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        RevenueArea4085TotalLbl: Label 'Revenue Area 40..85, Total', MaxLength = 100;
        RevenuenoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueArea1030TotalLbl: Label 'Revenue Area 10..30, Total', MaxLength = 100;
}