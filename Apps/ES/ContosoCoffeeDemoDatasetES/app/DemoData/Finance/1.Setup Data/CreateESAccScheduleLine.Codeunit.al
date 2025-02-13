codeunit 10830 "Create ES Acc. Schedule Line"
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
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, '999999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                10000:
                    Rec.Validate(Description, AnanlysisLiquidityAnalysisLbl);
                40000:
                    ValidateRecordFields(Rec, '3', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '43|44', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '50|53|54', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, '57', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                110000:
                    ValidateRecordFields(Rec, '51|52|56|58|59', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                120000:
                    ValidateRecordFields(Rec, '40', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                130000:
                    begin
                        ValidateRecordFields(Rec, '47', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                        Rec.Validate(Description, ' T.A.(Tax Authority)');
                    end;
                140000:
                    ValidateRecordFields(Rec, '46', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                150000:
                    ValidateRecordFields(Rec, '41', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '700|701|702|703|704|705|706|708|709', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '43|44', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '40', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '3', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
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
                    ValidateRecordFields(Rec, '43|44', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '40', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '57|51|52|56|58|59', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '700|701|702|703|704|705|706|708|709', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '600|601|602|606|607|608|609|61|6931|6932|6932|6933|7931|7932|7933', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '64|7950|7957|62|631|634|636|639|65|694|695|794|7954', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '64|7950|7957', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '68', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, '62|631|634|636|639|65|694|695|794|7954', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.1', BusinessTurnoverNetAmountLbl, '700|701|702|703|704|705|706|708|709', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.2', IncreaseDecreaseOfStocksOnFinishedGoodsAndManufacturedGoodsProdLbl, '71|6930|7930', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.3', WorkDoneByTheCompanyOnFixedAssetsLbl, '73', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.4', ConsumablesLbl, '600|601|602|606|607|608|609|61|6931|6932|6932|6933|7931|7932|7933', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.5', OtherOperatingIncomeLbl, '740|747|75', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.6', PersonnelExpensesLbl, '64|7950|7957', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.7', OtherOperatingExpensesLbl, '62|631|634|636|639|65|694|695|794|7954', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                80000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.8', FixedAssetsDepreciationAndExpensesLbl, '68|746|7951|7952|7955|7956|670|671|672|770|11|772|690|691|692|790|791|792', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                90000:
                    ValidateRecordFieldsReducedTrial(Rec, 'A.TOT', OperatingResultsLbl, 'A.1+A.2+A.3+A.4+A.5+A.6+A.7+A.8', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.NationalGoodsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.GoodsSalesEu(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.IntNonEuGoodsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                80000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                100000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.NationalGoodsSales() + '..' + CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.NationalGoodsSales() + '..' + CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.NationalGoodsSales() + '..' + CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateESGLAccounts.NationalGoodsSales() + '..' + CreateESGLAccounts.ProjectsSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    local procedure ValidateRecordFieldsReducedTrial(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[250]; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; ShowOppositeSign: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
    end;

    var
        BusinessTurnoverNetAmountLbl: Label '1. Business Turnover Net Amount', MaxLength = 250;
        IncreaseDecreaseOfStocksOnFinishedGoodsAndManufacturedGoodsProdLbl: Label '2. Increase/Decrease of Stocks on Finished Goods and Manufactured Goods-Prod.', MaxLength = 250;
        WorkDoneByTheCompanyOnFixedAssetsLbl: Label '3. Work Done by the Company on Fixed Assets', MaxLength = 250;
        ConsumablesLbl: Label '4. Consumables', MaxLength = 250;
        OtherOperatingIncomeLbl: Label '5. Other Operating Income', MaxLength = 250;
        PersonnelExpensesLbl: Label '6. Personnel Expenses', MaxLength = 250;
        OtherOperatingExpensesLbl: Label '7. Other Operating Expenses', MaxLength = 250;
        FixedAssetsDepreciationAndExpensesLbl: Label '8. Fixed Assets Depreciation and Expenses', MaxLength = 250;
        OperatingResultsLbl: Label 'A) OPERATING RESULTS', MaxLength = 250;
        AnanlysisLiquidityAnalysisLbl: Label 'LIQUIDITY ANALYSIS', MaxLength = 250;
}