codeunit 11492 "Create GB Acc Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Acc. Schedule Line"; RunTrigger: Boolean)
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if (Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview()) and (Rec."Line No." = 60000) then
            ValidateRecordFields(Rec, '4010', IncomeThisYearLbl, '4999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '', ACIDTestAnalysisLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
                40000:
                    ValidateRecordFields(Rec, '101', InventoryLbl, CreateGLAccount.FinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                50000:
                    ValidateRecordFields(Rec, '102', AccountsReceivableLbl, CreateGLAccount.CustomersDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                60000:
                    ValidateRecordFields(Rec, '103', SecuritiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                70000:
                    ValidateRecordFields(Rec, '104', LiquidAssetsLbl, '7820078100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                110000:
                    ValidateRecordFields(Rec, '111', RevolvingCreditLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                120000:
                    ValidateRecordFields(Rec, '112', AccountsPayableLbl, CreateGLAccount.VendorsDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                130000:
                    ValidateRecordFields(Rec, '113', VATLbl, '46200..46330|' + CreateGBGLAccounts.SalesVATNormal() + '..' + CreateGBGLAccounts.MiscVATPayables(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                140000:
                    ValidateRecordFields(Rec, '114', PersonnelRelatedItemsLbl, CreateGBGLAccounts.AccruedWagesSalaries() + '..' + CreateGBGLAccounts.SalesVATNormal(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                150000:
                    ValidateRecordFields(Rec, '115', OtherLiabilitiesLbl, CreateGBGLAccounts.PurchaseDiscounts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                180000:
                    ValidateRecordFields(Rec, '', CAMinusShortTermLiabLbl, '105|116', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '', REVENUELbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
                30000:
                    ValidateRecordFields(Rec, '', SalesofRetailLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
                40000:
                    ValidateRecordFields(Rec, '11', IncomeServicesLbl, CreateGBGLAccounts.SaleOfResources(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                50000:
                    ValidateRecordFields(Rec, '12', IncomeProductSalesLbl, CreateGBGLAccounts.SaleOfFinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                60000:
                    ValidateRecordFields(Rec, '13', SalesDiscountReturnsAllowancesLbl, CreateGBGLAccounts.DiscountsAndAllowances() + '..' + CreateGBGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                70000:
                    ValidateRecordFields(Rec, '14', JobSalesLbl, CreateGLAccount.JobSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                80000:
                    ValidateRecordFields(Rec, '15', SalesofRetailTotalLbl, '11..14', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
                100000:
                    ValidateRecordFields(Rec, '21', RevenueArea10to55TotalLbl, CreateGBGLAccounts.SaleOfResources() + '..' + CreateGBGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '10..55', false, true);
                110000:
                    ValidateRecordFields(Rec, '22', RevenueArea60to85TotalLbl, CreateGBGLAccounts.SaleOfResources() + '..' + CreateGBGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '60..85', false, true);
                120000:
                    ValidateRecordFields(Rec, '23', RevenueNoAreacodeTotalLbl, CreateGBGLAccounts.SaleOfResources() + '..' + CreateGBGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                130000:
                    ValidateRecordFields(Rec, '24', RevenueTotalLbl, '21..23', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Show: Enum "Acc. Schedule Line Show"; Dimension1Totaling: Text[250]; Bold: Boolean; ShowOppositeSign: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Show, Show);
        AccScheduleLine.Validate("Dimension 1 Totaling", Dimension1Totaling);
        AccScheduleLine.Validate(Bold, Bold);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
    end;

    var
        IncomeThisYearLbl: Label 'Income This Year', MaxLength = 100;
        ACIDTestAnalysisLbl: Label 'ACID-TEST ANALYSIS', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        VATLbl: Label 'VAT', MaxLength = 100;
        PersonnelRelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        CAMinusShortTermLiabLbl: Label 'Current Assets minus Short-term Liabilities', MaxLength = 100;
        REVENUELbl: Label 'REVENUE', MaxLength = 100;
        SalesofRetailLbl: Label 'Sales of Retail', MaxLength = 100;
        IncomeServicesLbl: Label 'Income, Services', MaxLength = 100;
        IncomeProductSalesLbl: Label 'Income, Product Sales', MaxLength = 100;
        SalesDiscountReturnsAllowancesLbl: Label 'Sales Discount, Returns and Allowances', MaxLength = 100;
        JobSalesLbl: Label 'Job Sales', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueArea10to55TotalLbl: Label 'Revenue Area 10..55, Total', MaxLength = 100;
        RevenueArea60to85TotalLbl: Label 'Revenue Area 60..85, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
}