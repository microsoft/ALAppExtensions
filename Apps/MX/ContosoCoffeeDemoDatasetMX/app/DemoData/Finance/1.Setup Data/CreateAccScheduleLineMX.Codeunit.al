codeunit 14112 "Create Acc. Schedule Line MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            if Rec."Line No." = 60000 then
                Rec.Validate(Totaling, CreateGLAccount.NetIncome());

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            if Rec."Line No." = 70000 then
                Rec.Validate(Totaling, '1190');

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    Rec.Validate("Hide Currency Symbol", true);
                60000:
                    Rec.Validate("Hide Currency Symbol", true);
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal() + '|' + CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '10' + '..' + '30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalOperatingExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFieldsReducedTrialBalance(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, TotalRevenueLbl);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    Rec.Validate("Hide Currency Symbol", true);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalOperatingExpenses() + '|' + CreateGLAccount.TotalPersonnelExpenses() + '|' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                90000:
                    ValidateRecordFields(Rec, CreateGLAccount.NetIncomeBeforeTaxes(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; HideCurrencySymbol: Boolean)
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        if HideCurrencySymbol then
            AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;

    local procedure ValidateRecordFieldsReducedTrialBalance(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; HideCurrencySymbol: Boolean; Description: Text[100])
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Description, Description);
        if HideCurrencySymbol then
            AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100, Locked = true;
}