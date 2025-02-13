codeunit 11533 "Create Acc. Schedule Line NL"
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
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, '999999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, '7999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalPayrollLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.GoodsforResale(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalLongtermLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                110000:
                    ValidateRecordFields(Rec, '0931', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    ValidateRecordFields(Rec, '1619', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                130000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalOtherCurrentLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                140000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                150000:
                    ValidateRecordFields(Rec, '1749', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '8799', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalPayrollLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, '1619', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '7999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
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
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalPayrollLiabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, '1619', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalLongtermLiabilities() + '|' + '0931', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '10' + '..' + '30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '8799', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalBankingandInterest(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '9395', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalBankingandInterest(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '4295', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, '8799' + '|' + '8899' + '|' + '8990' + '|6959', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalBankingandInterest() + '|' + '6099', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                50000:
                    ValidateRecordFields(Rec, '9395', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, '4099' + '|' + CreateNLGLAccounts.TotalExternalServices() + '|' + CreateNLGLAccounts.TotalBenefitsPension() + '|' + CreateNLGLAccounts.TotalInsurancesPersonnel() + '|' + '4699' + '|' + '4799' + '|' + CreateNLGLAccounts.TotalDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                90000:
                    ValidateRecordFields(Rec, CreateNLGLAccounts.TotalBankingandInterest() + '|' + '4099' + '|' + CreateNLGLAccounts.TotalExternalServices() + '|' + '4299' + '|' + CreateNLGLAccounts.TotalBenefitsPension() + '|' + CreateNLGLAccounts.TotalInsurancesPersonnel() + '|' + '4699' + '|' + '4799' + '|' + CreateNLGLAccounts.TotalDepreciation() + '|' + '6099' + '|' + '6959' + '|' + '8799' + '|' + '8899' + '|' + '8990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, '8030', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                50000:
                    ValidateRecordFields(Rec, '8040', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                60000:
                    ValidateRecordFields(Rec, '8050', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '8600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                80000:
                    ValidateRecordFields(Rec, '8000', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                100000:
                    ValidateRecordFields(Rec, '8030' + '..' + '8000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                110000:
                    ValidateRecordFields(Rec, '8030' + '..' + '8000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    begin
                        ValidateRecordFields(Rec, '8030' + '..' + '8000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                        Rec.Validate("Dimension 1 Totaling", '');
                    end;
                130000:
                    ValidateRecordFields(Rec, '8030' + '..' + '8000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
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