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
