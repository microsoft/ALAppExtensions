codeunit 10859 "Create Acc. Schedule Line FR"
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
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.NetIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlowCalculation() then
            case Rec."Line No." of
                150000:
                    Rec.Validate(Description, CostsfromoperationLbl);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SecuritiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateGLAccount.VatTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                140000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelRelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                150000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherLiabilitiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000, 60000, 70000, 80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal() + '|' + CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '607*|6087*|6097*|6037*|601*|602*|6081*|6082*|6091*|6092*|6031*|6032*|604*|605*|606*|6084*|6085*|6086*|6094*|6095*|6096*|61*|62*|63*|641*|644*645*|646*|647*|648*|6811*|6812*|6816*|6817*|6815*|650000..654999|656000..659999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsOfOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.TotalSalesOfRetail() + '|' + CreateGLAccount.TotalSalesOfRawMaterials() + '|75*', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, '60*|9*', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '61*|62*|63*|64*|65*', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                80000:
                    ValidateRecordFields(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                90000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalSalesOfRetail() + '|' + CreateGLAccount.TotalSalesOfRawMaterials() + '|75*|60*|9*|61*|62*|63*|64*|65*', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000, 70000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailEu(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.JobSalesAppliedRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalSalesOfRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                100000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        CostsfromoperationLbl: Label 'Costs from operation', MaxLength = 100;
}