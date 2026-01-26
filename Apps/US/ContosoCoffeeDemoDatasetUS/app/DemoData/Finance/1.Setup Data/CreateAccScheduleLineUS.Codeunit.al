// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 11489 "Create Acc. Schedule Line US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleName: Code[10];
    begin
        AccountScheduleName := CreateAccountScheduleName.CapitalStructure();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, '', CAMinusShortTermLiabLbl, '06|16', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, false, false, false, 0);

        CreateUSAccountScheduleLines();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        if (Rec."Schedule Name" = CreateAccScheduleName.AccountCategoriesOverview()) and (Rec."Line No." = 60000) then
            ValidateRecordFields(Rec, '4010', IncomeThisYearLbl, CreateGLAccount.NETINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);

        if Rec."Schedule Name" = CreateAccScheduleName.CapitalStructure() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '', AcidTestAnalysisLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false);
                30000:
                    ValidateRecordFields(Rec, '', CurrentAssetsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false);
                40000:
                    ValidateRecordFields(Rec, '01', LiquidAssetsLbl, CreateUSGLAccounts.BusinessAccountOperatingDomestic() + '..' + CreateGLAccount.Cash(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false, false);
                50000:
                    ValidateRecordFields(Rec, '02', SecuritiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false, false);
                60000:
                    ValidateRecordFields(Rec, '03', AccountsReceivableLbl, CreateUSGLAccounts.AccountReceivableDomestic() + '|' + CreateUSGLAccounts.PrepaidRent() + '|' + CreateUSGLAccounts.OtherPrepaidExpensesAndAccruedIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false, false);
                70000:
                    ValidateRecordFields(Rec, '04', InventoryLbl, CreateUSGLAccounts.FinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false, false);
                80000:
                    ValidateRecordFields(Rec, '05', WIPLbl, '10910..10950', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false, false);
                90000:
                    ValidateRecordFields(Rec, '06', CurrentAssetsTotalLbl, '01..05', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, false, false);
                100000:
                    ValidateRecordFields(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                110000:
                    ValidateRecordFields(Rec, '', ShortTermLiabilitiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false);
                120000:
                    ValidateRecordFields(Rec, '11', RevolvingCreditLbl, '20500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true, false);
                130000:
                    ValidateRecordFields(Rec, '12', AccountsPayableLbl, CreateUSGLAccounts.AccountsPayableDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true, false);
                140000:
                    ValidateRecordFields(Rec, '13', SalesTaxesPayableLbl, CreateUSGLAccounts.SalesTaxVATLiable(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true, false);
                150000:
                    ValidateRecordFields(Rec, '14', PersonnelRelatedItemsLbl, CreateUSGLAccounts.TaxesLiable() + '..' + CreateUSGLAccounts.EmployeesWithholdingTaxes(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true, false);
                160000:
                    ValidateRecordFields(Rec, '15', OtherLiabilitiesLbl, CreateUSGLAccounts.PurchaseDiscounts() + '..' + CreateUSGLAccounts.DeferredIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true, false);
                170000:
                    ValidateRecordFields(Rec, '16', ShortTermLiabilitiesLbl, '11..15', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, true, false);
                180000:
                    ValidateRecordFields(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalReceivablesLbl, CreateUSGLAccounts.AccountReceivableDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalPayablesLbl, CreateUSGLAccounts.AccountsPayableDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalInventoryLbl, CreateUSGLAccounts.FinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalReceivablesLbl, CreateUSGLAccounts.AccountReceivableDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalPayablesLbl, CreateUSGLAccounts.AccountsPayableDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalLiquidFundsLbl, CreateUSGLAccounts.BusinessAccountOperatingDomestic() + '..' + CreateGLAccount.Cash(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalCashFlowLbl, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueCreditLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                30000:
                    ValidateRecordFields(Rec, '20', TotalGoodsSoldLbl, CreateUSGLAccounts.CostofMaterials(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                40000:
                    ValidateRecordFields(Rec, '30', TotalExternalCostsLbl, CreateUSGLAccounts.RentLeases() + '..' + CreateUSGLAccounts.AdvertisementDevelopment() + '|' + CreateUSGLAccounts.BankingFees() + '..' + CreateUSGLAccounts.BadDebtLosses() + '|' + CreateUSGLAccounts.RepairsandMaintenanceforRental() + '..' + CreateGLAccount.OfficeSupplies(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                50000:
                    ValidateRecordFields(Rec, '40', TotalPersonnelCostsLbl, CreateGLAccount.Salaries() + '..' + CreateUSGLAccounts.LifeInsurance(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                60000:
                    ValidateRecordFields(Rec, '50', TotalDeprOnFALbl, CreateUSGLAccounts.DepreciationFixedAssets(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                70000:
                    ValidateRecordFields(Rec, '60', OtherExpensesLbl, CreateUSGLAccounts.OtherExternalServices(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.SalesReturns(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalCostLbl, CreateUSGLAccounts.CostofMaterials(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                50000:
                    ValidateRecordFields(Rec, '50', OperatingExpensesLbl, CreateUSGLAccounts.RentLeases() + '..' + CreateUSGLAccounts.AdvertisementDevelopment() + '|' + CreateUSGLAccounts.BankingFees() + '..' + CreateGLAccount.OfficeSupplies() + '|' + CreateUSGLAccounts.DepreciationFixedAssets(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                80000:
                    ValidateRecordFields(Rec, '80', OtherExpensesLbl, CreateUSGLAccounts.OtherExternalServices(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
                90000:
                    ValidateRecordFields(Rec, '90', IncomeBeforeInterestAndTaxLbl, '60 - 80', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, '11', IncomeServicesLbl, CreateUSGLAccounts.SalesofServiceWork(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                50000:
                    ValidateRecordFields(Rec, '12', IncomeProductSalesLbl, CreateUSGLAccounts.SalesofGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                60000:
                    ValidateRecordFields(Rec, '13', JobSalesContraLbl, '40250', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                70000:
                    ValidateRecordFields(Rec, '14', OtherIncomeLbl, CreateUSGLAccounts.SalesDiscounts() + '..' + CreateUSGLAccounts.InterestIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                80000:
                    ValidateRecordFields(Rec, '15', SalesofRetailTotalLbl, CreateUSGLAccounts.TotalIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true, true);
                100000:
                    ValidateRecordFields(Rec, '', RevenueArea10to55TotalLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.TotalIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '10..55', false, true, false);
                110000:
                    ValidateRecordFields(Rec, '', RevenueArea60to85TotalLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.TotalIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '60..85', false, true, false);
                120000:
                    ValidateRecordFields(Rec, '', RevenueNoAreacodeTotalLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.TotalIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true, false);
                130000:
                    ValidateRecordFields(Rec, '', RevenueTotalLbl, CreateUSGLAccounts.SalesofServiceWork() + '..' + CreateUSGLAccounts.TotalIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true, false);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Show: Enum "Acc. Schedule Line Show"; Dimension1Totaling: Text[250]; Bold: Boolean; ShowOppositeSign: Boolean; NewPage: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Show, Show);
        AccScheduleLine.Validate("Dimension 1 Totaling", Dimension1Totaling);
        AccScheduleLine.Validate(Bold, Bold);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
        AccScheduleLine.Validate("New Page", NewPage);
    end;

    internal procedure CreateUSAccountScheduleLines()
    var
        GLAccount: Record "G/L Account";
        AccScheduleLine: Record "Acc. Schedule Line";
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateAccountScheduleNameUS: Codeunit "Create Acc. Schedule Name US";
        AccountScheduleName: Code[10];
        LineNo: Integer;
    begin
        AccountScheduleName := CreateAccountScheduleName.BalanceSheetDetailed();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '', 'Current Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, 'CA', 'Cash', '18000..18999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, 'CA', 'Accounts Receivable', '15000..15999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, 'CA', 'Other Receivables', '13000..13999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, 'CA', 'Inventory', '14000..14999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, 'CA', 'Prepaid Expenses', '16000..16999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, 'CA', 'Other Current Assets', '10000..11999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, 'F1', 'Total Current Assets', 'CA', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', 'Long Term Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, 'LTA', 'Fixed Assets', '12000..12899', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'LTA', 'Accumulated Depreciation', '12900..12999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'LTA', 'Other Long Term Assets', '17000..17999|19000..19999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, 'F2', 'Total Long Term Assets', 'LTA', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, 'F3', 'Total Assets', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        DoubleUnderscoreCurrentLine(AccountScheduleName, 160000);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, '', 'Current Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'CL', 'Accounts Payable', '22100..22399', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'CL', 'Accrued Payroll', '23500..25399|26100..26399', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, 'CL', 'Accrued Tax', '23100..23499', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, 'CL', 'Accrued Other', '26400..29999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, 'CL', 'Other Current Liabilities', '22400..23099|25400..26099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, 'F4', 'Total Current Liabilities', 'CL', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, '', 'Long Term Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, 'LTL', 'Notes Payable', '20000..21299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, 'LTL', 'Other Long Term Liabilities', '21300..22099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, 'F5', 'Total Long Term Liabilities', 'LTL', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 310000, 'F6', 'Total Liabilities', 'F4+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 320000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 330000, '', 'Equity', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 340000, 'E', 'Common Stock', '30000..30299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 350000, 'E', 'Retained Earnings', '30300..39999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 360000, 'E', 'Current Year Earnings', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 370000, 'F7', 'Total Equity', 'E', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 380000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 390000, 'F8', 'Total Liabilities and Equity', 'F6+F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        DoubleUnderscoreCurrentLine(AccountScheduleName, 390000);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 400000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 410000, 'F9', 'Check Figure', 'F3+F8', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.BalanceSheetSummarized();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '1', 'Assets', '10000..19999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '2', 'Total Assets', '1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '3', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '4', 'Liabilities', '20000..29999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '5', 'Equity', '30000..39999|40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '6', 'Total Liabilities and Equity', '4+5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        DoubleUnderscoreCurrentLine(AccountScheduleName, 60000);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '7', 'Check Figure', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '8', 'Check Figure', '2+6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);

        AccountScheduleName := CreateAccountScheduleName.IncomeStatementDetailed();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '', 'Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, 'R', 'Product Revenue', '40000..40209', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, 'R', 'Job Revenue', '40410..40429', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, 'R', 'Services Revenue', '40210..40309|40430..40909', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, 'R', 'Other Revenue', '40310..40409|40920..40939', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, 'R', 'Discounts and Returns', '40910..40919|40940..49999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, 'F1', 'Total Revenue', 'R', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', 'Cost of Goods', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, 'C', 'Materials', '50000..50209', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, 'C', 'Labor', '50210..59999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'C', 'Manufacturing Overhead', '60000..69999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'F2', 'Total Cost of Goods', 'C', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, 'F3', 'Gross Margin $', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, 'F4', 'Gross Margin %', 'F3/F1*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, '', 'Operating Expense', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'OE', 'Salaries and Wages', '70000..72109', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'OE', 'Employee Benefits', '72110..73299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, 'OE', 'Employee Insurance', '73300..74109', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, 'OE', 'Employee Tax', '74110..79999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, 'OE', 'Depreciation', '80000..89999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, 'OE', 'Other Expense', '90000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, 'F5', 'Total Operating Expense', 'OE', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, 'F6', 'Net (Income) / Loss', 'F1+F2+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        DoubleUnderscoreCurrentLine(AccountScheduleName, 270000);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, 'F7', 'Total of Income Statement', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, 'F8', 'Check Figure', 'F6-F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.IncomeStatementSummarized();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '1', 'Revenue', '40000..49999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '2', 'Cost of Goods', '50000..59999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '3', 'Gross Margin', '1+2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '4', 'Gross Margin %', '3/1*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '5', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '6', 'Operating Expense', '60000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '7', 'Net (Income) / Loss', '1+2+6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        DoubleUnderscoreCurrentLine(AccountScheduleName, 70000);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '8', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '9', 'Total of Income Statement', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '10', 'Check Figure', '7-9', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);


        AccountScheduleName := CreateAccountScheduleName.TrialBalance();
        LineNo := 10000;
        GLAccount.SetRange("Account Type", Enum::"G/L Account Type"::Posting);
        GLAccount.SetLoadFields("No.", "Name");
        if GLAccount.FindSet() then
            repeat
                ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, LineNo, CopyStr(GLAccount."No.", 1, MaxStrLen(AccScheduleLine."Row No.")), CopyStr(GLAccount."No." + ' ' + GLAccount.Name, 1, MaxStrLen(AccScheduleLine.Description)), GLAccount."No.", Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
                LineNo := LineNo + 10000;
            until GLAccount.Next() = 0;
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, LineNo, '', 'Check Figure', '10000..99999', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        AccountScheduleName := CreateAccountScheduleNameUS.BalanceSheet();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', 'Current Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, 'CA', 'Cash', '18000..18999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'CA', 'Accounts Receivable', '15000..15999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 127500, 'CA', 'Inventory', '14000..14999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'CA', 'Prepaid Expenses', '16000..16999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 142500, 'CA', 'Other Current Assets', '10000..11999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 145000, 'F1', 'Total Current Assets', 'CA', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, '', 'Long Term Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, 'LTA', 'Fixed Assets', '10000..12899', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, 'LTA', 'Accumulated Depreciation', '12900..12999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 185000, 'LTA', 'Other Long Term Assets', '12900..12999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'F2', 'Total Long Term Assets', 'LTA', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, 'F3', 'Total Assets', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, '', 'Current Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, 'CL', 'Accounts Payable', '22100..22399', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, 'CL', 'Accrued Payroll', '23500..25399|26100..26399', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 255000, 'CL', 'Accrued Tax', '23100..23499', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 257500, 'CL', 'Accrued Other', '26400..29999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 258750, 'CL', 'Other Current Liabilities', '22400..23099|25400..26099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, 'F4', 'Total Long Term Assets', 'CL', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, '', 'Long Term Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, 'LTL', 'Notes Payable', '20000..21299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 295000, 'LTL', 'Other Long Term Liabilities', '21300..22099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, 'F5', 'Total Long Term Liabilities', 'LTL', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 305000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 307500, 'F6', 'Total Liabilities', 'F4+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 310000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 320000, '', 'Equity', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 330000, 'E', 'Common Stock', '30000..30299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 340000, 'E', 'Retained Earnings', '30300..39999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 350000, 'E', 'Current Year Earnings', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 360000, 'F7', 'Total Equity', 'E', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 370000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 380000, 'F8', 'Total Liabilities and Equity', 'F6+F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 390000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 400000, 'F9', 'Check Figure', 'F3+F8', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 1);

        AccountScheduleName := CreateAccountScheduleNameUS.BalanceSheetAudit();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', 'Current Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, '', 'Cash', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 115000, 'CA1', 'Petty Cash', '18100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 117500, 'CA1', 'Business account, Operating, Domestic', '18200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 118750, 'CA1', 'Business account, Operating, Foreign', '18300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 119375, 'CA1', 'Other bank accounts ', '18400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 119687, 'CA1', 'Certificate of Deposit', '18500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 119843, '', 'Cash Total', 'CA1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 119921, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, '', 'Accounts Receivable', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, 'CA2', 'Account Receivable, Domestic', '15110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, 'CA2', 'Account Receivable, Foreign', '15120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, 'CA2', 'Contractual Receivables', '15130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, 'CA2', 'Consignment Receivables', '15140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, 'CA2', 'Credit cards and Vouchers Receivables', '15150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'CA2', 'Current Receivable from Employees', '15910', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'CA2', 'Accrued income not yet invoiced', '15920', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, 'CA2', 'Clearing Accounts for Taxes and charges', '15930', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, 'CA2', 'Tax Assets', '15940', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, 'CA2', 'Current Receivables from group companies', '15950', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, '', 'Accounts Receivable Total', 'CA2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, '', 'Other Receivables', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, 'CA3', 'Long-term Receivables ', '13100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, 'CA3', 'Participation in Group Companies', '13200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, 'CA3', 'Loans to Partners or related Parties', '13300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 310000, 'CA3', 'Deferred Tax Assets', '13400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 320000, 'CA3', 'Other Long-term Receivables', '13500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 330000, '', 'Other Receivables Total', 'CA3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 340000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 350000, '', 'Inventory', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 370000, 'CA4', 'Supplies and Consumables', '14100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 380000, 'CA4', 'Raw Materials', '14110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 390000, 'CA4', 'Products in Progress', '14120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 400000, 'CA4', 'Finished Goods', '14130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 410000, 'CA4', 'Goods for Resale', '14140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 420000, 'CA4', 'Advanced Payments for goods and services', '14160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 430000, 'CA4', 'Other Inventory Items', '14170', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 440000, 'CA4', 'Work in Progress, Finished Goods', '14210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 450000, 'CA4', 'WIP Job Sales', '14220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 460000, 'CA4', 'WIP Job Costs', '14230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 470000, 'CA4', 'WIP, Accrued Costs', '14240', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 480000, 'CA4', 'WIP, Invoiced Sales', '14250', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 490000, '', 'Inventory Total', 'CA4', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 500000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 510000, '', 'Prepaid Expenses', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 530000, 'CA5', 'Prepaid Rent', '16100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 540000, 'CA5', 'Prepaid Interest expense', '16200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 550000, 'CA5', 'Accrued Rental Income', '16300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 560000, 'CA5', 'Accrued Interest Income', '16400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 570000, 'CA5', 'Assets in the form of prepaid expenses', '16500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 580000, 'CA5', 'Other prepaid expenses and accrued income', '16600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 590000, '', 'Prepaid Expenses Total', 'CA5', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 600000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 610000, '', 'Other Current Assets', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 630000, 'CA6', 'Development Expenditure', '11100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 640000, 'CA6', 'Tenancy, Site Leasehold and similar rights', '11200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 650000, 'CA6', 'Goodwill', '11300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 660000, 'CA6', 'Advanced Payments for Intangible Fixed Assets', '11400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 670000, '', 'Other Current Assets Total', 'CA6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 680000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 690000, 'F1', 'Total Current Assets', 'CA1..CA6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 700000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 710000, '', 'Long Term Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 720000, '', 'Fixed Assets and Accumulated Depreciation', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 740000, 'LTA1', 'Building', '12110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 750000, 'LTA1', 'Cost of Improvements to Leased Property', '12120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 760000, 'LTA1', 'Land ', '12130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 770000, 'LTA1', 'Equipment and Tools', '12210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 780000, 'LTA1', 'Computers', '12220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 790000, 'LTA1', 'Cars and other Transport Equipment', '12230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 800000, 'LTA1', 'Leased Assets', '12240', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 810000, 'LTA1', 'Accumulated Depreciation', '12900', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 820000, '', 'Fixed Assets and Accumulated Depreciation Total', 'LTA1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 830000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 840000, '', 'Other Long Term Assets', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 860000, 'LTA2', 'Bonds', '17100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 870000, 'LTA2', 'Decreases during the Year', '17120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 880000, 'LTA2', 'Convertible debt instruments', '17200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 890000, 'LTA2', 'Other short-term Investments', '17300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 900000, 'LTA2', 'Write-down of Short-term investments', '17400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 910000, '', 'Other Long Term Assets Total', 'LTA2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 920000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 930000, 'F2', 'Total Long Term Assets', 'LTA1+LTA2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 940000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 950000, 'F3', 'Total Assets', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 960000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 970000, '', 'Current Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 975000, '', 'Accounts Payable', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 977500, 'CL1', 'Accounts Payable, Domestic', '22100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 978750, 'CL1', 'Accounts Payable, Foreign', '22200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 979375, 'CL1', 'Advances from customers', '22300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 979531, '', 'Accounts Payable Total', 'CL1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 979687, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 980000, '', 'Accrued Payroll', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1000000, 'CL2', 'Estimated Payroll tax on Pension Costs', '23500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1010000, 'CL2', 'Employees Payable', '23850', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1020000, 'CL2', 'Employees Withholding Taxes', '24100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1030000, 'CL2', 'Statutory Social security Contributions', '24200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1040000, 'CL2', 'Contractual Social security Contributions', '24300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1050000, 'CL2', 'Attachments of Earning', '24400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1060000, 'CL2', 'Holiday Pay fund', '24500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1070000, 'CL2', 'Other Salary/wage Deductions', '24600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1080000, 'CL2', 'Clearing Account for Factoring, Current Portion', '25100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1090000, 'CL2', 'Current Liabilities to Employees', '25200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1100000, 'CL2', 'Clearing Account for third party', '25300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1110000, 'CL2', 'Accrued wages/salaries', '26100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1120000, 'CL2', 'Accrued Holiday pay', '26200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1130000, 'CL2', 'Accrued Pension costs', '26300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1140000, '', 'Accrued Payroll Total', 'CL2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1150000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1160000, '', 'Accrued Tax', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1180000, 'CL3', 'Sales Tax Liable', '23100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1190000, 'CL3', 'Taxes Liable', '23200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1200000, 'CL3', 'Estimated Income Tax', '23300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1210000, '', 'Accrued Tax Total', 'CL3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1220000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1230000, '', 'Accrued Other', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1250000, 'CL4', 'Accrued Interest Expense', '26400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1260000, 'CL4', 'Deferred Income', '26500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1270000, 'CL4', 'Accrued Contractual costs', '26600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1280000, 'CL4', 'Other Accrued Expenses and Deferred Income', '26700', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1290000, '', 'Accrued Other Total', 'CL4', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1300000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1310000, '', 'Other Current Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1330000, 'CL5', 'Change in Work in Progress', '22400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1340000, 'CL5', 'Bank overdraft short-term', '22500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1350000, 'CL5', 'Other Liabilities', '22600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1360000, 'CL5', 'Current Loans', '25400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1370000, 'CL5', 'Liabilities, Grants Received ', '25500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1380000, '', 'Other Current Liabilities Total', 'CL5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1390000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1400000, 'F4', 'Total Current Liabilities', 'CL1..CL5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1410000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1420000, '', 'Long Term Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1430000, '', 'Notes Payable', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1440000, 'LT1', 'Bonds and Debenture Loans', '21100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1450000, 'LT1', 'Convertibles Loans', '21200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1460000, '', 'Long Term Liabilities Total', 'LT1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1465000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1470000, '', 'Other Long Term Liabilities', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1480000, 'LT2', 'Other Long-term Liabilities', '21300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1490000, 'LT2', 'Bank overdraft Facilities', '21400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1500000, '', 'Other Long Term Liabilities', 'LT2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1510000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1520000, 'F5', 'Total Long Term Liabilities', 'LT1+LT2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1530000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1540000, 'F6', 'Total Liabilities', 'F4+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1550000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1560000, '', 'Equity', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1570000, '', 'Common Stock', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1590000, 'E1', 'Equity Partner ', '30100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1600000, 'E1', 'Net Results ', '30110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1610000, 'E1', 'Restricted Equity ', '30111', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1620000, 'E1', 'Share Capital ', '30200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1630000, 'E1', 'Non-Restricted Equity', '30210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1640000, '', 'Common Stock Total', 'E1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1650000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1660000, '', 'Retained Earnings', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1680000, 'E2', 'Profit or loss from the previous year', '30300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1690000, 'E2', 'Results for the Financial year', '30310', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1700000, 'E2', 'Distributions to Shareholders', '30320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1705000, 'E2', 'Current Year Earnings', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1710000, '', 'Retained Earnings Total', 'E2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1720000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1730000, 'F7', 'Total Equity', 'E1+E2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1740000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1750000, 'F8', 'Total Liabilities and Equity', 'F6+F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1760000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1770000, 'F9', 'Check Figure', 'F3+F8', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleNameUS.IncomeStatement();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', 'Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, 'R', 'Product Revenue', '40000..40209', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, 'R', 'Job Revenue', '40410..40429', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'R', 'Services Revenue', '40210..40309|40430..40909', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'R', 'Other Revenue', '40310..40409|40920..40939', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 135000, 'R', 'Discounts and Returns', '40910..40919|40940..49999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, 'F1', 'Total Revenue', 'R', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, '', 'Cost of Goods', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, 'C', 'Materials', '50000..50209', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, 'C', 'Labor', '50210..59999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'C', 'Manufacturing Overhead', '60000..69999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'F2', 'Total Cost of Goods', 'C', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, 'F3', 'Gross Margin $', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, 'F4', 'Gross Margin %', 'F3/F1*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, '', 'Operating Expense', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, 'OE', 'Salaries and Wages', '70000..72109', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, 'OE', 'Employee Benefits', '72110..73299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, 'OE', 'Employee Insurance', '73300..74109', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, 'OE', 'Employee Tax', '74110..79999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, 'OE', 'Depreciation', '80000..89999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 310000, 'OE', 'Other Expense', '90000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 320000, 'F5', 'Total Operating Expense', 'OE', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 330000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 340000, 'F6', 'Net (Income) / Loss', 'F1+F2+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 350000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 360000, 'F7', 'Total of Income Statement', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 370000, 'F8', 'Check Figure', 'F6-F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleNameUS.IncomeStatementAudit();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', 'Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', 'Product Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'R1', 'Sale of Raw Materials', '40110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'R1', 'Sale of Finished Goods', '40130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, 'R1', 'Resale of Goods', '40140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, '', 'Product Revenue Total', 'R1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, '', 'Job Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'R2', 'Job Sales', '40410', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'R2', 'Job Sales Applied', '40420', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, '', 'Job Revenue Total', 'R2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, '', 'Services Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, 'R3', 'Sale of Resources', '40210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, 'R3', 'Sale of Subcontracting', '40220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, 'R3', 'Sales of Service Contracts', '40430', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, 'R3', 'Sales of Service Work', '40440', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, '', 'Services Revenue Total', 'R3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 310000, '', 'Other Revenue', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 330000, 'R4', 'Income from securities', '40310', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 340000, 'R4', 'Management Fee Revenue', '40320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 350000, 'R4', 'Interest Income', '40330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 360000, 'R4', 'Currency Gains', '40380', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 370000, 'R4', 'Other Incidental Revenue', '40390', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 380000, 'R4', 'Invoice Rounding', '40920', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 390000, 'R4', 'Payment Tolerance', '40930', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 400000, '', 'Other Revenue Total', 'R4', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 410000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 420000, '', 'Discounts and Returns', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 440000, 'R5', 'Discounts and Allowances', '40910', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 450000, 'R5', 'Sales Returns', '40940', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 460000, '', 'Discounts and Returns Total', 'R5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 470000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 480000, 'F1', 'Total Revenue', 'R1..R5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 490000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 500000, '', 'Cost of Goods', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 510000, '', 'Materials', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 530000, 'C1', 'Cost of Materials', '50110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 540000, 'C1', 'Cost of Materials, Projects', '50120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 550000, '', 'Materials Total', 'C1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 560000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 570000, '', 'Labor', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 610000, 'C2', 'Cost of Labor', '50210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 620000, 'C2', 'Cost of Labor, Projects', '50220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 630000, 'C2', 'Cost of Labor, Warranty/Contract', '50230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 640000, 'C2', 'Project Costs', '50310', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 650000, 'C2', 'Project Cost Applied', '50320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 660000, 'C2', 'Subcontracted work', '50400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 670000, 'C2', 'Purchase Variance, Retail', '50410', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 680000, 'C2', 'Material Variance', '50420', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 690000, 'C2', 'Capacity Variance', '50421', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 700000, 'C2', 'Subcontracted Variance', '50422', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 710000, 'C2', 'Capacity Overhead Variance', '50423', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 720000, 'C2', 'Manufacturing Overhead Variance', '50424', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 730000, 'C2', 'Cost of Variances', '50500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 740000, '', 'Labor Total', 'C2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 750000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 760000, '', 'Manufacturing Overhead', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 780000, 'C3', 'Rent / Leases', '60110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 790000, 'C3', 'Electricity for Rental', '60120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 800000, 'C3', 'Heating for Rental', '60130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 810000, 'C3', 'Water and Sewerage for Rental', '60140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 820000, 'C3', 'Cleaning and Waste for Rental', '60150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 830000, 'C3', 'Repairs and Maintenance for Rental', '60160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 840000, 'C3', 'Insurances, Rental', '60170', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 850000, 'C3', 'Other Rental Expenses', '60190', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 860000, 'C3', 'Site Fees / Leases', '60210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 870000, 'C3', 'Electricity for Property', '60220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 880000, 'C3', 'Heating for Property', '60230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 890000, 'C3', 'Water and Sewerage for Property', '60240', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 900000, 'C3', 'Cleaning and Waste for Property', '60250', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 910000, 'C3', 'Repairs and Maintenance for Property', '60260', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 920000, 'C3', 'Insurances, Property', '60270', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 930000, 'C3', 'Other Property Expenses', '60290', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 940000, 'C3', 'Hire of machinery', '61100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 950000, 'C3', 'Hire of computers', '61200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 960000, 'C3', 'Hire of other fixed assets', '61300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 970000, 'C3', 'Passenger Car Costs', '62110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 980000, 'C3', 'Truck Costs', '62120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 990000, 'C3', 'Other vehicle expenses', '62190', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1000000, 'C3', 'Freight fees for goods', '62210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1010000, 'C3', 'Customs and forwarding', '62220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1020000, 'C3', 'Freight fees, projects', '62230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1030000, 'C3', 'Tickets', '62310', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1040000, 'C3', 'Rental vehicles', '62320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1050000, 'C3', 'Board and lodging', '62330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1060000, 'C3', 'Other travel expenses', '62340', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1070000, 'C3', 'Advertisement Development', '63110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1080000, 'C3', 'Outdoor and Transportation Ads', '63120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1090000, 'C3', 'Ad matter and direct mailings', '63130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1100000, 'C3', 'Conference/Exhibition Sponsorship', '63140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1110000, 'C3', 'Samples, contests, gifts', '63150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1120000, 'C3', 'Film, TV, radio, internet ads', '63160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1130000, 'C3', 'PR and Agency Fees', '63170', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1140000, 'C3', 'Other advertising fees', '63190', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1150000, 'C3', 'Catalogs, price lists', '63210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1160000, 'C3', 'Trade Publications', '63220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1170000, 'C3', 'Credit Card Charges', '63410', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1180000, 'C3', 'Business Entertaining, deductible', '63420', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1190000, 'C3', 'Business Entertaining, nondeductible', '63430', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1200000, 'C3', 'Office Supplies', '64100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1210000, 'C3', 'Phone Services', '64200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1220000, 'C3', 'Data services', '64300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1230000, 'C3', 'Postal fees', '64400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1240000, 'C3', 'Consumable/Expensible hardware', '64500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1250000, 'C3', 'Software and subscription fees', '64600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1260000, 'C3', 'Corporate Insurance', '65100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1270000, 'C3', 'Damages Paid', '65200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1280000, 'C3', 'Bad Debt Losses', '65300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1290000, 'C3', 'Security services', '65400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1300000, 'C3', 'Other risk expenses', '65900', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1310000, 'C3', 'Remuneration to Directors', '66110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1320000, 'C3', 'Management Fees', '66120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1330000, 'C3', 'Annual/interim Reports', '66130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1340000, 'C3', 'Annual/general meeting', '66140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1350000, 'C3', 'Audit and Audit Services', '66150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1360000, 'C3', 'Tax advisory Services', '66160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1370000, 'C3', 'Depreciation, Equipment', '66200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1380000, 'C3', 'Banking fees', '67100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1390000, 'C3', 'Interest Expenses', '67200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1400000, 'C3', 'Payable Invoice Rounding', '67300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1410000, 'C3', 'Miscellaneous', '67400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1420000, 'C3', 'Accounting Services', '68110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1430000, 'C3', 'IT Services', '68120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1440000, 'C3', 'Media Services', '68130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1450000, 'C3', 'Consulting Services', '68140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1460000, 'C3', 'Legal Fees and Attorney Services', '68150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1470000, 'C3', 'Other External Services', '68190', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1480000, 'C3', 'License Fees/Royalties', '68210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1490000, 'C3', 'Trademarks/Patents', '68220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1500000, 'C3', 'Association Fees', '68230', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1510000, 'C3', 'Misc. external expenses', '68280', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1520000, 'C3', 'Purchase Discounts', '68290', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1530000, '', 'Manufacturing Overhead Total', 'C3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1540000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1550000, 'F2', 'Total Cost of Goods', 'C1..C3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1560000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1570000, 'F3', 'Gross Margin $', 'F1+F2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1580000, 'F4', 'Gross Margin %', 'F3/F1*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1590000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1600000, '', 'Operating Expense', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1610000, '', 'Salaries and Wages', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1630000, 'E1', 'Salaries', '71100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1640000, 'E1', 'Hourly Wages', '71110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1650000, 'E1', 'Overtime Wages', '71120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1660000, 'E1', 'Bonuses', '71130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1670000, 'E1', 'Commissions Paid', '71140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1680000, 'E1', 'PTO Accrued', '71150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1690000, '', 'Salaries and Wages Total', 'E1', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1700000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1710000, '', 'Employee Benefits', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1730000, 'E2', 'Training Costs', '72110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1740000, 'E2', 'Health Care Contributions', '72120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1750000, 'E2', 'Entertainment of personnel', '72130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1760000, 'E2', 'Allowances', '72140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1770000, 'E2', 'Mandatory clothing expenses', '72150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1780000, 'E2', 'Other cash/remuneration benefits', '72160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1790000, 'E2', 'Pension fees and recurring costs', '72210', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1800000, 'E2', 'Employer Contributions', '72220', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1810000, 'E2', 'Health Insurance', '73100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1820000, 'E2', 'Dental Insurance', '73200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1830000, '', 'Employee Benefits Total', 'E2', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1840000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1850000, '', 'Employee Insurance', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1870000, 'E3', 'Worker''s Compensation', '73300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1880000, 'E3', 'Life Insurance', '73400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1890000, '', 'Employee Insurance Total', 'E3', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1900000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1910000, '', 'Employee Tax', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1930000, 'E4', 'Federal Withholding Expense', '74110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1940000, 'E4', 'FICA Expense', '74120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1950000, 'E4', 'FUTA Expense', '74130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1960000, 'E4', 'Medicare Expense', '74140', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1970000, 'E4', 'Other Federal Expense', '74190', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1980000, 'E4', 'State Withholding Expense', '74410', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 1990000, 'E4', 'SUTA Expense', '74420', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0, Enum::"Account Schedule Amount Type"::"Net Amount", 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2000000, '', 'Employee Tax Total', 'E4', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2010000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2020000, '', 'Depreciation', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2040000, 'E5', 'Depreciation, Land and Property', '81000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2050000, 'E5', 'Gains and Losses', '81200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2060000, 'E5', 'Depreciation, Fixed Assets', '82000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2070000, '', 'Depreciation Total', 'E5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2080000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2090000, '', 'Other Expense', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2100000, 'E6', 'Currency Losses', '91000', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2110000, '', 'Other Expense Total', 'E6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2120000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2130000, 'F5', 'Total Operating Expense', 'E1..E6', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2140000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2150000, 'F6', 'Net (Income) / Loss', 'F1+F2+F5', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2160000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2170000, 'F7', 'Total of Income Statement', '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 2180000, 'F8', 'Check Figure', 'F6-F7', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
    end;

    local procedure DoubleUnderscoreCurrentLine(AccScheduleNameCode: Code[10]; LineNo: Integer)
    var
        CurrentAccScheduleLine: Record "Acc. Schedule Line";
    begin
        CurrentAccScheduleLine.Get(AccScheduleNameCode, LineNo);
        CurrentAccScheduleLine."Double Underline" := true;
        CurrentAccScheduleLine.Modify();
    end;

    var
        IncomeThisYearLbl: Label 'Income This Year', MaxLength = 100;
        AcidTestAnalysisLbl: Label 'ACID-TEST ANALYSIS', MaxLength = 100;
        CurrentAssetsLbl: Label 'Current Assets', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        CurrentAssetsTotalLbl: Label 'Current Assets, Total', MaxLength = 100;
        ShortTermLiabilitiesLbl: Label 'Short-term Liabilities', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        PersonnelRelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        OtherExpensesLbl: Label 'Other Expenses', MaxLength = 100;
        TotalCashFlowLbl: Label 'Total Cash Flow', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total Receivables', MaxLength = 100;
        TotalPayablesLbl: Label 'Total Payables', MaxLength = 100;
        TotalInventoryLbl: Label 'Total Inventory', MaxLength = 100;
        TotalLiquidFundsLbl: Label 'Total Liquid Funds', MaxLength = 100;
        TotalRevenueCreditLbl: Label 'Total Revenue (Credit)', MaxLength = 100;
        TotalGoodsSoldLbl: Label 'Total Goods Sold', MaxLength = 100;
        TotalExternalCostsLbl: Label 'Total External Costs ', MaxLength = 100;
        TotalPersonnelCostsLbl: Label 'Total Personnel Costs', MaxLength = 100;
        TotalDeprOnFALbl: Label 'Total Depr. on Fixed Assets', MaxLength = 100;
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        IncomeBeforeInterestAndTaxLbl: Label 'Income before Interest and Tax', MaxLength = 100;
        IncomeServicesLbl: Label 'Income, Services', MaxLength = 100;
        IncomeProductSalesLbl: Label 'Income, Product Sales', MaxLength = 100;
        JobSalesContraLbl: Label 'Job Sales Contra', MaxLength = 100;
        OtherIncomeLbl: Label 'Other Income', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueArea10to55TotalLbl: Label 'Revenue Area 10..55, Total', MaxLength = 100;
        RevenueArea60to85TotalLbl: Label 'Revenue Area 60..85, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
        SalesTaxesPayableLbl: Label 'Sales Taxes Payable', MaxLength = 100;
        WIPLbl: Label 'WIP', MaxLength = 100;
        CAMinusShortTermLiabLbl: Label 'Current Assets minus Short-term Liabilities', MaxLength = 100;
}
