codeunit 14629 "Create Acc. Schedule Line IS"
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
                    ValidateRecordFields(Rec, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                60000:
                    ValidateRecordFields(Rec, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                70000:
                    ValidateRecordFields(Rec, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
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
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalOperatingExpenses() + '|' + CreateGLAccount.TotalPersonnelExpenses() + '|' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
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

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
}