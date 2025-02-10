codeunit 13405 "Create FI GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        InventorySetup: Record "Inventory Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '1700');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '2760');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '3001');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '7110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '2943');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '1842');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '4142');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '1630');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '7210');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '4800');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '4820');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '1620');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '1621')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '3820');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '4411');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '4412');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '4413');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '4510');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '4511');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '4512');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '4513');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '4514');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '1610');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '1650');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '1218');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '6870');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '7040');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '3810');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '2914');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '1640');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '1641');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '3121');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '3070');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '4121');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '4150');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforFI()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '0900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '0910');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '1609');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '1879');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '1899');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '1900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '1990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '3676');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '6530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '6821');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '9100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '9300');
        ContosoGLAccount.AddAccountForLocalization(IntangibleassetsName(), '0920');
        ContosoGLAccount.AddAccountForLocalization(FoundingcostsName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear1Name(), '1005');
        ContosoGLAccount.AddAccountForLocalization(ResearchName(), '1010');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear2Name(), '1015');
        ContosoGLAccount.AddAccountForLocalization(DevelopmentName(), '1020');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear3Name(), '1025');
        ContosoGLAccount.AddAccountForLocalization(IntangiblerightsName(), '1030');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear4Name(), '1035');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '1040');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear5Name(), '1041');
        ContosoGLAccount.AddAccountForLocalization(Goodwill2Name(), '1045');
        ContosoGLAccount.AddAccountForLocalization(OthercapitalisedexpenditureName(), '1050');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear6Name(), '1055');
        ContosoGLAccount.AddAccountForLocalization(AdvancepaymentsName(), '1080');
        ContosoGLAccount.AddAccountForLocalization(IntangibleassetstotalName(), '1089');
        ContosoGLAccount.AddAccountForLocalization(TangibleassetsName(), '1099');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets1Name(), '1100');
        ContosoGLAccount.AddAccountForLocalization(MachineryandequipmentName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear7Name(), '1128');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets17Name(), '1150');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear8Name(), '1158');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets18Name(), '1160');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear9Name(), '1168');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets19Name(), '1190');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear10Name(), '1198');
        ContosoGLAccount.AddAccountForLocalization(Machineryandequipment2Name(), '1200');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear11Name(), '1218');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets20Name(), '1220');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear12Name(), '1228');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets2Name(), '1230');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets3Name(), '1231');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets4Name(), '1232');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets5Name(), '1233');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets6Name(), '1234');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets7Name(), '1235');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets8Name(), '1236');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets9Name(), '1239');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets10Name(), '1240');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets11Name(), '1250');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear13Name(), '1258');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets12Name(), '1260');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets13Name(), '1291');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets14Name(), '1320');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets15Name(), '1321');
        ContosoGLAccount.AddAccountForLocalization(Othertangibleassets16Name(), '1324');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYear14Name(), '1328');
        ContosoGLAccount.AddAccountForLocalization(TangibleassetstotalName(), '1329');
        ContosoGLAccount.AddAccountForLocalization(InvestmentsName(), '1399');
        ContosoGLAccount.AddAccountForLocalization(SharesandholdingsName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(SharesinGroupcompaniesName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(SharesinassociatedcompaniesName(), '1411');
        ContosoGLAccount.AddAccountForLocalization(OthersharesandholdingsName(), '1415');
        ContosoGLAccount.AddAccountForLocalization(Othersharesandholdings2Name(), '1420');
        ContosoGLAccount.AddAccountForLocalization(Ownshares1Name(), '1440');
        ContosoGLAccount.AddAccountForLocalization(Ownshares2Name(), '1450');
        ContosoGLAccount.AddAccountForLocalization(OtherinvestmentsName(), '1490');
        ContosoGLAccount.AddAccountForLocalization(InvestmentstotalName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetstotalName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies1Name(), '1610');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies2Name(), '1611');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies3Name(), '1612');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies4Name(), '1620');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies5Name(), '1621');
        ContosoGLAccount.AddAccountForLocalization(Itemsandsupplies6Name(), '1622');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoods1Name(), '1630');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoods2Name(), '1631');
        ContosoGLAccount.AddAccountForLocalization(WIPAccountName(), '1640');
        ContosoGLAccount.AddAccountForLocalization(WIPAccount2Name(), '1641');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedCostName(), '1642');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedSalesName(), '1643');
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '1644');
        ContosoGLAccount.AddAccountForLocalization(OtherinventoriesName(), '1660');
        ContosoGLAccount.AddAccountForLocalization(Advancepayments2Name(), '1670');
        ContosoGLAccount.AddAccountForLocalization(InventorytotalName(), '1679');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivable10Name(), '1699');
        ContosoGLAccount.AddAccountForLocalization(Salesreceivables1Name(), '1700');
        ContosoGLAccount.AddAccountForLocalization(Salesreceivables2Name(), '1701');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesofGroupcompaniesName(), '1705');
        ContosoGLAccount.AddAccountForLocalization(ReceivablessociatedcompaniesName(), '1710');
        ContosoGLAccount.AddAccountForLocalization(LoanesName(), '1715');
        ContosoGLAccount.AddAccountForLocalization(Otherreceivables1Name(), '1720');
        ContosoGLAccount.AddAccountForLocalization(Salesreceivables3Name(), '1725');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesofGroupcompanies2Name(), '1730');
        ContosoGLAccount.AddAccountForLocalization(Receivablesociatedcompanies2Name(), '1735');
        ContosoGLAccount.AddAccountForLocalization(Loanes2Name(), '1740');
        ContosoGLAccount.AddAccountForLocalization(Otherreceivables2Name(), '1745');
        ContosoGLAccount.AddAccountForLocalization(SharesnotpaidName(), '1750');
        ContosoGLAccount.AddAccountForLocalization(Sharesnotpaid2Name(), '1760');
        ContosoGLAccount.AddAccountForLocalization(AccruedincomeName(), '1800');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables1Name(), '1840');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables2Name(), '1841');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables3Name(), '1842');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables4Name(), '1843');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables5Name(), '1844');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables6Name(), '1845');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables7Name(), '1848');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxreceivables8Name(), '1849');
        ContosoGLAccount.AddAccountForLocalization(AllocationsName(), '1850');
        ContosoGLAccount.AddAccountForLocalization(Otherreceivables3Name(), '1860');
        ContosoGLAccount.AddAccountForLocalization(ShorttermReceivablestotalName(), '1869');
        ContosoGLAccount.AddAccountForLocalization(SharesandparticipationsName(), '1880');
        ContosoGLAccount.AddAccountForLocalization(SharesandpartipaupcompaniesName(), '1882');
        ContosoGLAccount.AddAccountForLocalization(Ownshares3Name(), '1884');
        ContosoGLAccount.AddAccountForLocalization(SharesandpaicipoupcompaniesName(), '1885');
        ContosoGLAccount.AddAccountForLocalization(OthersharesandparticipationsName(), '1887');
        ContosoGLAccount.AddAccountForLocalization(OthersecuritiesName(), '1890');
        ContosoGLAccount.AddAccountForLocalization(SecuritiestotalName(), '1891');
        ContosoGLAccount.AddAccountForLocalization(BankNordeaName(), '1910');
        ContosoGLAccount.AddAccountForLocalization(BankSampoName(), '1916');
        ContosoGLAccount.AddAccountForLocalization(Bank3Name(), '1920');
        ContosoGLAccount.AddAccountForLocalization(Bank4Name(), '1940');
        ContosoGLAccount.AddAccountForLocalization(Bank5Name(), '1950');
        ContosoGLAccount.AddAccountForLocalization(Bank6Name(), '1960');
        ContosoGLAccount.AddAccountForLocalization(Bank7Name(), '1970');
        ContosoGLAccount.AddAccountForLocalization(Liquidassets2Name(), '1979');
        ContosoGLAccount.AddAccountForLocalization(CurrentAssetstotalName(), '1988');
        ContosoGLAccount.AddAccountForLocalization(ASSETSTOTALName(), '1989');
        ContosoGLAccount.AddAccountForLocalization(EQUITYCAPITALName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(SharecapitalestrictedequityName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(SharepremiumaccountName(), '2006');
        ContosoGLAccount.AddAccountForLocalization(RevaluationreserveName(), '2009');
        ContosoGLAccount.AddAccountForLocalization(ReserveforownsharesName(), '2010');
        ContosoGLAccount.AddAccountForLocalization(ReservefundName(), '2020');
        ContosoGLAccount.AddAccountForLocalization(OtherfundsName(), '2036');
        ContosoGLAccount.AddAccountForLocalization(ProfitLossbroughtforwardName(), '2080');
        ContosoGLAccount.AddAccountForLocalization(ProfitLossfohefinancialyearName(), '2090');
        ContosoGLAccount.AddAccountForLocalization(SharecapilerrestrictedequityName(), '2099');
        ContosoGLAccount.AddAccountForLocalization(EQUITYCAPITALTOTALName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(APPROPRIATIONSName(), '2199');
        ContosoGLAccount.AddAccountForLocalization(Depreciationdifference1Name(), '2200');
        ContosoGLAccount.AddAccountForLocalization(Depreciationdifference2Name(), '2210');
        ContosoGLAccount.AddAccountForLocalization(Depreciationdifference3Name(), '2220');
        ContosoGLAccount.AddAccountForLocalization(Voluntaryprovisions1Name(), '2240');
        ContosoGLAccount.AddAccountForLocalization(Voluntaryprovisions2Name(), '2260');
        ContosoGLAccount.AddAccountForLocalization(Voluntaryprovisions3Name(), '2264');
        ContosoGLAccount.AddAccountForLocalization(APPROPRIATIONSTOTALName(), '2269');
        ContosoGLAccount.AddAccountForLocalization(COMPULSORYPROVISIONSName(), '2270');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsforpensionsName(), '2271');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsfortaxationName(), '2275');
        ContosoGLAccount.AddAccountForLocalization(Otherprovisions1Name(), '2280');
        ContosoGLAccount.AddAccountForLocalization(Otherprovisions2Name(), '2290');
        ContosoGLAccount.AddAccountForLocalization(COMPULSORYPROVISIONSTOTALName(), '2299');
        ContosoGLAccount.AddAccountForLocalization(CREDITORSName(), '2499');
        ContosoGLAccount.AddAccountForLocalization(DepenturesName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(ConvertibledepenturesName(), '2510');
        ContosoGLAccount.AddAccountForLocalization(Loansfromcreditinstitutions1Name(), '2520');
        ContosoGLAccount.AddAccountForLocalization(Loansfromcreditinstitutions2Name(), '2530');
        ContosoGLAccount.AddAccountForLocalization(Loansfromcreditinstitutions3Name(), '2550');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors1Name(), '2561');
        ContosoGLAccount.AddAccountForLocalization(PensionloansName(), '2570');
        ContosoGLAccount.AddAccountForLocalization(AdvancesreceivedName(), '2580');
        ContosoGLAccount.AddAccountForLocalization(Tradecreditors1Name(), '2590');
        ContosoGLAccount.AddAccountForLocalization(Amountsowedundertakings1Name(), '2592');
        ContosoGLAccount.AddAccountForLocalization(Amountsowtoparticdertakings1Name(), '2593');
        ContosoGLAccount.AddAccountForLocalization(Billsofexchangepayable1Name(), '2594');
        ContosoGLAccount.AddAccountForLocalization(AccrualsanddeferredincomeName(), '2597');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors2Name(), '2640');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors3Name(), '2660');
        ContosoGLAccount.AddAccountForLocalization(Amountsowedtodertakings2Name(), '2673');
        ContosoGLAccount.AddAccountForLocalization(Amountsowedtoparticikings2Name(), '2674');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors4Name(), '2690');
        ContosoGLAccount.AddAccountForLocalization(Loansfromcreditinstitutions4Name(), '2700');
        ContosoGLAccount.AddAccountForLocalization(Loansfromcreditinstitutions5Name(), '2720');
        ContosoGLAccount.AddAccountForLocalization(Pensionloans2Name(), '2740');
        ContosoGLAccount.AddAccountForLocalization(Advancesreceived2Name(), '2750');
        ContosoGLAccount.AddAccountForLocalization(Tradecreditors2Name(), '2760');
        ContosoGLAccount.AddAccountForLocalization(Tradecreditors3Name(), '2761');
        ContosoGLAccount.AddAccountForLocalization(Amountsedtogrouundertakings3Name(), '2770');
        ContosoGLAccount.AddAccountForLocalization(Amountsowtorestundertakings3Name(), '2771');
        ContosoGLAccount.AddAccountForLocalization(Billsofexchangepayable2Name(), '2790');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome9Name(), '2800');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors5Name(), '2839');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome1Name(), '2840');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome2Name(), '2841');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome3Name(), '2842');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome4Name(), '2849');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome5Name(), '2850');
        ContosoGLAccount.AddAccountForLocalization(Othercreditors6Name(), '2860');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome6Name(), '2870');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome7Name(), '2890');
        ContosoGLAccount.AddAccountForLocalization(Accrualsanddeferredincome8Name(), '2900');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability1Name(), '2910');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability2Name(), '2911');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability3Name(), '2912');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability4Name(), '2913');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability5Name(), '2915');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability6Name(), '2920');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability7Name(), '2940');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability8Name(), '2941');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability9Name(), '2942');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability10Name(), '2943');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability11Name(), '2945');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability12Name(), '2947');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability13Name(), '2950');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability14Name(), '2957');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability15Name(), '2960');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability16Name(), '2970');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability17Name(), '2974');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability18Name(), '2990');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability19Name(), '2991');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability20Name(), '2992');
        ContosoGLAccount.AddAccountForLocalization(Deferredtaxliability21Name(), '2993');
        ContosoGLAccount.AddAccountForLocalization(CREDITORSTOTALName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(LIABILITIESTOTALName(), '2996');
        ContosoGLAccount.AddAccountForLocalization(NETTURNOVERName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(SalesofrawmaterialsdomName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(SalesofgoodsdomName(), '3001');
        ContosoGLAccount.AddAccountForLocalization(SalesofservicesdomName(), '3002');
        ContosoGLAccount.AddAccountForLocalization(SalesofservicecontName(), '3010');
        ContosoGLAccount.AddAccountForLocalization(Sales1Name(), '3040');
        ContosoGLAccount.AddAccountForLocalization(Sales2Name(), '3050');
        ContosoGLAccount.AddAccountForLocalization(Sales3Name(), '3060');
        ContosoGLAccount.AddAccountForLocalization(Sales4Name(), '3070');
        ContosoGLAccount.AddAccountForLocalization(Sales5Name(), '3075');
        ContosoGLAccount.AddAccountForLocalization(Sales6Name(), '3090');
        ContosoGLAccount.AddAccountForLocalization(SalesofrawmaterialsforName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(SalesofgoodsforName(), '3101');
        ContosoGLAccount.AddAccountForLocalization(SalesofservicesforName(), '3102');
        ContosoGLAccount.AddAccountForLocalization(SalesofrawmaterialsEUName(), '3110');
        ContosoGLAccount.AddAccountForLocalization(SalesofgoodsEUName(), '3111');
        ContosoGLAccount.AddAccountForLocalization(SalesofservicesEUName(), '3112');
        ContosoGLAccount.AddAccountForLocalization(Sales7Name(), '3120');
        ContosoGLAccount.AddAccountForLocalization(Sales8Name(), '3121');
        ContosoGLAccount.AddAccountForLocalization(Sales9Name(), '3122');
        ContosoGLAccount.AddAccountForLocalization(Sales10Name(), '3140');
        ContosoGLAccount.AddAccountForLocalization(Sales11Name(), '3144');
        ContosoGLAccount.AddAccountForLocalization(Sales12Name(), '3145');
        ContosoGLAccount.AddAccountForLocalization(Sales13Name(), '3150');
        ContosoGLAccount.AddAccountForLocalization(Sales14Name(), '3160');
        ContosoGLAccount.AddAccountForLocalization(Sales15Name(), '3170');
        ContosoGLAccount.AddAccountForLocalization(Sales16Name(), '3173');
        ContosoGLAccount.AddAccountForLocalization(Sales17Name(), '3180');
        ContosoGLAccount.AddAccountForLocalization(Sales18Name(), '3190');
        ContosoGLAccount.AddAccountForLocalization(Sales19Name(), '3290');
        ContosoGLAccount.AddAccountForLocalization(Discounts1Name(), '3600');
        ContosoGLAccount.AddAccountForLocalization(Discounts2Name(), '3610');
        ContosoGLAccount.AddAccountForLocalization(Discounts3Name(), '3611');
        ContosoGLAccount.AddAccountForLocalization(ExchangeratedifferencesName(), '3620');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains7Name(), '3621');
        ContosoGLAccount.AddAccountForLocalization(ExchangeratelossesName(), '3622');
        ContosoGLAccount.AddAccountForLocalization(PaymenttoleranceName(), '3630');
        ContosoGLAccount.AddAccountForLocalization(PaymenttolerancededucName(), '3631');
        ContosoGLAccount.AddAccountForLocalization(VATcorrectionsName(), '3650');
        ContosoGLAccount.AddAccountForLocalization(ShippingExpences1Name(), '3660');
        ContosoGLAccount.AddAccountForLocalization(ShippingExpences2Name(), '3661');
        ContosoGLAccount.AddAccountForLocalization(OthersalesdeductionsName(), '3670');
        ContosoGLAccount.AddAccountForLocalization(CreditcardprovisionsName(), '3675');
        ContosoGLAccount.AddAccountForLocalization(NETTURNOVERTOTALName(), '3679');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks1Name(), '3709');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks2Name(), '3710');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks3Name(), '3711');
        ContosoGLAccount.AddAccountForLocalization(VariationinstockstotalName(), '3720');
        ContosoGLAccount.AddAccountForLocalization(Manafacturedforownuse1Name(), '3749');
        ContosoGLAccount.AddAccountForLocalization(Manafacturedforownuse2Name(), '3750');
        ContosoGLAccount.AddAccountForLocalization(Manafacturedforownuse3Name(), '3760');
        ContosoGLAccount.AddAccountForLocalization(ManafacturedforownusetotalName(), '3769');
        ContosoGLAccount.AddAccountForLocalization(Otheroperatingincome1Name(), '3799');
        ContosoGLAccount.AddAccountForLocalization(Otheroperatingincome2Name(), '3800');
        ContosoGLAccount.AddAccountForLocalization(Otheroperatingincome3Name(), '3810');
        ContosoGLAccount.AddAccountForLocalization(RentsName(), '3840');
        ContosoGLAccount.AddAccountForLocalization(InsurancesName(), '3910');
        ContosoGLAccount.AddAccountForLocalization(GroupservicesName(), '3930');
        ContosoGLAccount.AddAccountForLocalization(OthergroupservicesName(), '3940');
        ContosoGLAccount.AddAccountForLocalization(OperatingincometotalName(), '3949');
        ContosoGLAccount.AddAccountForLocalization(RawmaterialsandservicesName(), '3998');
        ContosoGLAccount.AddAccountForLocalization(RawmaterialsandconsumablesName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofrawmaterialsdomName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofgoodsdomName(), '4001');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofservicesdomName(), '4002');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofrawmaterialsforName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofgoodsforName(), '4101');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofservicesforName(), '4102');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofrawmaterialsEUName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofgoodsEUName(), '4111');
        ContosoGLAccount.AddAccountForLocalization(PurchasesofservicesEUName(), '4112');
        ContosoGLAccount.AddAccountForLocalization(Purchases1Name(), '4120');
        ContosoGLAccount.AddAccountForLocalization(Purchases2Name(), '4121');
        ContosoGLAccount.AddAccountForLocalization(Purchases3Name(), '4122');
        ContosoGLAccount.AddAccountForLocalization(Purchases4Name(), '4150');
        ContosoGLAccount.AddAccountForLocalization(Purchases5Name(), '4200');
        ContosoGLAccount.AddAccountForLocalization(Purchases6Name(), '4240');
        ContosoGLAccount.AddAccountForLocalization(Purchases7Name(), '4255');
        ContosoGLAccount.AddAccountForLocalization(Purchases8Name(), '4270');
        ContosoGLAccount.AddAccountForLocalization(Purchases9Name(), '4380');
        ContosoGLAccount.AddAccountForLocalization(Discounts4Name(), '4600');
        ContosoGLAccount.AddAccountForLocalization(Discounts5Name(), '4610');
        ContosoGLAccount.AddAccountForLocalization(Discounts6Name(), '4611');
        ContosoGLAccount.AddAccountForLocalization(Invoicerounding2Name(), '4615');
        ContosoGLAccount.AddAccountForLocalization(Exchangeratedifferences2Name(), '4620');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains6Name(), '4621');
        ContosoGLAccount.AddAccountForLocalization(Paymenttolerance2Name(), '4630');
        ContosoGLAccount.AddAccountForLocalization(Paymenttolerancededuc2Name(), '4631');
        ContosoGLAccount.AddAccountForLocalization(VATcorrections2Name(), '4650');
        ContosoGLAccount.AddAccountForLocalization(ShippingName(), '4662');
        ContosoGLAccount.AddAccountForLocalization(InsuranceName(), '4672');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks9Name(), '4800');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks10Name(), '4801');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks11Name(), '4810');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks4Name(), '4811');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks5Name(), '4820');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks6Name(), '4821');
        ContosoGLAccount.AddAccountForLocalization(Variationinstocks7Name(), '4830');
        ContosoGLAccount.AddAccountForLocalization(RawmaterialndcoumablestotalName(), '4899');
        ContosoGLAccount.AddAccountForLocalization(Externalservices1Name(), '4900');
        ContosoGLAccount.AddAccountForLocalization(Externalservices2Name(), '4910');
        ContosoGLAccount.AddAccountForLocalization(Externalservices3Name(), '4980');
        ContosoGLAccount.AddAccountForLocalization(ShippingservicesName(), '4983');
        ContosoGLAccount.AddAccountForLocalization(RawmaterialsandservicestotalName(), '4998');
        ContosoGLAccount.AddAccountForLocalization(StaffexpencesName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries1Name(), '5000');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries2Name(), '5060');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries3Name(), '5070');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses1Name(), '5080');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses2Name(), '5090');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses3Name(), '5100');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses4Name(), '5101');
        ContosoGLAccount.AddAccountForLocalization(Pensionexpenses1Name(), '5102');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses1Name(), '5105');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses2Name(), '5106');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses3Name(), '5107');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses1Name(), '5120');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses2Name(), '5122');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses3Name(), '5125');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses4Name(), '5130');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses5Name(), '5131');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses6Name(), '5132');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses7Name(), '5150');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses8Name(), '5200');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses9Name(), '5202');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses10Name(), '5203');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses11Name(), '5204');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses12Name(), '5205');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses13Name(), '5970');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries4Name(), '6000');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries5Name(), '6010');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries6Name(), '6020');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries7Name(), '6030');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries8Name(), '6040');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries9Name(), '6050');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries10Name(), '6060');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries11Name(), '6070');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries12Name(), '6071');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries13Name(), '6073');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries14Name(), '6075');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries15Name(), '6076');
        ContosoGLAccount.AddAccountForLocalization(Wagesandsalaries16Name(), '6078');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses5Name(), '6100');
        ContosoGLAccount.AddAccountForLocalization(Socialsecurityexpenses6Name(), '6101');
        ContosoGLAccount.AddAccountForLocalization(Pensionexpenses2Name(), '6102');
        ContosoGLAccount.AddAccountForLocalization(Pensionexpenses3Name(), '6104');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses4Name(), '6105');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses5Name(), '6106');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses6Name(), '6107');
        ContosoGLAccount.AddAccountForLocalization(Pensionexpenses4Name(), '6108');
        ContosoGLAccount.AddAccountForLocalization(Othersocialsecurityexpenses7Name(), '6110');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses14Name(), '6120');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses15Name(), '6122');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses16Name(), '6125');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses17Name(), '6130');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses18Name(), '6131');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses19Name(), '6132');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses20Name(), '6150');
        ContosoGLAccount.AddAccountForLocalization(StaffexpencestotalName(), '6159');
        ContosoGLAccount.AddAccountForLocalization(OtheroperatingchargesName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(Rents2Name(), '6200');
        ContosoGLAccount.AddAccountForLocalization(Rents3Name(), '6210');
        ContosoGLAccount.AddAccountForLocalization(Rents4Name(), '6220');
        ContosoGLAccount.AddAccountForLocalization(Rents5Name(), '6230');
        ContosoGLAccount.AddAccountForLocalization(Rents6Name(), '6240');
        ContosoGLAccount.AddAccountForLocalization(Rents7Name(), '6250');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses21Name(), '6300');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses22Name(), '6301');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses23Name(), '6302');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses24Name(), '6303');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses25Name(), '6306');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses26Name(), '6310');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses27Name(), '6320');
        ContosoGLAccount.AddAccountForLocalization(Otherstaffexpenses28Name(), '6330');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp1Name(), '6340');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp2Name(), '6350');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp3Name(), '6360');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp4Name(), '6370');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp5Name(), '6380');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp6Name(), '6390');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp7Name(), '6400');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp8Name(), '6420');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp9Name(), '6430');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp10Name(), '6450');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp11Name(), '6460');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp12Name(), '6470');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp13Name(), '6480');
        ContosoGLAccount.AddAccountForLocalization(Salesmarketingexp14Name(), '6490');
        ContosoGLAccount.AddAccountForLocalization(FuelName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(Maintenance1Name(), '6510');
        ContosoGLAccount.AddAccountForLocalization(Maintenance2Name(), '6522');
        ContosoGLAccount.AddAccountForLocalization(Maintenance3Name(), '6524');
        ContosoGLAccount.AddAccountForLocalization(Maintenance4Name(), '6526');
        ContosoGLAccount.AddAccountForLocalization(FurnitureName(), '6540');
        ContosoGLAccount.AddAccountForLocalization(OtherequipmentName(), '6550');
        ContosoGLAccount.AddAccountForLocalization(SuppliesName(), '6555');
        ContosoGLAccount.AddAccountForLocalization(OthermaintenanceservicesName(), '6560');
        ContosoGLAccount.AddAccountForLocalization(WaterName(), '6570');
        ContosoGLAccount.AddAccountForLocalization(GasandelectricityName(), '6580');
        ContosoGLAccount.AddAccountForLocalization(RealestateexpencesName(), '6600');
        ContosoGLAccount.AddAccountForLocalization(OutsourcedservicesName(), '6610');
        ContosoGLAccount.AddAccountForLocalization(WasteName(), '6630');
        ContosoGLAccount.AddAccountForLocalization(ElectricityName(), '6640');
        ContosoGLAccount.AddAccountForLocalization(Insurances2Name(), '6660');
        ContosoGLAccount.AddAccountForLocalization(RealestatetaxName(), '6670');
        ContosoGLAccount.AddAccountForLocalization(Maintenance5Name(), '6680');
        ContosoGLAccount.AddAccountForLocalization(Vehicles1Name(), '6700');
        ContosoGLAccount.AddAccountForLocalization(Vehicles2Name(), '6710');
        ContosoGLAccount.AddAccountForLocalization(Vehicles3Name(), '6720');
        ContosoGLAccount.AddAccountForLocalization(Vehicles4Name(), '6730');
        ContosoGLAccount.AddAccountForLocalization(Vehicles5Name(), '6740');
        ContosoGLAccount.AddAccountForLocalization(Vehicles6Name(), '6750');
        ContosoGLAccount.AddAccountForLocalization(Vehicles7Name(), '6760');
        ContosoGLAccount.AddAccountForLocalization(Vehicles8Name(), '6770');
        ContosoGLAccount.AddAccountForLocalization(Vehicles9Name(), '6780');
        ContosoGLAccount.AddAccountForLocalization(Vehicles10Name(), '6790');
        ContosoGLAccount.AddAccountForLocalization(Otheroperatingexp1Name(), '6800');
        ContosoGLAccount.AddAccountForLocalization(Otheroperatingexp2Name(), '6810');
        ContosoGLAccount.AddAccountForLocalization(InformationcostsName(), '6820');
        ContosoGLAccount.AddAccountForLocalization(Telecosts1Name(), '6822');
        ContosoGLAccount.AddAccountForLocalization(Telecosts2Name(), '6824');
        ContosoGLAccount.AddAccountForLocalization(Insurance2Name(), '6830');
        ContosoGLAccount.AddAccountForLocalization(Insurance3Name(), '6840');
        ContosoGLAccount.AddAccountForLocalization(Officesupplies1Name(), '6850');
        ContosoGLAccount.AddAccountForLocalization(Officesupplies2Name(), '6851');
        ContosoGLAccount.AddAccountForLocalization(Officesupplies3Name(), '6854');
        ContosoGLAccount.AddAccountForLocalization(Officesupplies4Name(), '6855');
        ContosoGLAccount.AddAccountForLocalization(Officesupplies5Name(), '6856');
        ContosoGLAccount.AddAccountForLocalization(Outsourcedservices2Name(), '6860');
        ContosoGLAccount.AddAccountForLocalization(AccountingName(), '6861');
        ContosoGLAccount.AddAccountForLocalization(ITservicesName(), '6862');
        ContosoGLAccount.AddAccountForLocalization(AuditingName(), '6866');
        ContosoGLAccount.AddAccountForLocalization(LawservicesName(), '6868');
        ContosoGLAccount.AddAccountForLocalization(OtherexpencesName(), '6870');
        ContosoGLAccount.AddAccountForLocalization(MembershipsName(), '6871');
        ContosoGLAccount.AddAccountForLocalization(NotificationsName(), '6872');
        ContosoGLAccount.AddAccountForLocalization(BankingexpencesName(), '6874');
        ContosoGLAccount.AddAccountForLocalization(MeetingsName(), '6875');
        ContosoGLAccount.AddAccountForLocalization(Otherexpences2Name(), '6879');
        ContosoGLAccount.AddAccountForLocalization(Baddept1Name(), '6920');
        ContosoGLAccount.AddAccountForLocalization(Baddept2Name(), '6930');
        ContosoGLAccount.AddAccountForLocalization(Baddept3Name(), '7000');
        ContosoGLAccount.AddAccountForLocalization(OtheroperatingexpensestotalName(), '7001');
        ContosoGLAccount.AddAccountForLocalization(Depreciation1Name(), '7009');
        ContosoGLAccount.AddAccountForLocalization(Depreciation2Name(), '7010');
        ContosoGLAccount.AddAccountForLocalization(Depreciation3Name(), '7017');
        ContosoGLAccount.AddAccountForLocalization(Depreciation4Name(), '7020');
        ContosoGLAccount.AddAccountForLocalization(Depreciation5Name(), '7030');
        ContosoGLAccount.AddAccountForLocalization(Depreciation6Name(), '7040');
        ContosoGLAccount.AddAccountForLocalization(Depreciation7Name(), '7060');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue1Name(), '7110');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue2Name(), '7120');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue3Name(), '7130');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue4Name(), '7140');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue5Name(), '7160');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue6Name(), '7210');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue7Name(), '7220');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue8Name(), '7310');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue9Name(), '7320');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue10Name(), '7330');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue11Name(), '7340');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue12Name(), '7350');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue13Name(), '7360');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue14Name(), '7370');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue15Name(), '7410');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue16Name(), '7420');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue17Name(), '7440');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue18Name(), '7470');
        ContosoGLAccount.AddAccountForLocalization(Reductioninvalue19Name(), '7490');
        ContosoGLAccount.AddAccountForLocalization(DepreciationeductionsinvalueName(), '7499');
        ContosoGLAccount.AddAccountForLocalization(OPERATINGPROFITLOSSName(), '7500');
        ContosoGLAccount.AddAccountForLocalization(FinancialincomeandexpensesName(), '7999');
        ContosoGLAccount.AddAccountForLocalization(ShareofprofitlossName(), '8000');
        ContosoGLAccount.AddAccountForLocalization(ShareofprofitlsofgdertakingsName(), '8011');
        ContosoGLAccount.AddAccountForLocalization(ShareofprofitssofassompaniesName(), '8013');
        ContosoGLAccount.AddAccountForLocalization(IncomefromgroupundertakingsName(), '8021');
        ContosoGLAccount.AddAccountForLocalization(IncomefrompaipatinginterestsName(), '8023');
        ContosoGLAccount.AddAccountForLocalization(Otherintereaninancialincome1Name(), '8090');
        ContosoGLAccount.AddAccountForLocalization(Otherintereaninancialincome2Name(), '8100');
        ContosoGLAccount.AddAccountForLocalization(ReductioninvalueofirentassetsName(), '8200');
        ContosoGLAccount.AddAccountForLocalization(ReductioninvalueofinvesassetsName(), '8210');
        ContosoGLAccount.AddAccountForLocalization(InterestandothinancialincomeName(), '8290');
        ContosoGLAccount.AddAccountForLocalization(FinancialincomeName(), '8310');
        ContosoGLAccount.AddAccountForLocalization(OtherfinancialincomeName(), '8400');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains1Name(), '8410');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains2Name(), '8420');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains3Name(), '8430');
        ContosoGLAccount.AddAccountForLocalization(Otherfinancialincome2Name(), '8490');
        ContosoGLAccount.AddAccountForLocalization(Exchangerategains5Name(), '8491');
        ContosoGLAccount.AddAccountForLocalization(FinancialincometotalName(), '8498');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses1Name(), '8499');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses2Name(), '8500');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses3Name(), '8570');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses4Name(), '8650');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses5Name(), '8660');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses6Name(), '8680');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses7Name(), '8760');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses8Name(), '8880');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses9Name(), '8900');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses10Name(), '8901');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses11Name(), '8905');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses12Name(), '8910');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses13Name(), '8990');
        ContosoGLAccount.AddAccountForLocalization(Financialexpenses14Name(), '8999');
        ContosoGLAccount.AddAccountForLocalization(PROFITLOSSBEFOEXDINARYITEMSName(), '9000');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryitemsName(), '9099');
        ContosoGLAccount.AddAccountForLocalization(OtherextraordinaryincomeName(), '9290');
        ContosoGLAccount.AddAccountForLocalization(VATadjustmentsName(), '9373');
        ContosoGLAccount.AddAccountForLocalization(TAXadjusmentsName(), '9374');
        ContosoGLAccount.AddAccountForLocalization(OtherextraordinaryexpenseName(), '9390');
        ContosoGLAccount.AddAccountForLocalization(Otherextraordinaryexpense2Name(), '9490');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryitemstotalName(), '9499');
        ContosoGLAccount.AddAccountForLocalization(PROFITLOSSBEFEAPPROSANDTAXESName(), '9500');
        ContosoGLAccount.AddAccountForLocalization(Appropriations1Name(), '9599');
        ContosoGLAccount.AddAccountForLocalization(Changeindepreciationreserve1Name(), '9600');
        ContosoGLAccount.AddAccountForLocalization(Changeindepreciationreserve2Name(), '9610');
        ContosoGLAccount.AddAccountForLocalization(Changeindepreciationreserve3Name(), '9630');
        ContosoGLAccount.AddAccountForLocalization(Changeindepreciationreserve4Name(), '9640');
        ContosoGLAccount.AddAccountForLocalization(Changeindepreciationreserve5Name(), '9660');
        ContosoGLAccount.AddAccountForLocalization(Changeinuntaxedreserves1Name(), '9700');
        ContosoGLAccount.AddAccountForLocalization(Changeinuntaxedreserves2Name(), '9740');
        ContosoGLAccount.AddAccountForLocalization(Changeinuntaxedreserves3Name(), '9760');
        ContosoGLAccount.AddAccountForLocalization(Appropriationstotal1Name(), '9769');
        ContosoGLAccount.AddAccountForLocalization(IncometaxesName(), '9799');
        ContosoGLAccount.AddAccountForLocalization(Taxesoncialyeandyearsbefore1Name(), '9800');
        ContosoGLAccount.AddAccountForLocalization(Taxesoncialyeandyearsbefore2Name(), '9820');
        ContosoGLAccount.AddAccountForLocalization(Taxesoncialyeandyearsbefore3Name(), '9870');
        ContosoGLAccount.AddAccountForLocalization(Taxesoncialyeandyearsbefore4Name(), '9880');
        ContosoGLAccount.AddAccountForLocalization(Incometaxes2Name(), '9899');
        ContosoGLAccount.AddAccountForLocalization(PROFITLOSSFORTHEFINANCIALYEARName(), '9999');

        ModifyGLAccountForW1();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FinishedGoodsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALLIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalancesheetName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdepreciationbuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandbuildingstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdeproperequipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingequipmenttotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdepreciationvehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangiblefixedassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleitemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleitemsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresalesoldinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedgoodsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawmaterialsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmatsoldinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoinventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventorytotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobwipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipsalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipsalestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipcostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipcoststotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobwiptotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersdomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersforeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedinterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsreceivabletotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseprepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Vendorprepaymentsvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Vendorprepaymentsvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseprepaymentstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BanklcyName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankcurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroaccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedearningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomefortheyearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredtaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermbankloansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesprepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesprepaymentstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsdomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsforeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountspayabletotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimtotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Salesvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Salesvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat25euName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat10euName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FueltaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoaltaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatpayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VattotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelateditemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementarytaxespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalpersonnelrelateditemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherliabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsforthefiscalyearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporatetaxespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalliabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomestatementName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretaildomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretaileuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretailexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialsdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialsexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourcesdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourceseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourcesexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofjobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesotherjobexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofjobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingfeesdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandchargesrecdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountgrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretaildomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretaileuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretailexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscreceivedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofretailsoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialsdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialsexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscreceivedrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryadjmtrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmaterialssoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresourcesusedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingmaintenanceexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandheatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalbldgmaintexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficesuppliesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandfaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotaladministrativeexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantservicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OthercomputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcomputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandprName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsellingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandmotoroilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationfeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalvehicleexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtheroperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BaddebtexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandaccountingservicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtheroperatingexptotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotaloperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementplancontributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrolltaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalpersonnelexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationoffixedassetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationbuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationequipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationvehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandlossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalfixedassetdepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OthercostsofoperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetoperatingincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonbankbalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinancechargesfromcustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentdiscountsreceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscreceiveddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationroundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymenttolerancereceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmttolreceiveddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalinterestincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonrevolvingcreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonbankloansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinancechargestovendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentdiscountsgrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscgranteddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymenttolerancegrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmttolgranteddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalinterestexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NibeforeextritemsTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomebeforetaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporatetaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CurrentAssets(), CreateGLAccount.CurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Liabilities(), CreateGLAccount.LiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Securities(), CreateGLAccount.SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Intangibleassets(), IntangibleassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Foundingcosts(), FoundingcostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear1(), DecreasesduringtheYear1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Research(), ResearchName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear2(), DecreasesduringtheYear2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Development(), DevelopmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear3(), DecreasesduringtheYear3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Intangiblerights(), IntangiblerightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear4(), DecreasesduringtheYear4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear5(), DecreasesduringtheYear5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill2(), Goodwill2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othercapitalisedexpenditure(), OthercapitalisedexpenditureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear6(), DecreasesduringtheYear6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Advancepayments(), AdvancepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Intangibleassetstotal(), IntangibleassetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Intangibleassets() + '..' + Intangibleassetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tangibleassets(), TangibleassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets1(), Othertangibleassets1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Machineryandequipment(), MachineryandequipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear7(), DecreasesduringtheYear7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets17(), Othertangibleassets17Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear8(), DecreasesduringtheYear8Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets18(), Othertangibleassets18Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear9(), DecreasesduringtheYear9Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets19(), Othertangibleassets19Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear10(), DecreasesduringtheYear10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Machineryandequipment2(), Machineryandequipment2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear11(), DecreasesduringtheYear11Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets20(), Othertangibleassets20Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear12(), DecreasesduringtheYear12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets2(), Othertangibleassets2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets3(), Othertangibleassets3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets4(), Othertangibleassets4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets5(), Othertangibleassets5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets6(), Othertangibleassets6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets7(), Othertangibleassets7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets8(), Othertangibleassets8Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets9(), Othertangibleassets9Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets10(), Othertangibleassets10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets11(), Othertangibleassets11Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear13(), DecreasesduringtheYear13Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets12(), Othertangibleassets12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets13(), Othertangibleassets13Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets14(), Othertangibleassets14Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets15(), Othertangibleassets15Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Othertangibleassets16(), Othertangibleassets16Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYear14(), DecreasesduringtheYear14Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tangibleassetstotal(), TangibleassetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Tangibleassets() + '..' + Tangibleassetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Investments(), InvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesandholdings(), SharesandholdingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SharesinGroupcompanies(), SharesinGroupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesinassociatedcompanies(), SharesinassociatedcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersharesandholdings(), OthersharesandholdingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersharesandholdings2(), Othersharesandholdings2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Ownshares1(), Ownshares1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Ownshares2(), Ownshares2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherinvestments(), OtherinvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Investmentstotal(), InvestmentstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Investments() + '..' + Investmentstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetstotal(), FixedAssetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + FixedAssetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies1(), Itemsandsupplies1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies2(), Itemsandsupplies2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies3(), Itemsandsupplies3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies4(), Itemsandsupplies4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies5(), Itemsandsupplies5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Itemsandsupplies6(), Itemsandsupplies6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoods1(), FinishedGoods1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoods2(), FinishedGoods2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccount(), WIPAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccount2(), WIPAccount2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedCost(), WIPAccruedCostName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedSales(), WIPAccruedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherinventories(), OtherinventoriesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancepayments2(), Advancepayments2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Inventorytotal(), InventorytotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Inventory() + '..' + Inventorytotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivable10(), AccountsReceivable10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Salesreceivables1(), Salesreceivables1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Salesreceivables2(), Salesreceivables2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesofGroupcompanies(), ReceivablesofGroupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Receivablessociatedcompanies(), ReceivablessociatedcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loanes(), LoanesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherreceivables1(), Otherreceivables1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesreceivables3(), Salesreceivables3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesofGroupcompanies2(), ReceivablesofGroupcompanies2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Receivablesociatedcompanies2(), Receivablesociatedcompanies2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loanes2(), Loanes2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherreceivables2(), Otherreceivables2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesnotpaid(), SharesnotpaidName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesnotpaid2(), Sharesnotpaid2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accruedincome(), AccruedincomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables1(), Deferredtaxreceivables1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables2(), Deferredtaxreceivables2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables3(), Deferredtaxreceivables3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables4(), Deferredtaxreceivables4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables5(), Deferredtaxreceivables5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables6(), Deferredtaxreceivables6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables7(), Deferredtaxreceivables7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxreceivables8(), Deferredtaxreceivables8Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Allocations(), AllocationsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherreceivables3(), Otherreceivables3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShorttermReceivablestotal(), ShorttermReceivablestotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsReceivable10() + '..' + ShorttermReceivablestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesandparticipations(), SharesandparticipationsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesandpartipaupcompanies(), SharesandpartipaupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Ownshares3(), Ownshares3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharesandpaicipoupcompanies(), SharesandpaicipoupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersharesandparticipations(), OthersharesandparticipationsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersecurities(), OthersecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Securitiestotal(), SecuritiestotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Securities() + '..' + Securitiestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankNordea(), BankNordeaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(BankSampo(), BankSampoName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Bank3(), Bank3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Bank4(), Bank4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Bank5(), Bank5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Bank6(), Bank6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Bank7(), Bank7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(Liquidassets2(), Liquidassets2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiquidAssets() + '..' + Liquidassets2(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentAssetstotal(), CurrentAssetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + CurrentAssetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ASSETSTOTAL(), ASSETSTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Assets() + '..' + ASSETSTOTAL(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EQUITYCAPITAL(), EQUITYCAPITALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Sharecapitalestrictedequity(), SharecapitalestrictedequityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sharepremiumaccount(), SharepremiumaccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Revaluationreserve(), RevaluationreserveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reserveforownshares(), ReserveforownsharesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reservefund(), ReservefundName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherfunds(), OtherfundsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitLossbroughtforward(), ProfitLossbroughtforwardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitLossfohefinancialyear(), ProfitLossfohefinancialyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Total, '', '', 0, Salesofrawmaterialsdom() + '..' + PROFITLOSSFORTHEFINANCIALYEAR(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Sharecapilerrestrictedequity(), SharecapilerrestrictedequityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EQUITYCAPITALTOTAL(), EQUITYCAPITALTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Total, '', '', 0, EQUITYCAPITAL() + '..' + EQUITYCAPITALTOTAL() + '|' + Salesofrawmaterialsdom() + '..' + PROFITLOSSFORTHEFINANCIALYEAR(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(APPROPRIATIONS(), APPROPRIATIONSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationdifference1(), Depreciationdifference1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationdifference2(), Depreciationdifference2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationdifference3(), Depreciationdifference3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Voluntaryprovisions1(), Voluntaryprovisions1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Voluntaryprovisions2(), Voluntaryprovisions2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Voluntaryprovisions3(), Voluntaryprovisions3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(APPROPRIATIONSTOTAL(), APPROPRIATIONSTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, APPROPRIATIONS() + '..' + APPROPRIATIONSTOTAL(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COMPULSORYPROVISIONS(), COMPULSORYPROVISIONSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Provisionsforpensions(), ProvisionsforpensionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Provisionsfortaxation(), ProvisionsfortaxationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherprovisions1(), Otherprovisions1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherprovisions2(), Otherprovisions2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(COMPULSORYPROVISIONSTOTAL(), COMPULSORYPROVISIONSTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, COMPULSORYPROVISIONS() + '..' + COMPULSORYPROVISIONSTOTAL(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CREDITORS(), CREDITORSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depentures(), DepenturesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Convertibledepentures(), ConvertibledepenturesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loansfromcreditinstitutions1(), Loansfromcreditinstitutions1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loansfromcreditinstitutions2(), Loansfromcreditinstitutions2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loansfromcreditinstitutions3(), Loansfromcreditinstitutions3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors1(), Othercreditors1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionloans(), PensionloansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancesreceived(), AdvancesreceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Tradecreditors1(), Tradecreditors1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsowedundertakings1(), Amountsowedundertakings1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsowtoparticdertakings1(), Amountsowtoparticdertakings1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Billsofexchangepayable1(), Billsofexchangepayable1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome(), AccrualsanddeferredincomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors2(), Othercreditors2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors3(), Othercreditors3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsowedtodertakings2(), Amountsowedtodertakings2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsowedtoparticikings2(), Amountsowedtoparticikings2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors4(), Othercreditors4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loansfromcreditinstitutions4(), Loansfromcreditinstitutions4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loansfromcreditinstitutions5(), Loansfromcreditinstitutions5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionloans2(), Pensionloans2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancesreceived2(), Advancesreceived2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Tradecreditors2(), Tradecreditors2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Tradecreditors3(), Tradecreditors3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsedtogrouundertakings3(), Amountsedtogrouundertakings3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Amountsowtorestundertakings3(), Amountsowtorestundertakings3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Billsofexchangepayable2(), Billsofexchangepayable2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome9(), Accrualsanddeferredincome9Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors5(), Othercreditors5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome1(), Accrualsanddeferredincome1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome2(), Accrualsanddeferredincome2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome3(), Accrualsanddeferredincome3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome4(), Accrualsanddeferredincome4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, Accrualsanddeferredincome1() + '..' + Accrualsanddeferredincome4(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome5(), Accrualsanddeferredincome5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercreditors6(), Othercreditors6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome6(), Accrualsanddeferredincome6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome7(), Accrualsanddeferredincome7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accrualsanddeferredincome8(), Accrualsanddeferredincome8Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability1(), Deferredtaxliability1Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability2(), Deferredtaxliability2Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability3(), Deferredtaxliability3Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability4(), Deferredtaxliability4Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability5(), Deferredtaxliability5Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability6(), Deferredtaxliability6Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability7(), Deferredtaxliability7Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability8(), Deferredtaxliability8Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability9(), Deferredtaxliability9Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability10(), Deferredtaxliability10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability11(), Deferredtaxliability11Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability12(), Deferredtaxliability12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability13(), Deferredtaxliability13Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability14(), Deferredtaxliability14Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability15(), Deferredtaxliability15Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability16(), Deferredtaxliability16Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability17(), Deferredtaxliability17Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability18(), Deferredtaxliability18Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability19(), Deferredtaxliability19Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability20(), Deferredtaxliability20Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deferredtaxliability21(), Deferredtaxliability21Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CREDITORSTOTAL(), CREDITORSTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CREDITORS() + '..' + CREDITORSTOTAL(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LIABILITIESTOTAL(), LIABILITIESTOTALName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Total, '', '', 0, ASSETSTOTAL() + '..' + LIABILITIESTOTAL() + '|' + '2997' + '..' + PROFITLOSSFORTHEFINANCIALYEAR(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(NETTURNOVER(), NETTURNOVERName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofrawmaterialsdom(), SalesofrawmaterialsdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofgoodsdom(), SalesofgoodsdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofservicesdom(), SalesofservicesdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofservicecont(), SalesofservicecontName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales1(), Sales1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales2(), Sales2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales3(), Sales3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales4(), Sales4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales5(), Sales5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales6(), Sales6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofrawmaterialsfor(), SalesofrawmaterialsforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofgoodsfor(), SalesofgoodsforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesofservicesfor(), SalesofservicesforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofrawmaterialsEU(), SalesofrawmaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofgoodsEU(), SalesofgoodsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofservicesEU(), SalesofservicesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales7(), Sales7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales8(), Sales8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales9(), Sales9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales10(), Sales10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales11(), Sales11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales12(), Sales12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales13(), Sales13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales14(), Sales14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales15(), Sales15Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales16(), Sales16Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales17(), Sales17Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales18(), Sales18Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Sales19(), Sales19Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts1(), Discounts1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts2(), Discounts2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts3(), Discounts3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangeratedifferences(), ExchangeratedifferencesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains7(), Exchangerategains7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangeratelosses(), ExchangeratelossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Paymenttolerance(), PaymenttoleranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Paymenttolerancededuc(), PaymenttolerancededucName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATcorrections(), VATcorrectionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShippingExpences1(), ShippingExpences1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShippingExpences2(), ShippingExpences2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersalesdeductions(), OthersalesdeductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Creditcardprovisions(), CreditcardprovisionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NETTURNOVERTOTAL(), NETTURNOVERTOTALName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, NETTURNOVER() + '..' + NETTURNOVERTOTAL(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks1(), Variationinstocks1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks2(), Variationinstocks2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks3(), Variationinstocks3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstockstotal(), VariationinstockstotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Variationinstocks1() + '..' + Variationinstockstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Manafacturedforownuse1(), Manafacturedforownuse1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Manafacturedforownuse2(), Manafacturedforownuse2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Manafacturedforownuse3(), Manafacturedforownuse3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Manafacturedforownusetotal(), ManafacturedforownusetotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Manafacturedforownuse1() + '..' + Manafacturedforownusetotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingincome1(), Otheroperatingincome1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingincome2(), Otheroperatingincome2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingincome3(), Otheroperatingincome3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents(), RentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurances(), InsurancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Groupservices(), GroupservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othergroupservices(), OthergroupservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Operatingincometotal(), OperatingincometotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Otheroperatingincome1() + '..' + Operatingincometotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Rawmaterialsandservices(), RawmaterialsandservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Rawmaterialsandconsumables(), RawmaterialsandconsumablesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofrawmaterialsdom(), PurchasesofrawmaterialsdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofgoodsdom(), PurchasesofgoodsdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofservicesdom(), PurchasesofservicesdomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofrawmaterialsfor(), PurchasesofrawmaterialsforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofgoodsfor(), PurchasesofgoodsforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchasesofservicesfor(), PurchasesofservicesforName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesofrawmaterialsEU(), PurchasesofrawmaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesofgoodsEU(), PurchasesofgoodsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesofservicesEU(), PurchasesofservicesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases1(), Purchases1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases2(), Purchases2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases3(), Purchases3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases4(), Purchases4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases5(), Purchases5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases6(), Purchases6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases7(), Purchases7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases8(), Purchases8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Purchases9(), Purchases9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts4(), Discounts4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts5(), Discounts5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts6(), Discounts6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Invoicerounding2(), Invoicerounding2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangeratedifferences2(), Exchangeratedifferences2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains6(), Exchangerategains6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Paymenttolerance2(), Paymenttolerance2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Paymenttolerancededuc2(), Paymenttolerancededuc2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATcorrections2(), VATcorrections2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Shipping(), ShippingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurance(), InsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks9(), Variationinstocks9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks10(), Variationinstocks10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks11(), Variationinstocks11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks4(), Variationinstocks4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks5(), Variationinstocks5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks6(), Variationinstocks6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variationinstocks7(), Variationinstocks7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Rawmaterialndcoumablestotal(), RawmaterialndcoumablestotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, Rawmaterialsandconsumables() + '..' + Rawmaterialndcoumablestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Externalservices1(), Externalservices1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Externalservices2(), Externalservices2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Externalservices3(), Externalservices3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Shippingservices(), ShippingservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rawmaterialsandservicestotal(), RawmaterialsandservicestotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, Rawmaterialsandservices() + '..' + Rawmaterialsandservicestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Staffexpences(), StaffexpencesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries1(), Wagesandsalaries1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries2(), Wagesandsalaries2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries3(), Wagesandsalaries3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses1(), Socialsecurityexpenses1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses2(), Socialsecurityexpenses2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses3(), Socialsecurityexpenses3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses4(), Socialsecurityexpenses4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionexpenses1(), Pensionexpenses1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses1(), Othersocialsecurityexpenses1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses2(), Othersocialsecurityexpenses2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses3(), Othersocialsecurityexpenses3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses1(), Otherstaffexpenses1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses2(), Otherstaffexpenses2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses3(), Otherstaffexpenses3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses4(), Otherstaffexpenses4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses5(), Otherstaffexpenses5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses6(), Otherstaffexpenses6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses7(), Otherstaffexpenses7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses8(), Otherstaffexpenses8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses9(), Otherstaffexpenses9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses10(), Otherstaffexpenses10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses11(), Otherstaffexpenses11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses12(), Otherstaffexpenses12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses13(), Otherstaffexpenses13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries4(), Wagesandsalaries4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries5(), Wagesandsalaries5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries6(), Wagesandsalaries6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries7(), Wagesandsalaries7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries8(), Wagesandsalaries8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries9(), Wagesandsalaries9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries10(), Wagesandsalaries10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries11(), Wagesandsalaries11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries12(), Wagesandsalaries12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries13(), Wagesandsalaries13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries14(), Wagesandsalaries14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries15(), Wagesandsalaries15Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Wagesandsalaries16(), Wagesandsalaries16Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses5(), Socialsecurityexpenses5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Socialsecurityexpenses6(), Socialsecurityexpenses6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionexpenses2(), Pensionexpenses2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionexpenses3(), Pensionexpenses3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses4(), Othersocialsecurityexpenses4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses5(), Othersocialsecurityexpenses5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses6(), Othersocialsecurityexpenses6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionexpenses4(), Pensionexpenses4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialsecurityexpenses7(), Othersocialsecurityexpenses7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses14(), Otherstaffexpenses14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses15(), Otherstaffexpenses15Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses16(), Otherstaffexpenses16Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses17(), Otherstaffexpenses17Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses18(), Otherstaffexpenses18Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses19(), Otherstaffexpenses19Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses20(), Otherstaffexpenses20Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Staffexpencestotal(), StaffexpencestotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Staffexpences() + '..' + Staffexpencestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingcharges(), OtheroperatingchargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Rents2(), Rents2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents3(), Rents3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents4(), Rents4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents5(), Rents5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents6(), Rents6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rents7(), Rents7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses21(), Otherstaffexpenses21Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses22(), Otherstaffexpenses22Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses23(), Otherstaffexpenses23Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses24(), Otherstaffexpenses24Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses25(), Otherstaffexpenses25Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses26(), Otherstaffexpenses26Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses27(), Otherstaffexpenses27Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherstaffexpenses28(), Otherstaffexpenses28Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp1(), Salesmarketingexp1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp2(), Salesmarketingexp2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp3(), Salesmarketingexp3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp4(), Salesmarketingexp4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp5(), Salesmarketingexp5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp6(), Salesmarketingexp6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp7(), Salesmarketingexp7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp8(), Salesmarketingexp8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp9(), Salesmarketingexp9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp10(), Salesmarketingexp10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp11(), Salesmarketingexp11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp12(), Salesmarketingexp12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp13(), Salesmarketingexp13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salesmarketingexp14(), Salesmarketingexp14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Fuel(), FuelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Maintenance1(), Maintenance1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Maintenance2(), Maintenance2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Maintenance3(), Maintenance3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Maintenance4(), Maintenance4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Furniture(), FurnitureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherequipment(), OtherequipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Supplies(), SuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othermaintenanceservices(), OthermaintenanceservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Water(), WaterName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Gasandelectricity(), GasandelectricityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Realestateexpences(), RealestateexpencesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Outsourcedservices(), OutsourcedservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Waste(), WasteName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Electricity(), ElectricityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurances2(), Insurances2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Realestatetax(), RealestatetaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Maintenance5(), Maintenance5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles1(), Vehicles1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles2(), Vehicles2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles3(), Vehicles3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles4(), Vehicles4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles5(), Vehicles5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles6(), Vehicles6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles7(), Vehicles7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles8(), Vehicles8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles9(), Vehicles9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles10(), Vehicles10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingexp1(), Otheroperatingexp1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingexp2(), Otheroperatingexp2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Informationcosts(), InformationcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Telecosts1(), Telecosts1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Telecosts2(), Telecosts2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurance2(), Insurance2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurance3(), Insurance3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Officesupplies1(), Officesupplies1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Officesupplies2(), Officesupplies2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Officesupplies3(), Officesupplies3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Officesupplies4(), Officesupplies4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Officesupplies5(), Officesupplies5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Outsourcedservices2(), Outsourcedservices2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accounting(), AccountingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ITservices(), ITservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Auditing(), AuditingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Lawservices(), LawservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherexpences(), OtherexpencesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Memberships(), MembershipsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Notifications(), NotificationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bankingexpences(), BankingexpencesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Meetings(), MeetingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherexpences2(), Otherexpences2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Baddept1(), Baddept1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Baddept2(), Baddept2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Baddept3(), Baddept3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingexpensestotal(), OtheroperatingexpensestotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Otheroperatingcharges() + '..' + Otheroperatingexpensestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation1(), Depreciation1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation2(), Depreciation2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation3(), Depreciation3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation4(), Depreciation4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation5(), Depreciation5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation6(), Depreciation6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation7(), Depreciation7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue1(), Reductioninvalue1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue2(), Reductioninvalue2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue3(), Reductioninvalue3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue4(), Reductioninvalue4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue5(), Reductioninvalue5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue6(), Reductioninvalue6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue7(), Reductioninvalue7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue8(), Reductioninvalue8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue9(), Reductioninvalue9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue10(), Reductioninvalue10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue11(), Reductioninvalue11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue12(), Reductioninvalue12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue13(), Reductioninvalue13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue14(), Reductioninvalue14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue15(), Reductioninvalue15Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue16(), Reductioninvalue16Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue17(), Reductioninvalue17Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue18(), Reductioninvalue18Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalue19(), Reductioninvalue19Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationeductionsinvalue(), DepreciationeductionsinvalueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciation1() + '..' + Depreciationeductionsinvalue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OPERATINGPROFITLOSS(), OPERATINGPROFITLOSSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, Salesofrawmaterialsdom() + '..' + OPERATINGPROFITLOSS(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Financialincomeandexpenses(), FinancialincomeandexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Shareofprofitloss(), ShareofprofitlossName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Shareofprofitlsofgdertakings(), ShareofprofitlsofgdertakingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Shareofprofitssofassompanies(), ShareofprofitssofassompaniesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Incomefromgroupundertakings(), IncomefromgroupundertakingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Incomefrompaipatinginterests(), IncomefrompaipatinginterestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherintereaninancialincome1(), Otherintereaninancialincome1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherintereaninancialincome2(), Otherintereaninancialincome2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalueofirentassets(), ReductioninvalueofirentassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reductioninvalueofinvesassets(), ReductioninvalueofinvesassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Interestandothinancialincome(), InterestandothinancialincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialincome(), FinancialincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherfinancialincome(), OtherfinancialincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains1(), Exchangerategains1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains2(), Exchangerategains2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains3(), Exchangerategains3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherfinancialincome2(), Otherfinancialincome2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exchangerategains5(), Exchangerategains5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialincometotal(), FinancialincometotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Financialincomeandexpenses() + '..' + Financialincometotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses1(), Financialexpenses1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses2(), Financialexpenses2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses3(), Financialexpenses3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses4(), Financialexpenses4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses5(), Financialexpenses5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses6(), Financialexpenses6Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses7(), Financialexpenses7Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses8(), Financialexpenses8Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses9(), Financialexpenses9Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroups.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses10(), Financialexpenses10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses11(), Financialexpenses11Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses12(), Financialexpenses12Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses13(), Financialexpenses13Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Financialexpenses14(), Financialexpenses14Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Financialexpenses1() + '..' + Financialexpenses14(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PROFITLOSSBEFOEXDINARYITEMS(), PROFITLOSSBEFOEXDINARYITEMSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, Salesofrawmaterialsdom() + '..' + PROFITLOSSBEFOEXDINARYITEMS(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Extraordinaryitems(), ExtraordinaryitemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherextraordinaryincome(), OtherextraordinaryincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATadjustments(), VATadjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TAXadjusments(), TAXadjusmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherextraordinaryexpense(), OtherextraordinaryexpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherextraordinaryexpense2(), Otherextraordinaryexpense2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Extraordinaryitemstotal(), ExtraordinaryitemstotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"End-Total", '', '', 0, Extraordinaryitems() + '..' + Extraordinaryitemstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PROFITLOSSBEFEAPPROSANDTAXES(), PROFITLOSSBEFEAPPROSANDTAXESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, Salesofrawmaterialsdom() + '..' + PROFITLOSSBEFEAPPROSANDTAXES(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Appropriations1(), Appropriations1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Changeindepreciationreserve1(), Changeindepreciationreserve1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeindepreciationreserve2(), Changeindepreciationreserve2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeindepreciationreserve3(), Changeindepreciationreserve3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeindepreciationreserve4(), Changeindepreciationreserve4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeindepreciationreserve5(), Changeindepreciationreserve5Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeinuntaxedreserves1(), Changeinuntaxedreserves1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeinuntaxedreserves2(), Changeinuntaxedreserves2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeinuntaxedreserves3(), Changeinuntaxedreserves3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Appropriationstotal1(), Appropriationstotal1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Appropriations1() + '..' + Appropriationstotal1(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Incometaxes(), IncometaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Taxesoncialyeandyearsbefore1(), Taxesoncialyeandyearsbefore1Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Taxesoncialyeandyearsbefore2(), Taxesoncialyeandyearsbefore2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Taxesoncialyeandyearsbefore3(), Taxesoncialyeandyearsbefore3Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Taxesoncialyeandyearsbefore4(), Taxesoncialyeandyearsbefore4Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Incometaxes2(), Incometaxes2Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Incometaxes() + '..' + Incometaxes2(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PROFITLOSSFORTHEFINANCIALYEAR(), PROFITLOSSFORTHEFINANCIALYEARName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, Salesofrawmaterialsdom() + '..' + PROFITLOSSFORTHEFINANCIALYEAR(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.SetOverwriteData(false);
    end;

    procedure AddCategoriesToGLAccounts()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;

        GLAccountCategory.SetFilter("Parent Entry No.", '<>%1', 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignSubcategoryToChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    procedure AssignCategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), ShorttermReceivablestotal());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LiquidAssets(), ASSETSTOTAL());
                end;
            GLAccountCategory."Account Category"::Liabilities:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Liabilities(), EQUITYCAPITALTOTAL());
                    UpdateGLAccounts(GLAccountCategory, COMPULSORYPROVISIONS(), LIABILITIESTOTAL());
                end;
            GLAccountCategory."Account Category"::Equity:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Securities(), Securitiestotal());
                    UpdateGLAccounts(GLAccountCategory, APPROPRIATIONS(), APPROPRIATIONSTOTAL());
                end;
            GLAccountCategory."Account Category"::Income:
                begin
                    UpdateGLAccounts(GLAccountCategory, NETTURNOVER(), Operatingincometotal());
                    UpdateGLAccounts(GLAccountCategory, Financialincomeandexpenses(), Financialincometotal());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ExtraordinaryIncome(), Otherextraordinaryincome());
                end;
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, Rawmaterialsandservices(), Rawmaterialsandservicestotal());
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, Staffexpences(), Staffexpencestotal());
                    UpdateGLAccounts(GLAccountCategory, Otheroperatingcharges(), Otheroperatingexpensestotal());
                    UpdateGLAccounts(GLAccountCategory, Depreciation1(), Depreciationeductionsinvalue());
                    UpdateGLAccounts(GLAccountCategory, Financialexpenses1(), Financialexpenses14());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ExtraordinaryExpenses(), Otherextraordinaryexpense2());
                    UpdateGLAccounts(GLAccountCategory, Appropriations1(), Appropriationstotal1());
                    UpdateGLAccounts(GLAccountCategory, Incometaxes(), Incometaxes2());
                end;
        end;
    end;

    procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            Assets():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), CreateGLAccount.LiquidAssets());
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cash(), Bank7());
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, AccountsReceivable10(), ShorttermReceivablestotal());
            GLAccountCategoryMgt.GetPrepaidExpenses():
                begin
                    UpdateGLAccounts(GLAccountCategory, Advancepayments(), Advancepayments());
                    UpdateGLAccounts(GLAccountCategory, Advancepayments2(), Advancepayments2());
                end;
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Inventory(), Inventorytotal());
            GLAccountCategoryMgt.GetEquipment():
                begin
                    UpdateGLAccounts(GLAccountCategory, Machineryandequipment(), Machineryandequipment());
                    UpdateGLAccounts(GLAccountCategory, Machineryandequipment2(), Machineryandequipment2());
                end;
            GLAccountCategoryMgt.GetAccumDeprec():
                begin
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear1(), DecreasesduringtheYear1());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear2(), DecreasesduringtheYear2());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear3(), DecreasesduringtheYear3());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear4(), DecreasesduringtheYear4());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear5(), DecreasesduringtheYear5());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear6(), DecreasesduringtheYear6());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear7(), DecreasesduringtheYear7());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear8(), DecreasesduringtheYear8());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear9(), DecreasesduringtheYear9());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear10(), DecreasesduringtheYear10());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear11(), DecreasesduringtheYear11());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear12(), DecreasesduringtheYear12());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear13(), DecreasesduringtheYear13());
                    UpdateGLAccounts(GLAccountCategory, DecreasesduringtheYear14(), DecreasesduringtheYear14());
                end;
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, Depreciationdifference1(), Voluntaryprovisions3());
                    UpdateGLAccounts(GLAccountCategory, Provisionsforpensions(), Otherprovisions2());
                    UpdateGLAccounts(GLAccountCategory, Depentures(), Othercreditors5());
                    UpdateGLAccounts(GLAccountCategory, Accrualsanddeferredincome2(), Accrualsanddeferredincome3());
                    UpdateGLAccounts(GLAccountCategory, Accrualsanddeferredincome5(), Deferredtaxliability21());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                ;
            GLAccountCategoryMgt.GetLongTermLiabilities():
                ;
            GLAccountCategoryMgt.GetCommonStock():
                begin
                    UpdateGLAccounts(GLAccountCategory, Sharesandparticipations(), Othersecurities());
                    UpdateGLAccounts(GLAccountCategory, APPROPRIATIONS(), APPROPRIATIONSTOTAL());
                end;
            GLAccountCategoryMgt.GetRetEarnings():
                ;
            GLAccountCategoryMgt.GetDistrToShareholders():
                ;
            GLAccountCategoryMgt.GetIncomeService():
                begin
                    UpdateGLAccounts(GLAccountCategory, Salesofrawmaterialsdom(), CreateGLAccount.InvoiceRounding());
                    UpdateGLAccounts(GLAccountCategory, Variationinstocks2(), Variationinstocks3());
                    UpdateGLAccounts(GLAccountCategory, Manafacturedforownuse2(), Manafacturedforownuse3());
                    UpdateGLAccounts(GLAccountCategory, Otheroperatingincome2(), Othergroupservices());
                end;
            GLAccountCategoryMgt.GetIncomeProdSales():
                ;
            GLAccountCategoryMgt.GetIncomeSalesDiscounts():
                ;
            GLAccountCategoryMgt.GetIncomeSalesReturns():
                ;
            GLAccountCategoryMgt.GetCOGSLabor():
                ;
            GLAccountCategoryMgt.GetCOGSMaterials():
                begin
                    UpdateGLAccounts(GLAccountCategory, Purchasesofrawmaterialsdom(), Variationinstocks7());
                    UpdateGLAccounts(GLAccountCategory, Externalservices1(), Shippingservices());
                end;
            GLAccountCategoryMgt.GetRentExpense():
                ;
            GLAccountCategoryMgt.GetAdvertisingExpense():
                ;
            GLAccountCategoryMgt.GetInterestExpense():
                ;
            GLAccountCategoryMgt.GetFeesExpense():
                ;
            GLAccountCategoryMgt.GetInsuranceExpense():
                ;
            GLAccountCategoryMgt.GetPayrollExpense():
                UpdateGLAccounts(GLAccountCategory, Wagesandsalaries1(), Otherstaffexpenses20());
            GLAccountCategoryMgt.GetBenefitsExpense():
                ;
            GLAccountCategoryMgt.GetRepairsExpense():
                ;
            GLAccountCategoryMgt.GetUtilitiesExpense():
                ;
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, Depreciation2(), Reductioninvalue19());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ExtraordinaryExpenses(), CreateGLAccount.ExtraordinaryExpenses());
                    UpdateGLAccounts(GLAccountCategory, Otherextraordinaryexpense(), Otherextraordinaryexpense2());
                end;
            GLAccountCategoryMgt.GetTaxExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, VATadjustments(), TAXadjusments());
                    UpdateGLAccounts(GLAccountCategory, Taxesoncialyeandyearsbefore1(), Taxesoncialyeandyearsbefore4());
                end;
            GLAccountCategoryMgt.GetCurrentAssets():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CurrentAssets(), CreateGLAccount.CurrentAssets());
                    UpdateGLAccounts(GLAccountCategory, CurrentAssetstotal(), CurrentAssetstotal());
                end;
        end;
    end;

    local procedure UpdateGLAccounts(GLAccountCategory: Record "G/L Account Category"; FromGLAccountNo: Code[20]; ToGLAccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("No.", FromGLAccountNo, ToGLAccountNo);
        if GLAccount.FindSet() then begin
            GLAccount.ModifyAll("Account Category", GLAccountCategory."Account Category", false);
            GLAccount.ModifyAll("Account Subcategory Entry No.", GLAccountCategory."Entry No.", false);
        end;
    end;

    procedure Intangibleassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleassetsName()));
    end;

    procedure Foundingcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FoundingcostsName()));
    end;

    procedure DecreasesduringtheYear1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear1Name()));
    end;

    procedure Research(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResearchName()));
    end;

    procedure DecreasesduringtheYear2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear2Name()));
    end;

    procedure Development(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopmentName()));
    end;

    procedure DecreasesduringtheYear3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear3Name()));
    end;

    procedure Intangiblerights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangiblerightsName()));
    end;

    procedure DecreasesduringtheYear4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear4Name()));
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure DecreasesduringtheYear5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear5Name()));
    end;

    procedure Goodwill2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Goodwill2Name()));
    end;

    procedure Othercapitalisedexpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthercapitalisedexpenditureName()));
    end;

    procedure DecreasesduringtheYear6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear6Name()));
    end;

    procedure Advancepayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancepaymentsName()));
    end;

    procedure Intangibleassetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleassetstotalName()));
    end;

    procedure Tangibleassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangibleassetsName()));
    end;

    procedure Othertangibleassets1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets1Name()));
    end;

    procedure Machineryandequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryandequipmentName()));
    end;

    procedure DecreasesduringtheYear7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear7Name()));
    end;

    procedure Othertangibleassets17(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets17Name()));
    end;

    procedure DecreasesduringtheYear8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear8Name()));
    end;

    procedure Othertangibleassets18(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets18Name()));
    end;

    procedure DecreasesduringtheYear9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear9Name()));
    end;

    procedure Othertangibleassets19(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets19Name()));
    end;

    procedure DecreasesduringtheYear10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear10Name()));
    end;

    procedure Machineryandequipment2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Machineryandequipment2Name()));
    end;

    procedure DecreasesduringtheYear11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear11Name()));
    end;

    procedure Othertangibleassets20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets20Name()));
    end;

    procedure DecreasesduringtheYear12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear12Name()));
    end;

    procedure Othertangibleassets2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets2Name()));
    end;

    procedure Othertangibleassets3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets3Name()));
    end;

    procedure Othertangibleassets4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets4Name()));
    end;

    procedure Othertangibleassets5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets5Name()));
    end;

    procedure Othertangibleassets6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets6Name()));
    end;

    procedure Othertangibleassets7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets7Name()));
    end;

    procedure Othertangibleassets8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets8Name()));
    end;

    procedure Othertangibleassets9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets9Name()));
    end;

    procedure Othertangibleassets10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets10Name()));
    end;

    procedure Othertangibleassets11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets11Name()));
    end;

    procedure DecreasesduringtheYear13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear13Name()));
    end;

    procedure Othertangibleassets12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets12Name()));
    end;

    procedure Othertangibleassets13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets13Name()));
    end;

    procedure Othertangibleassets14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets14Name()));
    end;

    procedure Othertangibleassets15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets15Name()));
    end;

    procedure Othertangibleassets16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othertangibleassets16Name()));
    end;

    procedure DecreasesduringtheYear14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYear14Name()));
    end;

    procedure Tangibleassetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangibleassetstotalName()));
    end;

    procedure Investments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentsName()));
    end;

    procedure Sharesandholdings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesandholdingsName()));
    end;

    procedure SharesinGroupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesinGroupcompaniesName()));
    end;

    procedure Sharesinassociatedcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesinassociatedcompaniesName()));
    end;

    procedure Othersharesandholdings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthersharesandholdingsName()));
    end;

    procedure Othersharesandholdings2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersharesandholdings2Name()));
    end;

    procedure Ownshares1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Ownshares1Name()));
    end;

    procedure Ownshares2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Ownshares2Name()));
    end;

    procedure Otherinvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherinvestmentsName()));
    end;

    procedure Investmentstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentstotalName()));
    end;

    procedure FixedAssetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetstotalName()));
    end;

    procedure Itemsandsupplies1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies1Name()));
    end;

    procedure Itemsandsupplies2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies2Name()));
    end;

    procedure Itemsandsupplies3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies3Name()));
    end;

    procedure Itemsandsupplies4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies4Name()));
    end;

    procedure Itemsandsupplies5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies5Name()));
    end;

    procedure Itemsandsupplies6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Itemsandsupplies6Name()));
    end;

    procedure FinishedGoods1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoods1Name()));
    end;

    procedure FinishedGoods2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoods2Name()));
    end;

    procedure WIPAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccountName()));
    end;

    procedure WIPAccount2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccount2Name()));
    end;

    procedure WIPAccruedCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedCostName()));
    end;

    procedure WIPAccruedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedSalesName()));
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure Otherinventories(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherinventoriesName()));
    end;

    procedure Advancepayments2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Advancepayments2Name()));
    end;

    procedure Inventorytotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventorytotalName()));
    end;

    procedure AccountsReceivable10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivable10Name()));
    end;

    procedure Salesreceivables1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesreceivables1Name()));
    end;

    procedure Salesreceivables2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesreceivables2Name()));
    end;

    procedure ReceivablesofGroupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesofGroupcompaniesName()));
    end;

    procedure Receivablessociatedcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablessociatedcompaniesName()));
    end;

    procedure Loanes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanesName()));
    end;

    procedure Otherreceivables1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherreceivables1Name()));
    end;

    procedure Salesreceivables3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesreceivables3Name()));
    end;

    procedure ReceivablesofGroupcompanies2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesofGroupcompanies2Name()));
    end;

    procedure Receivablesociatedcompanies2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Receivablesociatedcompanies2Name()));
    end;

    procedure Loanes2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loanes2Name()));
    end;

    procedure Otherreceivables2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherreceivables2Name()));
    end;

    procedure Sharesnotpaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesnotpaidName()));
    end;

    procedure Sharesnotpaid2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sharesnotpaid2Name()));
    end;

    procedure Accruedincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedincomeName()));
    end;

    procedure Deferredtaxreceivables1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables1Name()));
    end;

    procedure Deferredtaxreceivables2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables2Name()));
    end;

    procedure Deferredtaxreceivables3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables3Name()));
    end;

    procedure Deferredtaxreceivables4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables4Name()));
    end;

    procedure Deferredtaxreceivables5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables5Name()));
    end;

    procedure Deferredtaxreceivables6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables6Name()));
    end;

    procedure Deferredtaxreceivables7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables7Name()));
    end;

    procedure Deferredtaxreceivables8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxreceivables8Name()));
    end;

    procedure Allocations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllocationsName()));
    end;

    procedure Otherreceivables3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherreceivables3Name()));
    end;

    procedure ShorttermReceivablestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShorttermReceivablestotalName()));
    end;

    procedure Sharesandparticipations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesandparticipationsName()));
    end;

    procedure Sharesandpartipaupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesandpartipaupcompaniesName()));
    end;

    procedure Ownshares3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Ownshares3Name()));
    end;

    procedure Sharesandpaicipoupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharesandpaicipoupcompaniesName()));
    end;

    procedure Othersharesandparticipations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthersharesandparticipationsName()));
    end;

    procedure Othersecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthersecuritiesName()));
    end;

    procedure Securitiestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiestotalName()));
    end;

    procedure BankNordea(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankNordeaName()));
    end;

    procedure BankSampo(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankSampoName()));
    end;

    procedure Bank3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Bank3Name()));
    end;

    procedure Bank4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Bank4Name()));
    end;

    procedure Bank5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Bank5Name()));
    end;

    procedure Bank6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Bank6Name()));
    end;

    procedure Bank7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Bank7Name()));
    end;

    procedure Liquidassets2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Liquidassets2Name()));
    end;

    procedure CurrentAssetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentAssetstotalName()));
    end;

    procedure ASSETSTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ASSETSTOTALName()));
    end;

    procedure EQUITYCAPITAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EQUITYCAPITALName()));
    end;

    procedure Sharecapitalestrictedequity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharecapitalestrictedequityName()));
    end;

    procedure Sharepremiumaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharepremiumaccountName()));
    end;

    procedure Revaluationreserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevaluationreserveName()));
    end;

    procedure Reserveforownshares(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReserveforownsharesName()));
    end;

    procedure Reservefund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservefundName()));
    end;

    procedure Otherfunds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherfundsName()));
    end;

    procedure ProfitLossbroughtforward(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitLossbroughtforwardName()));
    end;

    procedure ProfitLossfohefinancialyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitLossfohefinancialyearName()));
    end;

    procedure Sharecapilerrestrictedequity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SharecapilerrestrictedequityName()));
    end;

    procedure EQUITYCAPITALTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EQUITYCAPITALTOTALName()));
    end;

    procedure APPROPRIATIONS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(APPROPRIATIONSName()));
    end;

    procedure Depreciationdifference1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciationdifference1Name()));
    end;

    procedure Depreciationdifference2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciationdifference2Name()));
    end;

    procedure Depreciationdifference3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciationdifference3Name()));
    end;

    procedure Voluntaryprovisions1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Voluntaryprovisions1Name()));
    end;

    procedure Voluntaryprovisions2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Voluntaryprovisions2Name()));
    end;

    procedure Voluntaryprovisions3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Voluntaryprovisions3Name()));
    end;

    procedure APPROPRIATIONSTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(APPROPRIATIONSTOTALName()));
    end;

    procedure COMPULSORYPROVISIONS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COMPULSORYPROVISIONSName()));
    end;

    procedure Provisionsforpensions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsforpensionsName()));
    end;

    procedure Provisionsfortaxation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsfortaxationName()));
    end;

    procedure Otherprovisions1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherprovisions1Name()));
    end;

    procedure Otherprovisions2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherprovisions2Name()));
    end;

    procedure COMPULSORYPROVISIONSTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COMPULSORYPROVISIONSTOTALName()));
    end;

    procedure CREDITORS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CREDITORSName()));
    end;

    procedure Depentures(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepenturesName()));
    end;

    procedure Convertibledepentures(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertibledepenturesName()));
    end;

    procedure Loansfromcreditinstitutions1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loansfromcreditinstitutions1Name()));
    end;

    procedure Loansfromcreditinstitutions2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loansfromcreditinstitutions2Name()));
    end;

    procedure Loansfromcreditinstitutions3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loansfromcreditinstitutions3Name()));
    end;

    procedure Othercreditors1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors1Name()));
    end;

    procedure Pensionloans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionloansName()));
    end;

    procedure Advancesreceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesreceivedName()));
    end;

    procedure Tradecreditors1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Tradecreditors1Name()));
    end;

    procedure Amountsowedundertakings1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsowedundertakings1Name()));
    end;

    procedure Amountsowtoparticdertakings1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsowtoparticdertakings1Name()));
    end;

    procedure Billsofexchangepayable1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Billsofexchangepayable1Name()));
    end;

    procedure Accrualsanddeferredincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccrualsanddeferredincomeName()));
    end;

    procedure Othercreditors2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors2Name()));
    end;

    procedure Othercreditors3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors3Name()));
    end;

    procedure Amountsowedtodertakings2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsowedtodertakings2Name()));
    end;

    procedure Amountsowedtoparticikings2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsowedtoparticikings2Name()));
    end;

    procedure Othercreditors4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors4Name()));
    end;

    procedure Loansfromcreditinstitutions4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loansfromcreditinstitutions4Name()));
    end;

    procedure Loansfromcreditinstitutions5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Loansfromcreditinstitutions5Name()));
    end;

    procedure Pensionloans2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Pensionloans2Name()));
    end;

    procedure Advancesreceived2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Advancesreceived2Name()));
    end;

    procedure Tradecreditors2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Tradecreditors2Name()));
    end;

    procedure Tradecreditors3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Tradecreditors3Name()));
    end;

    procedure Amountsedtogrouundertakings3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsedtogrouundertakings3Name()));
    end;

    procedure Amountsowtorestundertakings3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Amountsowtorestundertakings3Name()));
    end;

    procedure Billsofexchangepayable2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Billsofexchangepayable2Name()));
    end;

    procedure Accrualsanddeferredincome9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome9Name()));
    end;

    procedure Othercreditors5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors5Name()));
    end;

    procedure Accrualsanddeferredincome1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome1Name()));
    end;

    procedure Accrualsanddeferredincome2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome2Name()));
    end;

    procedure Accrualsanddeferredincome3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome3Name()));
    end;

    procedure Accrualsanddeferredincome4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome4Name()));
    end;

    procedure Accrualsanddeferredincome5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome5Name()));
    end;

    procedure Othercreditors6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othercreditors6Name()));
    end;

    procedure Accrualsanddeferredincome6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome6Name()));
    end;

    procedure Accrualsanddeferredincome7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome7Name()));
    end;

    procedure Accrualsanddeferredincome8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Accrualsanddeferredincome8Name()));
    end;

    procedure Deferredtaxliability1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability1Name()));
    end;

    procedure Deferredtaxliability2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability2Name()));
    end;

    procedure Deferredtaxliability3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability3Name()));
    end;

    procedure Deferredtaxliability4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability4Name()));
    end;

    procedure Deferredtaxliability5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability5Name()));
    end;

    procedure Deferredtaxliability6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability6Name()));
    end;

    procedure Deferredtaxliability7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability7Name()));
    end;

    procedure Deferredtaxliability8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability8Name()));
    end;

    procedure Deferredtaxliability9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability9Name()));
    end;

    procedure Deferredtaxliability10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability10Name()));
    end;

    procedure Deferredtaxliability11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability11Name()));
    end;

    procedure Deferredtaxliability12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability12Name()));
    end;

    procedure Deferredtaxliability13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability13Name()));
    end;

    procedure Deferredtaxliability14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability14Name()));
    end;

    procedure Deferredtaxliability15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability15Name()));
    end;

    procedure Deferredtaxliability16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability16Name()));
    end;

    procedure Deferredtaxliability17(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability17Name()));
    end;

    procedure Deferredtaxliability18(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability18Name()));
    end;

    procedure Deferredtaxliability19(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability19Name()));
    end;

    procedure Deferredtaxliability20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability20Name()));
    end;

    procedure Deferredtaxliability21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Deferredtaxliability21Name()));
    end;

    procedure CREDITORSTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CREDITORSTOTALName()));
    end;

    procedure LIABILITIESTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LIABILITIESTOTALName()));
    end;

    procedure NETTURNOVER(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NETTURNOVERName()));
    end;

    procedure Salesofrawmaterialsdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofrawmaterialsdomName()));
    end;

    procedure Salesofgoodsdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofgoodsdomName()));
    end;

    procedure Salesofservicesdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofservicesdomName()));
    end;

    procedure Salesofservicecont(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofservicecontName()));
    end;

    procedure Sales1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales1Name()));
    end;

    procedure Sales2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales2Name()));
    end;

    procedure Sales3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales3Name()));
    end;

    procedure Sales4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales4Name()));
    end;

    procedure Sales5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales5Name()));
    end;

    procedure Sales6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales6Name()));
    end;

    procedure Salesofrawmaterialsfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofrawmaterialsforName()));
    end;

    procedure Salesofgoodsfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofgoodsforName()));
    end;

    procedure Salesofservicesfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofservicesforName()));
    end;

    procedure SalesofrawmaterialsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofrawmaterialsEUName()));
    end;

    procedure SalesofgoodsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofgoodsEUName()));
    end;

    procedure SalesofservicesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofservicesEUName()));
    end;

    procedure Sales7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales7Name()));
    end;

    procedure Sales8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales8Name()));
    end;

    procedure Sales9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales9Name()));
    end;

    procedure Sales10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales10Name()));
    end;

    procedure Sales11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales11Name()));
    end;

    procedure Sales12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales12Name()));
    end;

    procedure Sales13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales13Name()));
    end;

    procedure Sales14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales14Name()));
    end;

    procedure Sales15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales15Name()));
    end;

    procedure Sales16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales16Name()));
    end;

    procedure Sales17(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales17Name()));
    end;

    procedure Sales18(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales18Name()));
    end;

    procedure Sales19(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Sales19Name()));
    end;

    procedure Discounts1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts1Name()));
    end;

    procedure Discounts2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts2Name()));
    end;

    procedure Discounts3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts3Name()));
    end;

    procedure Exchangeratedifferences(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeratedifferencesName()));
    end;

    procedure Exchangerategains7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains7Name()));
    end;

    procedure Exchangeratelosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeratelossesName()));
    end;

    procedure Paymenttolerance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymenttoleranceName()));
    end;

    procedure Paymenttolerancededuc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymenttolerancededucName()));
    end;

    procedure VATcorrections(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATcorrectionsName()));
    end;

    procedure ShippingExpences1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShippingExpences1Name()));
    end;

    procedure ShippingExpences2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShippingExpences2Name()));
    end;

    procedure Othersalesdeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthersalesdeductionsName()));
    end;

    procedure Creditcardprovisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditcardprovisionsName()));
    end;

    procedure NETTURNOVERTOTAL(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NETTURNOVERTOTALName()));
    end;

    procedure Variationinstocks1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks1Name()));
    end;

    procedure Variationinstocks2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks2Name()));
    end;

    procedure Variationinstocks3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks3Name()));
    end;

    procedure Variationinstockstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VariationinstockstotalName()));
    end;

    procedure Manafacturedforownuse1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Manafacturedforownuse1Name()));
    end;

    procedure Manafacturedforownuse2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Manafacturedforownuse2Name()));
    end;

    procedure Manafacturedforownuse3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Manafacturedforownuse3Name()));
    end;

    procedure Manafacturedforownusetotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManafacturedforownusetotalName()));
    end;

    procedure Otheroperatingincome1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otheroperatingincome1Name()));
    end;

    procedure Otheroperatingincome2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otheroperatingincome2Name()));
    end;

    procedure Otheroperatingincome3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otheroperatingincome3Name()));
    end;

    procedure Rents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentsName()));
    end;

    procedure Insurances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesName()));
    end;

    procedure Groupservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GroupservicesName()));
    end;

    procedure Othergroupservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthergroupservicesName()));
    end;

    procedure Operatingincometotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingincometotalName()));
    end;

    procedure Rawmaterialsandservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawmaterialsandservicesName()));
    end;

    procedure Rawmaterialsandconsumables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawmaterialsandconsumablesName()));
    end;

    procedure Purchasesofrawmaterialsdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofrawmaterialsdomName()));
    end;

    procedure Purchasesofgoodsdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofgoodsdomName()));
    end;

    procedure Purchasesofservicesdom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofservicesdomName()));
    end;

    procedure Purchasesofrawmaterialsfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofrawmaterialsforName()));
    end;

    procedure Purchasesofgoodsfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofgoodsforName()));
    end;

    procedure Purchasesofservicesfor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofservicesforName()));
    end;

    procedure PurchasesofrawmaterialsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofrawmaterialsEUName()));
    end;

    procedure PurchasesofgoodsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofgoodsEUName()));
    end;

    procedure PurchasesofservicesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesofservicesEUName()));
    end;

    procedure Purchases1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases1Name()));
    end;

    procedure Purchases2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases2Name()));
    end;

    procedure Purchases3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases3Name()));
    end;

    procedure Purchases4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases4Name()));
    end;

    procedure Purchases5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases5Name()));
    end;

    procedure Purchases6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases6Name()));
    end;

    procedure Purchases7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases7Name()));
    end;

    procedure Purchases8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases8Name()));
    end;

    procedure Purchases9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Purchases9Name()));
    end;

    procedure Discounts4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts4Name()));
    end;

    procedure Discounts5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts5Name()));
    end;

    procedure Discounts6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Discounts6Name()));
    end;

    procedure Invoicerounding2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Invoicerounding2Name()));
    end;

    procedure Exchangeratedifferences2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangeratedifferences2Name()));
    end;

    procedure Exchangerategains6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains6Name()));
    end;

    procedure Paymenttolerance2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Paymenttolerance2Name()));
    end;

    procedure Paymenttolerancededuc2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Paymenttolerancededuc2Name()));
    end;

    procedure VATcorrections2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATcorrections2Name()));
    end;

    procedure Shipping(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShippingName()));
    end;

    procedure Insurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceName()));
    end;

    procedure Variationinstocks9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks9Name()));
    end;

    procedure Variationinstocks10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks10Name()));
    end;

    procedure Variationinstocks11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks11Name()));
    end;

    procedure Variationinstocks4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks4Name()));
    end;

    procedure Variationinstocks5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks5Name()));
    end;

    procedure Variationinstocks6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks6Name()));
    end;

    procedure Variationinstocks7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Variationinstocks7Name()));
    end;

    procedure Rawmaterialndcoumablestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawmaterialndcoumablestotalName()));
    end;

    procedure Externalservices1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Externalservices1Name()));
    end;

    procedure Externalservices2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Externalservices2Name()));
    end;

    procedure Externalservices3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Externalservices3Name()));
    end;

    procedure Shippingservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShippingservicesName()));
    end;

    procedure Rawmaterialsandservicestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawmaterialsandservicestotalName()));
    end;

    procedure Staffexpences(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StaffexpencesName()));
    end;

    procedure Wagesandsalaries1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries1Name()));
    end;

    procedure Wagesandsalaries2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries2Name()));
    end;

    procedure Wagesandsalaries3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries3Name()));
    end;

    procedure Socialsecurityexpenses1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses1Name()));
    end;

    procedure Socialsecurityexpenses2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses2Name()));
    end;

    procedure Socialsecurityexpenses3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses3Name()));
    end;

    procedure Socialsecurityexpenses4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses4Name()));
    end;

    procedure Pensionexpenses1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Pensionexpenses1Name()));
    end;

    procedure Othersocialsecurityexpenses1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses1Name()));
    end;

    procedure Othersocialsecurityexpenses2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses2Name()));
    end;

    procedure Othersocialsecurityexpenses3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses3Name()));
    end;

    procedure Otherstaffexpenses1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses1Name()));
    end;

    procedure Otherstaffexpenses2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses2Name()));
    end;

    procedure Otherstaffexpenses3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses3Name()));
    end;

    procedure Otherstaffexpenses4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses4Name()));
    end;

    procedure Otherstaffexpenses5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses5Name()));
    end;

    procedure Otherstaffexpenses6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses6Name()));
    end;

    procedure Otherstaffexpenses7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses7Name()));
    end;

    procedure Otherstaffexpenses8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses8Name()));
    end;

    procedure Otherstaffexpenses9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses9Name()));
    end;

    procedure Otherstaffexpenses10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses10Name()));
    end;

    procedure Otherstaffexpenses11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses11Name()));
    end;

    procedure Otherstaffexpenses12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses12Name()));
    end;

    procedure Otherstaffexpenses13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses13Name()));
    end;

    procedure Wagesandsalaries4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries4Name()));
    end;

    procedure Wagesandsalaries5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries5Name()));
    end;

    procedure Wagesandsalaries6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries6Name()));
    end;

    procedure Wagesandsalaries7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries7Name()));
    end;

    procedure Wagesandsalaries8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries8Name()));
    end;

    procedure Wagesandsalaries9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries9Name()));
    end;

    procedure Wagesandsalaries10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries10Name()));
    end;

    procedure Wagesandsalaries11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries11Name()));
    end;

    procedure Wagesandsalaries12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries12Name()));
    end;

    procedure Wagesandsalaries13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries13Name()));
    end;

    procedure Wagesandsalaries14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries14Name()));
    end;

    procedure Wagesandsalaries15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries15Name()));
    end;

    procedure Wagesandsalaries16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Wagesandsalaries16Name()));
    end;

    procedure Socialsecurityexpenses5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses5Name()));
    end;

    procedure Socialsecurityexpenses6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Socialsecurityexpenses6Name()));
    end;

    procedure Pensionexpenses2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Pensionexpenses2Name()));
    end;

    procedure Pensionexpenses3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Pensionexpenses3Name()));
    end;

    procedure Othersocialsecurityexpenses4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses4Name()));
    end;

    procedure Othersocialsecurityexpenses5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses5Name()));
    end;

    procedure Othersocialsecurityexpenses6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses6Name()));
    end;

    procedure Pensionexpenses4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Pensionexpenses4Name()));
    end;

    procedure Othersocialsecurityexpenses7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Othersocialsecurityexpenses7Name()));
    end;

    procedure Otherstaffexpenses14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses14Name()));
    end;

    procedure Otherstaffexpenses15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses15Name()));
    end;

    procedure Otherstaffexpenses16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses16Name()));
    end;

    procedure Otherstaffexpenses17(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses17Name()));
    end;

    procedure Otherstaffexpenses18(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses18Name()));
    end;

    procedure Otherstaffexpenses19(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses19Name()));
    end;

    procedure Otherstaffexpenses20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses20Name()));
    end;

    procedure Staffexpencestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StaffexpencestotalName()));
    end;

    procedure Otheroperatingcharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtheroperatingchargesName()));
    end;

    procedure Rents2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents2Name()));
    end;

    procedure Rents3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents3Name()));
    end;

    procedure Rents4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents4Name()));
    end;

    procedure Rents5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents5Name()));
    end;

    procedure Rents6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents6Name()));
    end;

    procedure Rents7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Rents7Name()));
    end;

    procedure Otherstaffexpenses21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses21Name()));
    end;

    procedure Otherstaffexpenses22(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses22Name()));
    end;

    procedure Otherstaffexpenses23(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses23Name()));
    end;

    procedure Otherstaffexpenses24(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses24Name()));
    end;

    procedure Otherstaffexpenses25(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses25Name()));
    end;

    procedure Otherstaffexpenses26(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses26Name()));
    end;

    procedure Otherstaffexpenses27(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses27Name()));
    end;

    procedure Otherstaffexpenses28(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherstaffexpenses28Name()));
    end;

    procedure Salesmarketingexp1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp1Name()));
    end;

    procedure Salesmarketingexp2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp2Name()));
    end;

    procedure Salesmarketingexp3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp3Name()));
    end;

    procedure Salesmarketingexp4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp4Name()));
    end;

    procedure Salesmarketingexp5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp5Name()));
    end;

    procedure Salesmarketingexp6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp6Name()));
    end;

    procedure Salesmarketingexp7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp7Name()));
    end;

    procedure Salesmarketingexp8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp8Name()));
    end;

    procedure Salesmarketingexp9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp9Name()));
    end;

    procedure Salesmarketingexp10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp10Name()));
    end;

    procedure Salesmarketingexp11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp11Name()));
    end;

    procedure Salesmarketingexp12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp12Name()));
    end;

    procedure Salesmarketingexp13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp13Name()));
    end;

    procedure Salesmarketingexp14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Salesmarketingexp14Name()));
    end;

    procedure Fuel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FuelName()));
    end;

    procedure Maintenance1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Maintenance1Name()));
    end;

    procedure Maintenance2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Maintenance2Name()));
    end;

    procedure Maintenance3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Maintenance3Name()));
    end;

    procedure Maintenance4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Maintenance4Name()));
    end;

    procedure Furniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FurnitureName()));
    end;

    procedure Otherequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherequipmentName()));
    end;

    procedure Supplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuppliesName()));
    end;

    procedure Othermaintenanceservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthermaintenanceservicesName()));
    end;

    procedure Water(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterName()));
    end;

    procedure Gasandelectricity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasandelectricityName()));
    end;

    procedure Realestateexpences(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealestateexpencesName()));
    end;

    procedure Outsourcedservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutsourcedservicesName()));
    end;

    procedure Waste(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WasteName()));
    end;

    procedure Electricity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityName()));
    end;

    procedure Insurances2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Insurances2Name()));
    end;

    procedure Realestatetax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealestatetaxName()));
    end;

    procedure Maintenance5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Maintenance5Name()));
    end;

    procedure Vehicles1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles1Name()));
    end;

    procedure Vehicles2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles2Name()));
    end;

    procedure Vehicles3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles3Name()));
    end;

    procedure Vehicles4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles4Name()));
    end;

    procedure Vehicles5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles5Name()));
    end;

    procedure Vehicles6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles6Name()));
    end;

    procedure Vehicles7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles7Name()));
    end;

    procedure Vehicles8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles8Name()));
    end;

    procedure Vehicles9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles9Name()));
    end;

    procedure Vehicles10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Vehicles10Name()));
    end;

    procedure Otheroperatingexp1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otheroperatingexp1Name()));
    end;

    procedure Otheroperatingexp2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otheroperatingexp2Name()));
    end;

    procedure Informationcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InformationcostsName()));
    end;

    procedure Telecosts1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Telecosts1Name()));
    end;

    procedure Telecosts2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Telecosts2Name()));
    end;

    procedure Insurance2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Insurance2Name()));
    end;

    procedure Insurance3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Insurance3Name()));
    end;

    procedure Officesupplies1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Officesupplies1Name()));
    end;

    procedure Officesupplies2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Officesupplies2Name()));
    end;

    procedure Officesupplies3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Officesupplies3Name()));
    end;

    procedure Officesupplies4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Officesupplies4Name()));
    end;

    procedure Officesupplies5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Officesupplies5Name()));
    end;

    procedure Outsourcedservices2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Outsourcedservices2Name()));
    end;

    procedure Accounting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingName()));
    end;

    procedure ITservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ITservicesName()));
    end;

    procedure Auditing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditingName()));
    end;

    procedure Lawservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LawservicesName()));
    end;

    procedure Otherexpences(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherexpencesName()));
    end;

    procedure Memberships(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MembershipsName()));
    end;

    procedure Notifications(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NotificationsName()));
    end;

    procedure Bankingexpences(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingexpencesName()));
    end;

    procedure Meetings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MeetingsName()));
    end;

    procedure Otherexpences2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherexpences2Name()));
    end;

    procedure Baddept1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Baddept1Name()));
    end;

    procedure Baddept2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Baddept2Name()));
    end;

    procedure Baddept3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Baddept3Name()));
    end;

    procedure Otheroperatingexpensestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtheroperatingexpensestotalName()));
    end;

    procedure Depreciation1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation1Name()));
    end;

    procedure Depreciation2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation2Name()));
    end;

    procedure Depreciation3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation3Name()));
    end;

    procedure Depreciation4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation4Name()));
    end;

    procedure Depreciation5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation5Name()));
    end;

    procedure Depreciation6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation6Name()));
    end;

    procedure Depreciation7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Depreciation7Name()));
    end;

    procedure Reductioninvalue1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue1Name()));
    end;

    procedure Reductioninvalue2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue2Name()));
    end;

    procedure Reductioninvalue3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue3Name()));
    end;

    procedure Reductioninvalue4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue4Name()));
    end;

    procedure Reductioninvalue5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue5Name()));
    end;

    procedure Reductioninvalue6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue6Name()));
    end;

    procedure Reductioninvalue7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue7Name()));
    end;

    procedure Reductioninvalue8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue8Name()));
    end;

    procedure Reductioninvalue9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue9Name()));
    end;

    procedure Reductioninvalue10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue10Name()));
    end;

    procedure Reductioninvalue11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue11Name()));
    end;

    procedure Reductioninvalue12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue12Name()));
    end;

    procedure Reductioninvalue13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue13Name()));
    end;

    procedure Reductioninvalue14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue14Name()));
    end;

    procedure Reductioninvalue15(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue15Name()));
    end;

    procedure Reductioninvalue16(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue16Name()));
    end;

    procedure Reductioninvalue17(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue17Name()));
    end;

    procedure Reductioninvalue18(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue18Name()));
    end;

    procedure Reductioninvalue19(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Reductioninvalue19Name()));
    end;

    procedure Depreciationeductionsinvalue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationeductionsinvalueName()));
    end;

    procedure OPERATINGPROFITLOSS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OPERATINGPROFITLOSSName()));
    end;

    procedure Financialincomeandexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialincomeandexpensesName()));
    end;

    procedure Shareofprofitloss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareofprofitlossName()));
    end;

    procedure Shareofprofitlsofgdertakings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareofprofitlsofgdertakingsName()));
    end;

    procedure Shareofprofitssofassompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareofprofitssofassompaniesName()));
    end;

    procedure Incomefromgroupundertakings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomefromgroupundertakingsName()));
    end;

    procedure Incomefrompaipatinginterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomefrompaipatinginterestsName()));
    end;

    procedure Otherintereaninancialincome1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherintereaninancialincome1Name()));
    end;

    procedure Otherintereaninancialincome2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherintereaninancialincome2Name()));
    end;

    procedure Reductioninvalueofirentassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReductioninvalueofirentassetsName()));
    end;

    procedure Reductioninvalueofinvesassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReductioninvalueofinvesassetsName()));
    end;

    procedure Interestandothinancialincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestandothinancialincomeName()));
    end;

    procedure Financialincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialincomeName()));
    end;

    procedure Otherfinancialincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherfinancialincomeName()));
    end;

    procedure Exchangerategains1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains1Name()));
    end;

    procedure Exchangerategains2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains2Name()));
    end;

    procedure Exchangerategains3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains3Name()));
    end;

    procedure Otherfinancialincome2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherfinancialincome2Name()));
    end;

    procedure Exchangerategains5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Exchangerategains5Name()));
    end;

    procedure Financialincometotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialincometotalName()));
    end;

    procedure Financialexpenses1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses1Name()));
    end;

    procedure Financialexpenses2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses2Name()));
    end;

    procedure Financialexpenses3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses3Name()));
    end;

    procedure Financialexpenses4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses4Name()));
    end;

    procedure Financialexpenses5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses5Name()));
    end;

    procedure Financialexpenses6(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses6Name()));
    end;

    procedure Financialexpenses7(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses7Name()));
    end;

    procedure Financialexpenses8(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses8Name()));
    end;

    procedure Financialexpenses9(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses9Name()));
    end;

    procedure Financialexpenses10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses10Name()));
    end;

    procedure Financialexpenses11(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses11Name()));
    end;

    procedure Financialexpenses12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses12Name()));
    end;

    procedure Financialexpenses13(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses13Name()));
    end;

    procedure Financialexpenses14(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Financialexpenses14Name()));
    end;

    procedure PROFITLOSSBEFOEXDINARYITEMS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PROFITLOSSBEFOEXDINARYITEMSName()));
    end;

    procedure Extraordinaryitems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryitemsName()));
    end;

    procedure Otherextraordinaryincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherextraordinaryincomeName()));
    end;

    procedure VATadjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATadjustmentsName()));
    end;

    procedure TAXadjusments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TAXadjusmentsName()));
    end;

    procedure Otherextraordinaryexpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherextraordinaryexpenseName()));
    end;

    procedure Otherextraordinaryexpense2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Otherextraordinaryexpense2Name()));
    end;

    procedure Extraordinaryitemstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryitemstotalName()));
    end;

    procedure PROFITLOSSBEFEAPPROSANDTAXES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PROFITLOSSBEFEAPPROSANDTAXESName()));
    end;

    procedure Appropriations1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Appropriations1Name()));
    end;

    procedure Changeindepreciationreserve1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeindepreciationreserve1Name()));
    end;

    procedure Changeindepreciationreserve2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeindepreciationreserve2Name()));
    end;

    procedure Changeindepreciationreserve3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeindepreciationreserve3Name()));
    end;

    procedure Changeindepreciationreserve4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeindepreciationreserve4Name()));
    end;

    procedure Changeindepreciationreserve5(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeindepreciationreserve5Name()));
    end;

    procedure Changeinuntaxedreserves1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeinuntaxedreserves1Name()));
    end;

    procedure Changeinuntaxedreserves2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeinuntaxedreserves2Name()));
    end;

    procedure Changeinuntaxedreserves3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Changeinuntaxedreserves3Name()));
    end;

    procedure Appropriationstotal1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Appropriationstotal1Name()));
    end;

    procedure Incometaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncometaxesName()));
    end;

    procedure Taxesoncialyeandyearsbefore1(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Taxesoncialyeandyearsbefore1Name()));
    end;

    procedure Taxesoncialyeandyearsbefore2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Taxesoncialyeandyearsbefore2Name()));
    end;

    procedure Taxesoncialyeandyearsbefore3(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Taxesoncialyeandyearsbefore3Name()));
    end;

    procedure Taxesoncialyeandyearsbefore4(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Taxesoncialyeandyearsbefore4Name()));
    end;

    procedure Incometaxes2(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Incometaxes2Name()));
    end;

    procedure PROFITLOSSFORTHEFINANCIALYEAR(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PROFITLOSSFORTHEFINANCIALYEARName()));
    end;

    procedure FoundingcostsName(): Text[100]
    begin
        exit(FoundingcostsTok);
    end;

    procedure DecreasesduringtheYear1Name(): Text[100]
    begin
        exit(DecreasesduringtheYear1Tok);
    end;

    procedure ResearchName(): Text[100]
    begin
        exit(ResearchTok);
    end;

    procedure DecreasesduringtheYear2Name(): Text[100]
    begin
        exit(DecreasesduringtheYear2Tok);
    end;

    procedure DevelopmentName(): Text[100]
    begin
        exit(DevelopmentTok);
    end;

    procedure DecreasesduringtheYear3Name(): Text[100]
    begin
        exit(DecreasesduringtheYear3Tok);
    end;

    procedure IntangiblerightsName(): Text[100]
    begin
        exit(IntangiblerightsTok);
    end;

    procedure DecreasesduringtheYear4Name(): Text[100]
    begin
        exit(DecreasesduringtheYear4Tok);
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillTok);
    end;

    procedure DecreasesduringtheYear5Name(): Text[100]
    begin
        exit(DecreasesduringtheYear5Tok);
    end;

    procedure Goodwill2Name(): Text[100]
    begin
        exit(Goodwill2Tok);
    end;

    procedure OthercapitalisedexpenditureName(): Text[100]
    begin
        exit(OthercapitalisedexpenditureTok);
    end;

    procedure DecreasesduringtheYear6Name(): Text[100]
    begin
        exit(DecreasesduringtheYear6Tok);
    end;

    procedure AdvancepaymentsName(): Text[100]
    begin
        exit(AdvancepaymentsTok);
    end;

    procedure IntangibleassetstotalName(): Text[100]
    begin
        exit(IntangibleassetstotalTok);
    end;

    procedure TangibleassetsName(): Text[100]
    begin
        exit(TangibleassetsTok);
    end;

    procedure Othertangibleassets1Name(): Text[100]
    begin
        exit(Othertangibleassets1Tok);
    end;

    procedure MachineryandequipmentName(): Text[100]
    begin
        exit(MachineryandequipmentTok);
    end;

    procedure DecreasesduringtheYear7Name(): Text[100]
    begin
        exit(DecreasesduringtheYear7Tok);
    end;

    procedure Othertangibleassets17Name(): Text[100]
    begin
        exit(Othertangibleassets17Tok);
    end;

    procedure DecreasesduringtheYear8Name(): Text[100]
    begin
        exit(DecreasesduringtheYear8Tok);
    end;

    procedure Othertangibleassets18Name(): Text[100]
    begin
        exit(Othertangibleassets18Tok);
    end;

    procedure DecreasesduringtheYear9Name(): Text[100]
    begin
        exit(DecreasesduringtheYear9Tok);
    end;

    procedure Othertangibleassets19Name(): Text[100]
    begin
        exit(Othertangibleassets19Tok);
    end;

    procedure DecreasesduringtheYear10Name(): Text[100]
    begin
        exit(DecreasesduringtheYear10Tok);
    end;

    procedure Machineryandequipment2Name(): Text[100]
    begin
        exit(Machineryandequipment2Tok);
    end;

    procedure DecreasesduringtheYear11Name(): Text[100]
    begin
        exit(DecreasesduringtheYear11Tok);
    end;

    procedure Othertangibleassets20Name(): Text[100]
    begin
        exit(Othertangibleassets20Tok);
    end;

    procedure DecreasesduringtheYear12Name(): Text[100]
    begin
        exit(DecreasesduringtheYear12Tok);
    end;

    procedure Othertangibleassets2Name(): Text[100]
    begin
        exit(Othertangibleassets2Tok);
    end;

    procedure Othertangibleassets3Name(): Text[100]
    begin
        exit(Othertangibleassets3Tok);
    end;

    procedure Othertangibleassets4Name(): Text[100]
    begin
        exit(Othertangibleassets4Tok);
    end;

    procedure Othertangibleassets5Name(): Text[100]
    begin
        exit(Othertangibleassets5Tok);
    end;

    procedure Othertangibleassets6Name(): Text[100]
    begin
        exit(Othertangibleassets6Tok);
    end;

    procedure Othertangibleassets7Name(): Text[100]
    begin
        exit(Othertangibleassets7Tok);
    end;

    procedure Othertangibleassets8Name(): Text[100]
    begin
        exit(Othertangibleassets8Tok);
    end;

    procedure Othertangibleassets9Name(): Text[100]
    begin
        exit(Othertangibleassets9Tok);
    end;

    procedure Othertangibleassets10Name(): Text[100]
    begin
        exit(Othertangibleassets10Tok);
    end;

    procedure Othertangibleassets11Name(): Text[100]
    begin
        exit(Othertangibleassets11Tok);
    end;

    procedure DecreasesduringtheYear13Name(): Text[100]
    begin
        exit(DecreasesduringtheYear13Tok);
    end;

    procedure Othertangibleassets12Name(): Text[100]
    begin
        exit(Othertangibleassets12Tok);
    end;

    procedure Othertangibleassets13Name(): Text[100]
    begin
        exit(Othertangibleassets13Tok);
    end;

    procedure Othertangibleassets14Name(): Text[100]
    begin
        exit(Othertangibleassets14Tok);
    end;

    procedure Othertangibleassets15Name(): Text[100]
    begin
        exit(Othertangibleassets15Tok);
    end;

    procedure Othertangibleassets16Name(): Text[100]
    begin
        exit(Othertangibleassets16Tok);
    end;

    procedure DecreasesduringtheYear14Name(): Text[100]
    begin
        exit(DecreasesduringtheYear14Tok);
    end;

    procedure TangibleassetstotalName(): Text[100]
    begin
        exit(TangibleassetstotalTok);
    end;

    procedure InvestmentsName(): Text[100]
    begin
        exit(InvestmentsTok);
    end;

    procedure SharesandholdingsName(): Text[100]
    begin
        exit(SharesandholdingsTok);
    end;

    procedure SharesinGroupcompaniesName(): Text[100]
    begin
        exit(SharesinGroupcompaniesTok);
    end;

    procedure SharesinassociatedcompaniesName(): Text[100]
    begin
        exit(SharesinassociatedcompaniesTok);
    end;

    procedure OthersharesandholdingsName(): Text[100]
    begin
        exit(OthersharesandholdingsTok);
    end;

    procedure Othersharesandholdings2Name(): Text[100]
    begin
        exit(Othersharesandholdings2Tok);
    end;

    procedure Ownshares1Name(): Text[100]
    begin
        exit(Ownshares1Tok);
    end;

    procedure Ownshares2Name(): Text[100]
    begin
        exit(Ownshares2Tok);
    end;

    procedure OtherinvestmentsName(): Text[100]
    begin
        exit(OtherinvestmentsTok);
    end;

    procedure InvestmentstotalName(): Text[100]
    begin
        exit(InvestmentstotalTok);
    end;

    procedure FixedAssetstotalName(): Text[100]
    begin
        exit(FixedAssetstotalTok);
    end;

    procedure Itemsandsupplies1Name(): Text[100]
    begin
        exit(Itemsandsupplies1Tok);
    end;

    procedure Itemsandsupplies2Name(): Text[100]
    begin
        exit(Itemsandsupplies2Tok);
    end;

    procedure Itemsandsupplies3Name(): Text[100]
    begin
        exit(Itemsandsupplies3Tok);
    end;

    procedure Itemsandsupplies4Name(): Text[100]
    begin
        exit(Itemsandsupplies4Tok);
    end;

    procedure Itemsandsupplies5Name(): Text[100]
    begin
        exit(Itemsandsupplies5Tok);
    end;

    procedure Itemsandsupplies6Name(): Text[100]
    begin
        exit(Itemsandsupplies6Tok);
    end;

    procedure FinishedGoods1Name(): Text[100]
    begin
        exit(FinishedGoods1Tok);
    end;

    procedure FinishedGoods2Name(): Text[100]
    begin
        exit(FinishedGoods2Tok);
    end;

    procedure WIPAccountName(): Text[100]
    begin
        exit(WIPAccountTok);
    end;

    procedure WIPAccount2Name(): Text[100]
    begin
        exit(WIPAccount2Tok);
    end;

    procedure WIPAccruedCostName(): Text[100]
    begin
        exit(WIPAccruedCostTok);
    end;

    procedure WIPAccruedSalesName(): Text[100]
    begin
        exit(WIPAccruedSalesTok);
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesTok);
    end;

    procedure OtherinventoriesName(): Text[100]
    begin
        exit(OtherinventoriesTok);
    end;

    procedure Advancepayments2Name(): Text[100]
    begin
        exit(Advancepayments2Tok);
    end;

    procedure InventorytotalName(): Text[100]
    begin
        exit(InventorytotalTok);
    end;

    procedure AccountsReceivable10Name(): Text[100]
    begin
        exit(AccountsReceivable10Tok);
    end;

    procedure Salesreceivables1Name(): Text[100]
    begin
        exit(Salesreceivables1Tok);
    end;

    procedure Salesreceivables2Name(): Text[100]
    begin
        exit(Salesreceivables2Tok);
    end;

    procedure ReceivablesofGroupcompaniesName(): Text[100]
    begin
        exit(ReceivablesofGroupcompaniesTok);
    end;

    procedure ReceivablessociatedcompaniesName(): Text[100]
    begin
        exit(ReceivablessociatedcompaniesTok);
    end;

    procedure LoanesName(): Text[100]
    begin
        exit(LoanesTok);
    end;

    procedure Otherreceivables1Name(): Text[100]
    begin
        exit(Otherreceivables1Tok);
    end;

    procedure Salesreceivables3Name(): Text[100]
    begin
        exit(Salesreceivables3Tok);
    end;

    procedure ReceivablesofGroupcompanies2Name(): Text[100]
    begin
        exit(ReceivablesofGroupcompanies2Tok);
    end;

    procedure Receivablesociatedcompanies2Name(): Text[100]
    begin
        exit(Receivablesociatedcompanies2Tok);
    end;

    procedure Loanes2Name(): Text[100]
    begin
        exit(Loanes2Tok);
    end;

    procedure Otherreceivables2Name(): Text[100]
    begin
        exit(Otherreceivables2Tok);
    end;

    procedure SharesnotpaidName(): Text[100]
    begin
        exit(SharesnotpaidTok);
    end;

    procedure Sharesnotpaid2Name(): Text[100]
    begin
        exit(Sharesnotpaid2Tok);
    end;

    procedure AccruedincomeName(): Text[100]
    begin
        exit(AccruedincomeTok);
    end;

    procedure Deferredtaxreceivables1Name(): Text[100]
    begin
        exit(Deferredtaxreceivables1Tok);
    end;

    procedure Deferredtaxreceivables2Name(): Text[100]
    begin
        exit(Deferredtaxreceivables2Tok);
    end;

    procedure Deferredtaxreceivables3Name(): Text[100]
    begin
        exit(Deferredtaxreceivables3Tok);
    end;

    procedure Deferredtaxreceivables4Name(): Text[100]
    begin
        exit(Deferredtaxreceivables4Tok);
    end;

    procedure Deferredtaxreceivables5Name(): Text[100]
    begin
        exit(Deferredtaxreceivables5Tok);
    end;

    procedure Deferredtaxreceivables6Name(): Text[100]
    begin
        exit(Deferredtaxreceivables6Tok);
    end;

    procedure Deferredtaxreceivables7Name(): Text[100]
    begin
        exit(Deferredtaxreceivables7Tok);
    end;

    procedure Deferredtaxreceivables8Name(): Text[100]
    begin
        exit(Deferredtaxreceivables8Tok);
    end;

    procedure AllocationsName(): Text[100]
    begin
        exit(AllocationsTok);
    end;

    procedure Otherreceivables3Name(): Text[100]
    begin
        exit(Otherreceivables3Tok);
    end;

    procedure ShorttermReceivablestotalName(): Text[100]
    begin
        exit(ShorttermReceivablestotalTok);
    end;

    procedure SharesandparticipationsName(): Text[100]
    begin
        exit(SharesandparticipationsTok);
    end;

    procedure SharesandpartipaupcompaniesName(): Text[100]
    begin
        exit(SharesandpartipaupcompaniesTok);
    end;

    procedure Ownshares3Name(): Text[100]
    begin
        exit(Ownshares3Tok);
    end;

    procedure SharesandpaicipoupcompaniesName(): Text[100]
    begin
        exit(SharesandpaicipoupcompaniesTok);
    end;

    procedure OthersharesandparticipationsName(): Text[100]
    begin
        exit(OthersharesandparticipationsTok);
    end;

    procedure OthersecuritiesName(): Text[100]
    begin
        exit(OthersecuritiesTok);
    end;

    procedure SecuritiestotalName(): Text[100]
    begin
        exit(SecuritiestotalTok);
    end;

    procedure BankNordeaName(): Text[100]
    begin
        exit(BankNordeaTok);
    end;

    procedure BankSampoName(): Text[100]
    begin
        exit(BankSampoTok);
    end;

    procedure Bank3Name(): Text[100]
    begin
        exit(Bank3Tok);
    end;

    procedure Bank4Name(): Text[100]
    begin
        exit(Bank4Tok);
    end;

    procedure Bank5Name(): Text[100]
    begin
        exit(Bank5Tok);
    end;

    procedure Bank6Name(): Text[100]
    begin
        exit(Bank6Tok);
    end;

    procedure Bank7Name(): Text[100]
    begin
        exit(Bank7Tok);
    end;

    procedure Liquidassets2Name(): Text[100]
    begin
        exit(Liquidassets2Tok);
    end;

    procedure CurrentAssetstotalName(): Text[100]
    begin
        exit(CurrentAssetstotalTok);
    end;

    procedure ASSETSTOTALName(): Text[100]
    begin
        exit(ASSETSTOTALTok);
    end;

    procedure EQUITYCAPITALName(): Text[100]
    begin
        exit(EQUITYCAPITALTok);
    end;

    procedure SharecapitalestrictedequityName(): Text[100]
    begin
        exit(SharecapitalestrictedequityTok);
    end;

    procedure SharepremiumaccountName(): Text[100]
    begin
        exit(SharepremiumaccountTok);
    end;

    procedure RevaluationreserveName(): Text[100]
    begin
        exit(RevaluationreserveTok);
    end;

    procedure ReserveforownsharesName(): Text[100]
    begin
        exit(ReserveforownsharesTok);
    end;

    procedure ReservefundName(): Text[100]
    begin
        exit(ReservefundTok);
    end;

    procedure OtherfundsName(): Text[100]
    begin
        exit(OtherfundsTok);
    end;

    procedure ProfitLossbroughtforwardName(): Text[100]
    begin
        exit(ProfitLossbroughtforwardTok);
    end;

    procedure ProfitLossfohefinancialyearName(): Text[100]
    begin
        exit(ProfitLossfohefinancialyearTok);
    end;

    procedure SharecapilerrestrictedequityName(): Text[100]
    begin
        exit(SharecapilerrestrictedequityTok);
    end;

    procedure EQUITYCAPITALTOTALName(): Text[100]
    begin
        exit(EQUITYCAPITALTOTALTok);
    end;

    procedure APPROPRIATIONSName(): Text[100]
    begin
        exit(APPROPRIATIONSTok);
    end;

    procedure Depreciationdifference1Name(): Text[100]
    begin
        exit(Depreciationdifference1Tok);
    end;

    procedure Depreciationdifference2Name(): Text[100]
    begin
        exit(Depreciationdifference2Tok);
    end;

    procedure Depreciationdifference3Name(): Text[100]
    begin
        exit(Depreciationdifference3Tok);
    end;

    procedure Voluntaryprovisions1Name(): Text[100]
    begin
        exit(Voluntaryprovisions1Tok);
    end;

    procedure Voluntaryprovisions2Name(): Text[100]
    begin
        exit(Voluntaryprovisions2Tok);
    end;

    procedure Voluntaryprovisions3Name(): Text[100]
    begin
        exit(Voluntaryprovisions3Tok);
    end;

    procedure APPROPRIATIONSTOTALName(): Text[100]
    begin
        exit(APPROPRIATIONSTOTALTok);
    end;

    procedure COMPULSORYPROVISIONSName(): Text[100]
    begin
        exit(COMPULSORYPROVISIONSTok);
    end;

    procedure ProvisionsforpensionsName(): Text[100]
    begin
        exit(ProvisionsforpensionsTok);
    end;

    procedure ProvisionsfortaxationName(): Text[100]
    begin
        exit(ProvisionsfortaxationTok);
    end;

    procedure Otherprovisions1Name(): Text[100]
    begin
        exit(Otherprovisions1Tok);
    end;

    procedure Otherprovisions2Name(): Text[100]
    begin
        exit(Otherprovisions2Tok);
    end;

    procedure COMPULSORYPROVISIONSTOTALName(): Text[100]
    begin
        exit(COMPULSORYPROVISIONSTOTALTok);
    end;

    procedure CREDITORSName(): Text[100]
    begin
        exit(CREDITORSTok);
    end;

    procedure DepenturesName(): Text[100]
    begin
        exit(DepenturesTok);
    end;

    procedure ConvertibledepenturesName(): Text[100]
    begin
        exit(ConvertibledepenturesTok);
    end;

    procedure Loansfromcreditinstitutions1Name(): Text[100]
    begin
        exit(Loansfromcreditinstitutions1Tok);
    end;

    procedure Loansfromcreditinstitutions2Name(): Text[100]
    begin
        exit(Loansfromcreditinstitutions2Tok);
    end;

    procedure Loansfromcreditinstitutions3Name(): Text[100]
    begin
        exit(Loansfromcreditinstitutions3Tok);
    end;

    procedure Othercreditors1Name(): Text[100]
    begin
        exit(Othercreditors1Tok);
    end;

    procedure PensionloansName(): Text[100]
    begin
        exit(PensionloansTok);
    end;

    procedure AdvancesreceivedName(): Text[100]
    begin
        exit(AdvancesreceivedTok);
    end;

    procedure Tradecreditors1Name(): Text[100]
    begin
        exit(Tradecreditors1Tok);
    end;

    procedure Amountsowedundertakings1Name(): Text[100]
    begin
        exit(Amountsowedundertakings1Tok);
    end;

    procedure Amountsowtoparticdertakings1Name(): Text[100]
    begin
        exit(Amountsowtoparticdertakings1Tok);
    end;

    procedure Billsofexchangepayable1Name(): Text[100]
    begin
        exit(Billsofexchangepayable1Tok);
    end;

    procedure AccrualsanddeferredincomeName(): Text[100]
    begin
        exit(AccrualsanddeferredincomeTok);
    end;

    procedure Othercreditors2Name(): Text[100]
    begin
        exit(Othercreditors2Tok);
    end;

    procedure Othercreditors3Name(): Text[100]
    begin
        exit(Othercreditors3Tok);
    end;

    procedure Amountsowedtodertakings2Name(): Text[100]
    begin
        exit(Amountsowedtodertakings2Tok);
    end;

    procedure Amountsowedtoparticikings2Name(): Text[100]
    begin
        exit(Amountsowedtoparticikings2Tok);
    end;

    procedure Othercreditors4Name(): Text[100]
    begin
        exit(Othercreditors4Tok);
    end;

    procedure Loansfromcreditinstitutions4Name(): Text[100]
    begin
        exit(Loansfromcreditinstitutions4Tok);
    end;

    procedure Loansfromcreditinstitutions5Name(): Text[100]
    begin
        exit(Loansfromcreditinstitutions5Tok);
    end;

    procedure Pensionloans2Name(): Text[100]
    begin
        exit(Pensionloans2Tok);
    end;

    procedure Advancesreceived2Name(): Text[100]
    begin
        exit(Advancesreceived2Tok);
    end;

    procedure Tradecreditors2Name(): Text[100]
    begin
        exit(Tradecreditors2Tok);
    end;

    procedure Tradecreditors3Name(): Text[100]
    begin
        exit(Tradecreditors3Tok);
    end;

    procedure Amountsedtogrouundertakings3Name(): Text[100]
    begin
        exit(Amountsedtogrouundertakings3Tok);
    end;

    procedure Amountsowtorestundertakings3Name(): Text[100]
    begin
        exit(Amountsowtorestundertakings3Tok);
    end;

    procedure Billsofexchangepayable2Name(): Text[100]
    begin
        exit(Billsofexchangepayable2Tok);
    end;

    procedure Accrualsanddeferredincome9Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome9Tok);
    end;

    procedure Othercreditors5Name(): Text[100]
    begin
        exit(Othercreditors5Tok);
    end;

    procedure Accrualsanddeferredincome1Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome1Tok);
    end;

    procedure Accrualsanddeferredincome2Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome2Tok);
    end;

    procedure Accrualsanddeferredincome3Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome3Tok);
    end;

    procedure Accrualsanddeferredincome4Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome4Tok);
    end;

    procedure Accrualsanddeferredincome5Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome5Tok);
    end;

    procedure Othercreditors6Name(): Text[100]
    begin
        exit(Othercreditors6Tok);
    end;

    procedure Accrualsanddeferredincome6Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome6Tok);
    end;

    procedure Accrualsanddeferredincome7Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome7Tok);
    end;

    procedure Accrualsanddeferredincome8Name(): Text[100]
    begin
        exit(Accrualsanddeferredincome8Tok);
    end;

    procedure Deferredtaxliability1Name(): Text[100]
    begin
        exit(Deferredtaxliability1Tok);
    end;

    procedure Deferredtaxliability2Name(): Text[100]
    begin
        exit(Deferredtaxliability2Tok);
    end;

    procedure Deferredtaxliability3Name(): Text[100]
    begin
        exit(Deferredtaxliability3Tok);
    end;

    procedure Deferredtaxliability4Name(): Text[100]
    begin
        exit(Deferredtaxliability4Tok);
    end;

    procedure Deferredtaxliability5Name(): Text[100]
    begin
        exit(Deferredtaxliability5Tok);
    end;

    procedure Deferredtaxliability6Name(): Text[100]
    begin
        exit(Deferredtaxliability6Tok);
    end;

    procedure Deferredtaxliability7Name(): Text[100]
    begin
        exit(Deferredtaxliability7Tok);
    end;

    procedure Deferredtaxliability8Name(): Text[100]
    begin
        exit(Deferredtaxliability8Tok);
    end;

    procedure Deferredtaxliability9Name(): Text[100]
    begin
        exit(Deferredtaxliability9Tok);
    end;

    procedure Deferredtaxliability10Name(): Text[100]
    begin
        exit(Deferredtaxliability10Tok);
    end;

    procedure Deferredtaxliability11Name(): Text[100]
    begin
        exit(Deferredtaxliability11Tok);
    end;

    procedure Deferredtaxliability12Name(): Text[100]
    begin
        exit(Deferredtaxliability12Tok);
    end;

    procedure Deferredtaxliability13Name(): Text[100]
    begin
        exit(Deferredtaxliability13Tok);
    end;

    procedure Deferredtaxliability14Name(): Text[100]
    begin
        exit(Deferredtaxliability14Tok);
    end;

    procedure Deferredtaxliability15Name(): Text[100]
    begin
        exit(Deferredtaxliability15Tok);
    end;

    procedure Deferredtaxliability16Name(): Text[100]
    begin
        exit(Deferredtaxliability16Tok);
    end;

    procedure Deferredtaxliability17Name(): Text[100]
    begin
        exit(Deferredtaxliability17Tok);
    end;

    procedure Deferredtaxliability18Name(): Text[100]
    begin
        exit(Deferredtaxliability18Tok);
    end;

    procedure Deferredtaxliability19Name(): Text[100]
    begin
        exit(Deferredtaxliability19Tok);
    end;

    procedure Deferredtaxliability20Name(): Text[100]
    begin
        exit(Deferredtaxliability20Tok);
    end;

    procedure Deferredtaxliability21Name(): Text[100]
    begin
        exit(Deferredtaxliability21Tok);
    end;

    procedure CREDITORSTOTALName(): Text[100]
    begin
        exit(CREDITORSTOTALTok);
    end;

    procedure LIABILITIESTOTALName(): Text[100]
    begin
        exit(LIABILITIESTOTALTok);
    end;

    procedure NETTURNOVERName(): Text[100]
    begin
        exit(NETTURNOVERTok);
    end;

    procedure SalesofrawmaterialsdomName(): Text[100]
    begin
        exit(SalesofrawmaterialsdomTok);
    end;

    procedure SalesofgoodsdomName(): Text[100]
    begin
        exit(SalesofgoodsdomTok);
    end;

    procedure SalesofservicesdomName(): Text[100]
    begin
        exit(SalesofservicesdomTok);
    end;

    procedure SalesofservicecontName(): Text[100]
    begin
        exit(SalesofservicecontTok);
    end;

    procedure Sales1Name(): Text[100]
    begin
        exit(Sales1Tok);
    end;

    procedure Sales2Name(): Text[100]
    begin
        exit(Sales2Tok);
    end;

    procedure Sales3Name(): Text[100]
    begin
        exit(Sales3Tok);
    end;

    procedure Sales4Name(): Text[100]
    begin
        exit(Sales4Tok);
    end;

    procedure Sales5Name(): Text[100]
    begin
        exit(Sales5Tok);
    end;

    procedure Sales6Name(): Text[100]
    begin
        exit(Sales6Tok);
    end;

    procedure SalesofrawmaterialsforName(): Text[100]
    begin
        exit(SalesofrawmaterialsforTok);
    end;

    procedure SalesofgoodsforName(): Text[100]
    begin
        exit(SalesofgoodsforTok);
    end;

    procedure SalesofservicesforName(): Text[100]
    begin
        exit(SalesofservicesforTok);
    end;

    procedure SalesofrawmaterialsEUName(): Text[100]
    begin
        exit(SalesofrawmaterialsEUTok);
    end;

    procedure SalesofgoodsEUName(): Text[100]
    begin
        exit(SalesofgoodsEUTok);
    end;

    procedure SalesofservicesEUName(): Text[100]
    begin
        exit(SalesofservicesEUTok);
    end;

    procedure Sales7Name(): Text[100]
    begin
        exit(Sales7Tok);
    end;

    procedure Sales8Name(): Text[100]
    begin
        exit(Sales8Tok);
    end;

    procedure Sales9Name(): Text[100]
    begin
        exit(Sales9Tok);
    end;

    procedure Sales10Name(): Text[100]
    begin
        exit(Sales10Tok);
    end;

    procedure Sales11Name(): Text[100]
    begin
        exit(Sales11Tok);
    end;

    procedure Sales12Name(): Text[100]
    begin
        exit(Sales12Tok);
    end;

    procedure Sales13Name(): Text[100]
    begin
        exit(Sales13Tok);
    end;

    procedure Sales14Name(): Text[100]
    begin
        exit(Sales14Tok);
    end;

    procedure Sales15Name(): Text[100]
    begin
        exit(Sales15Tok);
    end;

    procedure Sales16Name(): Text[100]
    begin
        exit(Sales16Tok);
    end;

    procedure Sales17Name(): Text[100]
    begin
        exit(Sales17Tok);
    end;

    procedure Sales18Name(): Text[100]
    begin
        exit(Sales18Tok);
    end;

    procedure Sales19Name(): Text[100]
    begin
        exit(Sales19Tok);
    end;

    procedure Discounts1Name(): Text[100]
    begin
        exit(Discounts1Tok);
    end;

    procedure Discounts2Name(): Text[100]
    begin
        exit(Discounts2Tok);
    end;

    procedure Discounts3Name(): Text[100]
    begin
        exit(Discounts3Tok);
    end;

    procedure ExchangeratedifferencesName(): Text[100]
    begin
        exit(ExchangeratedifferencesTok);
    end;

    procedure Exchangerategains7Name(): Text[100]
    begin
        exit(Exchangerategains7Tok);
    end;

    procedure ExchangeratelossesName(): Text[100]
    begin
        exit(ExchangeratelossesTok);
    end;

    procedure PaymenttoleranceName(): Text[100]
    begin
        exit(PaymenttoleranceTok);
    end;

    procedure PaymenttolerancededucName(): Text[100]
    begin
        exit(PaymenttolerancededucTok);
    end;

    procedure VATcorrectionsName(): Text[100]
    begin
        exit(VATcorrectionsTok);
    end;

    procedure ShippingExpences1Name(): Text[100]
    begin
        exit(ShippingExpences1Tok);
    end;

    procedure ShippingExpences2Name(): Text[100]
    begin
        exit(ShippingExpences2Tok);
    end;

    procedure OthersalesdeductionsName(): Text[100]
    begin
        exit(OthersalesdeductionsTok);
    end;

    procedure CreditcardprovisionsName(): Text[100]
    begin
        exit(CreditcardprovisionsTok);
    end;

    procedure NETTURNOVERTOTALName(): Text[100]
    begin
        exit(NETTURNOVERTOTALTok);
    end;

    procedure Variationinstocks1Name(): Text[100]
    begin
        exit(Variationinstocks1Tok);
    end;

    procedure Variationinstocks2Name(): Text[100]
    begin
        exit(Variationinstocks2Tok);
    end;

    procedure Variationinstocks3Name(): Text[100]
    begin
        exit(Variationinstocks3Tok);
    end;

    procedure VariationinstockstotalName(): Text[100]
    begin
        exit(VariationinstockstotalTok);
    end;

    procedure Manafacturedforownuse1Name(): Text[100]
    begin
        exit(Manafacturedforownuse1Tok);
    end;

    procedure Manafacturedforownuse2Name(): Text[100]
    begin
        exit(Manafacturedforownuse2Tok);
    end;

    procedure Manafacturedforownuse3Name(): Text[100]
    begin
        exit(Manafacturedforownuse3Tok);
    end;

    procedure ManafacturedforownusetotalName(): Text[100]
    begin
        exit(ManafacturedforownusetotalTok);
    end;

    procedure Otheroperatingincome1Name(): Text[100]
    begin
        exit(Otheroperatingincome1Tok);
    end;

    procedure Otheroperatingincome2Name(): Text[100]
    begin
        exit(Otheroperatingincome2Tok);
    end;

    procedure Otheroperatingincome3Name(): Text[100]
    begin
        exit(Otheroperatingincome3Tok);
    end;

    procedure RentsName(): Text[100]
    begin
        exit(RentsTok);
    end;

    procedure InsurancesName(): Text[100]
    begin
        exit(InsurancesTok);
    end;

    procedure GroupservicesName(): Text[100]
    begin
        exit(GroupservicesTok);
    end;

    procedure OthergroupservicesName(): Text[100]
    begin
        exit(OthergroupservicesTok);
    end;

    procedure OperatingincometotalName(): Text[100]
    begin
        exit(OperatingincometotalTok);
    end;

    procedure RawmaterialsandservicesName(): Text[100]
    begin
        exit(RawmaterialsandservicesTok);
    end;

    procedure RawmaterialsandconsumablesName(): Text[100]
    begin
        exit(RawmaterialsandconsumablesTok);
    end;

    procedure PurchasesofrawmaterialsdomName(): Text[100]
    begin
        exit(PurchasesofrawmaterialsdomTok);
    end;

    procedure PurchasesofgoodsdomName(): Text[100]
    begin
        exit(PurchasesofgoodsdomTok);
    end;

    procedure PurchasesofservicesdomName(): Text[100]
    begin
        exit(PurchasesofservicesdomTok);
    end;

    procedure PurchasesofrawmaterialsforName(): Text[100]
    begin
        exit(PurchasesofrawmaterialsforTok);
    end;

    procedure PurchasesofgoodsforName(): Text[100]
    begin
        exit(PurchasesofgoodsforTok);
    end;

    procedure PurchasesofservicesforName(): Text[100]
    begin
        exit(PurchasesofservicesforTok);
    end;

    procedure PurchasesofrawmaterialsEUName(): Text[100]
    begin
        exit(PurchasesofrawmaterialsEUTok);
    end;

    procedure PurchasesofgoodsEUName(): Text[100]
    begin
        exit(PurchasesofgoodsEUTok);
    end;

    procedure PurchasesofservicesEUName(): Text[100]
    begin
        exit(PurchasesofservicesEUTok);
    end;

    procedure Purchases1Name(): Text[100]
    begin
        exit(Purchases1Tok);
    end;

    procedure Purchases2Name(): Text[100]
    begin
        exit(Purchases2Tok);
    end;

    procedure Purchases3Name(): Text[100]
    begin
        exit(Purchases3Tok);
    end;

    procedure Purchases4Name(): Text[100]
    begin
        exit(Purchases4Tok);
    end;

    procedure Purchases5Name(): Text[100]
    begin
        exit(Purchases5Tok);
    end;

    procedure Purchases6Name(): Text[100]
    begin
        exit(Purchases6Tok);
    end;

    procedure Purchases7Name(): Text[100]
    begin
        exit(Purchases7Tok);
    end;

    procedure Purchases8Name(): Text[100]
    begin
        exit(Purchases8Tok);
    end;

    procedure Purchases9Name(): Text[100]
    begin
        exit(Purchases9Tok);
    end;

    procedure Discounts4Name(): Text[100]
    begin
        exit(Discounts4Tok);
    end;

    procedure Discounts5Name(): Text[100]
    begin
        exit(Discounts5Tok);
    end;

    procedure Discounts6Name(): Text[100]
    begin
        exit(Discounts6Tok);
    end;

    procedure Invoicerounding2Name(): Text[100]
    begin
        exit(Invoicerounding2Tok);
    end;

    procedure Exchangeratedifferences2Name(): Text[100]
    begin
        exit(Exchangeratedifferences2Tok);
    end;

    procedure Exchangerategains6Name(): Text[100]
    begin
        exit(Exchangerategains6Tok);
    end;

    procedure Paymenttolerance2Name(): Text[100]
    begin
        exit(Paymenttolerance2Tok);
    end;

    procedure Paymenttolerancededuc2Name(): Text[100]
    begin
        exit(Paymenttolerancededuc2Tok);
    end;

    procedure VATcorrections2Name(): Text[100]
    begin
        exit(VATcorrections2Tok);
    end;

    procedure ShippingName(): Text[100]
    begin
        exit(ShippingTok);
    end;

    procedure InsuranceName(): Text[100]
    begin
        exit(InsuranceTok);
    end;

    procedure Variationinstocks9Name(): Text[100]
    begin
        exit(Variationinstocks9Tok);
    end;

    procedure Variationinstocks10Name(): Text[100]
    begin
        exit(Variationinstocks10Tok);
    end;

    procedure Variationinstocks11Name(): Text[100]
    begin
        exit(Variationinstocks11Tok);
    end;

    procedure Variationinstocks4Name(): Text[100]
    begin
        exit(Variationinstocks4Tok);
    end;

    procedure Variationinstocks5Name(): Text[100]
    begin
        exit(Variationinstocks5Tok);
    end;

    procedure Variationinstocks6Name(): Text[100]
    begin
        exit(Variationinstocks6Tok);
    end;

    procedure Variationinstocks7Name(): Text[100]
    begin
        exit(Variationinstocks7Tok);
    end;

    procedure RawmaterialndcoumablestotalName(): Text[100]
    begin
        exit(RawmaterialndcoumablestotalTok);
    end;

    procedure Externalservices1Name(): Text[100]
    begin
        exit(Externalservices1Tok);
    end;

    procedure Externalservices2Name(): Text[100]
    begin
        exit(Externalservices2Tok);
    end;

    procedure Externalservices3Name(): Text[100]
    begin
        exit(Externalservices3Tok);
    end;

    procedure ShippingservicesName(): Text[100]
    begin
        exit(ShippingservicesTok);
    end;

    procedure RawmaterialsandservicestotalName(): Text[100]
    begin
        exit(RawmaterialsandservicestotalTok);
    end;

    procedure StaffexpencesName(): Text[100]
    begin
        exit(StaffexpencesTok);
    end;

    procedure Wagesandsalaries1Name(): Text[100]
    begin
        exit(Wagesandsalaries1Tok);
    end;

    procedure Wagesandsalaries2Name(): Text[100]
    begin
        exit(Wagesandsalaries2Tok);
    end;

    procedure Wagesandsalaries3Name(): Text[100]
    begin
        exit(Wagesandsalaries3Tok);
    end;

    procedure Socialsecurityexpenses1Name(): Text[100]
    begin
        exit(Socialsecurityexpenses1Tok);
    end;

    procedure Socialsecurityexpenses2Name(): Text[100]
    begin
        exit(Socialsecurityexpenses2Tok);
    end;

    procedure Socialsecurityexpenses3Name(): Text[100]
    begin
        exit(Socialsecurityexpenses3Tok);
    end;

    procedure Socialsecurityexpenses4Name(): Text[100]
    begin
        exit(Socialsecurityexpenses4Tok);
    end;

    procedure Pensionexpenses1Name(): Text[100]
    begin
        exit(Pensionexpenses1Tok);
    end;

    procedure Othersocialsecurityexpenses1Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses1Tok);
    end;

    procedure Othersocialsecurityexpenses2Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses2Tok);
    end;

    procedure Othersocialsecurityexpenses3Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses3Tok);
    end;

    procedure Otherstaffexpenses1Name(): Text[100]
    begin
        exit(Otherstaffexpenses1Tok);
    end;

    procedure Otherstaffexpenses2Name(): Text[100]
    begin
        exit(Otherstaffexpenses2Tok);
    end;

    procedure Otherstaffexpenses3Name(): Text[100]
    begin
        exit(Otherstaffexpenses3Tok);
    end;

    procedure Otherstaffexpenses4Name(): Text[100]
    begin
        exit(Otherstaffexpenses4Tok);
    end;

    procedure Otherstaffexpenses5Name(): Text[100]
    begin
        exit(Otherstaffexpenses5Tok);
    end;

    procedure Otherstaffexpenses6Name(): Text[100]
    begin
        exit(Otherstaffexpenses6Tok);
    end;

    procedure Otherstaffexpenses7Name(): Text[100]
    begin
        exit(Otherstaffexpenses7Tok);
    end;

    procedure Otherstaffexpenses8Name(): Text[100]
    begin
        exit(Otherstaffexpenses8Tok);
    end;

    procedure Otherstaffexpenses9Name(): Text[100]
    begin
        exit(Otherstaffexpenses9Tok);
    end;

    procedure Otherstaffexpenses10Name(): Text[100]
    begin
        exit(Otherstaffexpenses10Tok);
    end;

    procedure Otherstaffexpenses11Name(): Text[100]
    begin
        exit(Otherstaffexpenses11Tok);
    end;

    procedure Otherstaffexpenses12Name(): Text[100]
    begin
        exit(Otherstaffexpenses12Tok);
    end;

    procedure Otherstaffexpenses13Name(): Text[100]
    begin
        exit(Otherstaffexpenses13Tok);
    end;

    procedure Wagesandsalaries4Name(): Text[100]
    begin
        exit(Wagesandsalaries4Tok);
    end;

    procedure Wagesandsalaries5Name(): Text[100]
    begin
        exit(Wagesandsalaries5Tok);
    end;

    procedure Wagesandsalaries6Name(): Text[100]
    begin
        exit(Wagesandsalaries6Tok);
    end;

    procedure Wagesandsalaries7Name(): Text[100]
    begin
        exit(Wagesandsalaries7Tok);
    end;

    procedure Wagesandsalaries8Name(): Text[100]
    begin
        exit(Wagesandsalaries8Tok);
    end;

    procedure Wagesandsalaries9Name(): Text[100]
    begin
        exit(Wagesandsalaries9Tok);
    end;

    procedure Wagesandsalaries10Name(): Text[100]
    begin
        exit(Wagesandsalaries10Tok);
    end;

    procedure Wagesandsalaries11Name(): Text[100]
    begin
        exit(Wagesandsalaries11Tok);
    end;

    procedure Wagesandsalaries12Name(): Text[100]
    begin
        exit(Wagesandsalaries12Tok);
    end;

    procedure Wagesandsalaries13Name(): Text[100]
    begin
        exit(Wagesandsalaries13Tok);
    end;

    procedure Wagesandsalaries14Name(): Text[100]
    begin
        exit(Wagesandsalaries14Tok);
    end;

    procedure Wagesandsalaries15Name(): Text[100]
    begin
        exit(Wagesandsalaries15Tok);
    end;

    procedure Wagesandsalaries16Name(): Text[100]
    begin
        exit(Wagesandsalaries16Tok);
    end;

    procedure Socialsecurityexpenses5Name(): Text[100]
    begin
        exit(Socialsecurityexpenses5Tok);
    end;

    procedure Socialsecurityexpenses6Name(): Text[100]
    begin
        exit(Socialsecurityexpenses6Tok);
    end;

    procedure Pensionexpenses2Name(): Text[100]
    begin
        exit(Pensionexpenses2Tok);
    end;

    procedure Pensionexpenses3Name(): Text[100]
    begin
        exit(Pensionexpenses3Tok);
    end;

    procedure Othersocialsecurityexpenses4Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses4Tok);
    end;

    procedure Othersocialsecurityexpenses5Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses5Tok);
    end;

    procedure Othersocialsecurityexpenses6Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses6Tok);
    end;

    procedure Pensionexpenses4Name(): Text[100]
    begin
        exit(Pensionexpenses4Tok);
    end;

    procedure Othersocialsecurityexpenses7Name(): Text[100]
    begin
        exit(Othersocialsecurityexpenses7Tok);
    end;

    procedure Otherstaffexpenses14Name(): Text[100]
    begin
        exit(Otherstaffexpenses14Tok);
    end;

    procedure Otherstaffexpenses15Name(): Text[100]
    begin
        exit(Otherstaffexpenses15Tok);
    end;

    procedure Otherstaffexpenses16Name(): Text[100]
    begin
        exit(Otherstaffexpenses16Tok);
    end;

    procedure Otherstaffexpenses17Name(): Text[100]
    begin
        exit(Otherstaffexpenses17Tok);
    end;

    procedure Otherstaffexpenses18Name(): Text[100]
    begin
        exit(Otherstaffexpenses18Tok);
    end;

    procedure Otherstaffexpenses19Name(): Text[100]
    begin
        exit(Otherstaffexpenses19Tok);
    end;

    procedure Otherstaffexpenses20Name(): Text[100]
    begin
        exit(Otherstaffexpenses20Tok);
    end;

    procedure StaffexpencestotalName(): Text[100]
    begin
        exit(StaffexpencestotalTok);
    end;

    procedure OtheroperatingchargesName(): Text[100]
    begin
        exit(OtheroperatingchargesTok);
    end;

    procedure Rents2Name(): Text[100]
    begin
        exit(Rents2Tok);
    end;

    procedure Rents3Name(): Text[100]
    begin
        exit(Rents3Tok);
    end;

    procedure Rents4Name(): Text[100]
    begin
        exit(Rents4Tok);
    end;

    procedure Rents5Name(): Text[100]
    begin
        exit(Rents5Tok);
    end;

    procedure Rents6Name(): Text[100]
    begin
        exit(Rents6Tok);
    end;

    procedure Rents7Name(): Text[100]
    begin
        exit(Rents7Tok);
    end;

    procedure Otherstaffexpenses21Name(): Text[100]
    begin
        exit(Otherstaffexpenses21Tok);
    end;

    procedure Otherstaffexpenses22Name(): Text[100]
    begin
        exit(Otherstaffexpenses22Tok);
    end;

    procedure Otherstaffexpenses23Name(): Text[100]
    begin
        exit(Otherstaffexpenses23Tok);
    end;

    procedure Otherstaffexpenses24Name(): Text[100]
    begin
        exit(Otherstaffexpenses24Tok);
    end;

    procedure Otherstaffexpenses25Name(): Text[100]
    begin
        exit(Otherstaffexpenses25Tok);
    end;

    procedure Otherstaffexpenses26Name(): Text[100]
    begin
        exit(Otherstaffexpenses26Tok);
    end;

    procedure Otherstaffexpenses27Name(): Text[100]
    begin
        exit(Otherstaffexpenses27Tok);
    end;

    procedure Otherstaffexpenses28Name(): Text[100]
    begin
        exit(Otherstaffexpenses28Tok);
    end;

    procedure Salesmarketingexp1Name(): Text[100]
    begin
        exit(Salesmarketingexp1Tok);
    end;

    procedure Salesmarketingexp2Name(): Text[100]
    begin
        exit(Salesmarketingexp2Tok);
    end;

    procedure Salesmarketingexp3Name(): Text[100]
    begin
        exit(Salesmarketingexp3Tok);
    end;

    procedure Salesmarketingexp4Name(): Text[100]
    begin
        exit(Salesmarketingexp4Tok);
    end;

    procedure Salesmarketingexp5Name(): Text[100]
    begin
        exit(Salesmarketingexp5Tok);
    end;

    procedure Salesmarketingexp6Name(): Text[100]
    begin
        exit(Salesmarketingexp6Tok);
    end;

    procedure Salesmarketingexp7Name(): Text[100]
    begin
        exit(Salesmarketingexp7Tok);
    end;

    procedure Salesmarketingexp8Name(): Text[100]
    begin
        exit(Salesmarketingexp8Tok);
    end;

    procedure Salesmarketingexp9Name(): Text[100]
    begin
        exit(Salesmarketingexp9Tok);
    end;

    procedure Salesmarketingexp10Name(): Text[100]
    begin
        exit(Salesmarketingexp10Tok);
    end;

    procedure Salesmarketingexp11Name(): Text[100]
    begin
        exit(Salesmarketingexp11Tok);
    end;

    procedure Salesmarketingexp12Name(): Text[100]
    begin
        exit(Salesmarketingexp12Tok);
    end;

    procedure Salesmarketingexp13Name(): Text[100]
    begin
        exit(Salesmarketingexp13Tok);
    end;

    procedure Salesmarketingexp14Name(): Text[100]
    begin
        exit(Salesmarketingexp14Tok);
    end;

    procedure FuelName(): Text[100]
    begin
        exit(FuelTok);
    end;

    procedure Maintenance1Name(): Text[100]
    begin
        exit(Maintenance1Tok);
    end;

    procedure Maintenance2Name(): Text[100]
    begin
        exit(Maintenance2Tok);
    end;

    procedure Maintenance3Name(): Text[100]
    begin
        exit(Maintenance3Tok);
    end;

    procedure Maintenance4Name(): Text[100]
    begin
        exit(Maintenance4Tok);
    end;

    procedure FurnitureName(): Text[100]
    begin
        exit(FurnitureTok);
    end;

    procedure OtherequipmentName(): Text[100]
    begin
        exit(OtherequipmentTok);
    end;

    procedure SuppliesName(): Text[100]
    begin
        exit(SuppliesTok);
    end;

    procedure OthermaintenanceservicesName(): Text[100]
    begin
        exit(OthermaintenanceservicesTok);
    end;

    procedure WaterName(): Text[100]
    begin
        exit(WaterTok);
    end;

    procedure GasandelectricityName(): Text[100]
    begin
        exit(GasandelectricityTok);
    end;

    procedure RealestateexpencesName(): Text[100]
    begin
        exit(RealestateexpencesTok);
    end;

    procedure OutsourcedservicesName(): Text[100]
    begin
        exit(OutsourcedservicesTok);
    end;

    procedure WasteName(): Text[100]
    begin
        exit(WasteTok);
    end;

    procedure ElectricityName(): Text[100]
    begin
        exit(ElectricityTok);
    end;

    procedure Insurances2Name(): Text[100]
    begin
        exit(Insurances2Tok);
    end;

    procedure RealestatetaxName(): Text[100]
    begin
        exit(RealestatetaxTok);
    end;

    procedure Maintenance5Name(): Text[100]
    begin
        exit(Maintenance5Tok);
    end;

    procedure Vehicles1Name(): Text[100]
    begin
        exit(Vehicles1Tok);
    end;

    procedure Vehicles2Name(): Text[100]
    begin
        exit(Vehicles2Tok);
    end;

    procedure Vehicles3Name(): Text[100]
    begin
        exit(Vehicles3Tok);
    end;

    procedure Vehicles4Name(): Text[100]
    begin
        exit(Vehicles4Tok);
    end;

    procedure Vehicles5Name(): Text[100]
    begin
        exit(Vehicles5Tok);
    end;

    procedure Vehicles6Name(): Text[100]
    begin
        exit(Vehicles6Tok);
    end;

    procedure Vehicles7Name(): Text[100]
    begin
        exit(Vehicles7Tok);
    end;

    procedure Vehicles8Name(): Text[100]
    begin
        exit(Vehicles8Tok);
    end;

    procedure Vehicles9Name(): Text[100]
    begin
        exit(Vehicles9Tok);
    end;

    procedure Vehicles10Name(): Text[100]
    begin
        exit(Vehicles10Tok);
    end;

    procedure Otheroperatingexp1Name(): Text[100]
    begin
        exit(Otheroperatingexp1Tok);
    end;

    procedure Otheroperatingexp2Name(): Text[100]
    begin
        exit(Otheroperatingexp2Tok);
    end;

    procedure InformationcostsName(): Text[100]
    begin
        exit(InformationcostsTok);
    end;

    procedure Telecosts1Name(): Text[100]
    begin
        exit(Telecosts1Tok);
    end;

    procedure Telecosts2Name(): Text[100]
    begin
        exit(Telecosts2Tok);
    end;

    procedure Insurance2Name(): Text[100]
    begin
        exit(Insurance2Tok);
    end;

    procedure Insurance3Name(): Text[100]
    begin
        exit(Insurance3Tok);
    end;

    procedure Officesupplies1Name(): Text[100]
    begin
        exit(Officesupplies1Tok);
    end;

    procedure Officesupplies2Name(): Text[100]
    begin
        exit(Officesupplies2Tok);
    end;

    procedure Officesupplies3Name(): Text[100]
    begin
        exit(Officesupplies3Tok);
    end;

    procedure Officesupplies4Name(): Text[100]
    begin
        exit(Officesupplies4Tok);
    end;

    procedure Officesupplies5Name(): Text[100]
    begin
        exit(Officesupplies5Tok);
    end;

    procedure Outsourcedservices2Name(): Text[100]
    begin
        exit(Outsourcedservices2Tok);
    end;

    procedure AccountingName(): Text[100]
    begin
        exit(AccountingTok);
    end;

    procedure ITservicesName(): Text[100]
    begin
        exit(ITservicesTok);
    end;

    procedure AuditingName(): Text[100]
    begin
        exit(AuditingTok);
    end;

    procedure LawservicesName(): Text[100]
    begin
        exit(LawservicesTok);
    end;

    procedure OtherexpencesName(): Text[100]
    begin
        exit(OtherexpencesTok);
    end;

    procedure MembershipsName(): Text[100]
    begin
        exit(MembershipsTok);
    end;

    procedure NotificationsName(): Text[100]
    begin
        exit(NotificationsTok);
    end;

    procedure BankingexpencesName(): Text[100]
    begin
        exit(BankingexpencesTok);
    end;

    procedure MeetingsName(): Text[100]
    begin
        exit(MeetingsTok);
    end;

    procedure Otherexpences2Name(): Text[100]
    begin
        exit(Otherexpences2Tok);
    end;

    procedure Baddept1Name(): Text[100]
    begin
        exit(Baddept1Tok);
    end;

    procedure Baddept2Name(): Text[100]
    begin
        exit(Baddept2Tok);
    end;

    procedure Baddept3Name(): Text[100]
    begin
        exit(Baddept3Tok);
    end;

    procedure OtheroperatingexpensestotalName(): Text[100]
    begin
        exit(OtheroperatingexpensestotalTok);
    end;

    procedure Depreciation1Name(): Text[100]
    begin
        exit(Depreciation1Tok);
    end;

    procedure Depreciation2Name(): Text[100]
    begin
        exit(Depreciation2Tok);
    end;

    procedure Depreciation3Name(): Text[100]
    begin
        exit(Depreciation3Tok);
    end;

    procedure Depreciation4Name(): Text[100]
    begin
        exit(Depreciation4Tok);
    end;

    procedure Depreciation5Name(): Text[100]
    begin
        exit(Depreciation5Tok);
    end;

    procedure Depreciation6Name(): Text[100]
    begin
        exit(Depreciation6Tok);
    end;

    procedure Depreciation7Name(): Text[100]
    begin
        exit(Depreciation7Tok);
    end;

    procedure Reductioninvalue1Name(): Text[100]
    begin
        exit(Reductioninvalue1Tok);
    end;

    procedure Reductioninvalue2Name(): Text[100]
    begin
        exit(Reductioninvalue2Tok);
    end;

    procedure Reductioninvalue3Name(): Text[100]
    begin
        exit(Reductioninvalue3Tok);
    end;

    procedure Reductioninvalue4Name(): Text[100]
    begin
        exit(Reductioninvalue4Tok);
    end;

    procedure Reductioninvalue5Name(): Text[100]
    begin
        exit(Reductioninvalue5Tok);
    end;

    procedure Reductioninvalue6Name(): Text[100]
    begin
        exit(Reductioninvalue6Tok);
    end;

    procedure Reductioninvalue7Name(): Text[100]
    begin
        exit(Reductioninvalue7Tok);
    end;

    procedure Reductioninvalue8Name(): Text[100]
    begin
        exit(Reductioninvalue8Tok);
    end;

    procedure Reductioninvalue9Name(): Text[100]
    begin
        exit(Reductioninvalue9Tok);
    end;

    procedure Reductioninvalue10Name(): Text[100]
    begin
        exit(Reductioninvalue10Tok);
    end;

    procedure Reductioninvalue11Name(): Text[100]
    begin
        exit(Reductioninvalue11Tok);
    end;

    procedure Reductioninvalue12Name(): Text[100]
    begin
        exit(Reductioninvalue12Tok);
    end;

    procedure Reductioninvalue13Name(): Text[100]
    begin
        exit(Reductioninvalue13Tok);
    end;

    procedure Reductioninvalue14Name(): Text[100]
    begin
        exit(Reductioninvalue14Tok);
    end;

    procedure Reductioninvalue15Name(): Text[100]
    begin
        exit(Reductioninvalue15Tok);
    end;

    procedure Reductioninvalue16Name(): Text[100]
    begin
        exit(Reductioninvalue16Tok);
    end;

    procedure Reductioninvalue17Name(): Text[100]
    begin
        exit(Reductioninvalue17Tok);
    end;

    procedure Reductioninvalue18Name(): Text[100]
    begin
        exit(Reductioninvalue18Tok);
    end;

    procedure Reductioninvalue19Name(): Text[100]
    begin
        exit(Reductioninvalue19Tok);
    end;

    procedure DepreciationeductionsinvalueName(): Text[100]
    begin
        exit(DepreciationeductionsinvalueTok);
    end;

    procedure OPERATINGPROFITLOSSName(): Text[100]
    begin
        exit(OPERATINGPROFITLOSSTok);
    end;

    procedure FinancialincomeandexpensesName(): Text[100]
    begin
        exit(FinancialincomeandexpensesTok);
    end;

    procedure ShareofprofitlossName(): Text[100]
    begin
        exit(ShareofprofitlossTok);
    end;

    procedure ShareofprofitlsofgdertakingsName(): Text[100]
    begin
        exit(ShareofprofitlsofgdertakingsTok);
    end;

    procedure ShareofprofitssofassompaniesName(): Text[100]
    begin
        exit(ShareofprofitssofassompaniesTok);
    end;

    procedure IncomefromgroupundertakingsName(): Text[100]
    begin
        exit(IncomefromgroupundertakingsTok);
    end;

    procedure IncomefrompaipatinginterestsName(): Text[100]
    begin
        exit(IncomefrompaipatinginterestsTok);
    end;

    procedure Otherintereaninancialincome1Name(): Text[100]
    begin
        exit(Otherintereaninancialincome1Tok);
    end;

    procedure Otherintereaninancialincome2Name(): Text[100]
    begin
        exit(Otherintereaninancialincome2Tok);
    end;

    procedure ReductioninvalueofirentassetsName(): Text[100]
    begin
        exit(ReductioninvalueofirentassetsTok);
    end;

    procedure ReductioninvalueofinvesassetsName(): Text[100]
    begin
        exit(ReductioninvalueofinvesassetsTok);
    end;

    procedure InterestandothinancialincomeName(): Text[100]
    begin
        exit(InterestandothinancialincomeTok);
    end;

    procedure FinancialincomeName(): Text[100]
    begin
        exit(FinancialincomeTok);
    end;

    procedure OtherfinancialincomeName(): Text[100]
    begin
        exit(OtherfinancialincomeTok);
    end;

    procedure Exchangerategains1Name(): Text[100]
    begin
        exit(Exchangerategains1Tok);
    end;

    procedure Exchangerategains2Name(): Text[100]
    begin
        exit(Exchangerategains2Tok);
    end;

    procedure Exchangerategains3Name(): Text[100]
    begin
        exit(Exchangerategains3Tok);
    end;

    procedure Otherfinancialincome2Name(): Text[100]
    begin
        exit(Otherfinancialincome2Tok);
    end;

    procedure Exchangerategains5Name(): Text[100]
    begin
        exit(Exchangerategains5Tok);
    end;

    procedure FinancialincometotalName(): Text[100]
    begin
        exit(FinancialincometotalTok);
    end;

    procedure Financialexpenses1Name(): Text[100]
    begin
        exit(Financialexpenses1Tok);
    end;

    procedure Financialexpenses2Name(): Text[100]
    begin
        exit(Financialexpenses2Tok);
    end;

    procedure Financialexpenses3Name(): Text[100]
    begin
        exit(Financialexpenses3Tok);
    end;

    procedure Financialexpenses4Name(): Text[100]
    begin
        exit(Financialexpenses4Tok);
    end;

    procedure Financialexpenses5Name(): Text[100]
    begin
        exit(Financialexpenses5Tok);
    end;

    procedure Financialexpenses6Name(): Text[100]
    begin
        exit(Financialexpenses6Tok);
    end;

    procedure Financialexpenses7Name(): Text[100]
    begin
        exit(Financialexpenses7Tok);
    end;

    procedure Financialexpenses8Name(): Text[100]
    begin
        exit(Financialexpenses8Tok);
    end;

    procedure Financialexpenses9Name(): Text[100]
    begin
        exit(Financialexpenses9Tok);
    end;

    procedure Financialexpenses10Name(): Text[100]
    begin
        exit(Financialexpenses10Tok);
    end;

    procedure Financialexpenses11Name(): Text[100]
    begin
        exit(Financialexpenses11Tok);
    end;

    procedure Financialexpenses12Name(): Text[100]
    begin
        exit(Financialexpenses12Tok);
    end;

    procedure Financialexpenses13Name(): Text[100]
    begin
        exit(Financialexpenses13Tok);
    end;

    procedure Financialexpenses14Name(): Text[100]
    begin
        exit(Financialexpenses14Tok);
    end;

    procedure PROFITLOSSBEFOEXDINARYITEMSName(): Text[100]
    begin
        exit(PROFITLOSSBEFOEXDINARYITEMSTok);
    end;

    procedure ExtraordinaryitemsName(): Text[100]
    begin
        exit(ExtraordinaryitemsTok);
    end;

    procedure OtherextraordinaryincomeName(): Text[100]
    begin
        exit(OtherextraordinaryincomeTok);
    end;

    procedure VATadjustmentsName(): Text[100]
    begin
        exit(VATadjustmentsTok);
    end;

    procedure TAXadjusmentsName(): Text[100]
    begin
        exit(TAXadjusmentsTok);
    end;

    procedure OtherextraordinaryexpenseName(): Text[100]
    begin
        exit(OtherextraordinaryexpenseTok);
    end;

    procedure Otherextraordinaryexpense2Name(): Text[100]
    begin
        exit(Otherextraordinaryexpense2Tok);
    end;

    procedure ExtraordinaryitemstotalName(): Text[100]
    begin
        exit(ExtraordinaryitemstotalTok);
    end;

    procedure PROFITLOSSBEFEAPPROSANDTAXESName(): Text[100]
    begin
        exit(PROFITLOSSBEFEAPPROSANDTAXESTok);
    end;

    procedure Appropriations1Name(): Text[100]
    begin
        exit(Appropriations1Tok);
    end;

    procedure Changeindepreciationreserve1Name(): Text[100]
    begin
        exit(Changeindepreciationreserve1Tok);
    end;

    procedure Changeindepreciationreserve2Name(): Text[100]
    begin
        exit(Changeindepreciationreserve2Tok);
    end;

    procedure Changeindepreciationreserve3Name(): Text[100]
    begin
        exit(Changeindepreciationreserve3Tok);
    end;

    procedure Changeindepreciationreserve4Name(): Text[100]
    begin
        exit(Changeindepreciationreserve4Tok);
    end;

    procedure Changeindepreciationreserve5Name(): Text[100]
    begin
        exit(Changeindepreciationreserve5Tok);
    end;

    procedure Changeinuntaxedreserves1Name(): Text[100]
    begin
        exit(Changeinuntaxedreserves1Tok);
    end;

    procedure Changeinuntaxedreserves2Name(): Text[100]
    begin
        exit(Changeinuntaxedreserves2Tok);
    end;

    procedure Changeinuntaxedreserves3Name(): Text[100]
    begin
        exit(Changeinuntaxedreserves3Tok);
    end;

    procedure Appropriationstotal1Name(): Text[100]
    begin
        exit(Appropriationstotal1Tok);
    end;

    procedure IncometaxesName(): Text[100]
    begin
        exit(IncometaxesTok);
    end;

    procedure Taxesoncialyeandyearsbefore1Name(): Text[100]
    begin
        exit(Taxesoncialyeandyearsbefore1Tok);
    end;

    procedure Taxesoncialyeandyearsbefore2Name(): Text[100]
    begin
        exit(Taxesoncialyeandyearsbefore2Tok);
    end;

    procedure Taxesoncialyeandyearsbefore3Name(): Text[100]
    begin
        exit(Taxesoncialyeandyearsbefore3Tok);
    end;

    procedure Taxesoncialyeandyearsbefore4Name(): Text[100]
    begin
        exit(Taxesoncialyeandyearsbefore4Tok);
    end;

    procedure Incometaxes2Name(): Text[100]
    begin
        exit(Incometaxes2Tok);
    end;

    procedure PROFITLOSSFORTHEFINANCIALYEARName(): Text[100]
    begin
        exit(PROFITLOSSFORTHEFINANCIALYEARTok);
    end;

    procedure IntangibleassetsName(): Text[100]
    begin
        exit(IntangibleassetsTok);
    end;

    procedure Assets(): Text[80]
    begin
        exit(AsstesTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        IntangibleassetsTok: Label 'Intangibleassets', MaxLength = 100;
        FoundingcostsTok: Label 'Foundingcosts', MaxLength = 100;
        DecreasesduringtheYear1Tok: Label 'DecreasesduringtheYear1', MaxLength = 100;
        ResearchTok: Label 'Research', MaxLength = 100;
        DecreasesduringtheYear2Tok: Label 'DecreasesduringtheYear2', MaxLength = 100;
        DevelopmentTok: Label 'Development', MaxLength = 100;
        DecreasesduringtheYear3Tok: Label 'DecreasesduringtheYear3', MaxLength = 100;
        IntangiblerightsTok: Label 'Intangiblerights', MaxLength = 100;
        DecreasesduringtheYear4Tok: Label 'DecreasesduringtheYear4', MaxLength = 100;
        GoodwillTok: Label 'Goodwill', MaxLength = 100;
        DecreasesduringtheYear5Tok: Label 'DecreasesduringtheYear5', MaxLength = 100;
        Goodwill2Tok: Label 'Goodwill2', MaxLength = 100;
        OthercapitalisedexpenditureTok: Label 'Othercapitalisedexpenditure', MaxLength = 100;
        DecreasesduringtheYear6Tok: Label 'DecreasesduringtheYear6', MaxLength = 100;
        AdvancepaymentsTok: Label 'Advancepayments', MaxLength = 100;
        IntangibleassetstotalTok: Label 'Intangibleassetstotal', MaxLength = 100;
        TangibleassetsTok: Label 'Tangibleassets', MaxLength = 100;
        Othertangibleassets1Tok: Label 'Othertangibleassets1', MaxLength = 100;
        MachineryandequipmentTok: Label 'Machineryandequipment', MaxLength = 100;
        DecreasesduringtheYear7Tok: Label 'DecreasesduringtheYear7', MaxLength = 100;
        Othertangibleassets17Tok: Label 'Othertangibleassets17', MaxLength = 100;
        DecreasesduringtheYear8Tok: Label 'DecreasesduringtheYear8', MaxLength = 100;
        Othertangibleassets18Tok: Label 'Othertangibleassets18', MaxLength = 100;
        DecreasesduringtheYear9Tok: Label 'DecreasesduringtheYear9', MaxLength = 100;
        Othertangibleassets19Tok: Label 'Othertangibleassets19', MaxLength = 100;
        DecreasesduringtheYear10Tok: Label 'DecreasesduringtheYear10', MaxLength = 100;
        Machineryandequipment2Tok: Label 'Machineryandequipment2', MaxLength = 100;
        DecreasesduringtheYear11Tok: Label 'DecreasesduringtheYear11', MaxLength = 100;
        Othertangibleassets20Tok: Label 'Othertangibleassets20', MaxLength = 100;
        DecreasesduringtheYear12Tok: Label 'DecreasesduringtheYear12', MaxLength = 100;
        Othertangibleassets2Tok: Label 'Othertangibleassets2', MaxLength = 100;
        Othertangibleassets3Tok: Label 'Othertangibleassets3', MaxLength = 100;
        Othertangibleassets4Tok: Label 'Othertangibleassets4', MaxLength = 100;
        Othertangibleassets5Tok: Label 'Othertangibleassets5', MaxLength = 100;
        Othertangibleassets6Tok: Label 'Othertangibleassets6', MaxLength = 100;
        Othertangibleassets7Tok: Label 'Othertangibleassets7', MaxLength = 100;
        Othertangibleassets8Tok: Label 'Othertangibleassets8', MaxLength = 100;
        Othertangibleassets9Tok: Label 'Othertangibleassets9', MaxLength = 100;
        Othertangibleassets10Tok: Label 'Othertangibleassets10', MaxLength = 100;
        Othertangibleassets11Tok: Label 'Othertangibleassets11', MaxLength = 100;
        DecreasesduringtheYear13Tok: Label 'DecreasesduringtheYear13', MaxLength = 100;
        Othertangibleassets12Tok: Label 'Othertangibleassets12', MaxLength = 100;
        Othertangibleassets13Tok: Label 'Othertangibleassets13', MaxLength = 100;
        Othertangibleassets14Tok: Label 'Othertangibleassets14', MaxLength = 100;
        Othertangibleassets15Tok: Label 'Othertangibleassets15', MaxLength = 100;
        Othertangibleassets16Tok: Label 'Othertangibleassets16', MaxLength = 100;
        DecreasesduringtheYear14Tok: Label 'DecreasesduringtheYear14', MaxLength = 100;
        TangibleassetstotalTok: Label 'Tangibleassetstotal', MaxLength = 100;
        InvestmentsTok: Label 'Investments', MaxLength = 100;
        SharesandholdingsTok: Label 'Sharesandholdings', MaxLength = 100;
        SharesinGroupcompaniesTok: Label 'SharesinGroupcompanies', MaxLength = 100;
        SharesinassociatedcompaniesTok: Label 'Sharesinassociatedcompanies', MaxLength = 100;
        OthersharesandholdingsTok: Label 'Othersharesandholdings', MaxLength = 100;
        Othersharesandholdings2Tok: Label 'Othersharesandholdings2', MaxLength = 100;
        Ownshares1Tok: Label 'Ownshares1', MaxLength = 100;
        Ownshares2Tok: Label 'Ownshares2', MaxLength = 100;
        OtherinvestmentsTok: Label 'Otherinvestments', MaxLength = 100;
        InvestmentstotalTok: Label 'Investmentstotal', MaxLength = 100;
        FixedAssetstotalTok: Label 'FixedAssetstotal', MaxLength = 100;
        Itemsandsupplies1Tok: Label 'Itemsandsupplies1', MaxLength = 100;
        Itemsandsupplies2Tok: Label 'Itemsandsupplies2', MaxLength = 100;
        Itemsandsupplies3Tok: Label 'Itemsandsupplies3', MaxLength = 100;
        Itemsandsupplies4Tok: Label 'Itemsandsupplies4', MaxLength = 100;
        Itemsandsupplies5Tok: Label 'Itemsandsupplies5', MaxLength = 100;
        Itemsandsupplies6Tok: Label 'Itemsandsupplies6', MaxLength = 100;
        FinishedGoods1Tok: Label 'FinishedGoods1', MaxLength = 100;
        FinishedGoods2Tok: Label 'FinishedGoods2', MaxLength = 100;
        WIPAccountTok: Label 'WIPAccount', MaxLength = 100;
        WIPAccount2Tok: Label 'WIPAccount2', MaxLength = 100;
        WIPAccruedCostTok: Label 'WIP Accrued Cost ', MaxLength = 100;
        WIPAccruedSalesTok: Label 'WIP Accrued Sales', MaxLength = 100;
        WIPInvoicedSalesTok: Label 'WIP Invoiced Sales', MaxLength = 100;
        OtherinventoriesTok: Label 'Otherinventories', MaxLength = 100;
        Advancepayments2Tok: Label 'Advancepayments2', MaxLength = 100;
        InventorytotalTok: Label 'Inventorytotal', MaxLength = 100;
        AccountsReceivable10Tok: Label 'AccountsReceivable10', MaxLength = 100;
        Salesreceivables1Tok: Label 'Salesreceivables1', MaxLength = 100;
        Salesreceivables2Tok: Label 'Salesreceivables2', MaxLength = 100;
        ReceivablesofGroupcompaniesTok: Label 'ReceivablesofGroupcompanies', MaxLength = 100;
        ReceivablessociatedcompaniesTok: Label 'Receivablessociatedcompanies', MaxLength = 100;
        LoanesTok: Label 'Loanes', MaxLength = 100;
        Otherreceivables1Tok: Label 'Otherreceivables1', MaxLength = 100;
        Salesreceivables3Tok: Label 'Salesreceivables3', MaxLength = 100;
        ReceivablesofGroupcompanies2Tok: Label 'ReceivablesofGroupcompanies2', MaxLength = 100;
        Receivablesociatedcompanies2Tok: Label 'Receivablesociatedcompanies2', MaxLength = 100;
        Loanes2Tok: Label 'Loanes2', MaxLength = 100;
        Otherreceivables2Tok: Label 'Otherreceivables2', MaxLength = 100;
        SharesnotpaidTok: Label 'Sharesnotpaid', MaxLength = 100;
        Sharesnotpaid2Tok: Label 'Sharesnotpaid2', MaxLength = 100;
        AccruedincomeTok: Label 'Accruedincome', MaxLength = 100;
        Deferredtaxreceivables1Tok: Label 'Deferredtaxreceivables1', MaxLength = 100;
        Deferredtaxreceivables2Tok: Label 'Deferredtaxreceivables2', MaxLength = 100;
        Deferredtaxreceivables3Tok: Label 'Deferredtaxreceivables3', MaxLength = 100;
        Deferredtaxreceivables4Tok: Label 'Deferredtaxreceivables4', MaxLength = 100;
        Deferredtaxreceivables5Tok: Label 'Deferredtaxreceivables5', MaxLength = 100;
        Deferredtaxreceivables6Tok: Label 'Deferredtaxreceivables6', MaxLength = 100;
        Deferredtaxreceivables7Tok: Label 'Deferredtaxreceivables7', MaxLength = 100;
        Deferredtaxreceivables8Tok: Label 'Deferredtaxreceivables8', MaxLength = 100;
        AllocationsTok: Label 'Allocations', MaxLength = 100;
        Otherreceivables3Tok: Label 'Otherreceivables3', MaxLength = 100;
        ShorttermReceivablestotalTok: Label 'ShorttermReceivablestotal', MaxLength = 100;
        SharesandparticipationsTok: Label 'Sharesandparticipations', MaxLength = 100;
        SharesandpartipaupcompaniesTok: Label 'Sharesandpartipaupcompanies', MaxLength = 100;
        Ownshares3Tok: Label 'Ownshares3', MaxLength = 100;
        SharesandpaicipoupcompaniesTok: Label 'Sharesandpaicipoupcompanies', MaxLength = 100;
        OthersharesandparticipationsTok: Label 'Othersharesandparticipations', MaxLength = 100;
        OthersecuritiesTok: Label 'Othersecurities', MaxLength = 100;
        SecuritiestotalTok: Label 'Securitiestotal', MaxLength = 100;
        BankNordeaTok: Label 'BankNordea', MaxLength = 100;
        BankSampoTok: Label 'BankSampo', MaxLength = 100;
        Bank3Tok: Label 'Bank3', MaxLength = 100;
        Bank4Tok: Label 'Bank4', MaxLength = 100;
        Bank5Tok: Label 'Bank5', MaxLength = 100;
        Bank6Tok: Label 'Bank6', MaxLength = 100;
        Bank7Tok: Label 'Bank7', MaxLength = 100;
        Liquidassets2Tok: Label 'Liquidassets2', MaxLength = 100;
        CurrentAssetstotalTok: Label 'CurrentAssetstotal', MaxLength = 100;
        ASSETSTOTALTok: Label 'ASSETSTOTAL', MaxLength = 100;
        EQUITYCAPITALTok: Label 'EQUITYCAPITAL', MaxLength = 100;
        SharecapitalestrictedequityTok: Label 'Sharecapitalestrictedequity', MaxLength = 100;
        SharepremiumaccountTok: Label 'Sharepremiumaccount', MaxLength = 100;
        RevaluationreserveTok: Label 'Revaluationreserve', MaxLength = 100;
        ReserveforownsharesTok: Label 'Reserveforownshares', MaxLength = 100;
        ReservefundTok: Label 'Reservefund', MaxLength = 100;
        OtherfundsTok: Label 'Otherfunds', MaxLength = 100;
        ProfitLossbroughtforwardTok: Label 'ProfitLossbroughtforward', MaxLength = 100;
        ProfitLossfohefinancialyearTok: Label 'ProfitLossfohefinancialyear', MaxLength = 100;
        SharecapilerrestrictedequityTok: Label 'Sharecapilerrestrictedequity', MaxLength = 100;
        EQUITYCAPITALTOTALTok: Label 'EQUITYCAPITALTOTAL', MaxLength = 100;
        APPROPRIATIONSTok: Label 'APPROPRIATIONS', MaxLength = 100;
        Depreciationdifference1Tok: Label 'Depreciationdifference1', MaxLength = 100;
        Depreciationdifference2Tok: Label 'Depreciationdifference2', MaxLength = 100;
        Depreciationdifference3Tok: Label 'Depreciationdifference3', MaxLength = 100;
        Voluntaryprovisions1Tok: Label 'Voluntaryprovisions1', MaxLength = 100;
        Voluntaryprovisions2Tok: Label 'Voluntaryprovisions2', MaxLength = 100;
        Voluntaryprovisions3Tok: Label 'Voluntaryprovisions3', MaxLength = 100;
        APPROPRIATIONSTOTALTok: Label 'APPROPRIATIONSTOTAL', MaxLength = 100;
        COMPULSORYPROVISIONSTok: Label 'COMPULSORYPROVISIONS', MaxLength = 100;
        ProvisionsforpensionsTok: Label 'Provisionsforpensions', MaxLength = 100;
        ProvisionsfortaxationTok: Label 'Provisionsfortaxation', MaxLength = 100;
        Otherprovisions1Tok: Label 'Otherprovisions1', MaxLength = 100;
        Otherprovisions2Tok: Label 'Otherprovisions2', MaxLength = 100;
        COMPULSORYPROVISIONSTOTALTok: Label 'COMPULSORYPROVISIONSTOTAL', MaxLength = 100;
        CREDITORSTok: Label 'CREDITORS', MaxLength = 100;
        DepenturesTok: Label 'Depentures', MaxLength = 100;
        ConvertibledepenturesTok: Label 'Convertibledepentures', MaxLength = 100;
        Loansfromcreditinstitutions1Tok: Label 'Loansfromcreditinstitutions1', MaxLength = 100;
        Loansfromcreditinstitutions2Tok: Label 'Loansfromcreditinstitutions2', MaxLength = 100;
        Loansfromcreditinstitutions3Tok: Label 'Loansfromcreditinstitutions3', MaxLength = 100;
        Othercreditors1Tok: Label 'Othercreditors1', MaxLength = 100;
        PensionloansTok: Label 'Pensionloans', MaxLength = 100;
        AdvancesreceivedTok: Label 'Advancesreceived', MaxLength = 100;
        Tradecreditors1Tok: Label 'Tradecreditors1', MaxLength = 100;
        Amountsowedundertakings1Tok: Label 'Amountsowedundertakings1', MaxLength = 100;
        Amountsowtoparticdertakings1Tok: Label 'Amountsowtoparticdertakings1', MaxLength = 100;
        Billsofexchangepayable1Tok: Label 'Billsofexchangepayable1', MaxLength = 100;
        AccrualsanddeferredincomeTok: Label 'Accrualsanddeferredincome', MaxLength = 100;
        Othercreditors2Tok: Label 'Othercreditors2', MaxLength = 100;
        Othercreditors3Tok: Label 'Othercreditors3', MaxLength = 100;
        Amountsowedtodertakings2Tok: Label 'Amountsowedtodertakings2', MaxLength = 100;
        Amountsowedtoparticikings2Tok: Label 'Amountsowedtoparticikings2', MaxLength = 100;
        Othercreditors4Tok: Label 'Othercreditors4', MaxLength = 100;
        Loansfromcreditinstitutions4Tok: Label 'Loansfromcreditinstitutions4', MaxLength = 100;
        Loansfromcreditinstitutions5Tok: Label 'Loansfromcreditinstitutions5', MaxLength = 100;
        Pensionloans2Tok: Label 'Pensionloans2', MaxLength = 100;
        Advancesreceived2Tok: Label 'Advancesreceived2', MaxLength = 100;
        Tradecreditors2Tok: Label 'Tradecreditors2', MaxLength = 100;
        Tradecreditors3Tok: Label 'Tradecreditors3', MaxLength = 100;
        Amountsedtogrouundertakings3Tok: Label 'Amountsedtogrouundertakings3', MaxLength = 100;
        Amountsowtorestundertakings3Tok: Label 'Amountsowtorestundertakings3', MaxLength = 100;
        Billsofexchangepayable2Tok: Label 'Billsofexchangepayable2', MaxLength = 100;
        Accrualsanddeferredincome9Tok: Label 'Accrualsanddeferredincome9', MaxLength = 100;
        Othercreditors5Tok: Label 'Othercreditors5', MaxLength = 100;
        Accrualsanddeferredincome1Tok: Label 'Accrualsanddeferredincome1', MaxLength = 100;
        Accrualsanddeferredincome2Tok: Label 'Accrualsanddeferredincome2', MaxLength = 100;
        Accrualsanddeferredincome3Tok: Label 'Accrualsanddeferredincome3', MaxLength = 100;
        Accrualsanddeferredincome4Tok: Label 'Accrualsanddeferredincome4', MaxLength = 100;
        Accrualsanddeferredincome5Tok: Label 'Accrualsanddeferredincome5', MaxLength = 100;
        Othercreditors6Tok: Label 'Othercreditors6', MaxLength = 100;
        Accrualsanddeferredincome6Tok: Label 'Accrualsanddeferredincome6', MaxLength = 100;
        Accrualsanddeferredincome7Tok: Label 'Accrualsanddeferredincome7', MaxLength = 100;
        Accrualsanddeferredincome8Tok: Label 'Accrualsanddeferredincome8', MaxLength = 100;
        Deferredtaxliability1Tok: Label 'Deferredtaxliability1', MaxLength = 100;
        Deferredtaxliability2Tok: Label 'Deferredtaxliability2', MaxLength = 100;
        Deferredtaxliability3Tok: Label 'Deferredtaxliability3', MaxLength = 100;
        Deferredtaxliability4Tok: Label 'Deferredtaxliability4', MaxLength = 100;
        Deferredtaxliability5Tok: Label 'Deferredtaxliability5', MaxLength = 100;
        Deferredtaxliability6Tok: Label 'Deferredtaxliability6', MaxLength = 100;
        Deferredtaxliability7Tok: Label 'Deferredtaxliability7', MaxLength = 100;
        Deferredtaxliability8Tok: Label 'Deferredtaxliability8', MaxLength = 100;
        Deferredtaxliability9Tok: Label 'Deferredtaxliability9', MaxLength = 100;
        Deferredtaxliability10Tok: Label 'Deferredtaxliability10', MaxLength = 100;
        Deferredtaxliability11Tok: Label 'Deferredtaxliability11', MaxLength = 100;
        Deferredtaxliability12Tok: Label 'Deferredtaxliability12', MaxLength = 100;
        Deferredtaxliability13Tok: Label 'Deferredtaxliability13', MaxLength = 100;
        Deferredtaxliability14Tok: Label 'Deferredtaxliability14', MaxLength = 100;
        Deferredtaxliability15Tok: Label 'Deferredtaxliability15', MaxLength = 100;
        Deferredtaxliability16Tok: Label 'Deferredtaxliability16', MaxLength = 100;
        Deferredtaxliability17Tok: Label 'Deferredtaxliability17', MaxLength = 100;
        Deferredtaxliability18Tok: Label 'Deferredtaxliability18', MaxLength = 100;
        Deferredtaxliability19Tok: Label 'Deferredtaxliability19', MaxLength = 100;
        Deferredtaxliability20Tok: Label 'Deferredtaxliability20', MaxLength = 100;
        Deferredtaxliability21Tok: Label 'Deferredtaxliability21', MaxLength = 100;
        CREDITORSTOTALTok: Label 'CREDITORSTOTAL', MaxLength = 100;
        LIABILITIESTOTALTok: Label 'LIABILITIESTOTAL', MaxLength = 100;
        NETTURNOVERTok: Label 'NETTURNOVER', MaxLength = 100;
        SalesofrawmaterialsdomTok: Label 'Salesofrawmaterialsdom', MaxLength = 100;
        SalesofgoodsdomTok: Label 'Salesofgoodsdom', MaxLength = 100;
        SalesofservicesdomTok: Label 'Salesofservicesdom', MaxLength = 100;
        SalesofservicecontTok: Label 'Salesofservicecont', MaxLength = 100;
        Sales1Tok: Label 'Sales1', MaxLength = 100;
        Sales2Tok: Label 'Sales2', MaxLength = 100;
        Sales3Tok: Label 'Sales3', MaxLength = 100;
        Sales4Tok: Label 'Sales4', MaxLength = 100;
        Sales5Tok: Label 'Sales5', MaxLength = 100;
        Sales6Tok: Label 'Sales6', MaxLength = 100;
        SalesofrawmaterialsforTok: Label 'Salesofrawmaterialsfor', MaxLength = 100;
        SalesofgoodsforTok: Label 'Salesofgoodsfor', MaxLength = 100;
        SalesofservicesforTok: Label 'Salesofservicesfor', MaxLength = 100;
        SalesofrawmaterialsEUTok: Label 'SalesofrawmaterialsEU', MaxLength = 100;
        SalesofgoodsEUTok: Label 'SalesofgoodsEU', MaxLength = 100;
        SalesofservicesEUTok: Label 'SalesofservicesEU', MaxLength = 100;
        Sales7Tok: Label 'Sales7', MaxLength = 100;
        Sales8Tok: Label 'Sales8', MaxLength = 100;
        Sales9Tok: Label 'Sales9', MaxLength = 100;
        Sales10Tok: Label 'Sales10', MaxLength = 100;
        Sales11Tok: Label 'Sales11', MaxLength = 100;
        Sales12Tok: Label 'Sales12', MaxLength = 100;
        Sales13Tok: Label 'Sales13', MaxLength = 100;
        Sales14Tok: Label 'Sales14', MaxLength = 100;
        Sales15Tok: Label 'Sales15', MaxLength = 100;
        Sales16Tok: Label 'Sales16', MaxLength = 100;
        Sales17Tok: Label 'Sales17', MaxLength = 100;
        Sales18Tok: Label 'Sales18', MaxLength = 100;
        Sales19Tok: Label 'Sales19', MaxLength = 100;
        Discounts1Tok: Label 'Discounts1', MaxLength = 100;
        Discounts2Tok: Label 'Discounts2', MaxLength = 100;
        Discounts3Tok: Label 'Discounts3', MaxLength = 100;
        ExchangeratedifferencesTok: Label 'Exchangeratedifferences', MaxLength = 100;
        Exchangerategains7Tok: Label 'Exchangerategains7', MaxLength = 100;
        ExchangeratelossesTok: Label 'Exchangeratelosses', MaxLength = 100;
        PaymenttoleranceTok: Label 'Paymenttolerance', MaxLength = 100;
        PaymenttolerancededucTok: Label 'Paymenttolerancededuc', MaxLength = 100;
        VATcorrectionsTok: Label 'VATcorrections', MaxLength = 100;
        ShippingExpences1Tok: Label 'ShippingExpences1', MaxLength = 100;
        ShippingExpences2Tok: Label 'ShippingExpences2', MaxLength = 100;
        OthersalesdeductionsTok: Label 'Othersalesdeductions', MaxLength = 100;
        CreditcardprovisionsTok: Label 'Creditcardprovisions', MaxLength = 100;
        NETTURNOVERTOTALTok: Label 'NETTURNOVERTOTAL', MaxLength = 100;
        Variationinstocks1Tok: Label 'Variationinstocks1', MaxLength = 100;
        Variationinstocks2Tok: Label 'Variationinstocks2', MaxLength = 100;
        Variationinstocks3Tok: Label 'Variationinstocks3', MaxLength = 100;
        VariationinstockstotalTok: Label 'Variationinstockstotal', MaxLength = 100;
        Manafacturedforownuse1Tok: Label 'Manafacturedforownuse1', MaxLength = 100;
        Manafacturedforownuse2Tok: Label 'Manafacturedforownuse2', MaxLength = 100;
        Manafacturedforownuse3Tok: Label 'Manafacturedforownuse3', MaxLength = 100;
        ManafacturedforownusetotalTok: Label 'Manafacturedforownusetotal', MaxLength = 100;
        Otheroperatingincome1Tok: Label 'Otheroperatingincome1', MaxLength = 100;
        Otheroperatingincome2Tok: Label 'Otheroperatingincome2', MaxLength = 100;
        Otheroperatingincome3Tok: Label 'Otheroperatingincome3', MaxLength = 100;
        RentsTok: Label 'Rents', MaxLength = 100;
        InsurancesTok: Label 'Insurances', MaxLength = 100;
        GroupservicesTok: Label 'Groupservices', MaxLength = 100;
        OthergroupservicesTok: Label 'Othergroupservices', MaxLength = 100;
        OperatingincometotalTok: Label 'Operatingincometotal', MaxLength = 100;
        RawmaterialsandservicesTok: Label 'Rawmaterialsandservices', MaxLength = 100;
        RawmaterialsandconsumablesTok: Label 'Rawmaterialsandconsumables', MaxLength = 100;
        PurchasesofrawmaterialsdomTok: Label 'Purchasesofrawmaterialsdom', MaxLength = 100;
        PurchasesofgoodsdomTok: Label 'Purchasesofgoodsdom', MaxLength = 100;
        PurchasesofservicesdomTok: Label 'Purchasesofservicesdom', MaxLength = 100;
        PurchasesofrawmaterialsforTok: Label 'Purchasesofrawmaterialsfor', MaxLength = 100;
        PurchasesofgoodsforTok: Label 'Purchasesofgoodsfor', MaxLength = 100;
        PurchasesofservicesforTok: Label 'Purchasesofservicesfor', MaxLength = 100;
        PurchasesofrawmaterialsEUTok: Label 'PurchasesofrawmaterialsEU', MaxLength = 100;
        PurchasesofgoodsEUTok: Label 'PurchasesofgoodsEU', MaxLength = 100;
        PurchasesofservicesEUTok: Label 'PurchasesofservicesEU', MaxLength = 100;
        Purchases1Tok: Label 'Purchases1', MaxLength = 100;
        Purchases2Tok: Label 'Purchases2', MaxLength = 100;
        Purchases3Tok: Label 'Purchases3', MaxLength = 100;
        Purchases4Tok: Label 'Purchases4', MaxLength = 100;
        Purchases5Tok: Label 'Purchases5', MaxLength = 100;
        Purchases6Tok: Label 'Purchases6', MaxLength = 100;
        Purchases7Tok: Label 'Purchases7', MaxLength = 100;
        Purchases8Tok: Label 'Purchases8', MaxLength = 100;
        Purchases9Tok: Label 'Purchases9', MaxLength = 100;
        Discounts4Tok: Label 'Discounts4', MaxLength = 100;
        Discounts5Tok: Label 'Discounts5', MaxLength = 100;
        Discounts6Tok: Label 'Discounts6', MaxLength = 100;
        Invoicerounding2Tok: Label 'Invoicerounding2', MaxLength = 100;
        Exchangeratedifferences2Tok: Label 'Exchangeratedifferences2', MaxLength = 100;
        Exchangerategains6Tok: Label 'Exchangerategains6', MaxLength = 100;
        Paymenttolerance2Tok: Label 'Paymenttolerance2', MaxLength = 100;
        Paymenttolerancededuc2Tok: Label 'Paymenttolerancededuc2', MaxLength = 100;
        VATcorrections2Tok: Label 'VATcorrections2', MaxLength = 100;
        ShippingTok: Label 'Shipping', MaxLength = 100;
        InsuranceTok: Label 'Insurance', MaxLength = 100;
        Variationinstocks9Tok: Label 'Variationinstocks9', MaxLength = 100;
        Variationinstocks10Tok: Label 'Variationinstocks10', MaxLength = 100;
        Variationinstocks11Tok: Label 'Variationinstocks11', MaxLength = 100;
        Variationinstocks4Tok: Label 'Variationinstocks4', MaxLength = 100;
        Variationinstocks5Tok: Label 'Variationinstocks5', MaxLength = 100;
        Variationinstocks6Tok: Label 'Variationinstocks6', MaxLength = 100;
        Variationinstocks7Tok: Label 'Variationinstocks7', MaxLength = 100;
        RawmaterialndcoumablestotalTok: Label 'Rawmaterialndcoumablestotal', MaxLength = 100;
        Externalservices1Tok: Label 'Externalservices1', MaxLength = 100;
        Externalservices2Tok: Label 'Externalservices2', MaxLength = 100;
        Externalservices3Tok: Label 'Externalservices3', MaxLength = 100;
        ShippingservicesTok: Label 'Shippingservices', MaxLength = 100;
        RawmaterialsandservicestotalTok: Label 'Rawmaterialsandservicestotal', MaxLength = 100;
        StaffexpencesTok: Label 'Staffexpences', MaxLength = 100;
        Wagesandsalaries1Tok: Label 'Wagesandsalaries1', MaxLength = 100;
        Wagesandsalaries2Tok: Label 'Wagesandsalaries2', MaxLength = 100;
        Wagesandsalaries3Tok: Label 'Wagesandsalaries3', MaxLength = 100;
        Socialsecurityexpenses1Tok: Label 'Socialsecurityexpenses1', MaxLength = 100;
        Socialsecurityexpenses2Tok: Label 'Socialsecurityexpenses2', MaxLength = 100;
        Socialsecurityexpenses3Tok: Label 'Socialsecurityexpenses3', MaxLength = 100;
        Socialsecurityexpenses4Tok: Label 'Socialsecurityexpenses4', MaxLength = 100;
        Pensionexpenses1Tok: Label 'Pensionexpenses1', MaxLength = 100;
        Othersocialsecurityexpenses1Tok: Label 'Othersocialsecurityexpenses1', MaxLength = 100;
        Othersocialsecurityexpenses2Tok: Label 'Othersocialsecurityexpenses2', MaxLength = 100;
        Othersocialsecurityexpenses3Tok: Label 'Othersocialsecurityexpenses3', MaxLength = 100;
        Otherstaffexpenses1Tok: Label 'Otherstaffexpenses1', MaxLength = 100;
        Otherstaffexpenses2Tok: Label 'Otherstaffexpenses2', MaxLength = 100;
        Otherstaffexpenses3Tok: Label 'Otherstaffexpenses3', MaxLength = 100;
        Otherstaffexpenses4Tok: Label 'Otherstaffexpenses4', MaxLength = 100;
        Otherstaffexpenses5Tok: Label 'Otherstaffexpenses5', MaxLength = 100;
        Otherstaffexpenses6Tok: Label 'Otherstaffexpenses6', MaxLength = 100;
        Otherstaffexpenses7Tok: Label 'Otherstaffexpenses7', MaxLength = 100;
        Otherstaffexpenses8Tok: Label 'Otherstaffexpenses8', MaxLength = 100;
        Otherstaffexpenses9Tok: Label 'Otherstaffexpenses9', MaxLength = 100;
        Otherstaffexpenses10Tok: Label 'Otherstaffexpenses10', MaxLength = 100;
        Otherstaffexpenses11Tok: Label 'Otherstaffexpenses11', MaxLength = 100;
        Otherstaffexpenses12Tok: Label 'Otherstaffexpenses12', MaxLength = 100;
        Otherstaffexpenses13Tok: Label 'Otherstaffexpenses13', MaxLength = 100;
        Wagesandsalaries4Tok: Label 'Wagesandsalaries4', MaxLength = 100;
        Wagesandsalaries5Tok: Label 'Wagesandsalaries5', MaxLength = 100;
        Wagesandsalaries6Tok: Label 'Wagesandsalaries6', MaxLength = 100;
        Wagesandsalaries7Tok: Label 'Wagesandsalaries7', MaxLength = 100;
        Wagesandsalaries8Tok: Label 'Wagesandsalaries8', MaxLength = 100;
        Wagesandsalaries9Tok: Label 'Wagesandsalaries9', MaxLength = 100;
        Wagesandsalaries10Tok: Label 'Wagesandsalaries10', MaxLength = 100;
        Wagesandsalaries11Tok: Label 'Wagesandsalaries11', MaxLength = 100;
        Wagesandsalaries12Tok: Label 'Wagesandsalaries12', MaxLength = 100;
        Wagesandsalaries13Tok: Label 'Wagesandsalaries13', MaxLength = 100;
        Wagesandsalaries14Tok: Label 'Wagesandsalaries14', MaxLength = 100;
        Wagesandsalaries15Tok: Label 'Wagesandsalaries15', MaxLength = 100;
        Wagesandsalaries16Tok: Label 'Wagesandsalaries16', MaxLength = 100;
        Socialsecurityexpenses5Tok: Label 'Socialsecurityexpenses5', MaxLength = 100;
        Socialsecurityexpenses6Tok: Label 'Socialsecurityexpenses6', MaxLength = 100;
        Pensionexpenses2Tok: Label 'Pensionexpenses2', MaxLength = 100;
        Pensionexpenses3Tok: Label 'Pensionexpenses3', MaxLength = 100;
        Othersocialsecurityexpenses4Tok: Label 'Othersocialsecurityexpenses4', MaxLength = 100;
        Othersocialsecurityexpenses5Tok: Label 'Othersocialsecurityexpenses5', MaxLength = 100;
        Othersocialsecurityexpenses6Tok: Label 'Othersocialsecurityexpenses6', MaxLength = 100;
        Pensionexpenses4Tok: Label 'Pensionexpenses4', MaxLength = 100;
        Othersocialsecurityexpenses7Tok: Label 'Othersocialsecurityexpenses7', MaxLength = 100;
        Otherstaffexpenses14Tok: Label 'Otherstaffexpenses14', MaxLength = 100;
        Otherstaffexpenses15Tok: Label 'Otherstaffexpenses15', MaxLength = 100;
        Otherstaffexpenses16Tok: Label 'Otherstaffexpenses16', MaxLength = 100;
        Otherstaffexpenses17Tok: Label 'Otherstaffexpenses17', MaxLength = 100;
        Otherstaffexpenses18Tok: Label 'Otherstaffexpenses18', MaxLength = 100;
        Otherstaffexpenses19Tok: Label 'Otherstaffexpenses19', MaxLength = 100;
        Otherstaffexpenses20Tok: Label 'Otherstaffexpenses20', MaxLength = 100;
        StaffexpencestotalTok: Label 'Staffexpencestotal', MaxLength = 100;
        OtheroperatingchargesTok: Label 'Otheroperatingcharges', MaxLength = 100;
        Rents2Tok: Label 'Rents2', MaxLength = 100;
        Rents3Tok: Label 'Rents3', MaxLength = 100;
        Rents4Tok: Label 'Rents4', MaxLength = 100;
        Rents5Tok: Label 'Rents5', MaxLength = 100;
        Rents6Tok: Label 'Rents6', MaxLength = 100;
        Rents7Tok: Label 'Rents7', MaxLength = 100;
        Otherstaffexpenses21Tok: Label 'Otherstaffexpenses21', MaxLength = 100;
        Otherstaffexpenses22Tok: Label 'Otherstaffexpenses22', MaxLength = 100;
        Otherstaffexpenses23Tok: Label 'Otherstaffexpenses23', MaxLength = 100;
        Otherstaffexpenses24Tok: Label 'Otherstaffexpenses24', MaxLength = 100;
        Otherstaffexpenses25Tok: Label 'Otherstaffexpenses25', MaxLength = 100;
        Otherstaffexpenses26Tok: Label 'Otherstaffexpenses26', MaxLength = 100;
        Otherstaffexpenses27Tok: Label 'Otherstaffexpenses27', MaxLength = 100;
        Otherstaffexpenses28Tok: Label 'Otherstaffexpenses28', MaxLength = 100;
        Salesmarketingexp1Tok: Label 'Salesmarketingexp1', MaxLength = 100;
        Salesmarketingexp2Tok: Label 'Salesmarketingexp2', MaxLength = 100;
        Salesmarketingexp3Tok: Label 'Salesmarketingexp3', MaxLength = 100;
        Salesmarketingexp4Tok: Label 'Salesmarketingexp4', MaxLength = 100;
        Salesmarketingexp5Tok: Label 'Salesmarketingexp5', MaxLength = 100;
        Salesmarketingexp6Tok: Label 'Salesmarketingexp6', MaxLength = 100;
        Salesmarketingexp7Tok: Label 'Salesmarketingexp7', MaxLength = 100;
        Salesmarketingexp8Tok: Label 'Salesmarketingexp8', MaxLength = 100;
        Salesmarketingexp9Tok: Label 'Salesmarketingexp9', MaxLength = 100;
        Salesmarketingexp10Tok: Label 'Salesmarketingexp10', MaxLength = 100;
        Salesmarketingexp11Tok: Label 'Salesmarketingexp11', MaxLength = 100;
        Salesmarketingexp12Tok: Label 'Salesmarketingexp12', MaxLength = 100;
        Salesmarketingexp13Tok: Label 'Salesmarketingexp13', MaxLength = 100;
        Salesmarketingexp14Tok: Label 'Salesmarketingexp14', MaxLength = 100;
        FuelTok: Label 'Fuel', MaxLength = 100;
        Maintenance1Tok: Label 'Maintenance1', MaxLength = 100;
        Maintenance2Tok: Label 'Maintenance2', MaxLength = 100;
        Maintenance3Tok: Label 'Maintenance3', MaxLength = 100;
        Maintenance4Tok: Label 'Maintenance4', MaxLength = 100;
        FurnitureTok: Label 'Furniture', MaxLength = 100;
        OtherequipmentTok: Label 'Otherequipment', MaxLength = 100;
        SuppliesTok: Label 'Supplies', MaxLength = 100;
        OthermaintenanceservicesTok: Label 'Othermaintenanceservices', MaxLength = 100;
        WaterTok: Label 'Water', MaxLength = 100;
        GasandelectricityTok: Label 'Gasandelectricity', MaxLength = 100;
        RealestateexpencesTok: Label 'Realestateexpences', MaxLength = 100;
        OutsourcedservicesTok: Label 'Outsourcedservices', MaxLength = 100;
        WasteTok: Label 'Waste', MaxLength = 100;
        ElectricityTok: Label 'Electricity', MaxLength = 100;
        Insurances2Tok: Label 'Insurances2', MaxLength = 100;
        RealestatetaxTok: Label 'Realestatetax', MaxLength = 100;
        Maintenance5Tok: Label 'Maintenance5', MaxLength = 100;
        Vehicles1Tok: Label 'Vehicles1', MaxLength = 100;
        Vehicles2Tok: Label 'Vehicles2', MaxLength = 100;
        Vehicles3Tok: Label 'Vehicles3', MaxLength = 100;
        Vehicles4Tok: Label 'Vehicles4', MaxLength = 100;
        Vehicles5Tok: Label 'Vehicles5', MaxLength = 100;
        Vehicles6Tok: Label 'Vehicles6', MaxLength = 100;
        Vehicles7Tok: Label 'Vehicles7', MaxLength = 100;
        Vehicles8Tok: Label 'Vehicles8', MaxLength = 100;
        Vehicles9Tok: Label 'Vehicles9', MaxLength = 100;
        Vehicles10Tok: Label 'Vehicles10', MaxLength = 100;
        Otheroperatingexp1Tok: Label 'Otheroperatingexp1', MaxLength = 100;
        Otheroperatingexp2Tok: Label 'Otheroperatingexp2', MaxLength = 100;
        InformationcostsTok: Label 'Informationcosts', MaxLength = 100;
        Telecosts1Tok: Label 'Telecosts1', MaxLength = 100;
        Telecosts2Tok: Label 'Telecosts2', MaxLength = 100;
        Insurance2Tok: Label 'Insurance2', MaxLength = 100;
        Insurance3Tok: Label 'Insurance3', MaxLength = 100;
        Officesupplies1Tok: Label 'Officesupplies1', MaxLength = 100;
        Officesupplies2Tok: Label 'Officesupplies2', MaxLength = 100;
        Officesupplies3Tok: Label 'Officesupplies3', MaxLength = 100;
        Officesupplies4Tok: Label 'Officesupplies4', MaxLength = 100;
        Officesupplies5Tok: Label 'Officesupplies5', MaxLength = 100;
        Outsourcedservices2Tok: Label 'Outsourcedservices2', MaxLength = 100;
        AccountingTok: Label 'Accounting', MaxLength = 100;
        ITservicesTok: Label 'ITservices', MaxLength = 100;
        AuditingTok: Label 'Auditing', MaxLength = 100;
        LawservicesTok: Label 'Lawservices', MaxLength = 100;
        OtherexpencesTok: Label 'Otherexpences', MaxLength = 100;
        MembershipsTok: Label 'Memberships', MaxLength = 100;
        NotificationsTok: Label 'Notifications', MaxLength = 100;
        BankingexpencesTok: Label 'Bankingexpences', MaxLength = 100;
        MeetingsTok: Label 'Meetings', MaxLength = 100;
        Otherexpences2Tok: Label 'Otherexpences2', MaxLength = 100;
        Baddept1Tok: Label 'Baddept1', MaxLength = 100;
        Baddept2Tok: Label 'Baddept2', MaxLength = 100;
        Baddept3Tok: Label 'Baddept3', MaxLength = 100;
        OtheroperatingexpensestotalTok: Label 'Otheroperatingexpensestotal', MaxLength = 100;
        Depreciation1Tok: Label 'Depreciation1', MaxLength = 100;
        Depreciation2Tok: Label 'Depreciation2', MaxLength = 100;
        Depreciation3Tok: Label 'Depreciation3', MaxLength = 100;
        Depreciation4Tok: Label 'Depreciation4', MaxLength = 100;
        Depreciation5Tok: Label 'Depreciation5', MaxLength = 100;
        Depreciation6Tok: Label 'Depreciation6', MaxLength = 100;
        Depreciation7Tok: Label 'Depreciation7', MaxLength = 100;
        Reductioninvalue1Tok: Label 'Reductioninvalue1', MaxLength = 100;
        Reductioninvalue2Tok: Label 'Reductioninvalue2', MaxLength = 100;
        Reductioninvalue3Tok: Label 'Reductioninvalue3', MaxLength = 100;
        Reductioninvalue4Tok: Label 'Reductioninvalue4', MaxLength = 100;
        Reductioninvalue5Tok: Label 'Reductioninvalue5', MaxLength = 100;
        Reductioninvalue6Tok: Label 'Reductioninvalue6', MaxLength = 100;
        Reductioninvalue7Tok: Label 'Reductioninvalue7', MaxLength = 100;
        Reductioninvalue8Tok: Label 'Reductioninvalue8', MaxLength = 100;
        Reductioninvalue9Tok: Label 'Reductioninvalue9', MaxLength = 100;
        Reductioninvalue10Tok: Label 'Reductioninvalue10', MaxLength = 100;
        Reductioninvalue11Tok: Label 'Reductioninvalue11', MaxLength = 100;
        Reductioninvalue12Tok: Label 'Reductioninvalue12', MaxLength = 100;
        Reductioninvalue13Tok: Label 'Reductioninvalue13', MaxLength = 100;
        Reductioninvalue14Tok: Label 'Reductioninvalue14', MaxLength = 100;
        Reductioninvalue15Tok: Label 'Reductioninvalue15', MaxLength = 100;
        Reductioninvalue16Tok: Label 'Reductioninvalue16', MaxLength = 100;
        Reductioninvalue17Tok: Label 'Reductioninvalue17', MaxLength = 100;
        Reductioninvalue18Tok: Label 'Reductioninvalue18', MaxLength = 100;
        Reductioninvalue19Tok: Label 'Reductioninvalue19', MaxLength = 100;
        DepreciationeductionsinvalueTok: Label 'Depreciationeductionsinvalue', MaxLength = 100;
        OPERATINGPROFITLOSSTok: Label 'OPERATINGPROFITLOSS', MaxLength = 100;
        FinancialincomeandexpensesTok: Label 'Financialincomeandexpenses', MaxLength = 100;
        ShareofprofitlossTok: Label 'Shareofprofitloss', MaxLength = 100;
        ShareofprofitlsofgdertakingsTok: Label 'Shareofprofitlsofgdertakings', MaxLength = 100;
        ShareofprofitssofassompaniesTok: Label 'Shareofprofitssofassompanies', MaxLength = 100;
        IncomefromgroupundertakingsTok: Label 'Incomefromgroupundertakings', MaxLength = 100;
        IncomefrompaipatinginterestsTok: Label 'Incomefrompaipatinginterests', MaxLength = 100;
        Otherintereaninancialincome1Tok: Label 'Otherintereaninancialincome1', MaxLength = 100;
        Otherintereaninancialincome2Tok: Label 'Otherintereaninancialincome2', MaxLength = 100;
        ReductioninvalueofirentassetsTok: Label 'Reductioninvalueofirentassets', MaxLength = 100;
        ReductioninvalueofinvesassetsTok: Label 'Reductioninvalueofinvesassets', MaxLength = 100;
        InterestandothinancialincomeTok: Label 'Interestandothinancialincome', MaxLength = 100;
        FinancialincomeTok: Label 'Financialincome', MaxLength = 100;
        OtherfinancialincomeTok: Label 'Otherfinancialincome', MaxLength = 100;
        Exchangerategains1Tok: Label 'Exchangerategains1', MaxLength = 100;
        Exchangerategains2Tok: Label 'Exchangerategains2', MaxLength = 100;
        Exchangerategains3Tok: Label 'Exchangerategains3', MaxLength = 100;
        Otherfinancialincome2Tok: Label 'Otherfinancialincome2', MaxLength = 100;
        Exchangerategains5Tok: Label 'Exchangerategains5', MaxLength = 100;
        FinancialincometotalTok: Label 'Financialincometotal', MaxLength = 100;
        Financialexpenses1Tok: Label 'Financialexpenses1', MaxLength = 100;
        Financialexpenses2Tok: Label 'Financialexpenses2', MaxLength = 100;
        Financialexpenses3Tok: Label 'Financialexpenses3', MaxLength = 100;
        Financialexpenses4Tok: Label 'Financialexpenses4', MaxLength = 100;
        Financialexpenses5Tok: Label 'Financialexpenses5', MaxLength = 100;
        Financialexpenses6Tok: Label 'Financialexpenses6', MaxLength = 100;
        Financialexpenses7Tok: Label 'Financialexpenses7', MaxLength = 100;
        Financialexpenses8Tok: Label 'Financialexpenses8', MaxLength = 100;
        Financialexpenses9Tok: Label 'Financialexpenses9', MaxLength = 100;
        Financialexpenses10Tok: Label 'Financialexpenses10', MaxLength = 100;
        Financialexpenses11Tok: Label 'Financialexpenses11', MaxLength = 100;
        Financialexpenses12Tok: Label 'Financialexpenses12', MaxLength = 100;
        Financialexpenses13Tok: Label 'Financialexpenses13', MaxLength = 100;
        Financialexpenses14Tok: Label 'Financialexpenses14', MaxLength = 100;
        PROFITLOSSBEFOEXDINARYITEMSTok: Label 'PROFITLOSSBEFOEXDINARYITEMS', MaxLength = 100;
        ExtraordinaryitemsTok: Label 'Extraordinaryitems', MaxLength = 100;
        OtherextraordinaryincomeTok: Label 'Otherextraordinaryincome', MaxLength = 100;
        VATadjustmentsTok: Label 'VATadjustments', MaxLength = 100;
        TAXadjusmentsTok: Label 'TAXadjusments', MaxLength = 100;
        OtherextraordinaryexpenseTok: Label 'Otherextraordinaryexpense', MaxLength = 100;
        Otherextraordinaryexpense2Tok: Label 'Otherextraordinaryexpense2', MaxLength = 100;
        ExtraordinaryitemstotalTok: Label 'Extraordinaryitemstotal', MaxLength = 100;
        PROFITLOSSBEFEAPPROSANDTAXESTok: Label 'PROFITLOSSBEFEAPPROSANDTAXES', MaxLength = 100;
        Appropriations1Tok: Label 'Appropriations1', MaxLength = 100;
        Changeindepreciationreserve1Tok: Label 'Changeindepreciationreserve1', MaxLength = 100;
        Changeindepreciationreserve2Tok: Label 'Changeindepreciationreserve2', MaxLength = 100;
        Changeindepreciationreserve3Tok: Label 'Changeindepreciationreserve3', MaxLength = 100;
        Changeindepreciationreserve4Tok: Label 'Changeindepreciationreserve4', MaxLength = 100;
        Changeindepreciationreserve5Tok: Label 'Changeindepreciationreserve5', MaxLength = 100;
        Changeinuntaxedreserves1Tok: Label 'Changeinuntaxedreserves1', MaxLength = 100;
        Changeinuntaxedreserves2Tok: Label 'Changeinuntaxedreserves2', MaxLength = 100;
        Changeinuntaxedreserves3Tok: Label 'Changeinuntaxedreserves3', MaxLength = 100;
        Appropriationstotal1Tok: Label 'Appropriationstotal1', MaxLength = 100;
        IncometaxesTok: Label 'Incometaxes', MaxLength = 100;
        Taxesoncialyeandyearsbefore1Tok: Label 'Taxesoncialyeandyearsbefore1', MaxLength = 100;
        Taxesoncialyeandyearsbefore2Tok: Label 'Taxesoncialyeandyearsbefore2', MaxLength = 100;
        Taxesoncialyeandyearsbefore3Tok: Label 'Taxesoncialyeandyearsbefore3', MaxLength = 100;
        Taxesoncialyeandyearsbefore4Tok: Label 'Taxesoncialyeandyearsbefore4', MaxLength = 100;
        Incometaxes2Tok: Label 'Incometaxes2', MaxLength = 100;
        PROFITLOSSFORTHEFINANCIALYEARTok: Label 'PROFITLOSSFORTHEFINANCIALYEAR', MaxLength = 100;
        AsstesTok: Label 'Assets', MaxLength = 80;
}