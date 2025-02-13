codeunit 11499 "Create NL GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '0610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '1210');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '0760');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '3230');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '5110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '0505');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '7101')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '6430');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '3420');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '3430');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '5311');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '5315');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '5316');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '1520');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '6410');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '5520');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforNL()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '0000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '0001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '0100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '0101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '0504');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '0551');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '0552');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '0851');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '0999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '1001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '1270');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.INCOMESTATEMENTName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '3401');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '3501');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '3610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '3920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '4310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '4413');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '5510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '6330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '6410');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '5312');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '5313');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '5314');
        ContosoGLAccount.AddAccountForLocalization(IntangibleFixedAssetsName(), '0002');
        ContosoGLAccount.AddAccountForLocalization(DevelopmentExpenditureName(), '0010');
        ContosoGLAccount.AddAccountForLocalization(TenancySiteLeaseholdandsimilarrightsName(), '0020');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '0030');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforIntangibleFixedAssetsName(), '0040');
        ContosoGLAccount.AddAccountForLocalization(TotalIntangibleFixedAssetsName(), '0049');
        ContosoGLAccount.AddAccountForLocalization(BuildingName(), '0110');
        ContosoGLAccount.AddAccountForLocalization(CostofImprovementstoLeasedPropertyName(), '0120');
        ContosoGLAccount.AddAccountForLocalization(LandName(), '0130');
        ContosoGLAccount.AddAccountForLocalization(TotalLandandbuildingName(), '0199');
        ContosoGLAccount.AddAccountForLocalization(MachineryandEquipmentName(), '0200');
        ContosoGLAccount.AddAccountForLocalization(EquipmentsandToolsName(), '0210');
        ContosoGLAccount.AddAccountForLocalization(ComputersName(), '0220');
        ContosoGLAccount.AddAccountForLocalization(CarsandotherTransportEquipmentsName(), '0230');
        ContosoGLAccount.AddAccountForLocalization(LeasedAssetsName(), '0240');
        ContosoGLAccount.AddAccountForLocalization(TotalMachineryandEquipmentName(), '0299');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationName(), '0300');
        ContosoGLAccount.AddAccountForLocalization(TotalTangibleAssetsName(), '0399');
        ContosoGLAccount.AddAccountForLocalization(FinancialandFixedAssetsName(), '0400');
        ContosoGLAccount.AddAccountForLocalization(LongtermReceivablesName(), '0401');
        ContosoGLAccount.AddAccountForLocalization(ParticipationinGroupCompaniesName(), '0402');
        ContosoGLAccount.AddAccountForLocalization(LoanstoPartnersorrelatedPartiesName(), '0403');
        ContosoGLAccount.AddAccountForLocalization(DeferredTaxAssetsName(), '0404');
        ContosoGLAccount.AddAccountForLocalization(OtherLongtermReceivablesName(), '0405');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialandFixedAssetsName(), '0499');
        ContosoGLAccount.AddAccountForLocalization(InventoriesProductsandworkinProgressName(), '0500');
        ContosoGLAccount.AddAccountForLocalization(SuppliesandConsumablesName(), '0502');
        ContosoGLAccount.AddAccountForLocalization(ProductsinProgressName(), '0503');
        ContosoGLAccount.AddAccountForLocalization(GoodsforResaleName(), '0505');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforgoodsandservicesName(), '0506');
        ContosoGLAccount.AddAccountForLocalization(OtherInventoryItemsName(), '0507');
        ContosoGLAccount.AddAccountForLocalization(WorkinProgressName(), '0550');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedCostsName(), '0553');
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '0554');
        ContosoGLAccount.AddAccountForLocalization(TotalWorkinProgressName(), '0598');
        ContosoGLAccount.AddAccountForLocalization(TotalInventoryProductsandWorkinProgressName(), '0599');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '0600');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivablesName(), '0601');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableDomesticName(), '0610');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableForeignName(), '0620');
        ContosoGLAccount.AddAccountForLocalization(ContractualReceivablesName(), '0630');
        ContosoGLAccount.AddAccountForLocalization(ConsignmentReceivablesName(), '0640');
        ContosoGLAccount.AddAccountForLocalization(CreditcardsandVouchersReceivablesName(), '0650');
        ContosoGLAccount.AddAccountForLocalization(TotalAccountReceivablesName(), '0699');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentReceivablesName(), '0700');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablefromEmployeesName(), '0710');
        ContosoGLAccount.AddAccountForLocalization(AccruedincomenotyetinvoicedName(), '0720');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountsforTaxesandchargesName(), '0730');
        ContosoGLAccount.AddAccountForLocalization(TaxAssetsName(), '0740');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATReducedName(), '0750');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATNormalName(), '0760');
        ContosoGLAccount.AddAccountForLocalization(MiscVATReceivablesName(), '0770');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablesfromgroupcompaniesName(), '0780');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentReceivablesName(), '0798');
        ContosoGLAccount.AddAccountForLocalization(TotalReceivablesName(), '0799');
        ContosoGLAccount.AddAccountForLocalization(PrepaidexpensesandAccruedIncomeName(), '0800');
        ContosoGLAccount.AddAccountForLocalization(PrepaidRentName(), '0801');
        ContosoGLAccount.AddAccountForLocalization(PrepaidInterestexpenseName(), '0802');
        ContosoGLAccount.AddAccountForLocalization(AccruedRentalIncomeName(), '0803');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestIncomeName(), '0804');
        ContosoGLAccount.AddAccountForLocalization(AssetsintheformofprepaidexpensesName(), '0805');
        ContosoGLAccount.AddAccountForLocalization(OtherprepaidexpensesandaccruedincomeName(), '0806');
        ContosoGLAccount.AddAccountForLocalization(TotalPrepaidexpensesandAccruedIncomeName(), '0849');
        ContosoGLAccount.AddAccountForLocalization(ShortterminvestmentsName(), '0850');
        ContosoGLAccount.AddAccountForLocalization(ConvertibledebtinstrumentsName(), '0852');
        ContosoGLAccount.AddAccountForLocalization(OthershorttermInvestmentsName(), '0853');
        ContosoGLAccount.AddAccountForLocalization(WritedownofShortterminvestmentsName(), '0854');
        ContosoGLAccount.AddAccountForLocalization(TotalshortterminvestmentsName(), '0899');
        ContosoGLAccount.AddAccountForLocalization(CashandBankName(), '0900');
        ContosoGLAccount.AddAccountForLocalization(PettyCashName(), '0910');
        ContosoGLAccount.AddAccountForLocalization(BusinessaccountOperatingDomesticName(), '0920');
        ContosoGLAccount.AddAccountForLocalization(BusinessaccountOperatingForeignName(), '0930');
        ContosoGLAccount.AddAccountForLocalization(OtherbankaccountsName(), '0940');
        ContosoGLAccount.AddAccountForLocalization(CertificateofDepositName(), '0950');
        ContosoGLAccount.AddAccountForLocalization(TotalCashandBankName(), '0998');
        ContosoGLAccount.AddAccountForLocalization(LiabilityName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(BondsandDebentureLoansName(), '1110');
        ContosoGLAccount.AddAccountForLocalization(ConvertiblesLoansName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(OtherLongtermLiabilitiesName(), '1130');
        ContosoGLAccount.AddAccountForLocalization(BankoverdraftFacilitiesName(), '1140');
        ContosoGLAccount.AddAccountForLocalization(PaymtsRecptsinProcessName(), '1180');
        ContosoGLAccount.AddAccountForLocalization(TotalLongtermLiabilitiesName(), '1199');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiesName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableDomesticName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableForeignName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(AdvancesfromcustomersName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(ChangeinWorkinProgressName(), '1240');
        ContosoGLAccount.AddAccountForLocalization(BankoverdraftshorttermName(), '1250');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenueName(), '1260');
        ContosoGLAccount.AddAccountForLocalization(TotalCurrentLiabilitiesName(), '1299');
        ContosoGLAccount.AddAccountForLocalization(TaxLiabilitiesName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxVATLiableName(), '1310');
        ContosoGLAccount.AddAccountForLocalization(CollectioninProcessName(), '1312');
        ContosoGLAccount.AddAccountForLocalization(TaxesLiableName(), '1320');
        ContosoGLAccount.AddAccountForLocalization(SalesVATReducedName(), '1330');
        ContosoGLAccount.AddAccountForLocalization(SalesVATNormalName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(MiscVATPayablesName(), '1350');
        ContosoGLAccount.AddAccountForLocalization(EstimatedIncomeTaxName(), '1360');
        ContosoGLAccount.AddAccountForLocalization(EstimatedrealestateTaxRealestatechargeName(), '1370');
        ContosoGLAccount.AddAccountForLocalization(EstimatedPayrolltaxonPensionCostsName(), '1380');
        ContosoGLAccount.AddAccountForLocalization(TotalTaxLiabilitiesName(), '1399');
        ContosoGLAccount.AddAccountForLocalization(PayrollLiabilitiesName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(EmployeesWithholdingTaxesName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialsecurityContributionsName(), '1420');
        ContosoGLAccount.AddAccountForLocalization(ContractualSocialsecurityContributionsName(), '1430');
        ContosoGLAccount.AddAccountForLocalization(AttachmentsofEarningName(), '1440');
        ContosoGLAccount.AddAccountForLocalization(HolidayPayfundName(), '1450');
        ContosoGLAccount.AddAccountForLocalization(OtherSalarywageDeductionsName(), '1460');
        ContosoGLAccount.AddAccountForLocalization(TotalPayrollLiabilitiesName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentLiabilitiesName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountforFactoringCurrentPortionName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiestoEmployeesName(), '1520');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountforthirdpartyName(), '1530');
        ContosoGLAccount.AddAccountForLocalization(CurrentLoansName(), '1540');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesGrantsReceivedName(), '1550');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentLiabilitiesName(), '1599');
        ContosoGLAccount.AddAccountForLocalization(AccruedExpensesandDeferredIncomeName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(AccruedwagessalariesName(), '1610');
        ContosoGLAccount.AddAccountForLocalization(PaymentsinProcessName(), '1612');
        ContosoGLAccount.AddAccountForLocalization(AccruedHolidaypayName(), '1620');
        ContosoGLAccount.AddAccountForLocalization(AccruedPensioncostsName(), '1630');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestExpenseName(), '1640');
        ContosoGLAccount.AddAccountForLocalization(DeferredIncomeName(), '1650');
        ContosoGLAccount.AddAccountForLocalization(AccruedContractualcostsName(), '1660');
        ContosoGLAccount.AddAccountForLocalization(OtherAccruedExpensesandDeferredIncomeName(), '1670');
        ContosoGLAccount.AddAccountForLocalization(TotalAccruedExpensesandDeferredIncomeName(), '1699');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(EquityPartnerName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(NetResultsName(), '2200');
        ContosoGLAccount.AddAccountForLocalization(RestrictedEquityName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(ShareCapitalName(), '2400');
        ContosoGLAccount.AddAccountForLocalization(NonRestrictedEquityName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(ProfitorlossfromthepreviousyearName(), '2600');
        ContosoGLAccount.AddAccountForLocalization(ResultsfortheFinancialyearName(), '2700');
        ContosoGLAccount.AddAccountForLocalization(DistributionstoShareholdersName(), '2800');
        ContosoGLAccount.AddAccountForLocalization(TotalEquityName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(EXPENSESName(), '3001');
        ContosoGLAccount.AddAccountForLocalization(FacilityExpensesName(), '3002');
        ContosoGLAccount.AddAccountForLocalization(RentalFacilitiesName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(RentLeasesName(), '3110');
        ContosoGLAccount.AddAccountForLocalization(ElectricityforRentalName(), '3120');
        ContosoGLAccount.AddAccountForLocalization(HeatingforRentalName(), '3130');
        ContosoGLAccount.AddAccountForLocalization(WaterandSewerageforRentalName(), '3140');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforRentalName(), '3150');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceforRentalName(), '3160');
        ContosoGLAccount.AddAccountForLocalization(InsurancesRentalName(), '3170');
        ContosoGLAccount.AddAccountForLocalization(OtherRentalExpensesName(), '3180');
        ContosoGLAccount.AddAccountForLocalization(TotalRentalFacilitiesName(), '3199');
        ContosoGLAccount.AddAccountForLocalization(PropertyExpensesName(), '3200');
        ContosoGLAccount.AddAccountForLocalization(SiteFeesLeasesName(), '3210');
        ContosoGLAccount.AddAccountForLocalization(ElectricityforPropertyName(), '3220');
        ContosoGLAccount.AddAccountForLocalization(HeatingforPropertyName(), '3230');
        ContosoGLAccount.AddAccountForLocalization(WaterandSewerageforPropertyName(), '3240');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforPropertyName(), '3250');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceforPropertyName(), '3260');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPropertyName(), '3270');
        ContosoGLAccount.AddAccountForLocalization(OtherPropertyExpensesName(), '3280');
        ContosoGLAccount.AddAccountForLocalization(TotalPropertyExpensesName(), '3298');
        ContosoGLAccount.AddAccountForLocalization(TotalFacilityExpensesName(), '3299');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsLeasesName(), '3300');
        ContosoGLAccount.AddAccountForLocalization(HireofmachineryName(), '3310');
        ContosoGLAccount.AddAccountForLocalization(HireofcomputersName(), '3320');
        ContosoGLAccount.AddAccountForLocalization(HireofotherfixedassetsName(), '3330');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetLeasesName(), '3399');
        ContosoGLAccount.AddAccountForLocalization(LogisticsExpensesName(), '3400');
        ContosoGLAccount.AddAccountForLocalization(PassengerCarCostsName(), '3410');
        ContosoGLAccount.AddAccountForLocalization(TruckCostsName(), '3420');
        ContosoGLAccount.AddAccountForLocalization(OthervehicleexpensesName(), '3430');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleExpensesName(), '3449');
        ContosoGLAccount.AddAccountForLocalization(FreightCostsName(), '3450');
        ContosoGLAccount.AddAccountForLocalization(FreightfeesforgoodsName(), '3451');
        ContosoGLAccount.AddAccountForLocalization(CustomsandforwardingName(), '3452');
        ContosoGLAccount.AddAccountForLocalization(FreightfeesprojectsName(), '3453');
        ContosoGLAccount.AddAccountForLocalization(TotalFreightCostsName(), '3459');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesName(), '3460');
        ContosoGLAccount.AddAccountForLocalization(TicketsName(), '3461');
        ContosoGLAccount.AddAccountForLocalization(RentalvehiclesName(), '3462');
        ContosoGLAccount.AddAccountForLocalization(BoardandlodgingName(), '3463');
        ContosoGLAccount.AddAccountForLocalization(OthertravelexpensesName(), '3464');
        ContosoGLAccount.AddAccountForLocalization(TotalTravelExpensesName(), '3469');
        ContosoGLAccount.AddAccountForLocalization(TotalLogisticsExpensesName(), '3499');
        ContosoGLAccount.AddAccountForLocalization(MarketingandSalesName(), '3500');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementDevelopmentName(), '3502');
        ContosoGLAccount.AddAccountForLocalization(OutdoorandTransportationAdsName(), '3503');
        ContosoGLAccount.AddAccountForLocalization(AdmatteranddirectmailingsName(), '3504');
        ContosoGLAccount.AddAccountForLocalization(ConferenceExhibitionSponsorshipName(), '3505');
        ContosoGLAccount.AddAccountForLocalization(SamplescontestsgiftsName(), '3506');
        ContosoGLAccount.AddAccountForLocalization(FilmTVradiointernetadsName(), '3507');
        ContosoGLAccount.AddAccountForLocalization(PRandAgencyFeesName(), '3508');
        ContosoGLAccount.AddAccountForLocalization(OtheradvertisingfeesName(), '3509');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvertisingName(), '3549');
        ContosoGLAccount.AddAccountForLocalization(OtherMarketingExpensesName(), '3550');
        ContosoGLAccount.AddAccountForLocalization(CatalogspricelistsName(), '3551');
        ContosoGLAccount.AddAccountForLocalization(TradePublicationsName(), '3552');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherMarketingExpensesName(), '3559');
        ContosoGLAccount.AddAccountForLocalization(SalesExpensesName(), '3560');
        ContosoGLAccount.AddAccountForLocalization(CreditCardChargesName(), '3561');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingdeductibleName(), '3562');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingnondeductibleName(), '3563');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesExpensesName(), '3569');
        ContosoGLAccount.AddAccountForLocalization(TotalMarketingandSalesName(), '3599');
        ContosoGLAccount.AddAccountForLocalization(OfficeExpensesName(), '3600');
        ContosoGLAccount.AddAccountForLocalization(PhoneServicesName(), '3620');
        ContosoGLAccount.AddAccountForLocalization(DataservicesName(), '3630');
        ContosoGLAccount.AddAccountForLocalization(PostalfeesName(), '3640');
        ContosoGLAccount.AddAccountForLocalization(ConsumableExpensiblehardwareName(), '3650');
        ContosoGLAccount.AddAccountForLocalization(SoftwareandsubscriptionfeesName(), '3660');
        ContosoGLAccount.AddAccountForLocalization(TotalOfficeExpensesName(), '3699');
        ContosoGLAccount.AddAccountForLocalization(InsurancesandRisksName(), '3700');
        ContosoGLAccount.AddAccountForLocalization(CorporateInsuranceName(), '3710');
        ContosoGLAccount.AddAccountForLocalization(DamagesPaidName(), '3720');
        ContosoGLAccount.AddAccountForLocalization(BadDebtLossesName(), '3730');
        ContosoGLAccount.AddAccountForLocalization(SecurityservicesName(), '3740');
        ContosoGLAccount.AddAccountForLocalization(OtherriskexpensesName(), '3750');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesandRisksName(), '3799');
        ContosoGLAccount.AddAccountForLocalization(ManagementandAdminName(), '3800');
        ContosoGLAccount.AddAccountForLocalization(ManagementName(), '3801');
        ContosoGLAccount.AddAccountForLocalization(RemunerationtoDirectorsName(), '3810');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeesName(), '3811');
        ContosoGLAccount.AddAccountForLocalization(AnnualinterrimReportsName(), '3812');
        ContosoGLAccount.AddAccountForLocalization(AnnualgeneralmeetingName(), '3813');
        ContosoGLAccount.AddAccountForLocalization(AuditandAuditServicesName(), '3814');
        ContosoGLAccount.AddAccountForLocalization(TaxadvisoryServicesName(), '3815');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementFeesName(), '3849');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementandAdminName(), '3899');
        ContosoGLAccount.AddAccountForLocalization(BankingandInterestName(), '3900');
        ContosoGLAccount.AddAccountForLocalization(BankingfeesName(), '3910');
        ContosoGLAccount.AddAccountForLocalization(PayableInvoiceRoundingName(), '3930');
        ContosoGLAccount.AddAccountForLocalization(TotalBankingandInterestName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesExpensesName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(AccountingServicesName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(ITServicesName(), '4120');
        ContosoGLAccount.AddAccountForLocalization(MediaServicesName(), '4130');
        ContosoGLAccount.AddAccountForLocalization(ConsultingServicesName(), '4140');
        ContosoGLAccount.AddAccountForLocalization(LegalFeesandAttorneyServicesName(), '4150');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalServicesName(), '4160');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesName(), '4199');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalExpensesName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(LicenseFeesRoyaltiesName(), '4210');
        ContosoGLAccount.AddAccountForLocalization(TrademarksPatentsName(), '4220');
        ContosoGLAccount.AddAccountForLocalization(AssociationFeesName(), '4230');
        ContosoGLAccount.AddAccountForLocalization(MiscexternalexpensesName(), '4240');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDiscountsName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherExternalExpensesName(), '4298');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesExpensesName(), '4299');
        ContosoGLAccount.AddAccountForLocalization(PersonnelName(), '4300');
        ContosoGLAccount.AddAccountForLocalization(WagesandSalariesName(), '4301');
        ContosoGLAccount.AddAccountForLocalization(HourlyWagesName(), '4320');
        ContosoGLAccount.AddAccountForLocalization(OvertimeWagesName(), '4330');
        ContosoGLAccount.AddAccountForLocalization(BonusesName(), '4340');
        ContosoGLAccount.AddAccountForLocalization(CommissionsPaidName(), '4350');
        ContosoGLAccount.AddAccountForLocalization(PTOAccruedName(), '4360');
        ContosoGLAccount.AddAccountForLocalization(TotalWagesandSalariesName(), '4399');
        ContosoGLAccount.AddAccountForLocalization(BenefitsPensionName(), '4400');
        ContosoGLAccount.AddAccountForLocalization(BenefitsName(), '4401');
        ContosoGLAccount.AddAccountForLocalization(TrainingCostsName(), '4410');
        ContosoGLAccount.AddAccountForLocalization(HealthCareContributionsName(), '4411');
        ContosoGLAccount.AddAccountForLocalization(EntertainmentofpersonnelName(), '4412');
        ContosoGLAccount.AddAccountForLocalization(MandatoryclothingexpensesName(), '4414');
        ContosoGLAccount.AddAccountForLocalization(OthercashremunerationbenefitsName(), '4415');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsName(), '4449');
        ContosoGLAccount.AddAccountForLocalization(PensionName(), '4450');
        ContosoGLAccount.AddAccountForLocalization(PensionfeesandrecurringcostsName(), '4460');
        ContosoGLAccount.AddAccountForLocalization(EmployerContributionsName(), '4470');
        ContosoGLAccount.AddAccountForLocalization(TotalPensionName(), '4498');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsPensionName(), '4499');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPersonnelName(), '4500');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '4510');
        ContosoGLAccount.AddAccountForLocalization(DentalInsuranceName(), '4520');
        ContosoGLAccount.AddAccountForLocalization(WorkersCompensationName(), '4530');
        ContosoGLAccount.AddAccountForLocalization(LifeInsuranceName(), '4540');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesPersonnelName(), '4599');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelName(), '4699');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '4800');
        ContosoGLAccount.AddAccountForLocalization(DepreciationLandandPropertyName(), '4810');
        ContosoGLAccount.AddAccountForLocalization(DepreciationFixedAssetsName(), '4820');
        ContosoGLAccount.AddAccountForLocalization(TotalDepreciationName(), '4899');
        ContosoGLAccount.AddAccountForLocalization(MiscExpensesName(), '4900');
        ContosoGLAccount.AddAccountForLocalization(CurrencyLossesName(), '4910');
        ContosoGLAccount.AddAccountForLocalization(TotalMiscExpensesName(), '4998');
        ContosoGLAccount.AddAccountForLocalization(TOTALEXPENSESName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(COSTOFGOODSSOLDName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(CostofGoodsName(), '5100');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsProjectsName(), '5120');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofGoodsName(), '5199');
        ContosoGLAccount.AddAccountForLocalization(CostofResourcesandServicesName(), '5200');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborName(), '5210');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborProjectsName(), '5220');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborWarrantyContractName(), '5230');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofResourcesName(), '5299');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedworkName(), '5300');
        ContosoGLAccount.AddAccountForLocalization(ManufVariancesName(), '5310');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '5311');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '5315');
        ContosoGLAccount.AddAccountForLocalization(MfgOverheadVarianceName(), '5316');
        ContosoGLAccount.AddAccountForLocalization(TotalManufVariancesName(), '5390');
        ContosoGLAccount.AddAccountForLocalization(CostofVariancesName(), '5400');
        ContosoGLAccount.AddAccountForLocalization(CostsofJobsName(), '5500');
        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '5520');
        ContosoGLAccount.AddAccountForLocalization(TotalCostsofJobsName(), '5599');
        ContosoGLAccount.AddAccountForLocalization(TOTALCOSTOFGOODSSOLDName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(IncomeName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(SalesofGoodsName(), '6100');
        ContosoGLAccount.AddAccountForLocalization(SaleofFinishedGoodsName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(SaleofRawMaterialsName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(ResaleofGoodsName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofGoodsName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(SaleofResourcesName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(SaleofSubcontractingName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofResourcesName(), '6299');
        ContosoGLAccount.AddAccountForLocalization(AdditionalRevenueName(), '6300');
        ContosoGLAccount.AddAccountForLocalization(IncomefromsecuritiesName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeeRevenueName(), '6320');
        ContosoGLAccount.AddAccountForLocalization(CurrencyGainsName(), '6340');
        ContosoGLAccount.AddAccountForLocalization(OtherIncidentalRevenueName(), '6350');
        ContosoGLAccount.AddAccountForLocalization(TotalAdditionalRevenueName(), '6399');
        ContosoGLAccount.AddAccountForLocalization(JobsandServicesName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceContractsName(), '6430');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceWorkName(), '6440');
        ContosoGLAccount.AddAccountForLocalization(TotalJobsandServicesName(), '6499');
        ContosoGLAccount.AddAccountForLocalization(RevenueReductionsName(), '6900');
        ContosoGLAccount.AddAccountForLocalization(SalesDiscountsName(), '6910');
        ContosoGLAccount.AddAccountForLocalization(SalesInvoiceRoundingName(), '6920');
        ContosoGLAccount.AddAccountForLocalization(SalesReturnsName(), '6940');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueReductionsName(), '6998');
        ContosoGLAccount.AddAccountForLocalization(TOTALINCOMEName(), '6999');

        ModifyGLAccountForW1();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CashName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CorporateTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CostofRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.CustomersForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DepreciationofFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.DividendsfortheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ElectricityandHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.EntertainmentandPRName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FeesandChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FinanceChargesfromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FinanceChargestoVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FinishedGoodsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.GainsandLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.GasolineandMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InterestonBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InterestonBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InterestonRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvoiceRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobWIPName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.JobWIPTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LandandBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LegalandAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LongtermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.LongtermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NETINCOMEBEFORETAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NetIncomefortheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherCostsofOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentDiscountsGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PhoneandFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtDiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PmtDiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.ShorttermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.Stockholder(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalCostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalCostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalCostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TOTALLIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalPersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalPersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalSalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalSalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalSalesofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalSalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VATPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VATTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorsDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.VendorsForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WIPCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WIPCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WIPSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WIPSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGlAccount.WithholdingTaxesPayableName(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroup: codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), BalanceSheetLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), AssetsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), TotalAssetsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Assets() + '..' + CreateGLAccount.TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestExpenses(), CreateGLAccount.InterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Allowances(), CreateGLAccount.AllowancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Salaries(), CreateGLAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VehicleExpenses(), CreateGLAccount.VehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(IntangibleFixedAssets(), IntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DevelopmentExpenditure(), DevelopmentExpenditureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TenancySiteLeaseholdandsimilarrights(), TenancySiteLeaseholdandsimilarrightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforIntangibleFixedAssets(), AdvancedPaymentsforIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIntangibleFixedAssets(), TotalIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleFixedAssets() + '..' + TotalIntangibleFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Building(), BuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofImprovementstoLeasedProperty(), CostofImprovementstoLeasedPropertyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Land(), LandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLandandbuilding(), TotalLandandbuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LandandBuildings() + '..' + TotalLandandbuilding(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MachineryandEquipment(), MachineryandEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquipmentsandTools(), EquipmentsandToolsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Computers(), ComputersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarsandotherTransportEquipments(), CarsandotherTransportEquipmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LeasedAssets(), LeasedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMachineryandEquipment(), TotalMachineryandEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, MachineryandEquipment() + '..' + TotalMachineryandEquipment(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciation(), AccumulatedDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTangibleAssets(), TotalTangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + TotalTangibleAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialandFixedAssets(), FinancialandFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongtermReceivables(), LongtermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ParticipationinGroupCompanies(), ParticipationinGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LoanstoPartnersorrelatedParties(), LoanstoPartnersorrelatedPartiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredTaxAssets(), DeferredTaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongtermReceivables(), OtherLongtermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialandFixedAssets(), TotalFinancialandFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialandFixedAssets() + '..' + TotalFinancialandFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoriesProductsandworkinProgress(), InventoriesProductsandworkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SuppliesandConsumables(), SuppliesandConsumablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProductsinProgress(), ProductsinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsforResale(), GoodsforResaleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforgoodsandservices(), AdvancedPaymentsforgoodsandservicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInventoryItems(), OtherInventoryItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkinProgress(), WorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedCosts(), WIPAccruedCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWorkinProgress(), TotalWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, WorkinProgress() + '..' + TotalWorkinProgress(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInventoryProductsandWorkinProgress(), TotalInventoryProductsandWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, InventoriesProductsandworkinProgress() + '..' + TotalInventoryProductsandWorkinProgress(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivables(), AccountsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableDomestic(), AccountReceivableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableForeign(), AccountReceivableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualReceivables(), ContractualReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsignmentReceivables(), ConsignmentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreditcardsandVouchersReceivables(), CreditcardsandVouchersReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccountReceivables(), TotalAccountReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsReceivables() + '..' + TotalAccountReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentReceivables(), OtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablefromEmployees(), CurrentReceivablefromEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Accruedincomenotyetinvoiced(), AccruedincomenotyetinvoicedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountsforTaxesandcharges(), ClearingAccountsforTaxesandchargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAssets(), TaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATReduced(), PurchaseVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATNormal(), PurchaseVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATReceivables(), MiscVATReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablesfromgroupcompanies(), CurrentReceivablesfromgroupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentReceivables(), TotalOtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentReceivables() + '..' + TotalOtherCurrentReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalReceivables(), TotalReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Receivables() + '..' + TotalReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidexpensesandAccruedIncome(), PrepaidexpensesandAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidRent(), PrepaidRentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidInterestexpense(), PrepaidInterestexpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedRentalIncome(), AccruedRentalIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestIncome(), AccruedInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Assetsintheformofprepaidexpenses(), AssetsintheformofprepaidexpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherprepaidexpensesandaccruedincome(), OtherprepaidexpensesandaccruedincomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPrepaidexpensesandAccruedIncome(), TotalPrepaidexpensesandAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, PrepaidexpensesandAccruedIncome() + '..' + TotalPrepaidexpensesandAccruedIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Shortterminvestments(), ShortterminvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Convertibledebtinstruments(), ConvertibledebtinstrumentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OthershorttermInvestments(), OthershorttermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WritedownofShortterminvestments(), WritedownofShortterminvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Totalshortterminvestments(), TotalshortterminvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Shortterminvestments() + '..' + Totalshortterminvestments(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashandBank(), CashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PettyCash(), PettyCashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BusinessaccountOperatingDomestic(), BusinessaccountOperatingDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessaccountOperatingForeign(), BusinessaccountOperatingForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherbankaccounts(), OtherbankaccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CertificateofDeposit(), CertificateofDepositName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCashandBank(), TotalCashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CashandBank() + '..' + TotalCashandBank(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Liability(), LiabilityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BondsandDebentureLoans(), BondsandDebentureLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertiblesLoans(), ConvertiblesLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongtermLiabilities(), OtherLongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankoverdraftFacilities(), BankoverdraftFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymtsRecptsinProcess(), PaymtsRecptsinProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLongtermLiabilities(), TotalLongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongTermLiabilities() + '..' + TotalLongtermLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilities(), CurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableDomestic(), AccountsPayableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableForeign(), AccountsPayableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancesfromcustomers(), AdvancesfromcustomersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChangeinWorkinProgress(), ChangeinWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bankoverdraftshortterm(), BankoverdraftshorttermName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredRevenue(), DeferredRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCurrentLiabilities(), TotalCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CurrentLiabilities() + '..' + TotalCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxLiabilities(), TaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxVATLiable(), SalesTaxVATLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CollectioninProcess(), CollectioninProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesLiable(), TaxesLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATReduced(), SalesVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATNormal(), SalesVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATPayables(), MiscVATPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedIncomeTax(), EstimatedIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedrealestateTaxRealestatecharge(), EstimatedrealestateTaxRealestatechargeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedPayrolltaxonPensionCosts(), EstimatedPayrolltaxonPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTaxLiabilities(), TotalTaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxLiabilities() + '..' + TotalTaxLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollLiabilities(), PayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesWithholdingTaxes(), EmployeesWithholdingTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialsecurityContributions(), StatutorySocialsecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualSocialsecurityContributions(), ContractualSocialsecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AttachmentsofEarning(), AttachmentsofEarningName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HolidayPayfund(), HolidayPayfundName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSalarywageDeductions(), OtherSalarywageDeductionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPayrollLiabilities(), TotalPayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, PayrollLiabilities() + '..' + TotalPayrollLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentLiabilities(), OtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountforFactoringCurrentPortion(), ClearingAccountforFactoringCurrentPortionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilitiestoEmployees(), CurrentLiabilitiestoEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountforthirdparty(), ClearingAccountforthirdpartyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLoans(), CurrentLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LiabilitiesGrantsReceived(), LiabilitiesGrantsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentLiabilities(), TotalOtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentLiabilities() + '..' + TotalOtherCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedExpensesandDeferredIncome(), AccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accruedwagessalaries(), AccruedwagessalariesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentsinProcess(), PaymentsinProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedHolidaypay(), AccruedHolidaypayName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedPensioncosts(), AccruedPensioncostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestExpense(), AccruedInterestExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredIncome(), DeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedContractualcosts(), AccruedContractualcostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAccruedExpensesandDeferredIncome(), OtherAccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccruedExpensesandDeferredIncome(), TotalAccruedExpensesandDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccruedExpensesandDeferredIncome() + '..' + TotalAccruedExpensesandDeferredIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquityPartner(), EquityPartnerName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetResults(), NetResultsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RestrictedEquity(), RestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShareCapital(), ShareCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonRestrictedEquity(), NonRestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Profitorlossfromthepreviousyear(), ProfitorlossfromthepreviousyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResultsfortheFinancialyear(), ResultsfortheFinancialyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DistributionstoShareholders(), DistributionstoShareholdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEquity(), TotalEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, Equity() + '..' + TotalEquity(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EXPENSES(), EXPENSESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FacilityExpenses(), FacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalFacilities(), RentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentLeases(), RentLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityforRental(), ElectricityforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingforRental(), HeatingforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterandSewerageforRental(), WaterandSewerageforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningandWasteforRental(), CleaningandWasteforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceforRental(), RepairsandMaintenanceforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesRental(), InsurancesRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRentalExpenses(), OtherRentalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRentalFacilities(), TotalRentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, RentalFacilities() + '..' + TotalRentalFacilities(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyExpenses(), PropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SiteFeesLeases(), SiteFeesLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityforProperty(), ElectricityforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingforProperty(), HeatingforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterandSewerageforProperty(), WaterandSewerageforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningandWasteforProperty(), CleaningandWasteforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceforProperty(), RepairsandMaintenanceforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesProperty(), InsurancesPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPropertyExpenses(), OtherPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPropertyExpenses(), TotalPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PropertyExpenses() + '..' + TotalPropertyExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFacilityExpenses(), TotalFacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FacilityExpenses() + '..' + TotalFacilityExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsLeases(), FixedAssetsLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofmachinery(), HireofmachineryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofcomputers(), HireofcomputersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofotherfixedassets(), HireofotherfixedassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssetLeases(), TotalFixedAssetLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FixedAssetsLeases() + '..' + TotalFixedAssetLeases(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LogisticsExpenses(), LogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PassengerCarCosts(), PassengerCarCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TruckCosts(), TruckCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othervehicleexpenses(), OthervehicleexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVehicleExpenses(), TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + TotalVehicleExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightCosts(), FreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Freightfeesforgoods(), FreightfeesforgoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Customsandforwarding(), CustomsandforwardingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Freightfeesprojects(), FreightfeesprojectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFreightCosts(), TotalFreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FreightCosts() + '..' + TotalFreightCosts(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpenses(), TravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tickets(), TicketsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rentalvehicles(), RentalvehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Boardandlodging(), BoardandlodgingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othertravelexpenses(), OthertravelexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTravelExpenses(), TotalTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, TravelExpenses() + '..' + TotalTravelExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLogisticsExpenses(), TotalLogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, LogisticsExpenses() + '..' + TotalLogisticsExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MarketingandSales(), MarketingandSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisementDevelopment(), AdvertisementDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutdoorandTransportationAds(), OutdoorandTransportationAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Admatteranddirectmailings(), AdmatteranddirectmailingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConferenceExhibitionSponsorship(), ConferenceExhibitionSponsorshipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Samplescontestsgifts(), SamplescontestsgiftsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FilmTVradiointernetads(), FilmTVradiointernetadsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PRandAgencyFees(), PRandAgencyFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otheradvertisingfees(), OtheradvertisingfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvertising(), TotalAdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Advertising() + '..' + TotalAdvertising(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherMarketingExpenses(), OtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Catalogspricelists(), CatalogspricelistsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradePublications(), TradePublicationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherMarketingExpenses(), TotalOtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherMarketingExpenses() + '..' + TotalOtherMarketingExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesExpenses(), SalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreditCardCharges(), CreditCardChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingdeductible(), BusinessEntertainingdeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingnondeductible(), BusinessEntertainingnondeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesExpenses(), TotalSalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesExpenses() + '..' + TotalSalesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMarketingandSales(), TotalMarketingandSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MarketingandSales() + '..' + TotalMarketingandSales(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeExpenses(), OfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneServices(), PhoneServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Dataservices(), DataservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Postalfees(), PostalfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumableExpensiblehardware(), ConsumableExpensiblehardwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Softwareandsubscriptionfees(), SoftwareandsubscriptionfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOfficeExpenses(), TotalOfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OfficeExpenses() + '..' + TotalOfficeExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesandRisks(), InsurancesandRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateInsurance(), CorporateInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DamagesPaid(), DamagesPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BadDebtLosses(), BadDebtLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Securityservices(), SecurityservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Otherriskexpenses(), OtherriskexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesandRisks(), TotalInsurancesandRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesandRisks() + '..' + TotalInsurancesandRisks(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementandAdmin(), ManagementandAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Management(), ManagementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RemunerationtoDirectors(), RemunerationtoDirectorsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFees(), ManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualinterrimReports(), AnnualinterrimReportsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Annualgeneralmeeting(), AnnualgeneralmeetingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AuditandAuditServices(), AuditandAuditServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxadvisoryServices(), TaxadvisoryServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementFees(), TotalManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Management() + '..' + TotalManagementFees(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementandAdmin(), TotalManagementandAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ManagementandAdmin() + '..' + TotalManagementandAdmin(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankingandInterest(), BankingandInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Bankingfees(), BankingfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayableInvoiceRounding(), PayableInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBankingandInterest(), TotalBankingandInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BankingandInterest() + '..' + TotalBankingandInterest(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServicesExpenses(), ExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServices(), ExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountingServices(), AccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ITServices(), ITServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MediaServices(), MediaServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingServices(), ConsultingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalFeesandAttorneyServices(), LegalFeesandAttorneyServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalServices(), OtherExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServices(), TotalExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServices() + '..' + TotalExternalServices(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalExpenses(), OtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LicenseFeesRoyalties(), LicenseFeesRoyaltiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TrademarksPatents(), TrademarksPatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssociationFees(), AssociationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Miscexternalexpenses(), MiscexternalexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseDiscounts(), PurchaseDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherExternalExpenses(), TotalOtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherExternalExpenses() + '..' + TotalOtherExternalExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServicesExpenses(), TotalExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServicesExpenses() + '..' + TotalExternalServicesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Personnel(), PersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesandSalaries(), WagesandSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HourlyWages(), HourlyWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OvertimeWages(), OvertimeWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bonuses(), BonusesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommissionsPaid(), CommissionsPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PTOAccrued(), PTOAccruedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWagesandSalaries(), TotalWagesandSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, WagesandSalaries() + '..' + TotalWagesandSalaries(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BenefitsPension(), BenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Benefits(), BenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TrainingCosts(), TrainingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthCareContributions(), HealthCareContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Entertainmentofpersonnel(), EntertainmentofpersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Mandatoryclothingexpenses(), MandatoryclothingexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othercashremunerationbenefits(), OthercashremunerationbenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefits(), TotalBenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Benefits() + '..' + TotalBenefits(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Pension(), PensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionfeesandrecurringcosts(), PensionfeesandrecurringcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployerContributions(), EmployerContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPension(), TotalPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Pension() + '..' + TotalPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefitsPension(), TotalBenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BenefitsPension() + '..' + TotalBenefitsPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesPersonnel(), InsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DentalInsurance(), DentalInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkersCompensation(), WorkersCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LifeInsurance(), LifeInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesPersonnel(), TotalInsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesPersonnel() + '..' + TotalInsurancesPersonnel(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnel(), TotalPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Personnel() + '..' + TotalPersonnel(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationLandandProperty(), DepreciationLandandPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationFixedAssets(), DepreciationFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalDepreciation(), TotalDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciation() + '..' + TotalDepreciation(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MiscExpenses(), MiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyLosses(), CurrencyLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMiscExpenses(), TotalMiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MiscExpenses() + '..' + TotalMiscExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALEXPENSES(), TOTALEXPENSESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, EXPENSES() + '..' + TOTALEXPENSES(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COSTOFGOODSSOLD(), COSTOFGOODSSOLDName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofGoods(), CostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterials(), CostofMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterialsProjects(), CostofMaterialsProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofGoods(), TotalCostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofGoods() + '..' + TotalCostofGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofResourcesandServices(), CostofResourcesandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLabor(), CostofLaborName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborProjects(), CostofLaborProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborWarrantyContract(), CostofLaborWarrantyContractName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofResources(), TotalCostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofResourcesandServices() + '..' + TotalCostofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Subcontractedwork(), SubcontractedworkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManufVariances(), ManufVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MfgOverheadVariance(), MfgOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManufVariances(), TotalManufVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, ManufVariances() + '..' + TotalManufVariances(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofVariances(), CostofVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostsofJobs(), CostsofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostsofJobs(), TotalCostsofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostsofJobs() + '..' + TotalCostsofJobs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALCOSTOFGOODSSOLD(), TOTALCOSTOFGOODSSOLDName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, COSTOFGOODSSOLD() + '..' + TOTALCOSTOFGOODSSOLD(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Income(), IncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofGoods(), SalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofFinishedGoods(), SaleofFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofRawMaterials(), SaleofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleofGoods(), ResaleofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofGoods(), TotalSalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofGoods() + '..' + TotalSalesofGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofResources(), SaleofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofSubcontracting(), SaleofSubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofResources(), TotalSalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofResources() + '..' + TotalSalesofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdditionalRevenue(), AdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Incomefromsecurities(), IncomefromsecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFeeRevenue(), ManagementFeeRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyGains(), CurrencyGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherIncidentalRevenue(), OtherIncidentalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdditionalRevenue(), TotalAdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, AdditionalRevenue() + '..' + TotalAdditionalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobsandServices(), JobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceContracts(), SalesofServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceWork(), SalesofServiceWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalJobsandServices(), TotalJobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, JobsandServices() + '..' + TotalJobsandServices(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueReductions(), RevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesDiscounts(), SalesDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesInvoiceRounding(), SalesInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesReturns(), SalesReturnsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenueReductions(), TotalRevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, RevenueReductions() + '..' + TotalRevenueReductions(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALINCOME(), TOTALINCOMEName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Income() + '..' + TOTALINCOME(), Enum::"General Posting Type"::" ", '', '', false, false, false);
    end;

    procedure AddCategoriesToGLAccountsForMini()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToChartOfAccountsForMini(GLAccountCategory);
            until GLAccountCategory.Next() = 0;

        GLAccountCategory.SetFilter("Parent Entry No.", '<>%1', 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignSubcategoryToChartOfAccountsForMini(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    local procedure AssignCategoryToChartOfAccountsForMini(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), CreateGLAccount.TotalAssets());
            GLAccountCategory."Account Category"::Liabilities:
                begin
                    UpdateGLAccounts(GLAccountCategory, Liability(), '1179');
                    UpdateGLAccounts(GLAccountCategory, '1181', '1311');
                    UpdateGLAccounts(GLAccountCategory, '1313', '1611');
                    UpdateGLAccounts(GLAccountCategory, '1613', CreateGLAccount.TotalLiabilities());
                end;
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, Equity(), TotalEquity());
            GLAccountCategory."Account Category"::Income:
                UpdateGLAccounts(GLAccountCategory, Income(), TOTALINCOME());
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, COSTOFGOODSSOLD(), TOTALCOSTOFGOODSSOLD());
            GLAccountCategory."Account Category"::Expense:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.INCOMESTATEMENT(), TOTALEXPENSES());
        end;
    end;

    local procedure AssignSubcategoryToChartOfAccountsForMini(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, PettyCash(), CertificateofDeposit());
            GLAccountCategoryMgt.GetPrepaidExpenses():
                UpdateGLAccounts(GLAccountCategory, PrepaidRent(), Otherprepaidexpensesandaccruedincome());
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, InventoriesProductsandworkinProgress(), TotalInventoryProductsandWorkinProgress());
            GLAccountCategoryMgt.GetEquipment():
                UpdateGLAccounts(GLAccountCategory, EquipmentsandTools(), TotalMachineryandEquipment());
            GLAccountCategoryMgt.GetAccumDeprec():
                UpdateGLAccounts(GLAccountCategory, AccumulatedDepreciation(), AccumulatedDepreciation());
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, AccountsPayableDomestic(), '1311');
                    UpdateGLAccounts(GLAccountCategory, '1313', LiabilitiesGrantsReceived());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, EmployeesWithholdingTaxes(), OtherSalarywageDeductions());
            GLAccountCategoryMgt.GetDistrToShareholders():
                UpdateGLAccounts(GLAccountCategory, DistributionstoShareholders(), DistributionstoShareholders());
            GLAccountCategoryMgt.GetIncomeService():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesofResources(), TotalSalesofResources());
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, SalesofGoods(), TotalSalesofGoods());
            GLAccountCategoryMgt.GetCOGSLabor():
                UpdateGLAccounts(GLAccountCategory, CostofResourcesandServices(), TotalCostofResources());
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, CostofGoods(), TotalCostofGoods());
            GLAccountCategoryMgt.GetRentExpense():
                UpdateGLAccounts(GLAccountCategory, RentLeases(), RentLeases());
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Advertising(), TotalOtherMarketingExpenses());
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
            GLAccountCategoryMgt.GetFeesExpense():
                UpdateGLAccounts(GLAccountCategory, Bankingfees(), CreateGLAccount.InterestExpenses());
            GLAccountCategoryMgt.GetBadDebtExpense():
                UpdateGLAccounts(GLAccountCategory, BadDebtLosses(), BadDebtLosses());
            GLAccountCategoryMgt.GetInsuranceExpense():
                UpdateGLAccounts(GLAccountCategory, InsurancesPersonnel(), TotalInsurancesPersonnel());
            GLAccountCategoryMgt.GetBenefitsExpense():
                UpdateGLAccounts(GLAccountCategory, BenefitsPension(), TotalBenefitsPension());
            GLAccountCategoryMgt.GetRepairsExpense():
                UpdateGLAccounts(GLAccountCategory, RepairsandMaintenanceforRental(), RepairsandMaintenanceforRental());
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, ElectricityforRental(), CleaningandWasteforRental());
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

    procedure IntangibleFixedAssetsName(): Text[100]
    begin
        exit(IntangibleFixedAssetsLbl);
    end;

    procedure DevelopmentExpenditureName(): Text[100]
    begin
        exit(DevelopmentExpenditureLbl);
    end;

    procedure TenancySiteLeaseholdandsimilarrightsName(): Text[100]
    begin
        exit(TenancySiteLeaseholdandsimilarrightsLbl);
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssetsName(): Text[100]
    begin
        exit(AdvancedPaymentsforIntangibleFixedAssetsLbl);
    end;

    procedure TotalIntangibleFixedAssetsName(): Text[100]
    begin
        exit(TotalIntangibleFixedAssetsLbl);
    end;

    procedure BuildingName(): Text[100]
    begin
        exit(BuildingLbl);
    end;

    procedure CostofImprovementstoLeasedPropertyName(): Text[100]
    begin
        exit(CostofImprovementstoLeasedPropertyLbl);
    end;

    procedure LandName(): Text[100]
    begin
        exit(LandLbl);
    end;

    procedure TotalLandandbuildingName(): Text[100]
    begin
        exit(TotalLandandbuildingLbl);
    end;

    procedure MachineryandEquipmentName(): Text[100]
    begin
        exit(MachineryandEquipmentLbl);
    end;

    procedure EquipmentsandToolsName(): Text[100]
    begin
        exit(EquipmentsandToolsLbl);
    end;

    procedure ComputersName(): Text[100]
    begin
        exit(ComputersLbl);
    end;

    procedure CarsandotherTransportEquipmentsName(): Text[100]
    begin
        exit(CarsandotherTransportEquipmentsLbl);
    end;

    procedure LeasedAssetsName(): Text[100]
    begin
        exit(LeasedAssetsLbl);
    end;

    procedure TotalMachineryandEquipmentName(): Text[100]
    begin
        exit(TotalMachineryandEquipmentLbl);
    end;

    procedure AccumulatedDepreciationName(): Text[100]
    begin
        exit(AccumulatedDepreciationLbl);
    end;

    procedure TotalTangibleAssetsName(): Text[100]
    begin
        exit(TotalTangibleAssetsLbl);
    end;

    procedure FinancialandFixedAssetsName(): Text[100]
    begin
        exit(FinancialandFixedAssetsLbl);
    end;

    procedure LongtermReceivablesName(): Text[100]
    begin
        exit(LongtermReceivablesLbl);
    end;

    procedure ParticipationinGroupCompaniesName(): Text[100]
    begin
        exit(ParticipationinGroupCompaniesLbl);
    end;

    procedure LoanstoPartnersorrelatedPartiesName(): Text[100]
    begin
        exit(LoanstoPartnersorrelatedPartiesLbl);
    end;

    procedure DeferredTaxAssetsName(): Text[100]
    begin
        exit(DeferredTaxAssetsLbl);
    end;

    procedure OtherLongtermReceivablesName(): Text[100]
    begin
        exit(OtherLongtermReceivablesLbl);
    end;

    procedure TotalFinancialandFixedAssetsName(): Text[100]
    begin
        exit(TotalFinancialandFixedAssetsLbl);
    end;

    procedure InventoriesProductsandworkinProgressName(): Text[100]
    begin
        exit(InventoriesProductsandworkinProgressLbl);
    end;

    procedure SuppliesandConsumablesName(): Text[100]
    begin
        exit(SuppliesandConsumablesLbl);
    end;

    procedure ProductsinProgressName(): Text[100]
    begin
        exit(ProductsinProgressLbl);
    end;

    procedure GoodsforResaleName(): Text[100]
    begin
        exit(GoodsforResaleLbl);
    end;

    procedure AdvancedPaymentsforgoodsandservicesName(): Text[100]
    begin
        exit(AdvancedPaymentsforgoodsandservicesLbl);
    end;

    procedure OtherInventoryItemsName(): Text[100]
    begin
        exit(OtherInventoryItemsLbl);
    end;

    procedure WorkinProgressName(): Text[100]
    begin
        exit(WorkinProgressLbl);
    end;

    procedure WIPAccruedCostsName(): Text[100]
    begin
        exit(WIPAccruedCostsLbl);
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesLbl);
    end;

    procedure TotalWorkinProgressName(): Text[100]
    begin
        exit(TotalWorkinProgressLbl);
    end;

    procedure TotalInventoryProductsandWorkinProgressName(): Text[100]
    begin
        exit(TotalInventoryProductsandWorkinProgressLbl);
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesLbl);
    end;

    procedure AccountsReceivablesName(): Text[100]
    begin
        exit(AccountsReceivablesLbl);
    end;

    procedure AccountReceivableDomesticName(): Text[100]
    begin
        exit(AccountReceivableDomesticLbl);
    end;

    procedure AccountReceivableForeignName(): Text[100]
    begin
        exit(AccountReceivableForeignLbl);
    end;

    procedure ContractualReceivablesName(): Text[100]
    begin
        exit(ContractualReceivablesLbl);
    end;

    procedure ConsignmentReceivablesName(): Text[100]
    begin
        exit(ConsignmentReceivablesLbl);
    end;

    procedure CreditcardsandVouchersReceivablesName(): Text[100]
    begin
        exit(CreditcardsandVouchersReceivablesLbl);
    end;

    procedure TotalAccountReceivablesName(): Text[100]
    begin
        exit(TotalAccountReceivablesLbl);
    end;

    procedure OtherCurrentReceivablesName(): Text[100]
    begin
        exit(OtherCurrentReceivablesLbl);
    end;

    procedure CurrentReceivablefromEmployeesName(): Text[100]
    begin
        exit(CurrentReceivablefromEmployeesLbl);
    end;

    procedure AccruedincomenotyetinvoicedName(): Text[100]
    begin
        exit(AccruedincomenotyetinvoicedLbl);
    end;

    procedure ClearingAccountsforTaxesandchargesName(): Text[100]
    begin
        exit(ClearingAccountsforTaxesandchargesLbl);
    end;

    procedure TaxAssetsName(): Text[100]
    begin
        exit(TaxAssetsLbl);
    end;

    procedure PurchaseVATReducedName(): Text[100]
    begin
        exit(PurchaseVATReducedLbl);
    end;

    procedure PurchaseVATNormalName(): Text[100]
    begin
        exit(PurchaseVATNormalLbl);
    end;

    procedure MiscVATReceivablesName(): Text[100]
    begin
        exit(MiscVATReceivablesLbl);
    end;

    procedure CurrentReceivablesfromgroupcompaniesName(): Text[100]
    begin
        exit(CurrentReceivablesfromgroupcompaniesLbl);
    end;

    procedure TotalOtherCurrentReceivablesName(): Text[100]
    begin
        exit(TotalOtherCurrentReceivablesLbl);
    end;

    procedure TotalReceivablesName(): Text[100]
    begin
        exit(TotalReceivablesLbl);
    end;

    procedure PrepaidexpensesandAccruedIncomeName(): Text[100]
    begin
        exit(PrepaidexpensesandAccruedIncomeLbl);
    end;

    procedure PrepaidRentName(): Text[100]
    begin
        exit(PrepaidRentLbl);
    end;

    procedure PrepaidInterestexpenseName(): Text[100]
    begin
        exit(PrepaidInterestexpenseLbl);
    end;

    procedure AccruedRentalIncomeName(): Text[100]
    begin
        exit(AccruedRentalIncomeLbl);
    end;

    procedure AccruedInterestIncomeName(): Text[100]
    begin
        exit(AccruedInterestIncomeLbl);
    end;

    procedure AssetsintheformofprepaidexpensesName(): Text[100]
    begin
        exit(AssetsintheformofprepaidexpensesLbl);
    end;

    procedure OtherprepaidexpensesandaccruedincomeName(): Text[100]
    begin
        exit(OtherprepaidexpensesandaccruedincomeLbl);
    end;

    procedure TotalPrepaidexpensesandAccruedIncomeName(): Text[100]
    begin
        exit(TotalPrepaidexpensesandAccruedIncomeLbl);
    end;

    procedure ShortterminvestmentsName(): Text[100]
    begin
        exit(ShortterminvestmentsLbl);
    end;

    procedure ConvertibledebtinstrumentsName(): Text[100]
    begin
        exit(ConvertibledebtinstrumentsLbl);
    end;

    procedure OthershorttermInvestmentsName(): Text[100]
    begin
        exit(OthershorttermInvestmentsLbl);
    end;

    procedure WritedownofShortterminvestmentsName(): Text[100]
    begin
        exit(WritedownofShortterminvestmentsLbl);
    end;

    procedure TotalshortterminvestmentsName(): Text[100]
    begin
        exit(TotalshortterminvestmentsLbl);
    end;

    procedure CashandBankName(): Text[100]
    begin
        exit(CashandBankLbl);
    end;

    procedure PettyCashName(): Text[100]
    begin
        exit(PettyCashLbl);
    end;

    procedure BusinessaccountOperatingDomesticName(): Text[100]
    begin
        exit(BusinessaccountOperatingDomesticLbl);
    end;

    procedure BusinessaccountOperatingForeignName(): Text[100]
    begin
        exit(BusinessaccountOperatingForeignLbl);
    end;

    procedure OtherbankaccountsName(): Text[100]
    begin
        exit(OtherbankaccountsLbl);
    end;

    procedure CertificateofDepositName(): Text[100]
    begin
        exit(CertificateofDepositLbl);
    end;

    procedure TotalCashandBankName(): Text[100]
    begin
        exit(TotalCashandBankLbl);
    end;

    procedure LiabilityName(): Text[100]
    begin
        exit(LiabilityLbl);
    end;

    procedure BondsandDebentureLoansName(): Text[100]
    begin
        exit(BondsandDebentureLoansLbl);
    end;

    procedure ConvertiblesLoansName(): Text[100]
    begin
        exit(ConvertiblesLoansLbl);
    end;

    procedure OtherLongtermLiabilitiesName(): Text[100]
    begin
        exit(OtherLongTermLiabilitiesLbl);
    end;

    procedure BankoverdraftFacilitiesName(): Text[100]
    begin
        exit(BankoverdraftFacilitiesLbl);
    end;

    procedure PaymtsRecptsinProcessName(): Text[100]
    begin
        exit(PaymtsRecptsinProcessLbl);
    end;

    procedure TotalLongtermLiabilitiesName(): Text[100]
    begin
        exit(TotalLongtermLiabilitiesLbl);
    end;

    procedure CurrentLiabilitiesName(): Text[100]
    begin
        exit(CurrentLiabilitiesLbl);
    end;

    procedure AccountsPayableDomesticName(): Text[100]
    begin
        exit(AccountsPayableDomesticLbl);
    end;

    procedure AccountsPayableForeignName(): Text[100]
    begin
        exit(AccountsPayableForeignLbl);
    end;

    procedure AdvancesfromcustomersName(): Text[100]
    begin
        exit(AdvancesfromcustomersLbl);
    end;

    procedure ChangeinWorkinProgressName(): Text[100]
    begin
        exit(ChangeinWorkinProgressLbl);
    end;

    procedure BankoverdraftshorttermName(): Text[100]
    begin
        exit(BankoverdraftshorttermLbl);
    end;

    procedure DeferredRevenueName(): Text[100]
    begin
        exit(DeferredRevenueLbl);
    end;

    procedure TotalCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalCurrentLiabilitiesLbl);
    end;

    procedure TaxLiabilitiesName(): Text[100]
    begin
        exit(TaxLiabilitiesLbl);
    end;

    procedure SalesTaxVATLiableName(): Text[100]
    begin
        exit(SalesTaxVATLiableLbl);
    end;

    procedure CollectioninProcessName(): Text[100]
    begin
        exit(CollectioninProcessLbl);
    end;

    procedure TaxesLiableName(): Text[100]
    begin
        exit(TaxesLiableLbl);
    end;

    procedure SalesVATReducedName(): Text[100]
    begin
        exit(SalesVATReducedLbl);
    end;

    procedure SalesVATNormalName(): Text[100]
    begin
        exit(SalesVATNormalLbl);
    end;

    procedure MiscVATPayablesName(): Text[100]
    begin
        exit(MiscVATPayablesLbl);
    end;

    procedure EstimatedIncomeTaxName(): Text[100]
    begin
        exit(EstimatedIncomeTaxLbl);
    end;

    procedure EstimatedrealestateTaxRealestatechargeName(): Text[100]
    begin
        exit(EstimatedrealestateTaxRealestatechargeLbl);
    end;

    procedure EstimatedPayrolltaxonPensionCostsName(): Text[100]
    begin
        exit(EstimatedPayrolltaxonPensionCostsLbl);
    end;

    procedure TotalTaxLiabilitiesName(): Text[100]
    begin
        exit(TotalTaxLiabilitiesLbl);
    end;

    procedure PayrollLiabilitiesName(): Text[100]
    begin
        exit(PayrollLiabilitiesLbl);
    end;

    procedure EmployeesWithholdingTaxesName(): Text[100]
    begin
        exit(EmployeesWithholdingTaxesLbl);
    end;

    procedure StatutorySocialsecurityContributionsName(): Text[100]
    begin
        exit(StatutorySocialsecurityContributionsLbl);
    end;

    procedure ContractualSocialsecurityContributionsName(): Text[100]
    begin
        exit(ContractualSocialsecurityContributionsLbl);
    end;

    procedure AttachmentsofEarningName(): Text[100]
    begin
        exit(AttachmentsofEarningLbl);
    end;

    procedure HolidayPayfundName(): Text[100]
    begin
        exit(HolidayPayfundLbl);
    end;

    procedure OtherSalarywageDeductionsName(): Text[100]
    begin
        exit(OtherSalarywageDeductionsLbl);
    end;

    procedure TotalPayrollLiabilitiesName(): Text[100]
    begin
        exit(TotalPayrollLiabilitiesLbl);
    end;

    procedure OtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(OtherCurrentLiabilitiesLbl);
    end;

    procedure ClearingAccountforFactoringCurrentPortionName(): Text[100]
    begin
        exit(ClearingAccountforFactoringCurrentPortionLbl);
    end;

    procedure CurrentLiabilitiestoEmployeesName(): Text[100]
    begin
        exit(CurrentLiabilitiestoEmployeesLbl);
    end;

    procedure ClearingAccountforthirdpartyName(): Text[100]
    begin
        exit(ClearingAccountforthirdpartyLbl);
    end;

    procedure CurrentLoansName(): Text[100]
    begin
        exit(CurrentLoansLbl);
    end;

    procedure LiabilitiesGrantsReceivedName(): Text[100]
    begin
        exit(LiabilitiesGrantsReceivedLbl);
    end;

    procedure TotalOtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalOtherCurrentLiabilitiesLbl);
    end;

    procedure AccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(AccruedExpensesandDeferredIncomeLbl);
    end;

    procedure AccruedwagessalariesName(): Text[100]
    begin
        exit(AccruedwagessalariesLbl);
    end;

    procedure PaymentsinProcessName(): Text[100]
    begin
        exit(PaymentsinProcessLbl);
    end;

    procedure AccruedHolidaypayName(): Text[100]
    begin
        exit(AccruedHolidaypayLbl);
    end;

    procedure AccruedPensioncostsName(): Text[100]
    begin
        exit(AccruedPensioncostsLbl);
    end;

    procedure AccruedInterestExpenseName(): Text[100]
    begin
        exit(AccruedInterestExpenseLbl);
    end;

    procedure DeferredIncomeName(): Text[100]
    begin
        exit(DeferredIncomeLbl);
    end;

    procedure AccruedContractualcostsName(): Text[100]
    begin
        exit(AccruedContractualcostsLbl);
    end;

    procedure OtherAccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(OtherAccruedExpensesandDeferredIncomeLbl);
    end;

    procedure TotalAccruedExpensesandDeferredIncomeName(): Text[100]
    begin
        exit(TotalAccruedExpensesandDeferredIncomeLbl);
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityLbl);
    end;

    procedure EquityPartnerName(): Text[100]
    begin
        exit(EquityPartnerLbl);
    end;

    procedure NetResultsName(): Text[100]
    begin
        exit(NetResultsLbl);
    end;

    procedure RestrictedEquityName(): Text[100]
    begin
        exit(RestrictedEquityLbl);
    end;

    procedure ShareCapitalName(): Text[100]
    begin
        exit(ShareCapitalLbl);
    end;

    procedure NonRestrictedEquityName(): Text[100]
    begin
        exit(NonRestrictedEquityLbl);
    end;

    procedure ProfitorlossfromthepreviousyearName(): Text[100]
    begin
        exit(ProfitorlossfromthepreviousyearLbl);
    end;

    procedure ResultsfortheFinancialyearName(): Text[100]
    begin
        exit(ResultsfortheFinancialyearLbl);
    end;

    procedure DistributionstoShareholdersName(): Text[100]
    begin
        exit(DistributionstoShareholdersLbl);
    end;

    procedure TotalEquityName(): Text[100]
    begin
        exit(TotalEquityLbl);
    end;

    procedure EXPENSESName(): Text[100]
    begin
        exit(EXPENSESLbl);
    end;

    procedure FacilityExpensesName(): Text[100]
    begin
        exit(FacilityExpensesLbl);
    end;

    procedure RentalFacilitiesName(): Text[100]
    begin
        exit(RentalFacilitiesLbl);
    end;

    procedure RentLeasesName(): Text[100]
    begin
        exit(RentLeasesLbl);
    end;

    procedure ElectricityforRentalName(): Text[100]
    begin
        exit(ElectricityforRentalLbl);
    end;

    procedure HeatingforRentalName(): Text[100]
    begin
        exit(HeatingforRentalLbl);
    end;

    procedure WaterandSewerageforRentalName(): Text[100]
    begin
        exit(WaterandSewerageforRentalLbl);
    end;

    procedure CleaningandWasteforRentalName(): Text[100]
    begin
        exit(CleaningandWasteforRentalLbl);
    end;

    procedure RepairsandMaintenanceforRentalName(): Text[100]
    begin
        exit(RepairsandMaintenanceforRentalLbl);
    end;

    procedure InsurancesRentalName(): Text[100]
    begin
        exit(InsurancesRentalLbl);
    end;

    procedure OtherRentalExpensesName(): Text[100]
    begin
        exit(OtherRentalExpensesLbl);
    end;

    procedure TotalRentalFacilitiesName(): Text[100]
    begin
        exit(TotalRentalFacilitiesLbl);
    end;

    procedure PropertyExpensesName(): Text[100]
    begin
        exit(PropertyExpensesLbl);
    end;

    procedure SiteFeesLeasesName(): Text[100]
    begin
        exit(SiteFeesLeasesLbl);
    end;

    procedure ElectricityforPropertyName(): Text[100]
    begin
        exit(ElectricityforPropertyLbl);
    end;

    procedure HeatingforPropertyName(): Text[100]
    begin
        exit(HeatingforPropertyLbl);
    end;

    procedure WaterandSewerageforPropertyName(): Text[100]
    begin
        exit(WaterandSewerageforPropertyLbl);
    end;

    procedure CleaningandWasteforPropertyName(): Text[100]
    begin
        exit(CleaningandWasteforPropertyLbl);
    end;

    procedure RepairsandMaintenanceforPropertyName(): Text[100]
    begin
        exit(RepairsandMaintenanceforPropertyLbl);
    end;

    procedure InsurancesPropertyName(): Text[100]
    begin
        exit(InsurancesPropertyLbl);
    end;

    procedure OtherPropertyExpensesName(): Text[100]
    begin
        exit(OtherPropertyExpensesLbl);
    end;

    procedure TotalPropertyExpensesName(): Text[100]
    begin
        exit(TotalPropertyExpensesLbl);
    end;

    procedure TotalFacilityExpensesName(): Text[100]
    begin
        exit(TotalFacilityExpensesLbl);
    end;

    procedure FixedAssetsLeasesName(): Text[100]
    begin
        exit(FixedAssetsLeasesLbl);
    end;

    procedure HireofmachineryName(): Text[100]
    begin
        exit(HireofmachineryLbl);
    end;

    procedure HireofcomputersName(): Text[100]
    begin
        exit(HireofcomputersLbl);
    end;

    procedure HireofotherfixedassetsName(): Text[100]
    begin
        exit(HireofotherfixedassetsLbl);
    end;

    procedure TotalFixedAssetLeasesName(): Text[100]
    begin
        exit(TotalFixedAssetLeasesLbl);
    end;

    procedure LogisticsExpensesName(): Text[100]
    begin
        exit(LogisticsExpensesLbl);
    end;

    procedure PassengerCarCostsName(): Text[100]
    begin
        exit(PassengerCarCostsLbl);
    end;

    procedure TruckCostsName(): Text[100]
    begin
        exit(TruckCostsLbl);
    end;

    procedure OthervehicleexpensesName(): Text[100]
    begin
        exit(OthervehicleexpensesLbl);
    end;

    procedure TotalVehicleExpensesName(): Text[100]
    begin
        exit(TotalVehicleExpensesLbl);
    end;

    procedure FreightCostsName(): Text[100]
    begin
        exit(FreightCostsLbl);
    end;

    procedure FreightfeesforgoodsName(): Text[100]
    begin
        exit(FreightfeesforgoodsLbl);
    end;

    procedure CustomsandforwardingName(): Text[100]
    begin
        exit(CustomsandforwardingLbl);
    end;

    procedure FreightfeesprojectsName(): Text[100]
    begin
        exit(FreightfeesprojectsLbl);
    end;

    procedure TotalFreightCostsName(): Text[100]
    begin
        exit(TotalFreightCostsLbl);
    end;

    procedure TravelExpensesName(): Text[100]
    begin
        exit(TravelExpensesLbl);
    end;

    procedure TicketsName(): Text[100]
    begin
        exit(TicketsLbl);
    end;

    procedure RentalvehiclesName(): Text[100]
    begin
        exit(RentalvehiclesLbl);
    end;

    procedure BoardandlodgingName(): Text[100]
    begin
        exit(BoardandlodgingLbl);
    end;

    procedure OthertravelexpensesName(): Text[100]
    begin
        exit(OthertravelexpensesLbl);
    end;

    procedure TotalTravelExpensesName(): Text[100]
    begin
        exit(TotalTravelExpensesLbl);
    end;

    procedure TotalLogisticsExpensesName(): Text[100]
    begin
        exit(TotalLogisticsExpensesLbl);
    end;

    procedure MarketingandSalesName(): Text[100]
    begin
        exit(MarketingandSalesLbl);
    end;

    procedure AdvertisementDevelopmentName(): Text[100]
    begin
        exit(AdvertisementDevelopmentLbl);
    end;

    procedure OutdoorandTransportationAdsName(): Text[100]
    begin
        exit(OutdoorandTransportationAdsLbl);
    end;

    procedure AdmatteranddirectmailingsName(): Text[100]
    begin
        exit(AdmatteranddirectmailingsLbl);
    end;

    procedure ConferenceExhibitionSponsorshipName(): Text[100]
    begin
        exit(ConferenceExhibitionSponsorshipLbl);
    end;

    procedure SamplescontestsgiftsName(): Text[100]
    begin
        exit(SamplescontestsgiftsLbl);
    end;

    procedure FilmTVradiointernetadsName(): Text[100]
    begin
        exit(FilmTVradiointernetadsLbl);
    end;

    procedure PRandAgencyFeesName(): Text[100]
    begin
        exit(PRandAgencyFeesLbl);
    end;

    procedure OtheradvertisingfeesName(): Text[100]
    begin
        exit(OtheradvertisingfeesLbl);
    end;

    procedure TotalAdvertisingName(): Text[100]
    begin
        exit(TotalAdvertisingLbl);
    end;

    procedure OtherMarketingExpensesName(): Text[100]
    begin
        exit(OtherMarketingExpensesLbl);
    end;

    procedure CatalogspricelistsName(): Text[100]
    begin
        exit(CatalogspricelistsLbl);
    end;

    procedure TradePublicationsName(): Text[100]
    begin
        exit(TradePublicationsLbl);
    end;

    procedure TotalOtherMarketingExpensesName(): Text[100]
    begin
        exit(TotalOtherMarketingExpensesLbl);
    end;

    procedure SalesExpensesName(): Text[100]
    begin
        exit(SalesExpensesLbl);
    end;

    procedure CreditCardChargesName(): Text[100]
    begin
        exit(CreditCardChargesLbl);
    end;

    procedure BusinessEntertainingdeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingdeductibleLbl);
    end;

    procedure BusinessEntertainingnondeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingnondeductibleLbl);
    end;

    procedure TotalSalesExpensesName(): Text[100]
    begin
        exit(TotalSalesExpensesLbl);
    end;

    procedure TotalMarketingandSalesName(): Text[100]
    begin
        exit(TotalMarketingandSalesLbl);
    end;

    procedure OfficeExpensesName(): Text[100]
    begin
        exit(OfficeExpensesLbl);
    end;

    procedure PhoneServicesName(): Text[100]
    begin
        exit(PhoneServicesLbl);
    end;

    procedure DataservicesName(): Text[100]
    begin
        exit(DataservicesLbl);
    end;

    procedure PostalfeesName(): Text[100]
    begin
        exit(PostalfeesLbl);
    end;

    procedure ConsumableExpensiblehardwareName(): Text[100]
    begin
        exit(ConsumableExpensiblehardwareLbl);
    end;

    procedure SoftwareandsubscriptionfeesName(): Text[100]
    begin
        exit(SoftwareandsubscriptionfeesLbl);
    end;

    procedure TotalOfficeExpensesName(): Text[100]
    begin
        exit(TotalOfficeExpensesLbl);
    end;

    procedure InsurancesandRisksName(): Text[100]
    begin
        exit(InsurancesandRisksLbl);
    end;

    procedure CorporateInsuranceName(): Text[100]
    begin
        exit(CorporateInsuranceLbl);
    end;

    procedure DamagesPaidName(): Text[100]
    begin
        exit(DamagesPaidLbl);
    end;

    procedure BadDebtLossesName(): Text[100]
    begin
        exit(BadDebtLossesLbl);
    end;

    procedure SecurityservicesName(): Text[100]
    begin
        exit(SecurityservicesLbl);
    end;

    procedure OtherriskexpensesName(): Text[100]
    begin
        exit(OtherriskexpensesLbl);
    end;

    procedure TotalInsurancesandRisksName(): Text[100]
    begin
        exit(TotalInsurancesandRisksLbl);
    end;

    procedure ManagementandAdminName(): Text[100]
    begin
        exit(ManagementandAdminLbl);
    end;

    procedure ManagementName(): Text[100]
    begin
        exit(ManagementLbl);
    end;

    procedure RemunerationtoDirectorsName(): Text[100]
    begin
        exit(RemunerationtoDirectorsLbl);
    end;

    procedure ManagementFeesName(): Text[100]
    begin
        exit(ManagementFeesLbl);
    end;

    procedure AnnualinterrimReportsName(): Text[100]
    begin
        exit(AnnualinterrimReportsLbl);
    end;

    procedure AnnualgeneralmeetingName(): Text[100]
    begin
        exit(AnnualgeneralmeetingLbl);
    end;

    procedure AuditandAuditServicesName(): Text[100]
    begin
        exit(AuditandAuditServicesLbl);
    end;

    procedure TaxadvisoryServicesName(): Text[100]
    begin
        exit(TaxadvisoryServicesLbl);
    end;

    procedure TotalManagementFeesName(): Text[100]
    begin
        exit(TotalManagementFeesLbl);
    end;

    procedure TotalManagementandAdminName(): Text[100]
    begin
        exit(TotalManagementandAdminLbl);
    end;

    procedure BankingandInterestName(): Text[100]
    begin
        exit(BankingandInterestLbl);
    end;

    procedure BankingfeesName(): Text[100]
    begin
        exit(BankingfeesLbl);
    end;

    procedure PayableInvoiceRoundingName(): Text[100]
    begin
        exit(PayableInvoiceRoundingLbl);
    end;

    procedure TotalBankingandInterestName(): Text[100]
    begin
        exit(TotalBankingandInterestLbl);
    end;

    procedure ExternalServicesExpensesName(): Text[100]
    begin
        exit(ExternalServicesExpensesLbl);
    end;

    procedure ExternalServicesName(): Text[100]
    begin
        exit(ExternalServicesLbl);
    end;

    procedure AccountingServicesName(): Text[100]
    begin
        exit(AccountingServicesLbl);
    end;

    procedure ITServicesName(): Text[100]
    begin
        exit(ITServicesLbl);
    end;

    procedure MediaServicesName(): Text[100]
    begin
        exit(MediaServicesLbl);
    end;

    procedure ConsultingServicesName(): Text[100]
    begin
        exit(ConsultingServicesLbl);
    end;

    procedure LegalFeesandAttorneyServicesName(): Text[100]
    begin
        exit(LegalFeesandAttorneyServicesLbl);
    end;

    procedure OtherExternalServicesName(): Text[100]
    begin
        exit(OtherExternalServicesLbl);
    end;

    procedure TotalExternalServicesName(): Text[100]
    begin
        exit(TotalExternalServicesLbl);
    end;

    procedure OtherExternalExpensesName(): Text[100]
    begin
        exit(OtherExternalExpensesLbl);
    end;

    procedure LicenseFeesRoyaltiesName(): Text[100]
    begin
        exit(LicenseFeesRoyaltiesLbl);
    end;

    procedure TrademarksPatentsName(): Text[100]
    begin
        exit(TrademarksPatentsLbl);
    end;

    procedure AssociationFeesName(): Text[100]
    begin
        exit(AssociationFeesLbl);
    end;

    procedure MiscexternalexpensesName(): Text[100]
    begin
        exit(MiscexternalexpensesLbl);
    end;

    procedure PurchaseDiscountsName(): Text[100]
    begin
        exit(PurchaseDiscountsLbl);
    end;

    procedure TotalOtherExternalExpensesName(): Text[100]
    begin
        exit(TotalOtherExternalExpensesLbl);
    end;

    procedure TotalExternalServicesExpensesName(): Text[100]
    begin
        exit(TotalExternalServicesExpensesLbl);
    end;

    procedure PersonnelName(): Text[100]
    begin
        exit(PersonnelLbl);
    end;

    procedure WagesandSalariesName(): Text[100]
    begin
        exit(WagesandSalariesLbl);
    end;

    procedure HourlyWagesName(): Text[100]
    begin
        exit(HourlyWagesLbl);
    end;

    procedure OvertimeWagesName(): Text[100]
    begin
        exit(OvertimeWagesLbl);
    end;

    procedure BonusesName(): Text[100]
    begin
        exit(BonusesLbl);
    end;

    procedure CommissionsPaidName(): Text[100]
    begin
        exit(CommissionsPaidLbl);
    end;

    procedure PTOAccruedName(): Text[100]
    begin
        exit(PTOAccruedLbl);
    end;

    procedure TotalWagesandSalariesName(): Text[100]
    begin
        exit(TotalWagesandSalariesLbl);
    end;

    procedure BenefitsPensionName(): Text[100]
    begin
        exit(BenefitsPensionLbl);
    end;

    procedure BenefitsName(): Text[100]
    begin
        exit(BenefitsLbl);
    end;

    procedure TrainingCostsName(): Text[100]
    begin
        exit(TrainingCostsLbl);
    end;

    procedure HealthCareContributionsName(): Text[100]
    begin
        exit(HealthCareContributionsLbl);
    end;

    procedure EntertainmentofpersonnelName(): Text[100]
    begin
        exit(EntertainmentofpersonnelLbl);
    end;

    procedure MandatoryclothingexpensesName(): Text[100]
    begin
        exit(MandatoryclothingexpensesLbl);
    end;

    procedure OthercashremunerationbenefitsName(): Text[100]
    begin
        exit(OthercashremunerationbenefitsLbl);
    end;

    procedure TotalBenefitsName(): Text[100]
    begin
        exit(TotalBenefitsLbl);
    end;

    procedure PensionName(): Text[100]
    begin
        exit(PensionLbl);
    end;

    procedure PensionfeesandrecurringcostsName(): Text[100]
    begin
        exit(PensionfeesandrecurringcostsLbl);
    end;

    procedure EmployerContributionsName(): Text[100]
    begin
        exit(EmployerContributionsLbl);
    end;

    procedure TotalPensionName(): Text[100]
    begin
        exit(TotalPensionLbl);
    end;

    procedure TotalBenefitsPensionName(): Text[100]
    begin
        exit(TotalBenefitsPensionLbl);
    end;

    procedure InsurancesPersonnelName(): Text[100]
    begin
        exit(InsurancesPersonnelLbl);
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceLbl);
    end;

    procedure DentalInsuranceName(): Text[100]
    begin
        exit(DentalInsuranceLbl);
    end;

    procedure WorkersCompensationName(): Text[100]
    begin
        exit(WorkersCompensationLbl);
    end;

    procedure LifeInsuranceName(): Text[100]
    begin
        exit(LifeInsuranceLbl);
    end;

    procedure TotalInsurancesPersonnelName(): Text[100]
    begin
        exit(TotalInsurancesPersonnelLbl);
    end;

    procedure TotalPersonnelName(): Text[100]
    begin
        exit(TotalPersonnelLbl);
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationLbl);
    end;

    procedure DepreciationLandandPropertyName(): Text[100]
    begin
        exit(DepreciationLandandPropertyLbl);
    end;

    procedure DepreciationFixedAssetsName(): Text[100]
    begin
        exit(DepreciationFixedAssetsLbl);
    end;

    procedure TotalDepreciationName(): Text[100]
    begin
        exit(TotalDepreciationLbl);
    end;

    procedure MiscExpensesName(): Text[100]
    begin
        exit(MiscExpensesLbl);
    end;

    procedure CurrencyLossesName(): Text[100]
    begin
        exit(CurrencyLossesLbl);
    end;

    procedure TotalMiscExpensesName(): Text[100]
    begin
        exit(TotalMiscExpensesLbl);
    end;

    procedure TOTALEXPENSESName(): Text[100]
    begin
        exit(TOTALEXPENSESLbl);
    end;

    procedure COSTOFGOODSSOLDName(): Text[100]
    begin
        exit(COSTOFGOODSSOLDLbl);
    end;

    procedure CostofGoodsName(): Text[100]
    begin
        exit(CostofGoodsLbl);
    end;

    procedure CostofMaterialsName(): Text[100]
    begin
        exit(CostofMaterialsLbl);
    end;

    procedure CostofMaterialsProjectsName(): Text[100]
    begin
        exit(CostofMaterialsProjectsLbl);
    end;

    procedure TotalCostofGoodsName(): Text[100]
    begin
        exit(TotalCostofGoodsLbl);
    end;

    procedure CostofResourcesandServicesName(): Text[100]
    begin
        exit(CostofResourcesandServicesLbl);
    end;

    procedure CostofLaborName(): Text[100]
    begin
        exit(CostofLaborLbl);
    end;

    procedure CostofLaborProjectsName(): Text[100]
    begin
        exit(CostofLaborProjectsLbl);
    end;

    procedure CostofLaborWarrantyContractName(): Text[100]
    begin
        exit(CostofLaborWarrantyContractLbl);
    end;

    procedure TotalCostofResourcesName(): Text[100]
    begin
        exit(TotalCostofResourcesLbl);
    end;

    procedure SubcontractedworkName(): Text[100]
    begin
        exit(SubcontractedworkLbl);
    end;

    procedure ManufVariancesName(): Text[100]
    begin
        exit(ManufVariancesLbl);
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapLbl);
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceLbl);
    end;

    procedure MfgOverheadVarianceName(): Text[100]
    begin
        exit(MfgOverheadVarianceLbl);
    end;

    procedure TotalManufVariancesName(): Text[100]
    begin
        exit(TotalManufVariancesLbl);
    end;

    procedure CostofVariancesName(): Text[100]
    begin
        exit(CostofVariancesLbl);
    end;

    procedure CostsofJobsName(): Text[100]
    begin
        exit(CostsofJobsLbl);
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedLbl);
    end;

    procedure TotalCostsofJobsName(): Text[100]
    begin
        exit(TotalCostsofJobsLbl);
    end;

    procedure TOTALCOSTOFGOODSSOLDName(): Text[100]
    begin
        exit(TOTALCOSTOFGOODSSOLDLbl);
    end;

    procedure IncomeName(): Text[100]
    begin
        exit(IncomeLbl);
    end;

    procedure SalesofGoodsName(): Text[100]
    begin
        exit(SalesofGoodsLbl);
    end;

    procedure SaleofFinishedGoodsName(): Text[100]
    begin
        exit(SaleofFinishedGoodsLbl);
    end;

    procedure SaleofRawMaterialsName(): Text[100]
    begin
        exit(SaleofRawMaterialsLbl);
    end;

    procedure ResaleofGoodsName(): Text[100]
    begin
        exit(ResaleofGoodsLbl);
    end;

    procedure TotalSalesofGoodsName(): Text[100]
    begin
        exit(TotalSalesofGoodsLbl);
    end;

    procedure SaleofResourcesName(): Text[100]
    begin
        exit(SaleofResourcesLbl);
    end;

    procedure SaleofSubcontractingName(): Text[100]
    begin
        exit(SaleofSubcontractingLbl);
    end;

    procedure TotalSalesofResourcesName(): Text[100]
    begin
        exit(TotalSalesofResourcesLbl);
    end;

    procedure AdditionalRevenueName(): Text[100]
    begin
        exit(AdditionalRevenueLbl);
    end;

    procedure IncomefromsecuritiesName(): Text[100]
    begin
        exit(IncomefromsecuritiesLbl);
    end;

    procedure ManagementFeeRevenueName(): Text[100]
    begin
        exit(ManagementFeeRevenueLbl);
    end;

    procedure CurrencyGainsName(): Text[100]
    begin
        exit(CurrencyGainsLbl);
    end;

    procedure OtherIncidentalRevenueName(): Text[100]
    begin
        exit(OtherIncidentalRevenueLbl);
    end;

    procedure TotalAdditionalRevenueName(): Text[100]
    begin
        exit(TotalAdditionalRevenueLbl);
    end;

    procedure JobsandServicesName(): Text[100]
    begin
        exit(JobsandServicesLbl);
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedLbl);
    end;

    procedure SalesofServiceContractsName(): Text[100]
    begin
        exit(SalesofServiceContractsLbl);
    end;

    procedure SalesofServiceWorkName(): Text[100]
    begin
        exit(SalesofServiceWorkLbl);
    end;

    procedure TotalJobsandServicesName(): Text[100]
    begin
        exit(TotalJobsandServicesLbl);
    end;

    procedure RevenueReductionsName(): Text[100]
    begin
        exit(RevenueReductionsLbl);
    end;

    procedure SalesDiscountsName(): Text[100]
    begin
        exit(SalesDiscountsLbl);
    end;

    procedure SalesInvoiceRoundingName(): Text[100]
    begin
        exit(SalesInvoiceRoundingLbl);
    end;

    procedure SalesReturnsName(): Text[100]
    begin
        exit(SalesReturnsLbl);
    end;

    procedure TotalRevenueReductionsName(): Text[100]
    begin
        exit(TotalRevenueReductionsLbl);
    end;

    procedure TOTALINCOMEName(): Text[100]
    begin
        exit(TOTALINCOMELbl);
    end;

    procedure IntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleFixedAssetsName()));
    end;

    procedure DevelopmentExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopmentExpenditureName()));
    end;

    procedure TenancySiteLeaseholdandsimilarrights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TenancySiteLeaseholdandsimilarrightsName()));
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforIntangibleFixedAssetsName()));
    end;

    procedure TotalIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIntangibleFixedAssetsName()));
    end;

    procedure Building(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingName()));
    end;

    procedure CostofImprovementstoLeasedProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofImprovementstoLeasedPropertyName()));
    end;

    procedure Land(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandName()));
    end;

    procedure TotalLandandbuilding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLandandbuildingName()));
    end;

    procedure MachineryandEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryandEquipmentName()));
    end;

    procedure EquipmentsandTools(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentsandToolsName()));
    end;

    procedure Computers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersName()));
    end;

    procedure CarsandotherTransportEquipments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsandotherTransportEquipmentsName()));
    end;

    procedure LeasedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasedAssetsName()));
    end;

    procedure TotalMachineryandEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMachineryandEquipmentName()));
    end;

    procedure AccumulatedDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationName()));
    end;

    procedure TotalTangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTangibleAssetsName()));
    end;

    procedure FinancialandFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialandFixedAssetsName()));
    end;

    procedure LongtermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongtermReceivablesName()));
    end;

    procedure ParticipationinGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ParticipationinGroupCompaniesName()));
    end;

    procedure LoanstoPartnersorrelatedParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanstoPartnersorrelatedPartiesName()));
    end;

    procedure DeferredTaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredTaxAssetsName()));
    end;

    procedure OtherLongtermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongtermReceivablesName()));
    end;

    procedure TotalFinancialandFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialandFixedAssetsName()));
    end;

    procedure InventoriesProductsandworkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoriesProductsandworkinProgressName()));
    end;

    procedure SuppliesandConsumables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuppliesandConsumablesName()));
    end;

    procedure ProductsinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProductsinProgressName()));
    end;

    procedure GoodsforResale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsforResaleName()));
    end;

    procedure AdvancedPaymentsforgoodsandservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforgoodsandservicesName()));
    end;

    procedure OtherInventoryItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInventoryItemsName()));
    end;

    procedure WorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinProgressName()));
    end;

    procedure WIPAccruedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedCostsName()));
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure TotalWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWorkinProgressName()));
    end;

    procedure TotalInventoryProductsandWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInventoryProductsandWorkinProgressName()));
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure AccountsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivablesName()));
    end;

    procedure AccountReceivableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableDomesticName()));
    end;

    procedure AccountReceivableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableForeignName()));
    end;

    procedure ContractualReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualReceivablesName()));
    end;

    procedure ConsignmentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsignmentReceivablesName()));
    end;

    procedure CreditcardsandVouchersReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditcardsandVouchersReceivablesName()));
    end;

    procedure TotalAccountReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccountReceivablesName()));
    end;

    procedure OtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentReceivablesName()));
    end;

    procedure CurrentReceivablefromEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablefromEmployeesName()));
    end;

    procedure Accruedincomenotyetinvoiced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedincomenotyetinvoicedName()));
    end;

    procedure ClearingAccountsforTaxesandcharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountsforTaxesandchargesName()));
    end;

    procedure TaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAssetsName()));
    end;

    procedure PurchaseVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATReducedName()));
    end;

    procedure PurchaseVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATNormalName()));
    end;

    procedure MiscVATReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATReceivablesName()));
    end;

    procedure CurrentReceivablesfromgroupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablesfromgroupcompaniesName()));
    end;

    procedure TotalOtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentReceivablesName()));
    end;

    procedure TotalReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalReceivablesName()));
    end;

    procedure PrepaidexpensesandAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidexpensesandAccruedIncomeName()));
    end;

    procedure PrepaidRent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidRentName()));
    end;

    procedure PrepaidInterestexpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidInterestexpenseName()));
    end;

    procedure AccruedRentalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedRentalIncomeName()));
    end;

    procedure AccruedInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestIncomeName()));
    end;

    procedure Assetsintheformofprepaidexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsintheformofprepaidexpensesName()));
    end;

    procedure Otherprepaidexpensesandaccruedincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherprepaidexpensesandaccruedincomeName()));
    end;

    procedure TotalPrepaidexpensesandAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPrepaidexpensesandAccruedIncomeName()));
    end;

    procedure Shortterminvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortterminvestmentsName()));
    end;

    procedure Convertibledebtinstruments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertibledebtinstrumentsName()));
    end;

    procedure OthershorttermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthershorttermInvestmentsName()));
    end;

    procedure WritedownofShortterminvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WritedownofShortterminvestmentsName()));
    end;

    procedure Totalshortterminvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalshortterminvestmentsName()));
    end;

    procedure CashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashandBankName()));
    end;

    procedure PettyCash(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PettyCashName()));
    end;

    procedure BusinessaccountOperatingDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessaccountOperatingDomesticName()));
    end;

    procedure BusinessaccountOperatingForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessaccountOperatingForeignName()));
    end;

    procedure Otherbankaccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherbankaccountsName()));
    end;

    procedure CertificateofDeposit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CertificateofDepositName()));
    end;

    procedure TotalCashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCashandBankName()));
    end;

    procedure Liability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilityName()));
    end;

    procedure BondsandDebentureLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BondsandDebentureLoansName()));
    end;

    procedure ConvertiblesLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertiblesLoansName()));
    end;

    procedure OtherLongtermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongtermLiabilitiesName()));
    end;

    procedure BankoverdraftFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankoverdraftFacilitiesName()));
    end;

    procedure PaymtsRecptsinProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymtsRecptsinProcessName()));
    end;

    procedure TotalLongtermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLongtermLiabilitiesName()));
    end;

    procedure CurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiesName()));
    end;

    procedure AccountsPayableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableDomesticName()));
    end;

    procedure AccountsPayableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableForeignName()));
    end;

    procedure Advancesfromcustomers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesfromcustomersName()));
    end;

    procedure ChangeinWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeinWorkinProgressName()));
    end;

    procedure Bankoverdraftshortterm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankoverdraftshorttermName()));
    end;

    procedure DeferredRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredRevenueName()));
    end;

    procedure TotalCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCurrentLiabilitiesName()));
    end;

    procedure TaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxLiabilitiesName()));
    end;

    procedure SalesTaxVATLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxVATLiableName()));
    end;

    procedure CollectioninProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CollectioninProcessName()));
    end;

    procedure TaxesLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesLiableName()));
    end;

    procedure SalesVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATReducedName()));
    end;

    procedure SalesVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATNormalName()));
    end;

    procedure MiscVATPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATPayablesName()));
    end;

    procedure EstimatedIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedIncomeTaxName()));
    end;

    procedure EstimatedrealestateTaxRealestatecharge(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedrealestateTaxRealestatechargeName()));
    end;

    procedure EstimatedPayrolltaxonPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedPayrolltaxonPensionCostsName()));
    end;

    procedure TotalTaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTaxLiabilitiesName()));
    end;

    procedure PayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollLiabilitiesName()));
    end;

    procedure EmployeesWithholdingTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesWithholdingTaxesName()));
    end;

    procedure StatutorySocialsecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialsecurityContributionsName()));
    end;

    procedure ContractualSocialsecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualSocialsecurityContributionsName()));
    end;

    procedure AttachmentsofEarning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AttachmentsofEarningName()));
    end;

    procedure HolidayPayfund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HolidayPayfundName()));
    end;

    procedure OtherSalarywageDeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSalarywageDeductionsName()));
    end;

    procedure TotalPayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPayrollLiabilitiesName()));
    end;

    procedure OtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentLiabilitiesName()));
    end;

    procedure ClearingAccountforFactoringCurrentPortion(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountforFactoringCurrentPortionName()));
    end;

    procedure CurrentLiabilitiestoEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiestoEmployeesName()));
    end;

    procedure ClearingAccountforthirdparty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountforthirdpartyName()));
    end;

    procedure CurrentLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLoansName()));
    end;

    procedure LiabilitiesGrantsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesGrantsReceivedName()));
    end;

    procedure TotalOtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentLiabilitiesName()));
    end;

    procedure AccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedExpensesandDeferredIncomeName()));
    end;

    procedure Accruedwagessalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedwagessalariesName()));
    end;

    procedure PaymentsinProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentsinProcessName()));
    end;

    procedure AccruedHolidaypay(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedHolidaypayName()));
    end;

    procedure AccruedPensioncosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedPensioncostsName()));
    end;

    procedure AccruedInterestExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestExpenseName()));
    end;

    procedure DeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredIncomeName()));
    end;

    procedure AccruedContractualcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedContractualcostsName()));
    end;

    procedure OtherAccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAccruedExpensesandDeferredIncomeName()));
    end;

    procedure TotalAccruedExpensesandDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccruedExpensesandDeferredIncomeName()));
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure EquityPartner(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityPartnerName()));
    end;

    procedure NetResults(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetResultsName()));
    end;

    procedure RestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RestrictedEquityName()));
    end;

    procedure ShareCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareCapitalName()));
    end;

    procedure NonRestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRestrictedEquityName()));
    end;

    procedure Profitorlossfromthepreviousyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitorlossfromthepreviousyearName()));
    end;

    procedure ResultsfortheFinancialyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResultsfortheFinancialyearName()));
    end;

    procedure DistributionstoShareholders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DistributionstoShareholdersName()));
    end;

    procedure TotalEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEquityName()));
    end;

    procedure EXPENSES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EXPENSESName()));
    end;

    procedure FacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FacilityExpensesName()));
    end;

    procedure RentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalFacilitiesName()));
    end;

    procedure RentLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentLeasesName()));
    end;

    procedure ElectricityforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityforRentalName()));
    end;

    procedure HeatingforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingforRentalName()));
    end;

    procedure WaterandSewerageforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterandSewerageforRentalName()));
    end;

    procedure CleaningandWasteforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforRentalName()));
    end;

    procedure RepairsandMaintenanceforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceforRentalName()));
    end;

    procedure InsurancesRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesRentalName()));
    end;

    procedure OtherRentalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRentalExpensesName()));
    end;

    procedure TotalRentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRentalFacilitiesName()));
    end;

    procedure PropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyExpensesName()));
    end;

    procedure SiteFeesLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SiteFeesLeasesName()));
    end;

    procedure ElectricityforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityforPropertyName()));
    end;

    procedure HeatingforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingforPropertyName()));
    end;

    procedure WaterandSewerageforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterandSewerageforPropertyName()));
    end;

    procedure CleaningandWasteforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforPropertyName()));
    end;

    procedure RepairsandMaintenanceforProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceforPropertyName()));
    end;

    procedure InsurancesProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPropertyName()));
    end;

    procedure OtherPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPropertyExpensesName()));
    end;

    procedure TotalPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPropertyExpensesName()));
    end;

    procedure TotalFacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFacilityExpensesName()));
    end;

    procedure FixedAssetsLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsLeasesName()));
    end;

    procedure Hireofmachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofmachineryName()));
    end;

    procedure Hireofcomputers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofcomputersName()));
    end;

    procedure Hireofotherfixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofotherfixedassetsName()));
    end;

    procedure TotalFixedAssetLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetLeasesName()));
    end;

    procedure LogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LogisticsExpensesName()));
    end;

    procedure PassengerCarCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PassengerCarCostsName()));
    end;

    procedure TruckCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckCostsName()));
    end;

    procedure Othervehicleexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthervehicleexpensesName()));
    end;

    procedure TotalVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleExpensesName()));
    end;

    procedure FreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightCostsName()));
    end;

    procedure Freightfeesforgoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightfeesforgoodsName()));
    end;

    procedure Customsandforwarding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomsandforwardingName()));
    end;

    procedure Freightfeesprojects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightfeesprojectsName()));
    end;

    procedure TotalFreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFreightCostsName()));
    end;

    procedure TravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesName()));
    end;

    procedure Tickets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TicketsName()));
    end;

    procedure Rentalvehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalvehiclesName()));
    end;

    procedure Boardandlodging(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BoardandlodgingName()));
    end;

    procedure Othertravelexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthertravelexpensesName()));
    end;

    procedure TotalTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTravelExpensesName()));
    end;

    procedure TotalLogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLogisticsExpensesName()));
    end;

    procedure MarketingandSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketingandSalesName()));
    end;

    procedure AdvertisementDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementDevelopmentName()));
    end;

    procedure OutdoorandTransportationAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutdoorandTransportationAdsName()));
    end;

    procedure Admatteranddirectmailings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdmatteranddirectmailingsName()));
    end;

    procedure ConferenceExhibitionSponsorship(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConferenceExhibitionSponsorshipName()));
    end;

    procedure Samplescontestsgifts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SamplescontestsgiftsName()));
    end;

    procedure FilmTVradiointernetads(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FilmTVradiointernetadsName()));
    end;

    procedure PRandAgencyFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PRandAgencyFeesName()));
    end;

    procedure Otheradvertisingfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtheradvertisingfeesName()));
    end;

    procedure TotalAdvertising(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvertisingName()));
    end;

    procedure OtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherMarketingExpensesName()));
    end;

    procedure Catalogspricelists(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CatalogspricelistsName()));
    end;

    procedure TradePublications(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradePublicationsName()));
    end;

    procedure TotalOtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherMarketingExpensesName()));
    end;

    procedure SalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesExpensesName()));
    end;

    procedure CreditCardCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditCardChargesName()));
    end;

    procedure BusinessEntertainingdeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingdeductibleName()));
    end;

    procedure BusinessEntertainingnondeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingnondeductibleName()));
    end;

    procedure TotalSalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesExpensesName()));
    end;

    procedure TotalMarketingandSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMarketingandSalesName()));
    end;

    procedure OfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeExpensesName()));
    end;

    procedure PhoneServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneServicesName()));
    end;

    procedure Dataservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DataservicesName()));
    end;

    procedure Postalfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostalfeesName()));
    end;

    procedure ConsumableExpensiblehardware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumableExpensiblehardwareName()));
    end;

    procedure Softwareandsubscriptionfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareandsubscriptionfeesName()));
    end;

    procedure TotalOfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOfficeExpensesName()));
    end;

    procedure InsurancesandRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesandRisksName()));
    end;

    procedure CorporateInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateInsuranceName()));
    end;

    procedure DamagesPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DamagesPaidName()));
    end;

    procedure BadDebtLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BadDebtLossesName()));
    end;

    procedure Securityservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecurityservicesName()));
    end;

    procedure Otherriskexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherriskexpensesName()));
    end;

    procedure TotalInsurancesandRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesandRisksName()));
    end;

    procedure ManagementandAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementandAdminName()));
    end;

    procedure Management(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementName()));
    end;

    procedure RemunerationtoDirectors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RemunerationtoDirectorsName()));
    end;

    procedure ManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeesName()));
    end;

    procedure AnnualinterrimReports(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualinterrimReportsName()));
    end;

    procedure Annualgeneralmeeting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualgeneralmeetingName()));
    end;

    procedure AuditandAuditServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditandAuditServicesName()));
    end;

    procedure TaxadvisoryServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxadvisoryServicesName()));
    end;

    procedure TotalManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementFeesName()));
    end;

    procedure TotalManagementandAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementandAdminName()));
    end;

    procedure BankingandInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingandInterestName()));
    end;

    procedure Bankingfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingfeesName()));
    end;

    procedure PayableInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayableInvoiceRoundingName()));
    end;

    procedure TotalBankingandInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBankingandInterestName()));
    end;

    procedure ExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesExpensesName()));
    end;

    procedure ExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesName()));
    end;

    procedure AccountingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingServicesName()));
    end;

    procedure ITServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ITServicesName()));
    end;

    procedure MediaServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MediaServicesName()));
    end;

    procedure ConsultingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingServicesName()));
    end;

    procedure LegalFeesandAttorneyServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalFeesandAttorneyServicesName()));
    end;

    procedure OtherExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalServicesName()));
    end;

    procedure TotalExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesName()));
    end;

    procedure OtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalExpensesName()));
    end;

    procedure LicenseFeesRoyalties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LicenseFeesRoyaltiesName()));
    end;

    procedure TrademarksPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrademarksPatentsName()));
    end;

    procedure AssociationFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssociationFeesName()));
    end;

    procedure Miscexternalexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscexternalexpensesName()));
    end;

    procedure PurchaseDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDiscountsName()));
    end;

    procedure TotalOtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherExternalExpensesName()));
    end;

    procedure TotalExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesExpensesName()));
    end;

    procedure Personnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelName()));
    end;

    procedure WagesandSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesandSalariesName()));
    end;

    procedure HourlyWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HourlyWagesName()));
    end;

    procedure OvertimeWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OvertimeWagesName()));
    end;

    procedure Bonuses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BonusesName()));
    end;

    procedure CommissionsPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsPaidName()));
    end;

    procedure PTOAccrued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PTOAccruedName()));
    end;

    procedure TotalWagesandSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWagesandSalariesName()));
    end;

    procedure BenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsPensionName()));
    end;

    procedure Benefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsName()));
    end;

    procedure TrainingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrainingCostsName()));
    end;

    procedure HealthCareContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthCareContributionsName()));
    end;

    procedure Entertainmentofpersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntertainmentofpersonnelName()));
    end;

    procedure Mandatoryclothingexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MandatoryclothingexpensesName()));
    end;

    procedure Othercashremunerationbenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthercashremunerationbenefitsName()));
    end;

    procedure TotalBenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsName()));
    end;

    procedure Pension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionName()));
    end;

    procedure Pensionfeesandrecurringcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionfeesandrecurringcostsName()));
    end;

    procedure EmployerContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployerContributionsName()));
    end;

    procedure TotalPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPensionName()));
    end;

    procedure TotalBenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsPensionName()));
    end;

    procedure InsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPersonnelName()));
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure DentalInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DentalInsuranceName()));
    end;

    procedure WorkersCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkersCompensationName()));
    end;

    procedure LifeInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LifeInsuranceName()));
    end;

    procedure TotalInsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesPersonnelName()));
    end;

    procedure TotalPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelName()));
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure DepreciationLandandProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationLandandPropertyName()));
    end;

    procedure DepreciationFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationFixedAssetsName()));
    end;

    procedure TotalDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalDepreciationName()));
    end;

    procedure MiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscExpensesName()));
    end;

    procedure CurrencyLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyLossesName()));
    end;

    procedure TotalMiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMiscExpensesName()));
    end;

    procedure TOTALEXPENSES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALEXPENSESName()));
    end;

    procedure COSTOFGOODSSOLD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COSTOFGOODSSOLDName()));
    end;

    procedure CostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofGoodsName()));
    end;

    procedure CostofMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsName()));
    end;

    procedure CostofMaterialsProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsProjectsName()));
    end;

    procedure TotalCostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofGoodsName()));
    end;

    procedure CostofResourcesandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResourcesandServicesName()));
    end;

    procedure CostofLabor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborName()));
    end;

    procedure CostofLaborProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborProjectsName()));
    end;

    procedure CostofLaborWarrantyContract(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborWarrantyContractName()));
    end;

    procedure TotalCostofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofResourcesName()));
    end;

    procedure Subcontractedwork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedworkName()));
    end;

    procedure ManufVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManufVariancesName()));
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MfgOverheadVarianceName()));
    end;

    procedure TotalManufVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManufVariancesName()));
    end;

    procedure CostofVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofVariancesName()));
    end;

    procedure CostsofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostsofJobsName()));
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure TotalCostsofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostsofJobsName()));
    end;

    procedure TOTALCOSTOFGOODSSOLD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALCOSTOFGOODSSOLDName()));
    end;

    procedure Income(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeName()));
    end;

    procedure SalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofGoodsName()));
    end;

    procedure SaleofFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofFinishedGoodsName()));
    end;

    procedure SaleofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofRawMaterialsName()));
    end;

    procedure ResaleofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleofGoodsName()));
    end;

    procedure TotalSalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofGoodsName()));
    end;

    procedure SaleofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofResourcesName()));
    end;

    procedure SaleofSubcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofSubcontractingName()));
    end;

    procedure TotalSalesofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofResourcesName()));
    end;

    procedure AdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionalRevenueName()));
    end;

    procedure Incomefromsecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomefromsecuritiesName()));
    end;

    procedure ManagementFeeRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeeRevenueName()));
    end;

    procedure CurrencyGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyGainsName()));
    end;

    procedure OtherIncidentalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherIncidentalRevenueName()));
    end;

    procedure TotalAdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdditionalRevenueName()));
    end;

    procedure JobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobsandServicesName()));
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure SalesofServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceContractsName()));
    end;

    procedure SalesofServiceWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceWorkName()));
    end;

    procedure TotalJobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalJobsandServicesName()));
    end;

    procedure RevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueReductionsName()));
    end;

    procedure SalesDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesDiscountsName()));
    end;

    procedure SalesInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesInvoiceRoundingName()));
    end;

    procedure SalesReturns(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesReturnsName()));
    end;

    procedure TotalRevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueReductionsName()));
    end;

    procedure TOTALINCOME(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALINCOMEName()));
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceTok);
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceTok);
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 100;
        AssetsLbl: Label 'Assets', MaxLength = 100;
        MaterialVarianceTok: Label 'Material Variance', MaxLength = 100;
        CapacityVarianceTok: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceTok: Label 'Subcontracted Variance', MaxLength = 100;
        IntangibleFixedAssetsLbl: Label 'Intangible Fixed Assets', MaxLength = 100;
        DevelopmentExpenditureLbl: Label 'Development Expenditure', MaxLength = 100;
        TenancySiteLeaseholdandsimilarrightsLbl: Label 'Tenancy, Site Leasehold and similar rights', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        AdvancedPaymentsforIntangibleFixedAssetsLbl: Label 'Advanced Payments for Intangible Fixed Assets', MaxLength = 100;
        TotalIntangibleFixedAssetsLbl: Label 'Total, Intangible Fixed Assets', MaxLength = 100;
        BuildingLbl: Label 'Building', MaxLength = 100;
        CostofImprovementstoLeasedPropertyLbl: Label 'Cost of Improvements to Leased Property', MaxLength = 100;
        LandLbl: Label 'Land ', MaxLength = 100;
        TotalLandandbuildingLbl: Label 'Total, Land and building ', MaxLength = 100;
        MachineryandEquipmentLbl: Label 'Machinery and Equipment', MaxLength = 100;
        EquipmentsandToolsLbl: Label 'Equipments and Tools', MaxLength = 100;
        ComputersLbl: Label 'Computers', MaxLength = 100;
        CarsandotherTransportEquipmentsLbl: Label 'Cars and other Transport Equipments', MaxLength = 100;
        LeasedAssetsLbl: Label 'Leased Assets', MaxLength = 100;
        TotalMachineryandEquipmentLbl: Label 'Total, Machinery and Equipment', MaxLength = 100;
        AccumulatedDepreciationLbl: Label 'Accumulated Depreciation', MaxLength = 100;
        TotalTangibleAssetsLbl: Label 'Total, Tangible Assets', MaxLength = 100;
        FinancialandFixedAssetsLbl: Label 'Financial and Fixed Assets', MaxLength = 100;
        LongtermReceivablesLbl: Label 'Long-term Receivables ', MaxLength = 100;
        ParticipationinGroupCompaniesLbl: Label 'Participation in Group Companies', MaxLength = 100;
        LoanstoPartnersorrelatedPartiesLbl: Label 'Loans to Partners or related Parties', MaxLength = 100;
        DeferredTaxAssetsLbl: Label 'Deferred Tax Assets', MaxLength = 100;
        OtherLongtermReceivablesLbl: Label 'Other Long-term Receivables', MaxLength = 100;
        TotalFinancialandFixedAssetsLbl: Label 'Total, Financial and Fixed Assets', MaxLength = 100;
        InventoriesProductsandworkinProgressLbl: Label 'Inventories, Products and work in Progress', MaxLength = 100;
        SuppliesandConsumablesLbl: Label 'Supplies and Consumables', MaxLength = 100;
        ProductsinProgressLbl: Label 'Products in Progress', MaxLength = 100;
        GoodsforResaleLbl: Label 'Goods for Resale', MaxLength = 100;
        AdvancedPaymentsforgoodsandservicesLbl: Label 'Advanced Payments for goods and services', MaxLength = 100;
        OtherInventoryItemsLbl: Label 'Other Inventory Items', MaxLength = 100;
        WorkinProgressLbl: Label 'Work in Progress', MaxLength = 100;
        WIPAccruedCostsLbl: Label 'WIP, Accrued Costs', MaxLength = 100;
        WIPInvoicedSalesLbl: Label 'WIP, Invoiced Sales', MaxLength = 100;
        TotalWorkinProgressLbl: Label 'Total, Work in Progress', MaxLength = 100;
        TotalInventoryProductsandWorkinProgressLbl: Label 'Total, Inventory, Products and Work in Progress', MaxLength = 100;
        ReceivablesLbl: Label 'Receivables', MaxLength = 100;
        AccountsReceivablesLbl: Label 'Accounts Receivables', MaxLength = 100;
        AccountReceivableDomesticLbl: Label 'Account Receivable, Domestic', MaxLength = 100;
        AccountReceivableForeignLbl: Label 'Account Receivable, Foreign', MaxLength = 100;
        ContractualReceivablesLbl: Label 'Contractual Receivables', MaxLength = 100;
        ConsignmentReceivablesLbl: Label 'Consignment Receivables', MaxLength = 100;
        CreditcardsandVouchersReceivablesLbl: Label 'Credit cards and Vouchers Receivables', MaxLength = 100;
        TotalAccountReceivablesLbl: Label 'Total, Account Receivables', MaxLength = 100;
        OtherCurrentReceivablesLbl: Label 'Other Current Receivables', MaxLength = 100;
        CurrentReceivablefromEmployeesLbl: Label 'Current Receivable from Employees', MaxLength = 100;
        AccruedincomenotyetinvoicedLbl: Label 'Accrued income not yet invoiced', MaxLength = 100;
        ClearingAccountsforTaxesandchargesLbl: Label 'Clearing Accounts for Taxes and charges', MaxLength = 100;
        TaxAssetsLbl: Label 'Tax Assets', MaxLength = 100;
        PurchaseVATReducedLbl: Label 'Purchase VAT Reduced', MaxLength = 100;
        PurchaseVATNormalLbl: Label 'Purchase VAT Normal', MaxLength = 100;
        MiscVATReceivablesLbl: Label 'Misc VAT Receivables', MaxLength = 100;
        CurrentReceivablesfromgroupcompaniesLbl: Label 'Current Receivables from group companies', MaxLength = 100;
        TotalOtherCurrentReceivablesLbl: Label 'Total, Other Current Receivables', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total, Receivables', MaxLength = 100;
        PrepaidexpensesandAccruedIncomeLbl: Label 'Prepaid expenses and Accrued Income', MaxLength = 100;
        PrepaidRentLbl: Label 'Prepaid Rent', MaxLength = 100;
        PrepaidInterestexpenseLbl: Label 'Prepaid Interest expense', MaxLength = 100;
        AccruedRentalIncomeLbl: Label 'Accrued Rental Income', MaxLength = 100;
        AccruedInterestIncomeLbl: Label 'Accrued Interest Income', MaxLength = 100;
        AssetsintheformofprepaidexpensesLbl: Label 'Assets in the form of prepaid expenses', MaxLength = 100;
        OtherprepaidexpensesandaccruedincomeLbl: Label 'Other prepaid expenses and accrued income', MaxLength = 100;
        TotalPrepaidexpensesandAccruedIncomeLbl: Label 'Total, Prepaid expenses and Accrued Income', MaxLength = 100;
        ShortterminvestmentsLbl: Label 'Short-term investments', MaxLength = 100;
        ConvertibledebtinstrumentsLbl: Label 'Convertible debt instruments', MaxLength = 100;
        OthershorttermInvestmentsLbl: Label 'Other short-term Investments', MaxLength = 100;
        WritedownofShortterminvestmentsLbl: Label 'Write-down of Short-term investments', MaxLength = 100;
        TotalshortterminvestmentsLbl: Label 'Total, short term investments', MaxLength = 100;
        CashandBankLbl: Label 'Cash and Bank', MaxLength = 100;
        PettyCashLbl: Label 'Petty Cash', MaxLength = 100;
        BusinessaccountOperatingDomesticLbl: Label 'Business account, Operating, Domestic', MaxLength = 100;
        BusinessaccountOperatingForeignLbl: Label 'Business account, Operating, Foreign', MaxLength = 100;
        OtherbankaccountsLbl: Label 'Other bank accounts ', MaxLength = 100;
        CertificateofDepositLbl: Label 'Certificate of Deposit', MaxLength = 100;
        TotalCashandBankLbl: Label 'Total, Cash and Bank', MaxLength = 100;
        LiabilityLbl: Label 'Liability', MaxLength = 100;
        BondsandDebentureLoansLbl: Label 'Bonds and Debenture Loans', MaxLength = 100;
        ConvertiblesLoansLbl: Label 'Convertibles Loans', MaxLength = 100;
        OtherLongTermLiabilitiesLbl: Label 'Other Long-term Liabilities', MaxLength = 100;
        BankoverdraftFacilitiesLbl: Label 'Bank overdraft Facilities', MaxLength = 100;
        PaymtsRecptsinProcessLbl: Label 'Paymts./Recpts. in Process', MaxLength = 100;
        TotalLongtermLiabilitiesLbl: Label 'Total, Long-term Liabilities', MaxLength = 100;
        CurrentLiabilitiesLbl: Label 'Current Liabilities', MaxLength = 100;
        AccountsPayableDomesticLbl: Label 'Accounts Payable, Domestic', MaxLength = 100;
        AccountsPayableForeignLbl: Label 'Accounts Payable, Foreign', MaxLength = 100;
        AdvancesfromcustomersLbl: Label 'Advances from customers', MaxLength = 100;
        ChangeinWorkinProgressLbl: Label 'Change in Work in Progress', MaxLength = 100;
        BankoverdraftshorttermLbl: Label 'Bank overdraft short-term', MaxLength = 100;
        DeferredRevenueLbl: Label 'Deferred Revenue', MaxLength = 100;
        TotalCurrentLiabilitiesLbl: Label 'Total, Current Liabilities', MaxLength = 100;
        TaxLiabilitiesLbl: Label 'Tax Liabilities', MaxLength = 100;
        SalesTaxVATLiableLbl: Label 'Sales Tax / VAT Liable', MaxLength = 100;
        CollectioninProcessLbl: Label 'Collection in Process', MaxLength = 100;
        TaxesLiableLbl: Label 'Taxes Liable', MaxLength = 100;
        SalesVATReducedLbl: Label 'Sales VAT Reduced', MaxLength = 100;
        SalesVATNormalLbl: Label 'Sales VAT Normal', MaxLength = 100;
        MiscVATPayablesLbl: Label 'Misc VAT Payables', MaxLength = 100;
        EstimatedIncomeTaxLbl: Label 'Estimated Income Tax', MaxLength = 100;
        EstimatedrealestateTaxRealestatechargeLbl: Label 'Estimated real-estate Tax/Real-estate charge ', MaxLength = 100;
        EstimatedPayrolltaxonPensionCostsLbl: Label 'Estimated Payroll tax on Pension Costs', MaxLength = 100;
        TotalTaxLiabilitiesLbl: Label 'Total, Tax Liabilities', MaxLength = 100;
        PayrollLiabilitiesLbl: Label 'Payroll Liabilities', MaxLength = 100;
        EmployeesWithholdingTaxesLbl: Label 'Employees Withholding Taxes', MaxLength = 100;
        StatutorySocialsecurityContributionsLbl: Label 'Statutory Social security Contributions', MaxLength = 100;
        ContractualSocialsecurityContributionsLbl: Label 'Contractual Social security Contributions', MaxLength = 100;
        AttachmentsofEarningLbl: Label 'Attachments of Earning', MaxLength = 100;
        HolidayPayfundLbl: Label 'Holiday Pay fund', MaxLength = 100;
        OtherSalarywageDeductionsLbl: Label 'Other Salary/wage Deductions', MaxLength = 100;
        TotalPayrollLiabilitiesLbl: Label 'Total, Payroll Liabilities', MaxLength = 100;
        OtherCurrentLiabilitiesLbl: Label 'Other Current Liabilities', MaxLength = 100;
        ClearingAccountforFactoringCurrentPortionLbl: Label 'Clearing Account for Factoring, Current Portion', MaxLength = 100;
        CurrentLiabilitiestoEmployeesLbl: Label 'Current Liabilities to Employees', MaxLength = 100;
        ClearingAccountforthirdpartyLbl: Label 'Clearing Account for third party', MaxLength = 100;
        CurrentLoansLbl: Label 'Current Loans', MaxLength = 100;
        LiabilitiesGrantsReceivedLbl: Label 'Liabilities, Grants Received ', MaxLength = 100;
        TotalOtherCurrentLiabilitiesLbl: Label 'Total, Other Current Liabilities', MaxLength = 100;
        AccruedExpensesandDeferredIncomeLbl: Label 'Accrued Expenses and Deferred Income', MaxLength = 100;
        AccruedwagessalariesLbl: Label 'Accrued wages/salaries', MaxLength = 100;
        PaymentsinProcessLbl: Label 'Payments in Process', MaxLength = 100;
        AccruedHolidaypayLbl: Label 'Accrued Holiday pay', MaxLength = 100;
        AccruedPensioncostsLbl: Label 'Accrued Pension costs', MaxLength = 100;
        AccruedInterestExpenseLbl: Label 'Accrued Interest Expense', MaxLength = 100;
        DeferredIncomeLbl: Label 'Deferred Income', MaxLength = 100;
        AccruedContractualcostsLbl: Label 'Accrued Contractual costs', MaxLength = 100;
        OtherAccruedExpensesandDeferredIncomeLbl: Label 'Other Accrued Expenses and Deferred Income', MaxLength = 100;
        TotalAccruedExpensesandDeferredIncomeLbl: Label 'Total, Accrued Expenses and Deferred Income', MaxLength = 100;
        EquityLbl: Label 'Equity', MaxLength = 100;
        EquityPartnerLbl: Label 'Equity Partner ', MaxLength = 100;
        NetResultsLbl: Label 'Net Results ', MaxLength = 100;
        RestrictedEquityLbl: Label 'Restricted Equity ', MaxLength = 100;
        ShareCapitalLbl: Label 'Share Capital ', MaxLength = 100;
        NonRestrictedEquityLbl: Label 'Non-Restricted Equity', MaxLength = 100;
        ProfitorlossfromthepreviousyearLbl: Label 'Profit or loss from the previous year', MaxLength = 100;
        ResultsfortheFinancialyearLbl: Label 'Results for the Financial year', MaxLength = 100;
        DistributionstoShareholdersLbl: Label 'Distributions to Shareholders', MaxLength = 100;
        TotalEquityLbl: Label 'Total, Equity', MaxLength = 100;
        EXPENSESLbl: Label 'EXPENSES', MaxLength = 100;
        FacilityExpensesLbl: Label 'Facility Expenses', MaxLength = 100;
        RentalFacilitiesLbl: Label 'Rental Facilities', MaxLength = 100;
        RentLeasesLbl: Label 'Rent / Leases', MaxLength = 100;
        ElectricityforRentalLbl: Label 'Electricity for Rental', MaxLength = 100;
        HeatingforRentalLbl: Label 'Heating for Rental', MaxLength = 100;
        WaterandSewerageforRentalLbl: Label 'Water and Sewerage for Rental', MaxLength = 100;
        CleaningandWasteforRentalLbl: Label 'Cleaning and Waste for Rental', MaxLength = 100;
        RepairsandMaintenanceforRentalLbl: Label 'Repairs and Maintenance for Rental', MaxLength = 100;
        InsurancesRentalLbl: Label 'Insurances, Rental', MaxLength = 100;
        OtherRentalExpensesLbl: Label 'Other Rental Expenses', MaxLength = 100;
        TotalRentalFacilitiesLbl: Label 'Total, Rental Facilities', MaxLength = 100;
        PropertyExpensesLbl: Label 'Property Expenses', MaxLength = 100;
        SiteFeesLeasesLbl: Label 'Site Fees / Leases', MaxLength = 100;
        ElectricityforPropertyLbl: Label 'Electricity for Property', MaxLength = 100;
        HeatingforPropertyLbl: Label 'Heating for Property', MaxLength = 100;
        WaterandSewerageforPropertyLbl: Label 'Water and Sewerage for Property', MaxLength = 100;
        CleaningandWasteforPropertyLbl: Label 'Cleaning and Waste for Property', MaxLength = 100;
        RepairsandMaintenanceforPropertyLbl: Label 'Repairs and Maintenance for Property', MaxLength = 100;
        InsurancesPropertyLbl: Label 'Insurances, Property', MaxLength = 100;
        OtherPropertyExpensesLbl: Label 'Other Property Expenses', MaxLength = 100;
        TotalPropertyExpensesLbl: Label 'Total, Property Expenses', MaxLength = 100;
        TotalFacilityExpensesLbl: Label 'Total, Facility Expenses', MaxLength = 100;
        FixedAssetsLeasesLbl: Label 'Fixed Assets Leases', MaxLength = 100;
        HireofmachineryLbl: Label 'Hire of machinery', MaxLength = 100;
        HireofcomputersLbl: Label 'Hire of computers', MaxLength = 100;
        HireofotherfixedassetsLbl: Label 'Hire of other fixed assets', MaxLength = 100;
        TotalFixedAssetLeasesLbl: Label 'Total, Fixed Asset Leases', MaxLength = 100;
        LogisticsExpensesLbl: Label 'Logistics Expenses', MaxLength = 100;
        PassengerCarCostsLbl: Label 'Passenger Car Costs', MaxLength = 100;
        TruckCostsLbl: Label 'Truck Costs', MaxLength = 100;
        OthervehicleexpensesLbl: Label 'Other vehicle expenses', MaxLength = 100;
        TotalVehicleExpensesLbl: Label 'Total, Vehicle Expenses', MaxLength = 100;
        FreightCostsLbl: Label 'Freight Costs', MaxLength = 100;
        FreightfeesforgoodsLbl: Label 'Freight fees for goods', MaxLength = 100;
        CustomsandforwardingLbl: Label 'Customs and forwarding', MaxLength = 100;
        FreightfeesprojectsLbl: Label 'Freight fees, projects', MaxLength = 100;
        TotalFreightCostsLbl: Label 'Total, Freight Costs', MaxLength = 100;
        TravelExpensesLbl: Label 'Travel Expenses', MaxLength = 100;
        TicketsLbl: Label 'Tickets', MaxLength = 100;
        RentalvehiclesLbl: Label 'Rental vehicles', MaxLength = 100;
        BoardandlodgingLbl: Label 'Board and lodging', MaxLength = 100;
        OthertravelexpensesLbl: Label 'Other travel expenses', MaxLength = 100;
        TotalTravelExpensesLbl: Label 'Total, Travel Expenses', MaxLength = 100;
        TotalLogisticsExpensesLbl: Label 'Total, Logistics Expenses', MaxLength = 100;
        MarketingandSalesLbl: Label 'Marketing and Sales', MaxLength = 100;
        AdvertisementDevelopmentLbl: Label 'Advertisement Development', MaxLength = 100;
        OutdoorandTransportationAdsLbl: Label 'Outdoor and Transportation Ads', MaxLength = 100;
        AdmatteranddirectmailingsLbl: Label 'Ad matter and direct mailings', MaxLength = 100;
        ConferenceExhibitionSponsorshipLbl: Label 'Conference/Exhibition Sponsorship', MaxLength = 100;
        SamplescontestsgiftsLbl: Label 'Samples, contests, gifts', MaxLength = 100;
        FilmTVradiointernetadsLbl: Label 'Film, TV, radio, internet ads', MaxLength = 100;
        PRandAgencyFeesLbl: Label 'PR and Agency Fees', MaxLength = 100;
        OtheradvertisingfeesLbl: Label 'Other advertising fees', MaxLength = 100;
        TotalAdvertisingLbl: Label 'Total, Advertising', MaxLength = 100;
        OtherMarketingExpensesLbl: Label 'Other Marketing Expenses', MaxLength = 100;
        CatalogspricelistsLbl: Label 'Catalogs, price lists', MaxLength = 100;
        TradePublicationsLbl: Label 'Trade Publications', MaxLength = 100;
        TotalOtherMarketingExpensesLbl: Label 'Total, Other Marketing Expenses', MaxLength = 100;
        SalesExpensesLbl: Label 'Sales Expenses', MaxLength = 100;
        CreditCardChargesLbl: Label 'Credit Card Charges', MaxLength = 100;
        BusinessEntertainingdeductibleLbl: Label 'Business Entertaining, deductible', MaxLength = 100;
        BusinessEntertainingnondeductibleLbl: Label 'Business Entertaining, nondeductible', MaxLength = 100;
        TotalSalesExpensesLbl: Label 'Total, Sales Expenses', MaxLength = 100;
        TotalMarketingandSalesLbl: Label 'Total, Marketing and Sales', MaxLength = 100;
        OfficeExpensesLbl: Label 'Office Expenses', MaxLength = 100;
        PhoneServicesLbl: Label 'Phone Services', MaxLength = 100;
        DataservicesLbl: Label 'Data services', MaxLength = 100;
        PostalfeesLbl: Label 'Postal fees', MaxLength = 100;
        ConsumableExpensiblehardwareLbl: Label 'Consumable/Expensible hardware', MaxLength = 100;
        SoftwareandsubscriptionfeesLbl: Label 'Software and subscription fees', MaxLength = 100;
        TotalOfficeExpensesLbl: Label 'Total, Office Expenses', MaxLength = 100;
        InsurancesandRisksLbl: Label 'Insurances and Risks', MaxLength = 100;
        CorporateInsuranceLbl: Label 'Corporate Insurance', MaxLength = 100;
        DamagesPaidLbl: Label 'Damages Paid', MaxLength = 100;
        BadDebtLossesLbl: Label 'Bad Debt Losses', MaxLength = 100;
        SecurityservicesLbl: Label 'Security services', MaxLength = 100;
        OtherriskexpensesLbl: Label 'Other risk expenses', MaxLength = 100;
        TotalInsurancesandRisksLbl: Label 'Total, Insurances and Risks', MaxLength = 100;
        ManagementandAdminLbl: Label 'Management and Admin', MaxLength = 100;
        ManagementLbl: Label 'Management', MaxLength = 100;
        RemunerationtoDirectorsLbl: Label 'Remuneration to Directors', MaxLength = 100;
        ManagementFeesLbl: Label 'Management Fees', MaxLength = 100;
        AnnualinterrimReportsLbl: Label 'Annual/interrim Reports', MaxLength = 100;
        AnnualgeneralmeetingLbl: Label 'Annual/general meeting', MaxLength = 100;
        AuditandAuditServicesLbl: Label 'Audit and Audit Services', MaxLength = 100;
        TaxadvisoryServicesLbl: Label 'Tax advisory Services', MaxLength = 100;
        TotalManagementFeesLbl: Label 'Total, Management Fees', MaxLength = 100;
        TotalManagementandAdminLbl: Label 'Total, Management and Admin', MaxLength = 100;
        BankingandInterestLbl: Label 'Banking and Interest', MaxLength = 100;
        BankingfeesLbl: Label 'Banking fees', MaxLength = 100;
        PayableInvoiceRoundingLbl: Label 'Payable Invoice Rounding', MaxLength = 100;
        TotalBankingandInterestLbl: Label 'Total, Banking and Interest', MaxLength = 100;
        ExternalServicesExpensesLbl: Label 'External Services/Expenses', MaxLength = 100;
        ExternalServicesLbl: Label 'External Services', MaxLength = 100;
        AccountingServicesLbl: Label 'Accounting Services', MaxLength = 100;
        ITServicesLbl: Label 'IT Services', MaxLength = 100;
        MediaServicesLbl: Label 'Media Services', MaxLength = 100;
        ConsultingServicesLbl: Label 'Consulting Services', MaxLength = 100;
        LegalFeesandAttorneyServicesLbl: Label 'Legal Fees and Attorney Services', MaxLength = 100;
        OtherExternalServicesLbl: Label 'Other External Services', MaxLength = 100;
        TotalExternalServicesLbl: Label 'Total, External Services', MaxLength = 100;
        OtherExternalExpensesLbl: Label 'Other External Expenses', MaxLength = 100;
        LicenseFeesRoyaltiesLbl: Label 'License Fees/Royalties', MaxLength = 100;
        TrademarksPatentsLbl: Label 'Trademarks/Patents', MaxLength = 100;
        AssociationFeesLbl: Label 'Association Fees', MaxLength = 100;
        MiscexternalexpensesLbl: Label 'Misc. external expenses', MaxLength = 100;
        PurchaseDiscountsLbl: Label 'Purchase Discounts', MaxLength = 100;
        TotalOtherExternalExpensesLbl: Label 'Total, Other External Expenses', MaxLength = 100;
        TotalExternalServicesExpensesLbl: Label 'Total, External Services/Expenses', MaxLength = 100;
        PersonnelLbl: Label 'Personnel', MaxLength = 100;
        WagesandSalariesLbl: Label 'Wages and Salaries', MaxLength = 100;
        HourlyWagesLbl: Label 'Hourly Wages', MaxLength = 100;
        OvertimeWagesLbl: Label 'Overtime Wages', MaxLength = 100;
        BonusesLbl: Label 'Bonuses', MaxLength = 100;
        CommissionsPaidLbl: Label 'Commissions Paid', MaxLength = 100;
        PTOAccruedLbl: Label 'PTO Accrued', MaxLength = 100;
        TotalWagesandSalariesLbl: Label 'Total, Wages and Salaries', MaxLength = 100;
        BenefitsPensionLbl: Label 'Benefits/Pension', MaxLength = 100;
        BenefitsLbl: Label 'Benefits', MaxLength = 100;
        TrainingCostsLbl: Label 'Training Costs', MaxLength = 100;
        HealthCareContributionsLbl: Label 'Health Care Contributions', MaxLength = 100;
        EntertainmentofpersonnelLbl: Label 'Entertainment of personnel', MaxLength = 100;
        MandatoryclothingexpensesLbl: Label 'Mandatory clothing expenses', MaxLength = 100;
        OthercashremunerationbenefitsLbl: Label 'Other cash/remuneration benefits', MaxLength = 100;
        TotalBenefitsLbl: Label 'Total, Benefits', MaxLength = 100;
        PensionLbl: Label 'Pension', MaxLength = 100;
        PensionfeesandrecurringcostsLbl: Label 'Pension fees and recurring costs', MaxLength = 100;
        EmployerContributionsLbl: Label 'Employer Contributions', MaxLength = 100;
        TotalPensionLbl: Label 'Total, Pension', MaxLength = 100;
        TotalBenefitsPensionLbl: Label 'Total, Benefits/Pension', MaxLength = 100;
        InsurancesPersonnelLbl: Label 'Insurances, Personnel', MaxLength = 100;
        HealthInsuranceLbl: Label 'Health Insurance', MaxLength = 100;
        DentalInsuranceLbl: Label 'Dental Insurance', MaxLength = 100;
        WorkersCompensationLbl: Label 'Worker''s'' Compensation', MaxLength = 100;
        LifeInsuranceLbl: Label 'Life Insurance', MaxLength = 100;
        TotalInsurancesPersonnelLbl: Label 'Total, Insurances, Personnel', MaxLength = 100;
        TotalPersonnelLbl: Label 'Total, Personnel', MaxLength = 100;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
        DepreciationLandandPropertyLbl: Label 'Depreciation, Land and Property', MaxLength = 100;
        DepreciationFixedAssetsLbl: Label 'Depreciation, Fixed Assets', MaxLength = 100;
        TotalDepreciationLbl: Label 'Total, Depreciation', MaxLength = 100;
        MiscExpensesLbl: Label 'Misc. Expenses', MaxLength = 100;
        CurrencyLossesLbl: Label 'Currency Losses', MaxLength = 100;
        TotalMiscExpensesLbl: Label 'Total, Misc. Expenses', MaxLength = 100;
        TOTALEXPENSESLbl: Label 'TOTAL EXPENSES', MaxLength = 100;
        COSTOFGOODSSOLDLbl: Label 'COST OF GOODS SOLD', MaxLength = 100;
        CostofGoodsLbl: Label 'Cost of Goods', MaxLength = 100;
        CostofMaterialsLbl: Label 'Cost of Materials', MaxLength = 100;
        CostofMaterialsProjectsLbl: Label 'Cost of Materials, Projects', MaxLength = 100;
        TotalCostofGoodsLbl: Label 'Total, Cost of Goods', MaxLength = 100;
        CostofResourcesandServicesLbl: Label 'Cost of Resources and Services', MaxLength = 100;
        CostofLaborLbl: Label 'Cost of Labor', MaxLength = 100;
        CostofLaborProjectsLbl: Label 'Cost of Labor, Projects', MaxLength = 100;
        CostofLaborWarrantyContractLbl: Label 'Cost of Labor, Warranty/Contract', MaxLength = 100;
        TotalCostofResourcesLbl: Label 'Total, Cost of Resources', MaxLength = 100;
        SubcontractedworkLbl: Label 'Subcontracted work', MaxLength = 100;
        ManufVariancesLbl: Label 'Manuf. Variances', MaxLength = 100;
        PurchaseVarianceCapLbl: Label 'Purchase Variance, Cap.', MaxLength = 100;
        CapOverheadVarianceLbl: Label 'Cap. Overhead Variance', MaxLength = 100;
        MfgOverheadVarianceLbl: Label 'Mfg. Overhead Variance', MaxLength = 100;
        TotalManufVariancesLbl: Label 'Total, Manuf. Variances', MaxLength = 100;
        CostofVariancesLbl: Label 'Cost of Variances', MaxLength = 100;
        CostsofJobsLbl: Label 'Costs of Jobs', MaxLength = 100;
        JobCostsAppliedLbl: Label 'Job Costs, Applied', MaxLength = 100;
        TotalCostsofJobsLbl: Label 'Total, Costs of Jobs', MaxLength = 100;
        TOTALCOSTOFGOODSSOLDLbl: Label 'TOTAL COST OF GOODS SOLD', MaxLength = 100;
        IncomeLbl: Label 'Income', MaxLength = 100;
        SalesofGoodsLbl: Label 'Sales of Goods', MaxLength = 100;
        SaleofFinishedGoodsLbl: Label 'Sale of Finished Goods', MaxLength = 100;
        SaleofRawMaterialsLbl: Label 'Sale of Raw Materials', MaxLength = 100;
        ResaleofGoodsLbl: Label 'Resale of Goods', MaxLength = 100;
        TotalSalesofGoodsLbl: Label 'Total, Sales of Goods', MaxLength = 100;
        SaleofResourcesLbl: Label 'Sale of Resources', MaxLength = 100;
        SaleofSubcontractingLbl: Label 'Sale of Subcontracting', MaxLength = 100;
        TotalSalesofResourcesLbl: Label 'Total, Sales of Resources', MaxLength = 100;
        AdditionalRevenueLbl: Label 'Additional Revenue', MaxLength = 100;
        IncomefromsecuritiesLbl: Label 'Income from securities', MaxLength = 100;
        ManagementFeeRevenueLbl: Label 'Management Fee Revenue', MaxLength = 100;
        CurrencyGainsLbl: Label 'Currency Gains', MaxLength = 100;
        OtherIncidentalRevenueLbl: Label 'Other Incidental Revenue', MaxLength = 100;
        TotalAdditionalRevenueLbl: Label 'Total, Additional Revenue', MaxLength = 100;
        JobsandServicesLbl: Label 'Jobs and Services', MaxLength = 100;
        JobSalesAppliedLbl: Label 'Job Sales Applied', MaxLength = 100;
        SalesofServiceContractsLbl: Label 'Sales of Service Contracts', MaxLength = 100;
        SalesofServiceWorkLbl: Label 'Sales of Service Work', MaxLength = 100;
        TotalJobsandServicesLbl: Label 'Total, Jobs and Services', MaxLength = 100;
        RevenueReductionsLbl: Label 'Revenue Reductions', MaxLength = 100;
        SalesDiscountsLbl: Label 'Sales Discounts', MaxLength = 100;
        SalesInvoiceRoundingLbl: Label 'Sales Invoice Rounding', MaxLength = 100;
        SalesReturnsLbl: Label 'Sales Returns', MaxLength = 100;
        TotalRevenueReductionsLbl: Label 'Total, Revenue Reductions', MaxLength = 100;
        TOTALINCOMELbl: Label 'TOTAL INCOME', MaxLength = 100;
        TotalAssetsLbl: Label 'Total Assets', MaxLength = 100;
}