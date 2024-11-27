codeunit 17156 "Create AU Acc. Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    // ToDo: Need to Check with MS Team why standard Schedule Name are commented in W1

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
    begin
        if (Rec."Schedule Name" = CreateAccScheduleName.AccountCategoriesOverview()) and (Rec."Line No." = 60000) then
            Rec.Validate(Totaling, '9999');

        if (Rec."Schedule Name" = CreateAccScheduleName.CapitalStructure()) then
            case Rec."Line No." of
                40000:
                    Rec.Validate(Totaling, '2190');
                50000:
                    Rec.Validate(Totaling, CreateAUGLAccounts.TotalUnearnedRevenueOther());
                60000:
                    Rec.Validate(Totaling, '2890');
                70000:
                    Rec.Validate(Totaling, '2990');
                110000:
                    Rec.Validate(Totaling, '5310');
                120000:
                    Rec.Validate(Totaling, '5490');
                130000:
                    Rec.Validate(Totaling, '5790');
                140000:
                    Rec.Validate(Totaling, '5890');
                150000:
                    Rec.Validate(Totaling, '5990');
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '2190', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    Rec.Validate("Hide Currency Symbol", true);
                60000:
                    Rec.Validate("Hide Currency Symbol", true);
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '2990|5310', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '7995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '8695', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '8790', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, '8910', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, '7995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    Rec.Validate("Hide Currency Symbol", true);
                50000:
                    ValidateRecordFields(Rec, '8695|8790|8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    ValidateRecordFields(Rec, '8910', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                90000:
                    ValidateRecordFields(Rec, '9495', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
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
                    ValidateRecordFields(Rec, '6110', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFields(Rec, '6130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    Rec.Validate(Totaling, '6130');
                70000:
                    Rec.Validate(Totaling, '6190');
                80000:
                    Rec.Validate(Totaling, '6195');
                100000:
                    Rec.Validate(Totaling, '6110..6195');
                110000:
                    Rec.Validate(Totaling, '6110..6195');
                120000:
                    Rec.Validate(Totaling, '6110..6195');
                130000:
                    Rec.Validate(Totaling, '6110..6195');
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
}