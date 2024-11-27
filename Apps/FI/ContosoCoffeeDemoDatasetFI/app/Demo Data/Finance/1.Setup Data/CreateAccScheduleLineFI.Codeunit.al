codeunit 13436 "Create Acc. Schedule Line FI"
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
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.PROFITLOSSFORTHEFINANCIALYEAR(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Inventorytotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.ShorttermReceivablestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Securitiestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Liquidassets2(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                110000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Loansfromcreditinstitutions1(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.LIABILITIESTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                130000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Deferredtaxliability7(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                140000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Deferredtaxliability5(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                150000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Accrualsanddeferredincome9(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.NETTURNOVERTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.ShorttermReceivablestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.LIABILITIESTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Inventorytotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
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
                    ValidateRecordFields(Rec, CreateFIGLAccounts.ShorttermReceivablestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.LIABILITIESTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Liquidassets2() + '|' + CreateFIGLAccounts.Loansfromcreditinstitutions1(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '10' + '..' + '30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.NETTURNOVERTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Rawmaterialsandservicestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Variationinstockstotal() + '|' + CreateFIGLAccounts.Manafacturedforownusetotal() + '|' + CreateFIGLAccounts.Operatingincometotal() + '|' + CreateFIGLAccounts.Rawmaterialsandservicestotal() + '|' + CreateFIGLAccounts.Staffexpencestotal() + '|' + '6959', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Otheroperatingexpensestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Depreciationeductionsinvalue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Otherexpences(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFieldsReducedTrialBalance(Rec, CreateFIGLAccounts.NETTURNOVERTOTAL(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, TotalRevenueLbl);
                20000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Rawmaterialsandservicestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                50000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Variationinstockstotal() + '|' + CreateFIGLAccounts.Manafacturedforownusetotal() + '|' + CreateFIGLAccounts.Operatingincometotal() + '|' + CreateFIGLAccounts.Staffexpencestotal() + '|' + CreateFIGLAccounts.Otheroperatingexpensestotal() + '|' + CreateFIGLAccounts.Depreciationeductionsinvalue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                90000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Otheroperatingexpensestotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Salesofgoodsdom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.SalesofgoodsEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Salesofgoodsfor(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Sales8(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                80000:
                    ValidateRecordFields(Rec, CreateFIGLAccounts.Salesofgoodsdom(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
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