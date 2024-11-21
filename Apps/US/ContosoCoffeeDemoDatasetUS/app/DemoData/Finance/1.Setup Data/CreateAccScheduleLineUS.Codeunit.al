codeunit 11489 "Create Acc. Schedule Line US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    // ToDo: Need to Check with MS Team why standard Schedule Name are commented in W1

    // ToDO: MS Could not find out several GLAccount Eg. '10910..10950','20500','40250'

    trigger OnRun()
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleName: Code[10];
    begin
        AccountScheduleName := CreateAccountScheduleName.CapitalStructure();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, '', CAMinusShortTermLiabLbl, '06|16', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, false, false, false, 0);
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

        //ToDo: Need to Check with MS why standard Schedule Name are commented in W1
        // if Rec."Schedule Name" = CreateAccScheduleName.BalanceSheet() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateRecordFields(Rec, 'P0001', AssetsLbl, '10000..12200|12999..13999|15000..16000|16999..18000|18999..19999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
        //         30000:
        //             ValidateRecordFields(Rec, 'P0003', CashLbl, '18100..18500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         40000:
        //             ValidateRecordFields(Rec, 'P0004', AccountsReceivableLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         50000:
        //             ValidateRecordFields(Rec, 'P0005', PrepaidExpensesLbl, '16100..16600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         60000:
        //             ValidateRecordFields(Rec, 'P0006', InventoryLbl, '14000..14299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         90000:
        //             ValidateRecordFields(Rec, 'P0009', EquipmentLbl, '12210..12299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         100000:
        //             ValidateRecordFields(Rec, 'P0010', AccumulatedDepreciationLbl, '12900', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         140000:
        //             ValidateRecordFields(Rec, 'P0014', LiabilitiesLbl, '20000..22000|25999..29999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
        //         150000:
        //             ValidateRecordFields(Rec, 'P0015', CurrentLiabilitiesLbl, '22100..24000|24999..25500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         160000:
        //             ValidateRecordFields(Rec, 'P0016', PayrollLiabilitiesLbl, '24100..24600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         170000:
        //             ValidateRecordFields(Rec, 'P0017', LongTermLiabilitiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         200000:
        //             ValidateRecordFields(Rec, 'P0020', EquityLbl, '30000..30310|39999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
        //         210000:
        //             ValidateRecordFields(Rec, 'P0021', CommonStockLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         220000:
        //             ValidateRecordFields(Rec, 'P0022', RetainedEarningsLbl, '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         230000:
        //             ValidateRecordFields(Rec, 'P0023', DistributionsToShareholdersLbl, '30320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //     end;

        // if Rec."Schedule Name" = CreateAccScheduleName.CashFlowStatement() then
        //     case Rec."Line No." of
        //         20000:
        //             ValidateRecordFields(Rec, 'P0002', NetIncomeLbl, '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
        //         40000:
        //             ValidateRecordFields(Rec, 'P0004', AccountsReceivableLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         50000:
        //             ValidateRecordFields(Rec, 'P0005', PrepaidExpensesLbl, '16100..16600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         60000:
        //             ValidateRecordFields(Rec, 'P0006', InventoryLbl, '14000..14299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         70000:
        //             ValidateRecordFields(Rec, 'P0007', CurrentLiabilitiesLbl, '22100..24000|24999..25500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         80000:
        //             ValidateRecordFields(Rec, 'P0008', PayrollLiabilitiesLbl, '24100..24600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         120000:
        //             ValidateRecordFields(Rec, 'P0012', EquipmentLbl, '12210..12299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         130000:
        //             ValidateRecordFields(Rec, 'P0013', AccumulatedDepreciationLbl, '12900', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         170000:
        //             ValidateRecordFields(Rec, 'P0017', LongTermLiabilitiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         180000:
        //             ValidateRecordFields(Rec, 'P0018', DistributionsToShareholdersLbl, '30320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //         220000:
        //             ValidateRecordFields(Rec, 'P0022', CashBeginningofThePeriodLbl, '18100..18500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //     end;

        // if Rec."Schedule Name" = CreateAccScheduleName.IncomeStatement() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateRecordFields(Rec, 'P0001', IncomeLbl, '40000..40001|40300..40320|40380..49990|99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
        //         20000:
        //             ValidateRecordFields(Rec, 'P0002', IncomeServicesLbl, '40200..40299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         30000:
        //             ValidateRecordFields(Rec, 'P0003', IncomeProductSalesLbl, '40100..40199', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         50000:
        //             ValidateRecordFields(Rec, 'P0005', SalesDiscountsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
        //         110000:
        //             ValidateRecordFields(Rec, 'P0011', CostOfGoodsSoldLbl, '50001|50400..59990', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
        //         120000:
        //             ValidateRecordFields(Rec, 'P0012', LaborLbl, '50200..50299', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         130000:
        //             ValidateRecordFields(Rec, 'P0013', MaterialsLbl, '50100..50199', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         200000:
        //             ValidateRecordFields(Rec, 'P0020', ExpenseLbl, '60001..60100|60170..63000|63400..65200|65400..67000|67300..71999|80000..98990', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
        //         210000:
        //             ValidateRecordFields(Rec, 'P0021', RentExpenseLbl, '60110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         220000:
        //             ValidateRecordFields(Rec, 'P0022', AdvertisingExpenseLbl, '63100..63399', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         230000:
        //             ValidateRecordFields(Rec, 'P0023', InterestExpenseLbl, '40330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         240000:
        //             ValidateRecordFields(Rec, 'P0024', FeesExpenseLbl, '67100..67200', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         250000:
        //             ValidateRecordFields(Rec, 'P0025', InsuranceExpenseLbl, '73000..73999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         260000:
        //             ValidateRecordFields(Rec, 'P0026', PayrollExpenseLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         270000:
        //             ValidateRecordFields(Rec, 'P0027', BenefitsExpenseLbl, '72000..72999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         290000:
        //             ValidateRecordFields(Rec, 'P0029', RepairsMaintenanceExpenseLbl, '60160', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         300000:
        //             ValidateRecordFields(Rec, 'P0030', UtilitiesExpenseLbl, '60120..60150', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         310000:
        //             ValidateRecordFields(Rec, 'P0031', OtherIncomeExpensesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         320000:
        //             ValidateRecordFields(Rec, 'P0032', TaxExpenseLbl, '74000..79999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //         350000:
        //             ValidateRecordFields(Rec, 'P0035', BadDebtExpenseLbl, '65300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
        //     end;

        // if Rec."Schedule Name" = CreateAccScheduleName.RetainedEarnings() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateRecordFields(Rec, 'P0001', RetainedEarningsPeriodStartLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
        //         20000:
        //             ValidateRecordFields(Rec, 'P0002', NetIncomeLbl, '40000..99999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
        //         50000:
        //             ValidateRecordFields(Rec, 'P0005', DistributionsToShareholdersLbl, '30320', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
        //     end;

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