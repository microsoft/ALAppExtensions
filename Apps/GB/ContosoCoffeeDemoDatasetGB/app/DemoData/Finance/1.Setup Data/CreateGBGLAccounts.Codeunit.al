codeunit 10506 "Create GB GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '75110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '82100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '10130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '64140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '83120');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '75960');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '64140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '64140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '64100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '20110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '20110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '64140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '10430');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '20210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '20210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '64130');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '64210');
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
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '64250');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '64230');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '10420');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '10410');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '20320');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '20310');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccount()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '60000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '60001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '10200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '10410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '20310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '30401');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '30449');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '31010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '32000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '32110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '39999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '40000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '40999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '49999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '62000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '62100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), '62199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '62999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '64130');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '64220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '64230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '75100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '75110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '75120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '75199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '77100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '78100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '79999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '80000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '81000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), '81999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '82100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '82200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '82600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '89999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(InvoiceRoundingName(), '10920');
        ContosoGLAccount.AddAccountForLocalization(IncomeName(), '10001');
        ContosoGLAccount.AddAccountForLocalization(SalesOfGoodsName(), '10100');
        ContosoGLAccount.AddAccountForLocalization(SaleOfFinishedGoodsName(), '10110');
        ContosoGLAccount.AddAccountForLocalization(SaleOfRawMaterialsName(), '10120');
        ContosoGLAccount.AddAccountForLocalization(ResaleOfGoodsName(), '10130');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfGoodsName(), '10199');
        ContosoGLAccount.AddAccountForLocalization(SaleOfResourcesName(), '10210');
        ContosoGLAccount.AddAccountForLocalization(SaleOfSubcontractingName(), '10220');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfResourcesName(), '10299');
        ContosoGLAccount.AddAccountForLocalization(AdditionalRevenueName(), '10300');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromSecuritiesName(), '10310');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeeRevenueName(), '10320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '10330');
        ContosoGLAccount.AddAccountForLocalization(CurrencyGainsName(), '10380');
        ContosoGLAccount.AddAccountForLocalization(OtherIncidentalRevenueName(), '10390');
        ContosoGLAccount.AddAccountForLocalization(TotalAdditionalRevenueName(), '10399');
        ContosoGLAccount.AddAccountForLocalization(JobsAndServicesName(), '10400');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '10420');
        ContosoGLAccount.AddAccountForLocalization(SalesOfServiceContractsName(), '10430');
        ContosoGLAccount.AddAccountForLocalization(SalesOfServiceWorkName(), '10440');
        ContosoGLAccount.AddAccountForLocalization(TotalJobsAndServicesName(), '10499');
        ContosoGLAccount.AddAccountForLocalization(RevenueReductionsName(), '10900');
        ContosoGLAccount.AddAccountForLocalization(DiscountsAndAllowancesName(), '10910');
        ContosoGLAccount.AddAccountForLocalization(PaymentToleranceName(), '10930');
        ContosoGLAccount.AddAccountForLocalization(SalesReturnsName(), '10940');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueReductionsName(), '10999');
        ContosoGLAccount.AddAccountForLocalization(TotalIncomeName(), '19990');
        ContosoGLAccount.AddAccountForLocalization(CostOfGoodsSoldName(), '20001');
        ContosoGLAccount.AddAccountForLocalization(CostOfGoodsName(), '20100');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialsName(), '20110');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialsProjectsName(), '20120');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfGoodsName(), '20199');
        ContosoGLAccount.AddAccountForLocalization(CostOfResourcesAndServicesName(), '20200');
        ContosoGLAccount.AddAccountForLocalization(CostOfLaborName(), '20210');
        ContosoGLAccount.AddAccountForLocalization(CostOfLaborProjectsName(), '20220');
        ContosoGLAccount.AddAccountForLocalization(CostOfLaborWarrantyContractName(), '20230');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfResourcesName(), '20299');
        ContosoGLAccount.AddAccountForLocalization(CostsOfJobsName(), '20300');
        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '20320');
        ContosoGLAccount.AddAccountForLocalization(TotalCostsOfJobsName(), '20399');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedWorkName(), '20400');
        ContosoGLAccount.AddAccountForLocalization(CostOfVariancesName(), '20500');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfGoodsSoldName(), '29990');
        ContosoGLAccount.AddAccountForLocalization(ExpensesName(), '30001');
        ContosoGLAccount.AddAccountForLocalization(FacilityExpensesName(), '30002');
        ContosoGLAccount.AddAccountForLocalization(RentalFacilitiesName(), '30100');
        ContosoGLAccount.AddAccountForLocalization(RentLeasesName(), '30110');
        ContosoGLAccount.AddAccountForLocalization(ElectricityForRentalName(), '30120');
        ContosoGLAccount.AddAccountForLocalization(HeatingForRentalName(), '30130');
        ContosoGLAccount.AddAccountForLocalization(WaterAndSewerageForRentalName(), '30140');
        ContosoGLAccount.AddAccountForLocalization(CleaningAndWasteForRentalName(), '30150');
        ContosoGLAccount.AddAccountForLocalization(RepairsAndMaintenanceForRentalName(), '30160');
        ContosoGLAccount.AddAccountForLocalization(InsurancesRentalName(), '30170');
        ContosoGLAccount.AddAccountForLocalization(OtherRentalExpensesName(), '30190');
        ContosoGLAccount.AddAccountForLocalization(TotalRentalFacilitiesName(), '30199');
        ContosoGLAccount.AddAccountForLocalization(PropertyExpensesName(), '30200');
        ContosoGLAccount.AddAccountForLocalization(SiteFeesLeasesName(), '30210');
        ContosoGLAccount.AddAccountForLocalization(ElectricityForPropertyName(), '30220');
        ContosoGLAccount.AddAccountForLocalization(HeatingForPropertyName(), '30230');
        ContosoGLAccount.AddAccountForLocalization(WaterAndSewerageForPropertyName(), '30240');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforPropertyName(), '30250');
        ContosoGLAccount.AddAccountForLocalization(RepairsAndMaintenanceForPropertyName(), '30260');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPropertyName(), '30270');
        ContosoGLAccount.AddAccountForLocalization(OtherPropertyExpensesName(), '30290');
        ContosoGLAccount.AddAccountForLocalization(TotalPropertyExpensesName(), '30298');
        ContosoGLAccount.AddAccountForLocalization(TotalFacilityExpensesName(), '30299');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsLeasesName(), '30300');
        ContosoGLAccount.AddAccountForLocalization(HireOfMachineryName(), '30310');
        ContosoGLAccount.AddAccountForLocalization(HireOfComputersName(), '30320');
        ContosoGLAccount.AddAccountForLocalization(HireOfOtherFixedAssetsName(), '30330');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetLeasesName(), '30399');
        ContosoGLAccount.AddAccountForLocalization(LogisticsExpensesName(), '30400');
        ContosoGLAccount.AddAccountForLocalization(PassengerCarCostsName(), '30410');
        ContosoGLAccount.AddAccountForLocalization(TruckCostsName(), '30420');
        ContosoGLAccount.AddAccountForLocalization(OtherVehicleExpensesName(), '30430');
        ContosoGLAccount.AddAccountForLocalization(FreightCostsName(), '30450');
        ContosoGLAccount.AddAccountForLocalization(FreightFeesForGoodsName(), '30460');
        ContosoGLAccount.AddAccountForLocalization(CustomsAndForwardingName(), '30470');
        ContosoGLAccount.AddAccountForLocalization(FreightFeesProjectsName(), '30480');
        ContosoGLAccount.AddAccountForLocalization(TotalFreightCostsName(), '30499');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesName(), '30500');
        ContosoGLAccount.AddAccountForLocalization(TicketsName(), '30510');
        ContosoGLAccount.AddAccountForLocalization(RentalVehiclesName(), '30520');
        ContosoGLAccount.AddAccountForLocalization(BoardAndLodgingName(), '30530');
        ContosoGLAccount.AddAccountForLocalization(OtherTravelExpensesName(), '30540');
        ContosoGLAccount.AddAccountForLocalization(TotalTravelExpensesName(), '30598');
        ContosoGLAccount.AddAccountForLocalization(TotalLogisticsExpensesName(), '30599');
        ContosoGLAccount.AddAccountForLocalization(MarketingAndSalesName(), '30600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '30601');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementDevelopmentName(), '30610');
        ContosoGLAccount.AddAccountForLocalization(OutdoorAndTransportationAdsName(), '30620');
        ContosoGLAccount.AddAccountForLocalization(AdMatterAndDirectMailingsName(), '30630');
        ContosoGLAccount.AddAccountForLocalization(ConferenceExhibitionSponsorshipName(), '30640');
        ContosoGLAccount.AddAccountForLocalization(SamplesContestsGiftsName(), '30650');
        ContosoGLAccount.AddAccountForLocalization(FilmTvRadioInternetAdsName(), '30660');
        ContosoGLAccount.AddAccountForLocalization(PrAndAgencyFeesName(), '30670');
        ContosoGLAccount.AddAccountForLocalization(OtherAdvertisingFeesName(), '30680');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvertisingName(), '30699');
        ContosoGLAccount.AddAccountForLocalization(OtherMarketingExpensesName(), '30700');
        ContosoGLAccount.AddAccountForLocalization(CatalogsPriceListsName(), '30710');
        ContosoGLAccount.AddAccountForLocalization(TradePublicationsName(), '30720');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherMarketingExpensesName(), '30799');
        ContosoGLAccount.AddAccountForLocalization(SalesExpensesName(), '30800');
        ContosoGLAccount.AddAccountForLocalization(CreditCardChargesName(), '30810');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingDeductibleName(), '30820');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingNondeductibleName(), '30830');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesExpensesName(), '30898');
        ContosoGLAccount.AddAccountForLocalization(TotalMarketingAndSalesName(), '30899');
        ContosoGLAccount.AddAccountForLocalization(OfficeExpensesName(), '31001');
        ContosoGLAccount.AddAccountForLocalization(PhoneServicesName(), '31020');
        ContosoGLAccount.AddAccountForLocalization(DataServicesName(), '31030');
        ContosoGLAccount.AddAccountForLocalization(PostalFeesName(), '31040');
        ContosoGLAccount.AddAccountForLocalization(ConsumableExpensibleHardwareName(), '31050');
        ContosoGLAccount.AddAccountForLocalization(SoftwareAndSubscriptionFeesName(), '31060');
        ContosoGLAccount.AddAccountForLocalization(TotalOfficeExpensesName(), '31099');
        ContosoGLAccount.AddAccountForLocalization(InsurancesAndRisksName(), '31100');
        ContosoGLAccount.AddAccountForLocalization(CorporateInsuranceName(), '31110');
        ContosoGLAccount.AddAccountForLocalization(DamagesPaidName(), '31120');
        ContosoGLAccount.AddAccountForLocalization(BadDebtLossesName(), '31130');
        ContosoGLAccount.AddAccountForLocalization(SecurityServicesName(), '31140');
        ContosoGLAccount.AddAccountForLocalization(OtherRiskExpensesName(), '31150');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesAndRisksName(), '31199');
        ContosoGLAccount.AddAccountForLocalization(ManagementAndAdminName(), '31200');
        ContosoGLAccount.AddAccountForLocalization(ManagementName(), '31201');
        ContosoGLAccount.AddAccountForLocalization(RemunerationToDirectorsName(), '31210');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeesName(), '31220');
        ContosoGLAccount.AddAccountForLocalization(AnnualInterrimReportsName(), '31230');
        ContosoGLAccount.AddAccountForLocalization(AnnualGeneralMeetingName(), '31240');
        ContosoGLAccount.AddAccountForLocalization(AuditAndAuditServicesName(), '31250');
        ContosoGLAccount.AddAccountForLocalization(TaxAdvisoryServicesName(), '31260');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementFeesName(), '31298');
        ContosoGLAccount.AddAccountForLocalization(TotalManagementAndAdminName(), '31299');
        ContosoGLAccount.AddAccountForLocalization(BankingAndInterestName(), '31300');
        ContosoGLAccount.AddAccountForLocalization(BankingFeesName(), '31310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '31320');
        ContosoGLAccount.AddAccountForLocalization(PayableInvoiceRoundingName(), '31330');
        ContosoGLAccount.AddAccountForLocalization(TotalBankingAndInterestName(), '31399');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesExpensesName(), '31400');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesName(), '31401');
        ContosoGLAccount.AddAccountForLocalization(AccountingServicesName(), '31410');
        ContosoGLAccount.AddAccountForLocalization(ITServicesName(), '31420');
        ContosoGLAccount.AddAccountForLocalization(MediaServicesName(), '31430');
        ContosoGLAccount.AddAccountForLocalization(ConsultingServicesName(), '31440');
        ContosoGLAccount.AddAccountForLocalization(LegalFeesAndAttorneyServicesName(), '31450');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalServicesName(), '31460');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesName(), '31499');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalExpensesName(), '31500');
        ContosoGLAccount.AddAccountForLocalization(LicenseFeesRoyaltiesName(), '31510');
        ContosoGLAccount.AddAccountForLocalization(TrademarksPatentsName(), '31520');
        ContosoGLAccount.AddAccountForLocalization(AssociationFeesName(), '31530');
        ContosoGLAccount.AddAccountForLocalization(MiscExternalExpensesName(), '31540');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDiscountsName(), '31550');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherExternalExpensesName(), '31598');
        ContosoGLAccount.AddAccountForLocalization(TotalExternalServicesExpensesName(), '31599');
        ContosoGLAccount.AddAccountForLocalization(WagesAndSalariesName(), '32100');
        ContosoGLAccount.AddAccountForLocalization(HourlyWagesName(), '32120');
        ContosoGLAccount.AddAccountForLocalization(OvertimeWagesName(), '32130');
        ContosoGLAccount.AddAccountForLocalization(BonusesName(), '32140');
        ContosoGLAccount.AddAccountForLocalization(CommissionsPaidName(), '32150');
        ContosoGLAccount.AddAccountForLocalization(PTOAccruedName(), '32160');
        ContosoGLAccount.AddAccountForLocalization(PayrollTaxExpenseName(), '32170');
        ContosoGLAccount.AddAccountForLocalization(TotalWagesAndSalariesName(), '32199');
        ContosoGLAccount.AddAccountForLocalization(BenefitsPensionName(), '32200');
        ContosoGLAccount.AddAccountForLocalization(BenefitsName(), '32201');
        ContosoGLAccount.AddAccountForLocalization(TrainingCostsName(), '32210');
        ContosoGLAccount.AddAccountForLocalization(HealthCareContributionsName(), '32220');
        ContosoGLAccount.AddAccountForLocalization(EntertainmentOfpersonnelName(), '32230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '32240');
        ContosoGLAccount.AddAccountForLocalization(MandatoryClothingExpensesName(), '32250');
        ContosoGLAccount.AddAccountForLocalization(OtherCashRemunerationBenefitsName(), '32260');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsName(), '32299');
        ContosoGLAccount.AddAccountForLocalization(PensionName(), '32300');
        ContosoGLAccount.AddAccountForLocalization(PensionFeesAndRecurringCostsName(), '32310');
        ContosoGLAccount.AddAccountForLocalization(EmployerContributionsName(), '32320');
        ContosoGLAccount.AddAccountForLocalization(TotalPensionName(), '32398');
        ContosoGLAccount.AddAccountForLocalization(TotalBenefitsPensionName(), '32399');
        ContosoGLAccount.AddAccountForLocalization(InsurancesPersonnelName(), '32400');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '32410');
        ContosoGLAccount.AddAccountForLocalization(DentalInsuranceName(), '32420');
        ContosoGLAccount.AddAccountForLocalization(WorkersCompensationName(), '32430');
        ContosoGLAccount.AddAccountForLocalization(LifeInsuranceName(), '32440');
        ContosoGLAccount.AddAccountForLocalization(TotalInsurancesPersonnelName(), '32499');
        ContosoGLAccount.AddAccountForLocalization(DepreciationLandAndPropertyName(), '40100');
        ContosoGLAccount.AddAccountForLocalization(DepreciationFixedAssetsName(), '40110');
        ContosoGLAccount.AddAccountForLocalization(MiscExpensesName(), '41000');
        ContosoGLAccount.AddAccountForLocalization(CurrencyLossesName(), '41100');
        ContosoGLAccount.AddAccountForLocalization(TotalMiscExpensesName(), '41999');
        ContosoGLAccount.AddAccountForLocalization(TotalExpensesName(), '49000');
        ContosoGLAccount.AddAccountForLocalization(IntangibleFixedAssetsName(), '61000');
        ContosoGLAccount.AddAccountForLocalization(DevelopmentExpenditureName(), '61100');
        ContosoGLAccount.AddAccountForLocalization(TenancySiteLeaseholdAndSimilarRightsName(), '61200');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '61300');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsForIntangibleFixedAssetsName(), '61400');
        ContosoGLAccount.AddAccountForLocalization(TotalIntangibleFixedAssetsName(), '61999');
        ContosoGLAccount.AddAccountForLocalization(BuildingName(), '62110');
        ContosoGLAccount.AddAccountForLocalization(CostOfImprovementsToLeasedPropertyName(), '62120');
        ContosoGLAccount.AddAccountForLocalization(LandName(), '62130');
        ContosoGLAccount.AddAccountForLocalization(MachineryAndEquipmentName(), '62200');
        ContosoGLAccount.AddAccountForLocalization(EquipmentsAndToolsName(), '62210');
        ContosoGLAccount.AddAccountForLocalization(ComputersName(), '62220');
        ContosoGLAccount.AddAccountForLocalization(CarsAndOtherTransportEquipmentsName(), '62230');
        ContosoGLAccount.AddAccountForLocalization(LeasedAssetsName(), '62240');
        ContosoGLAccount.AddAccountForLocalization(TotalMachineryAndEquipmentName(), '62299');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationName(), '62300');
        ContosoGLAccount.AddAccountForLocalization(FinancialAndFixedAssetsName(), '63000');
        ContosoGLAccount.AddAccountForLocalization(LongTermReceivablesName(), '63100');
        ContosoGLAccount.AddAccountForLocalization(ParticipationinGroupCompaniesName(), '63200');
        ContosoGLAccount.AddAccountForLocalization(LoansToPartnersOrRelatedPartiesName(), '63300');
        ContosoGLAccount.AddAccountForLocalization(DeferredTaxAssetsName(), '63400');
        ContosoGLAccount.AddAccountForLocalization(OtherLongTermReceivablesName(), '63500');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialAndFixedAssetsName(), '63999');
        ContosoGLAccount.AddAccountForLocalization(InventoriesProductsAndWorkInProgressName(), '64000');
        ContosoGLAccount.AddAccountForLocalization(SuppliesAndConsumablesName(), '64110');
        ContosoGLAccount.AddAccountForLocalization(ProductsInProgressName(), '64120');
        ContosoGLAccount.AddAccountForLocalization(GoodsForResaleName(), '64140');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsForGoodsAndServicesName(), '64160');
        ContosoGLAccount.AddAccountForLocalization(OtherInventoryItemsName(), '64170');
        ContosoGLAccount.AddAccountForLocalization(WorkInProgressName(), '64200');
        ContosoGLAccount.AddAccountForLocalization(WorkInProgressFinishedGoodsName(), '64210');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedCostsName(), '64240');
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '64250');
        ContosoGLAccount.AddAccountForLocalization(TotalWorkInProgressName(), '64299');
        ContosoGLAccount.AddAccountForLocalization(TotalInventoryProductsAndWorkInProgressName(), '64999');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '75000');
        ContosoGLAccount.AddAccountForLocalization(ContractualReceivablesName(), '75130');
        ContosoGLAccount.AddAccountForLocalization(ConsignmentReceivablesName(), '75140');
        ContosoGLAccount.AddAccountForLocalization(CreditCardsAndVouchersReceivablesName(), '75150');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentReceivablesName(), '75900');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivableFromEmployeesName(), '75910');
        ContosoGLAccount.AddAccountForLocalization(AccruedIncomeNotYetInvoicedName(), '75920');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountsForTaxesAndchargesName(), '75930');
        ContosoGLAccount.AddAccountForLocalization(TaxAssetsName(), '75940');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATReducedName(), '75950');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATNormalName(), '75960');
        ContosoGLAccount.AddAccountForLocalization(MiscVATReceivablesName(), '75970');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablesFromGroupCompaniesName(), '75980');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentReceivablesName(), '75998');
        ContosoGLAccount.AddAccountForLocalization(TotalReceivablesName(), '75999');
        ContosoGLAccount.AddAccountForLocalization(PrepaidExpensesAndAccruedIncomeName(), '76000');
        ContosoGLAccount.AddAccountForLocalization(PrepaidRentName(), '76100');
        ContosoGLAccount.AddAccountForLocalization(PrepaidInterestExpenseName(), '76200');
        ContosoGLAccount.AddAccountForLocalization(AccruedRentalIncomeName(), '76300');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestIncomeName(), '76400');
        ContosoGLAccount.AddAccountForLocalization(AssetsInTheFormOfPrepaidExpensesName(), '76500');
        ContosoGLAccount.AddAccountForLocalization(OtherPrepaidExpensesAndAccruedIncomeName(), '76600');
        ContosoGLAccount.AddAccountForLocalization(TotalPrepaidExpensesAndAccruedIncomeName(), '76999');
        ContosoGLAccount.AddAccountForLocalization(ShortTermInvestmentsName(), '77000');
        ContosoGLAccount.AddAccountForLocalization(ConvertibleDebtInstrumentsName(), '77200');
        ContosoGLAccount.AddAccountForLocalization(OtherShortTermInvestmentsName(), '77300');
        ContosoGLAccount.AddAccountForLocalization(WriteDownOfShortTermInvestmentsName(), '77400');
        ContosoGLAccount.AddAccountForLocalization(TotalShortTermInvestmentsName(), '77999');
        ContosoGLAccount.AddAccountForLocalization(CashAndBankName(), '78000');
        ContosoGLAccount.AddAccountForLocalization(BusinessAccountOperatingDomesticName(), '78200');
        ContosoGLAccount.AddAccountForLocalization(BusinessAccountOperatingForeignName(), '78300');
        ContosoGLAccount.AddAccountForLocalization(OtherBankAccountsName(), '78400');
        ContosoGLAccount.AddAccountForLocalization(CertificateOfDepositName(), '78500');
        ContosoGLAccount.AddAccountForLocalization(TotalCashAndBankName(), '78999');
        ContosoGLAccount.AddAccountForLocalization(BondsAndDebentureLoansName(), '81100');
        ContosoGLAccount.AddAccountForLocalization(ConvertiblesLoansName(), '81200');
        ContosoGLAccount.AddAccountForLocalization(OtherLongTermLiabilitiesName(), '81300');
        ContosoGLAccount.AddAccountForLocalization(BankOverdraftFacilitiesName(), '81400');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiesName(), '82000');
        ContosoGLAccount.AddAccountForLocalization(AdvancesFromCustomersName(), '82300');
        ContosoGLAccount.AddAccountForLocalization(ChangeInWorkInProgressName(), '82400');
        ContosoGLAccount.AddAccountForLocalization(BankOverdraftShortTermName(), '82500');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenueName(), '82700');
        ContosoGLAccount.AddAccountForLocalization(TotalCurrentLiabilitiesName(), '82999');
        ContosoGLAccount.AddAccountForLocalization(TaxLiabilitiesName(), '83000');
        ContosoGLAccount.AddAccountForLocalization(TaxesLiableName(), '83100');
        ContosoGLAccount.AddAccountForLocalization(SalesVATReducedName(), '83110');
        ContosoGLAccount.AddAccountForLocalization(SalesVATNormalName(), '83120');
        ContosoGLAccount.AddAccountForLocalization(MiscVATPayablesName(), '83130');
        ContosoGLAccount.AddAccountForLocalization(EstimatedIncomeTaxName(), '83200');
        ContosoGLAccount.AddAccountForLocalization(EstimatedRealEstateTaxRealEstateChargeName(), '83300');
        ContosoGLAccount.AddAccountForLocalization(EstimatedPayrollTaxOnPensionCostsName(), '83400');
        ContosoGLAccount.AddAccountForLocalization(TotalTaxLiabilitiesName(), '83999');
        ContosoGLAccount.AddAccountForLocalization(PayrollLiabilitiesName(), '84000');
        ContosoGLAccount.AddAccountForLocalization(EmployeesWithholdingTaxesName(), '84100');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialSecurityContributionsName(), '84200');
        ContosoGLAccount.AddAccountForLocalization(ContractualSocialSecurityContributionsName(), '84300');
        ContosoGLAccount.AddAccountForLocalization(AttachmentsOfEarningName(), '84400');
        ContosoGLAccount.AddAccountForLocalization(HolidayPayfundName(), '84500');
        ContosoGLAccount.AddAccountForLocalization(OtherSalaryWageDeductionsName(), '84600');
        ContosoGLAccount.AddAccountForLocalization(TotalPayrollLiabilitiesName(), '84999');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentLiabilitiesName(), '85000');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountForFactoringCurrentPortionName(), '85100');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiesToEmployeesName(), '85200');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountForThirdPartyName(), '85300');
        ContosoGLAccount.AddAccountForLocalization(CurrentLoansName(), '85400');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesGrantsReceivedName(), '85500');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherCurrentLiabilitiesName(), '85999');
        ContosoGLAccount.AddAccountForLocalization(AccruedExpensesAndDeferredIncomeName(), '86000');
        ContosoGLAccount.AddAccountForLocalization(AccruedWagesSalariesName(), '86100');
        ContosoGLAccount.AddAccountForLocalization(AccruedHolidayPayName(), '86200');
        ContosoGLAccount.AddAccountForLocalization(AccruedPensionCostsName(), '86300');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestExpenseName(), '86400');
        ContosoGLAccount.AddAccountForLocalization(DeferredIncomeName(), '86500');
        ContosoGLAccount.AddAccountForLocalization(AccruedContractualCostsName(), '86600');
        ContosoGLAccount.AddAccountForLocalization(OtherAccruedExpensesAndDeferredIncomeName(), '86700');
        ContosoGLAccount.AddAccountForLocalization(TotalAccruedExpensesAndDeferredIncomeName(), '86999');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '90000');
        ContosoGLAccount.AddAccountForLocalization(EquityPartnerName(), '90100');
        ContosoGLAccount.AddAccountForLocalization(NetResultsName(), '90111');
        ContosoGLAccount.AddAccountForLocalization(RestrictedEquityName(), '90200');
        ContosoGLAccount.AddAccountForLocalization(ShareCapitalName(), '90210');
        ContosoGLAccount.AddAccountForLocalization(DividendsName(), '90220');
        ContosoGLAccount.AddAccountForLocalization(NonRestrictedEquityName(), '90300');
        ContosoGLAccount.AddAccountForLocalization(ProfitOrLossFromThePreviousYearName(), '90310');
        ContosoGLAccount.AddAccountForLocalization(ResultsfortheFinancialyearName(), '90320');
        ContosoGLAccount.AddAccountForLocalization(TotalEquityName(), '99999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '10000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Income(), IncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOfGoods(), SalesOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleOfFinishedGoods(), SaleOfFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleOfRawMaterials(), SaleOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleOfGoods(), ResaleOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfGoods(), TotalSalesOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesOfGoods() + '..' + TotalSalesOfGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleOfResources(), SaleOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleOfSubcontracting(), SaleOfSubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfResources(), TotalSalesOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofResources() + '..' + TotalSalesOfResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdditionalRevenue(), AdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromSecurities(), IncomeFromSecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFeeRevenue(), ManagementFeeRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyGains(), CurrencyGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherIncidentalRevenue(), OtherIncidentalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdditionalRevenue(), TotalAdditionalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, AdditionalRevenue() + '..' + TotalAdditionalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobsAndServices(), JobsAndServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOfServiceContracts(), SalesOfServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOfServiceWork(), SalesOfServiceWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalJobsAndServices(), TotalJobsAndServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, JobsAndServices() + '..' + TotalJobsAndServices(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueReductions(), RevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountsAndAllowances(), DiscountsAndAllowancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvoiceRounding(), InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentTolerance(), PaymentToleranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesReturns(), SalesReturnsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenueReductions(), TotalRevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, RevenueReductions() + '..' + TotalRevenueReductions(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIncome(), TotalIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, Income() + '..' + TotalIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfGoodsSold(), CostOfGoodsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfGoods(), CostOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterials(), CostOfMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterialsProjects(), CostOfMaterialsProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfGoods(), TotalCostOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostOfGoods() + '..' + TotalCostOfGoods(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfResourcesAndServices(), CostOfResourcesAndServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfLabor(), CostOfLaborName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfLaborProjects(), CostOfLaborProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfLaborWarrantyContract(), CostOfLaborWarrantyContractName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfResources(), TotalCostOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostOfResourcesAndServices() + '..' + TotalCostOfResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostsOfJobs(), CostsOfJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostsOfJobs(), TotalCostsOfJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CostsOfJobs() + '..' + TotalCostsOfJobs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedWork(), SubcontractedWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfVariances(), CostOfVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfGoodsSold(), TotalCostOfGoodsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostOfGoodsSold() + '..' + TotalCostOfGoodsSold(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Expenses(), ExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FacilityExpenses(), FacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalFacilities(), RentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentLeases(), RentLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityForRental(), ElectricityForRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingForRental(), HeatingForRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterAndSewerageForRental(), WaterAndSewerageForRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningAndWasteForRental(), CleaningAndWasteForRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsAndMaintenanceForRental(), RepairsAndMaintenanceForRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesRental(), InsurancesRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRentalExpenses(), OtherRentalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRentalFacilities(), TotalRentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, RentalFacilities() + '..' + TotalRentalFacilities(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyExpenses(), PropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SiteFeesLeases(), SiteFeesLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityForProperty(), ElectricityForPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingForProperty(), HeatingForPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterAndSewerageForProperty(), WaterAndSewerageForPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningAndWasteForProperty(), CleaningandWasteforPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsAndMaintenanceForProperty(), RepairsAndMaintenanceForPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesProperty(), InsurancesPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPropertyExpenses(), OtherPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPropertyExpenses(), TotalPropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PropertyExpenses() + '..' + TotalPropertyExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFacilityExpenses(), TotalFacilityExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FacilityExpenses() + '..' + TotalFacilityExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsLeases(), FixedAssetsLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HireOfMachinery(), HireOfMachineryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HireOfComputers(), HireOfComputersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HireOfOtherFixedAssets(), HireOfOtherFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssetLeases(), TotalFixedAssetLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FixedAssetsLeases() + '..' + TotalFixedAssetLeases(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LogisticsExpenses(), LogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PassengerCarCosts(), PassengerCarCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TruckCosts(), TruckCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherVehicleExpenses(), OtherVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreightCosts(), FreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FreightFeesForGoods(), FreightFeesForGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomsAndForwarding(), CustomsAndForwardingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreightFeesProjects(), FreightFeesProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFreightCosts(), TotalFreightCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, FreightCosts() + '..' + TotalFreightCosts(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpenses(), TravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tickets(), TicketsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RentalVehicles(), RentalVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BoardAndLodging(), BoardAndLodgingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherTravelExpenses(), OtherTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTravelExpenses(), TotalTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, TravelExpenses() + '..' + TotalTravelExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLogisticsExpenses(), TotalLogisticsExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, LogisticsExpenses() + '..' + TotalLogisticsExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MarketingAndSales(), MarketingAndSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisementDevelopment(), AdvertisementDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutdoorAndTransportationAds(), OutdoorAndTransportationAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdMatterAndDirectMailings(), AdMatterAndDirectMailingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConferenceExhibitionSponsorship(), ConferenceExhibitionSponsorshipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SamplesContestsGifts(), SamplesContestsGiftsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FilmTvRadioInternetAds(), FilmTvRadioInternetAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrAndAgencyFees(), PrAndAgencyFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAdvertisingFees(), OtherAdvertisingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvertising(), TotalAdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Advertising() + '..' + TotalAdvertising(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherMarketingExpenses(), OtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CatalogsPriceLists(), CatalogsPriceListsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradePublications(), TradePublicationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherMarketingExpenses(), TotalOtherMarketingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherMarketingExpenses() + '..' + TotalOtherMarketingExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesExpenses(), SalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreditCardCharges(), CreditCardChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingDeductible(), BusinessEntertainingDeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingNondeductible(), BusinessEntertainingNondeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesExpenses(), TotalSalesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesExpenses() + '..' + TotalSalesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMarketingAndSales(), TotalMarketingAndSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MarketingAndSales() + '..' + TotalMarketingAndSales(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeExpenses(), OfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneServices(), PhoneServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DataServices(), DataServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostalFees(), PostalFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumableExpensibleHardware(), ConsumableExpensibleHardwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SoftwareAndSubscriptionFees(), SoftwareAndSubscriptionFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOfficeExpenses(), TotalOfficeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OfficeExpenses() + '..' + TotalOfficeExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesAndRisks(), InsurancesAndRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateInsurance(), CorporateInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DamagesPaid(), DamagesPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BadDebtLosses(), BadDebtLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecurityServices(), SecurityServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRiskExpenses(), OtherRiskExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesAndRisks(), TotalInsurancesAndRisksName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesAndRisks() + '..' + TotalInsurancesAndRisks(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementAndAdmin(), ManagementAndAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Management(), ManagementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RemunerationToDirectors(), RemunerationToDirectorsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFees(), ManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualInterrimReports(), AnnualInterrimReportsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualGeneralMeeting(), AnnualGeneralMeetingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AuditAndAuditServices(), AuditAndAuditServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAdvisoryServices(), TaxAdvisoryServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementFees(), TotalManagementFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Management() + '..' + TotalManagementFees(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManagementAndAdmin(), TotalManagementAndAdminName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ManagementAndAdmin() + '..' + TotalManagementAndAdmin(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankingAndInterest(), BankingAndInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankingFees(), BankingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestExpenses(), CreateGLAccount.InterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayableInvoiceRounding(), PayableInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBankingAndInterest(), TotalBankingAndInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BankingAndInterest() + '..' + TotalBankingAndInterest(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServicesExpenses(), ExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServices(), ExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountingServices(), AccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ITServices(), ITServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MediaServices(), MediaServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingServices(), ConsultingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalFeesAndAttorneyServices(), LegalFeesAndAttorneyServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalServices(), OtherExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServices(), TotalExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServices() + '..' + TotalExternalServices(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalExpenses(), OtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LicenseFeesRoyalties(), LicenseFeesRoyaltiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TrademarksPatents(), TrademarksPatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssociationFees(), AssociationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscExternalExpenses(), MiscExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseDiscounts(), PurchaseDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherExternalExpenses(), TotalOtherExternalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherExternalExpenses() + '..' + TotalOtherExternalExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExternalServicesExpenses(), TotalExternalServicesExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExternalServicesExpenses() + '..' + TotalExternalServicesExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesAndSalaries(), WagesAndSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HourlyWages(), HourlyWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OvertimeWages(), OvertimeWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bonuses(), BonusesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommissionsPaid(), CommissionsPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PTOAccrued(), PTOAccruedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollTaxExpense(), PayrollTaxExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWagesAndSalaries(), TotalWagesAndSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, WagesAndSalaries() + '..' + TotalWagesAndSalaries(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BenefitsPension(), BenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Benefits(), BenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TrainingCosts(), TrainingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthCareContributions(), HealthCareContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EntertainmentOfpersonnel(), EntertainmentOfpersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Allowances(), CreateGLAccount.AllowancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MandatoryClothingExpenses(), MandatoryClothingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCashRemunerationBenefits(), OtherCashRemunerationBenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefits(), TotalBenefitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Benefits() + '..' + TotalBenefits(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Pension(), PensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PensionFeesAndRecurringCosts(), PensionFeesAndRecurringCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployerContributions(), EmployerContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPension(), TotalPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Pension() + '..' + TotalPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBenefitsPension(), TotalBenefitsPensionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, BenefitsPension() + '..' + TotalBenefitsPension(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesPersonnel(), InsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DentalInsurance(), DentalInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkersCompensation(), WorkersCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LifeInsurance(), LifeInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsurancesPersonnel(), TotalInsurancesPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, InsurancesPersonnel() + '..' + TotalInsurancesPersonnel(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationLandAndProperty(), DepreciationLandAndPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(DepreciationFixedAssets(), DepreciationFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscExpenses(), MiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyLosses(), CurrencyLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMiscExpenses(), TotalMiscExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MiscExpenses() + '..' + TotalMiscExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalExpenses(), TotalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Expenses() + '..' + TotalExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), CreateGLAccount.BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleFixedAssets(), IntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DevelopmentExpenditure(), DevelopmentExpenditureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TenancySiteLeaseholdAndSimilarRights(), TenancySiteLeaseholdAndSimilarRightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsForIntangibleFixedAssets(), AdvancedPaymentsForIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIntangibleFixedAssets(), TotalIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleFixedAssets() + '..' + TotalIntangibleFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Building(), BuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfImprovementsToLeasedProperty(), CostOfImprovementsToLeasedPropertyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Land(), LandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MachineryAndEquipment(), MachineryAndEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquipmentsAndTools(), EquipmentsAndToolsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Computers(), ComputersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarsAndOtherTransportEquipments(), CarsAndOtherTransportEquipmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LeasedAssets(), LeasedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMachineryAndEquipment(), TotalMachineryAndEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, MachineryAndEquipment() + '..' + TotalMachineryAndEquipment(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciation(), AccumulatedDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialAndFixedAssets(), FinancialAndFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermReceivables(), LongTermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ParticipationinGroupCompanies(), ParticipationinGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LoansToPartnersOrRelatedParties(), LoansToPartnersOrRelatedPartiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredTaxAssets(), DeferredTaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongTermReceivables(), OtherLongTermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialAndFixedAssets(), TotalFinancialAndFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialAndFixedAssets() + '..' + TotalFinancialAndFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoriesProductsAndWorkInProgress(), InventoriesProductsAndWorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SuppliesAndConsumables(), SuppliesAndConsumablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProductsInProgress(), ProductsInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsForResale(), GoodsForResaleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsForGoodsAndServices(), AdvancedPaymentsForGoodsAndServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInventoryItems(), OtherInventoryItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkInProgress(), WorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WorkInProgressFinishedGoods(), WorkInProgressFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedCosts(), WIPAccruedCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWorkInProgress(), TotalWorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, WorkInProgress() + '..' + TotalWorkInProgress(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInventoryProductsAndWorkInProgress(), TotalInventoryProductsAndWorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, InventoriesProductsAndWorkInProgress() + '..' + TotalInventoryProductsAndWorkInProgress(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualReceivables(), ContractualReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsignmentReceivables(), ConsignmentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreditCardsAndVouchersReceivables(), CreditCardsAndVouchersReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentReceivables(), OtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivableFromEmployees(), CurrentReceivableFromEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedIncomeNotYetInvoiced(), AccruedIncomeNotYetInvoicedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountsForTaxesAndcharges(), ClearingAccountsForTaxesAndchargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAssets(), TaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATReduced(), PurchaseVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATNormal(), PurchaseVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATReceivables(), MiscVATReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablesFromGroupCompanies(), CurrentReceivablesFromGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentReceivables(), TotalOtherCurrentReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentReceivables() + '..' + TotalOtherCurrentReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalReceivables(), TotalReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Receivables() + '..' + TotalReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidExpensesAndAccruedIncome(), PrepaidExpensesAndAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidRent(), PrepaidRentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidInterestExpense(), PrepaidInterestExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedRentalIncome(), AccruedRentalIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestIncome(), AccruedInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssetsInTheFormOfPrepaidExpenses(), AssetsInTheFormOfPrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPrepaidExpensesAndAccruedIncome(), OtherPrepaidExpensesAndAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPrepaidExpensesAndAccruedIncome(), TotalPrepaidExpensesAndAccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, PrepaidExpensesAndAccruedIncome() + '..' + TotalPrepaidExpensesAndAccruedIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShortTermInvestments(), ShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertibleDebtInstruments(), ConvertibleDebtInstrumentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherShortTermInvestments(), OtherShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WriteDownOfShortTermInvestments(), WriteDownOfShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalShortTermInvestments(), TotalShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, ShortTermInvestments() + '..' + TotalShortTermInvestments(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashAndBank(), CashAndBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessAccountOperatingDomestic(), BusinessAccountOperatingDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BusinessAccountOperatingForeign(), BusinessAccountOperatingForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherBankAccounts(), OtherBankAccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CertificateOfDeposit(), CertificateOfDepositName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCashAndBank(), TotalCashAndBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CashAndBank() + '..' + TotalCashAndBank(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BondsAndDebentureLoans(), BondsAndDebentureLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Liabilities(), CreateGLAccount.LiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertiblesLoans(), ConvertiblesLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongTermLiabilities(), OtherLongTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOverdraftFacilities(), BankOverdraftFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilities(), CurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancesFromCustomers(), AdvancesFromCustomersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChangeInWorkInProgress(), ChangeInWorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOverdraftShortTerm(), BankOverdraftShortTermName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredRevenue(), DeferredRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCurrentLiabilities(), TotalCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CurrentLiabilities() + '..' + TotalCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxLiabilities(), TaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesLiable(), TaxesLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATReduced(), SalesVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATNormal(), SalesVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATPayables(), MiscVATPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedIncomeTax(), EstimatedIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedRealEstateTaxRealEstateCharge(), EstimatedRealEstateTaxRealEstateChargeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedPayrollTaxOnPensionCosts(), EstimatedPayrollTaxOnPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTaxLiabilities(), TotalTaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxLiabilities() + '..' + TotalTaxLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollLiabilities(), PayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesWithholdingTaxes(), EmployeesWithholdingTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialSecurityContributions(), StatutorySocialSecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualSocialSecurityContributions(), ContractualSocialSecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AttachmentsOfEarning(), AttachmentsOfEarningName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HolidayPayfund(), HolidayPayfundName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSalaryWageDeductions(), OtherSalaryWageDeductionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPayrollLiabilities(), TotalPayrollLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, PayrollLiabilities() + '..' + TotalPayrollLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentLiabilities(), OtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountForFactoringCurrentPortion(), ClearingAccountForFactoringCurrentPortionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilitiesToEmployees(), CurrentLiabilitiesToEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountForThirdParty(), ClearingAccountForThirdPartyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLoans(), CurrentLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LiabilitiesGrantsReceived(), LiabilitiesGrantsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherCurrentLiabilities(), TotalOtherCurrentLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherCurrentLiabilities() + '..' + TotalOtherCurrentLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedExpensesAndDeferredIncome(), AccruedExpensesAndDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedWagesSalaries(), AccruedWagesSalariesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedHolidayPay(), AccruedHolidayPayName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedPensionCosts(), AccruedPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterestExpense(), AccruedInterestExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredIncome(), DeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedContractualCosts(), AccruedContractualCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAccruedExpensesAndDeferredIncome(), OtherAccruedExpensesAndDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccruedExpensesAndDeferredIncome(), TotalAccruedExpensesAndDeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccruedExpensesAndDeferredIncome() + '..' + TotalAccruedExpensesAndDeferredIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquityPartner(), EquityPartnerName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetResults(), NetResultsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RestrictedEquity(), RestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShareCapital(), ShareCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Dividends(), DividendsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonRestrictedEquity(), NonRestrictedEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitOrLossFromThePreviousYear(), ProfitOrLossFromThePreviousYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResultsfortheFinancialyear(), ResultsfortheFinancialyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEquity(), TotalEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, Equity() + '..' + TotalEquity(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalVehicleExpenses(), CreateGLAccount.TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + CreateGLAccount.TotalVehicleExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelExpenses(), CreateGLAccount.TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelExpenses() + '..' + CreateGLAccount.TotalPersonnelExpenses(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalFixedAssetDepreciation(), CreateGLAccount.TotalFixedAssetDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.DepreciationofFixedAssets() + '..' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsReceivableTotal(), CreateGLAccount.AccountsReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsReceivable() + '..' + CreateGLAccount.AccountsReceivableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Assets() + '..' + CreateGLAccount.TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LongtermLiabilitiesTotal(), CreateGLAccount.LongtermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongtermLiabilities() + '..' + CreateGLAccount.LongtermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildingsTotal(), CreateGLAccount.LandandBuildingsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LandandBuildingsBeginTotal() + '..' + CreateGLAccount.LandandBuildingsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TangibleFixedAssetsTotal(), CreateGLAccount.TangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + CreateGLAccount.TangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilities(), CreateGLAccount.TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Liabilities() + '..' + CreateGLAccount.TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VehicleExpenses(), CreateGLAccount.VehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelExpenses(), CreateGLAccount.PersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DepreciationofFixedAssets(), CreateGLAccount.DepreciationofFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
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

    local procedure AssignCategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), CreateGLAccount.TotalAssets());
            GLAccountCategory."Account Category"::Liabilities:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Liabilities(), CreateGLAccount.TotalLiabilities());
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, Equity(), TotalEquity());
            GLAccountCategory."Account Category"::Income:
                UpdateGLAccounts(GLAccountCategory, Income(), TotalIncome());
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                begin
                    UpdateGLAccounts(GLAccountCategory, CostOfGoodsSold(), CreateGLAccount.JobCosts());
                    UpdateGLAccounts(GLAccountCategory, CostOfVariances(), TotalCostOfGoodsSold())
                end;
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, Expenses(), TotalExpenses());
                    UpdateGLAccounts(GLAccountCategory, JobCostsApplied(), SubcontractedWork());
                end;
        end;
    end;

    local procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cash(), CertificateOfDeposit());
            GLAccountCategoryMgt.GetPrepaidExpenses():
                UpdateGLAccounts(GLAccountCategory, PrepaidRent(), OtherPrepaidExpensesAndAccruedIncome());
            GLAccountCategoryMgt.GetInventory():
                begin
                    UpdateGLAccounts(GLAccountCategory, InventoriesProductsAndWorkInProgress(), WorkInProgressFinishedGoods());
                    UpdateGLAccounts(GLAccountCategory, WIPAccruedCosts(), TotalInventoryProductsAndWorkInProgress());
                end;
            GLAccountCategoryMgt.GetEquipment():
                UpdateGLAccounts(GLAccountCategory, EquipmentsAndTools(), TotalMachineryAndEquipment());
            GLAccountCategoryMgt.GetAccumDeprec():
                UpdateGLAccounts(GLAccountCategory, AccumulatedDepreciation(), AccumulatedDepreciation());
            GLAccountCategoryMgt.GetCurrentLiabilities():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.VendorsDomestic(), LiabilitiesGrantsReceived());
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, EmployeesWithholdingTaxes(), OtherSalaryWageDeductions());
            GLAccountCategoryMgt.GetDistrToShareholders():
                UpdateGLAccounts(GLAccountCategory, Dividends(), Dividends());
            GLAccountCategoryMgt.GetIncomeService():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesofResources(), TotalSalesOfResources());
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, SalesOfGoods(), TotalSalesOfGoods());
            GLAccountCategoryMgt.GetCOGSLabor():
                UpdateGLAccounts(GLAccountCategory, CostOfResourcesAndServices(), TotalCostOfResources());
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, CostOfGoods(), TotalCostOfGoods());
            GLAccountCategoryMgt.GetRentExpense():
                UpdateGLAccounts(GLAccountCategory, RentLeases(), RentLeases());
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Advertising(), TotalOtherMarketingExpenses());
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
            GLAccountCategoryMgt.GetFeesExpense():
                UpdateGLAccounts(GLAccountCategory, BankingFees(), CreateGLAccount.InterestExpenses());
            GLAccountCategoryMgt.GetBadDebtExpense():
                UpdateGLAccounts(GLAccountCategory, BadDebtLosses(), BadDebtLosses());
            GLAccountCategoryMgt.GetInsuranceExpense():
                UpdateGLAccounts(GLAccountCategory, InsurancesPersonnel(), TotalInsurancesPersonnel());
            GLAccountCategoryMgt.GetBenefitsExpense():
                UpdateGLAccounts(GLAccountCategory, BenefitsPension(), TotalBenefitsPension());
            GLAccountCategoryMgt.GetRepairsExpense():
                UpdateGLAccounts(GLAccountCategory, RepairsAndMaintenanceForRental(), RepairsAndMaintenanceForRental());
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, ElectricityForRental(), CleaningAndWasteForRental());
            GLAccountCategoryMgt.GetJobSalesContra():
                UpdateGLAccounts(GLAccountCategory, JobSalesApplied(), SalesOfServiceWork());
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                UpdateGLAccounts(GLAccountCategory, JobCostsApplied(), SubcontractedWork());
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

    procedure Income(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeName()));
    end;

    procedure IncomeName(): Text[100]
    begin
        exit(IncomeTok);
    end;

    procedure SalesOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOfGoodsName()));
    end;

    procedure SalesOfGoodsName(): Text[100]
    begin
        exit(SalesOfGoodsTok);
    end;

    procedure SaleOfFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleOfFinishedGoodsName()));
    end;

    procedure SaleOfFinishedGoodsName(): Text[100]
    begin
        exit(SaleOfFinishedGoodsTok);
    end;

    procedure SaleOfRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleOfRawMaterialsName()));
    end;

    procedure SaleOfRawMaterialsName(): Text[100]
    begin
        exit(SaleOfRawMaterialsTok);
    end;

    procedure ResaleOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleOfGoodsName()));
    end;

    procedure ResaleOfGoodsName(): Text[100]
    begin
        exit(ResaleOfGoodsTok);
    end;

    procedure TotalSalesOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfGoodsName()));
    end;

    procedure TotalSalesOfGoodsName(): Text[100]
    begin
        exit(TotalSalesOfGoodsTok);
    end;

    procedure SaleOfResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleOfResourcesName()));
    end;

    procedure SaleOfResourcesName(): Text[100]
    begin
        exit(SaleOfResourcesTok);
    end;

    procedure SaleOfSubcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleOfSubcontractingName()));
    end;

    procedure SaleOfSubcontractingName(): Text[100]
    begin
        exit(SaleOfSubcontractingTok);
    end;

    procedure TotalSalesOfResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfResourcesName()));
    end;

    procedure TotalSalesOfResourcesName(): Text[100]
    begin
        exit(TotalSalesOfResourcesTok);
    end;

    procedure AdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionalRevenueName()));
    end;

    procedure AdditionalRevenueName(): Text[100]
    begin
        exit(AdditionalRevenueTok);
    end;

    procedure InvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoiceRoundingName()));
    end;

    procedure InvoiceRoundingName(): Text[100]
    begin
        exit(InvoiceRoundingTok);
    end;

    procedure IncomeFromSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromSecuritiesName()));
    end;

    procedure IncomeFromSecuritiesName(): Text[100]
    begin
        exit(IncomeFromSecuritiesTok);
    end;

    procedure ManagementFeeRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeeRevenueName()));
    end;

    procedure ManagementFeeRevenueName(): Text[100]
    begin
        exit(ManagementFeeRevenueTok);
    end;

    procedure CurrencyGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyGainsName()));
    end;

    procedure CurrencyGainsName(): Text[100]
    begin
        exit(CurrencyGainsTok);
    end;

    procedure OtherIncidentalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherIncidentalRevenueName()));
    end;

    procedure OtherIncidentalRevenueName(): Text[100]
    begin
        exit(OtherIncidentalRevenueTok);
    end;

    procedure TotalAdditionalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdditionalRevenueName()));
    end;

    procedure TotalAdditionalRevenueName(): Text[100]
    begin
        exit(TotalAdditionalRevenueTok);
    end;

    procedure JobsAndServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobsAndServicesName()));
    end;

    procedure JobsAndServicesName(): Text[100]
    begin
        exit(JobsAndServicesTok);
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedTok);
    end;

    procedure SalesOfServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOfServiceContractsName()));
    end;

    procedure SalesOfServiceContractsName(): Text[100]
    begin
        exit(SalesOfServiceContractsTok);
    end;

    procedure SalesOfServiceWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOfServiceWorkName()));
    end;

    procedure SalesOfServiceWorkName(): Text[100]
    begin
        exit(SalesOfServiceWorkTok);
    end;

    procedure TotalJobsAndServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalJobsAndServicesName()));
    end;

    procedure TotalJobsAndServicesName(): Text[100]
    begin
        exit(TotalJobsAndServicesTok);
    end;

    procedure RevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueReductionsName()));
    end;

    procedure RevenueReductionsName(): Text[100]
    begin
        exit(RevenueReductionsTok);
    end;

    procedure DiscountsAndAllowances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsAndAllowancesName()));
    end;

    procedure DiscountsAndAllowancesName(): Text[100]
    begin
        exit(DiscountsAndAllowancesTok);
    end;

    procedure PaymentTolerance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentToleranceName()));
    end;

    procedure PaymentToleranceName(): Text[100]
    begin
        exit(PaymentToleranceTok);
    end;

    procedure SalesReturns(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesReturnsName()));
    end;

    procedure SalesReturnsName(): Text[100]
    begin
        exit(SalesReturnsTok);
    end;

    procedure TotalRevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueReductionsName()));
    end;

    procedure TotalRevenueReductionsName(): Text[100]
    begin
        exit(TotalRevenueReductionsTok);
    end;

    procedure TotalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIncomeName()));
    end;

    procedure TotalIncomeName(): Text[100]
    begin
        exit(TotalIncomeTok);
    end;

    procedure CostOfGoodsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfGoodsSoldName()));
    end;

    procedure CostOfGoodsSoldName(): Text[100]
    begin
        exit(CostOfGoodsSoldTok);
    end;

    procedure CostOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfGoodsName()));
    end;

    procedure CostOfGoodsName(): Text[100]
    begin
        exit(CostOfGoodsTok);
    end;

    procedure CostOfMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialsName()));
    end;

    procedure CostOfMaterialsName(): Text[100]
    begin
        exit(CostOfMaterialsTok);
    end;

    procedure CostOfMaterialsProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialsProjectsName()));
    end;

    procedure CostOfMaterialsProjectsName(): Text[100]
    begin
        exit(CostOfMaterialsProjectsTok);
    end;

    procedure TotalCostOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfGoodsName()));
    end;

    procedure TotalCostOfGoodsName(): Text[100]
    begin
        exit(TotalCostOfGoodsTok);
    end;

    procedure CostOfResourcesAndServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfResourcesAndServicesName()));
    end;

    procedure CostOfResourcesAndServicesName(): Text[100]
    begin
        exit(CostOfResourcesAndServicesTok);
    end;

    procedure CostOfLabor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfLaborName()));
    end;

    procedure CostOfLaborName(): Text[100]
    begin
        exit(CostOfLaborTok);
    end;

    procedure CostOfLaborProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfLaborProjectsName()));
    end;

    procedure CostOfLaborProjectsName(): Text[100]
    begin
        exit(CostOfLaborProjectsTok);
    end;

    procedure CostOfLaborWarrantyContract(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfLaborWarrantyContractName()));
    end;

    procedure CostOfLaborWarrantyContractName(): Text[100]
    begin
        exit(CostOfLaborWarrantyContractTok);
    end;

    procedure TotalCostOfResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfResourcesName()));
    end;

    procedure TotalCostOfResourcesName(): Text[100]
    begin
        exit(TotalCostOfResourcesTok);
    end;

    procedure CostsOfJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostsOfJobsName()));
    end;

    procedure CostsOfJobsName(): Text[100]
    begin
        exit(CostsOfJobsTok);
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedTok);
    end;

    procedure TotalCostsOfJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostsOfJobsName()));
    end;

    procedure TotalCostsOfJobsName(): Text[100]
    begin
        exit(TotalCostsOfJobsTok);
    end;

    procedure SubcontractedWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedWorkName()));
    end;

    procedure SubcontractedWorkName(): Text[100]
    begin
        exit(SubcontractedWorkTok);
    end;

    procedure CostOfVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfVariancesName()));
    end;

    procedure CostOfVariancesName(): Text[100]
    begin
        exit(CostOfVariancesTok);
    end;

    procedure TotalCostOfGoodsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfGoodsSoldName()));
    end;

    procedure TotalCostOfGoodsSoldName(): Text[100]
    begin
        exit(TotalCostOfGoodsSoldTok);
    end;

    procedure Expenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesName()));
    end;

    procedure ExpensesName(): Text[100]
    begin
        exit(ExpensesTok);
    end;

    procedure FacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FacilityExpensesName()));
    end;

    procedure FacilityExpensesName(): Text[100]
    begin
        exit(FacilityExpensesTok);
    end;

    procedure RentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalFacilitiesName()));
    end;

    procedure RentalFacilitiesName(): Text[100]
    begin
        exit(RentalFacilitiesTok);
    end;

    procedure RentLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentLeasesName()));
    end;

    procedure RentLeasesName(): Text[100]
    begin
        exit(RentLeasesTok);
    end;

    procedure ElectricityForRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityForRentalName()));
    end;

    procedure ElectricityForRentalName(): Text[100]
    begin
        exit(ElectricityForRentalTok);
    end;

    procedure HeatingForRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingForRentalName()));
    end;

    procedure HeatingForRentalName(): Text[100]
    begin
        exit(HeatingForRentalTok);
    end;

    procedure WaterAndSewerageForRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterAndSewerageForRentalName()));
    end;

    procedure WaterAndSewerageForRentalName(): Text[100]
    begin
        exit(WaterAndSewerageForRentalTok);
    end;

    procedure CleaningAndWasteForRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningAndWasteForRentalName()));
    end;

    procedure CleaningAndWasteForRentalName(): Text[100]
    begin
        exit(CleaningAndWasteForRentalTok);
    end;

    procedure RepairsAndMaintenanceForRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsAndMaintenanceForRentalName()));
    end;

    procedure RepairsAndMaintenanceForRentalName(): Text[100]
    begin
        exit(RepairsAndMaintenanceForRentalTok);
    end;

    procedure InsurancesRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesRentalName()));
    end;

    procedure InsurancesRentalName(): Text[100]
    begin
        exit(InsurancesRentalTok);
    end;

    procedure OtherRentalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRentalExpensesName()));
    end;

    procedure OtherRentalExpensesName(): Text[100]
    begin
        exit(OtherRentalExpensesTok);
    end;

    procedure TotalRentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRentalFacilitiesName()));
    end;

    procedure TotalRentalFacilitiesName(): Text[100]
    begin
        exit(TotalRentalFacilitiesTok);
    end;

    procedure PropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyExpensesName()));
    end;

    procedure PropertyExpensesName(): Text[100]
    begin
        exit(PropertyExpensesTok);
    end;

    procedure SiteFeesLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SiteFeesLeasesName()));
    end;

    procedure SiteFeesLeasesName(): Text[100]
    begin
        exit(SiteFeesLeasesTok);
    end;

    procedure ElectricityForProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityForPropertyName()));
    end;

    procedure ElectricityForPropertyName(): Text[100]
    begin
        exit(ElectricityForPropertyTok);
    end;

    procedure HeatingForProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingForPropertyName()));
    end;

    procedure HeatingForPropertyName(): Text[100]
    begin
        exit(HeatingForPropertyTok);
    end;

    procedure WaterAndSewerageForProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterAndSewerageForPropertyName()));
    end;

    procedure WaterAndSewerageForPropertyName(): Text[100]
    begin
        exit(WaterAndSewerageForPropertyTok);
    end;

    procedure CleaningAndWasteForProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforPropertyName()));
    end;

    procedure CleaningandWasteforPropertyName(): Text[100]
    begin
        exit(CleaningAndWasteForPropertyTok);
    end;

    procedure RepairsAndMaintenanceForProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsAndMaintenanceForPropertyName()));
    end;

    procedure RepairsAndMaintenanceForPropertyName(): Text[100]
    begin
        exit(RepairsAndMaintenanceForPropertyTok);
    end;

    procedure InsurancesProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPropertyName()));
    end;

    procedure InsurancesPropertyName(): Text[100]
    begin
        exit(InsurancesPropertyTok);
    end;

    procedure OtherPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPropertyExpensesName()));
    end;

    procedure OtherPropertyExpensesName(): Text[100]
    begin
        exit(OtherPropertyExpensesTok);
    end;

    procedure TotalPropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPropertyExpensesName()));
    end;

    procedure TotalPropertyExpensesName(): Text[100]
    begin
        exit(TotalPropertyExpensesTok);
    end;

    procedure TotalFacilityExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFacilityExpensesName()));
    end;

    procedure TotalFacilityExpensesName(): Text[100]
    begin
        exit(TotalFacilityExpensesTok);
    end;

    procedure FixedAssetsLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsLeasesName()));
    end;

    procedure FixedAssetsLeasesName(): Text[100]
    begin
        exit(FixedAssetsLeasesTok);
    end;

    procedure HireOfMachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireOfMachineryName()));
    end;

    procedure HireOfMachineryName(): Text[100]
    begin
        exit(HireOfMachineryTok);
    end;

    procedure HireOfComputers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireOfComputersName()));
    end;

    procedure HireOfComputersName(): Text[100]
    begin
        exit(HireOfComputersTok);
    end;

    procedure HireOfOtherFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireOfOtherFixedAssetsName()));
    end;

    procedure HireOfOtherFixedAssetsName(): Text[100]
    begin
        exit(HireOfOtherFixedAssetsTok);
    end;

    procedure TotalFixedAssetLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetLeasesName()));
    end;

    procedure TotalFixedAssetLeasesName(): Text[100]
    begin
        exit(TotalFixedAssetLeasesTok);
    end;

    procedure LogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LogisticsExpensesName()));
    end;

    procedure LogisticsExpensesName(): Text[100]
    begin
        exit(LogisticsExpensesTok);
    end;

    procedure PassengerCarCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PassengerCarCostsName()));
    end;

    procedure PassengerCarCostsName(): Text[100]
    begin
        exit(PassengerCarCostsTok);
    end;

    procedure TruckCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckCostsName()));
    end;

    procedure TruckCostsName(): Text[100]
    begin
        exit(TruckCostsTok);
    end;

    procedure OtherVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherVehicleExpensesName()));
    end;

    procedure OtherVehicleExpensesName(): Text[100]
    begin
        exit(OtherVehicleExpensesTok);
    end;

    procedure FreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightCostsName()));
    end;

    procedure FreightCostsName(): Text[100]
    begin
        exit(FreightCostsTok);
    end;

    procedure FreightFeesForGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightFeesForGoodsName()));
    end;

    procedure FreightFeesForGoodsName(): Text[100]
    begin
        exit(FreightFeesForGoodsTok);
    end;

    procedure CustomsAndForwarding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomsAndForwardingName()));
    end;

    procedure CustomsAndForwardingName(): Text[100]
    begin
        exit(CustomsAndForwardingTok);
    end;

    procedure FreightFeesProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightFeesProjectsName()));
    end;

    procedure FreightFeesProjectsName(): Text[100]
    begin
        exit(FreightFeesProjectsTok);
    end;

    procedure TotalFreightCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFreightCostsName()));
    end;

    procedure TotalFreightCostsName(): Text[100]
    begin
        exit(TotalFreightCostsTok);
    end;

    procedure TravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesName()));
    end;

    procedure TravelExpensesName(): Text[100]
    begin
        exit(TravelExpensesTok);
    end;

    procedure Tickets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TicketsName()));
    end;

    procedure TicketsName(): Text[100]
    begin
        exit(TicketsTok);
    end;

    procedure RentalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalVehiclesName()));
    end;

    procedure RentalVehiclesName(): Text[100]
    begin
        exit(RentalVehiclesTok);
    end;

    procedure BoardAndLodging(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BoardAndLodgingName()));
    end;

    procedure BoardAndLodgingName(): Text[100]
    begin
        exit(BoardAndLodgingTok);
    end;

    procedure OtherTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherTravelExpensesName()));
    end;

    procedure OtherTravelExpensesName(): Text[100]
    begin
        exit(OtherTravelExpensesTok);
    end;

    procedure TotalTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTravelExpensesName()));
    end;

    procedure TotalTravelExpensesName(): Text[100]
    begin
        exit(TotalTravelExpensesTok);
    end;

    procedure TotalLogisticsExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLogisticsExpensesName()));
    end;

    procedure TotalLogisticsExpensesName(): Text[100]
    begin
        exit(TotalLogisticsExpensesTok);
    end;

    procedure MarketingAndSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketingAndSalesName()));
    end;

    procedure MarketingAndSalesName(): Text[100]
    begin
        exit(MarketingAndSalesTok);
    end;

    procedure AdvertisementDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementDevelopmentName()));
    end;

    procedure AdvertisementDevelopmentName(): Text[100]
    begin
        exit(AdvertisementDevelopmentTok);
    end;

    procedure OutdoorAndTransportationAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutdoorAndTransportationAdsName()));
    end;

    procedure OutdoorAndTransportationAdsName(): Text[100]
    begin
        exit(OutdoorAndTransportationAdsTok);
    end;

    procedure AdMatterAndDirectMailings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdMatterAndDirectMailingsName()));
    end;

    procedure AdMatterAndDirectMailingsName(): Text[100]
    begin
        exit(AdMatterAndDirectMailingsTok);
    end;

    procedure ConferenceExhibitionSponsorship(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConferenceExhibitionSponsorshipName()));
    end;

    procedure ConferenceExhibitionSponsorshipName(): Text[100]
    begin
        exit(ConferenceExhibitionSponsorshipTok);
    end;

    procedure SamplesContestsGifts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SamplesContestsGiftsName()));
    end;

    procedure SamplesContestsGiftsName(): Text[100]
    begin
        exit(SamplesContestsGiftsTok);
    end;

    procedure FilmTvRadioInternetAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FilmTvRadioInternetAdsName()));
    end;

    procedure FilmTvRadioInternetAdsName(): Text[100]
    begin
        exit(FilmTvRadioInternetAdsTok);
    end;

    procedure PrAndAgencyFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrAndAgencyFeesName()));
    end;

    procedure PrAndAgencyFeesName(): Text[100]
    begin
        exit(PrAndAgencyFeesTok);
    end;

    procedure OtherAdvertisingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAdvertisingFeesName()));
    end;

    procedure OtherAdvertisingFeesName(): Text[100]
    begin
        exit(OtherAdvertisingFeesTok);
    end;

    procedure TotalAdvertising(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvertisingName()));
    end;

    procedure TotalAdvertisingName(): Text[100]
    begin
        exit(TotalAdvertisingTok);
    end;

    procedure OtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherMarketingExpensesName()));
    end;

    procedure OtherMarketingExpensesName(): Text[100]
    begin
        exit(OtherMarketingExpensesTok);
    end;

    procedure CatalogsPriceLists(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CatalogsPriceListsName()));
    end;

    procedure CatalogsPriceListsName(): Text[100]
    begin
        exit(CatalogsPriceListsTok);
    end;

    procedure TradePublications(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradePublicationsName()));
    end;

    procedure TradePublicationsName(): Text[100]
    begin
        exit(TradePublicationsTok);
    end;

    procedure TotalOtherMarketingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherMarketingExpensesName()));
    end;

    procedure TotalOtherMarketingExpensesName(): Text[100]
    begin
        exit(TotalOtherMarketingExpensesTok);
    end;

    procedure SalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesExpensesName()));
    end;

    procedure SalesExpensesName(): Text[100]
    begin
        exit(SalesExpensesTok);
    end;

    procedure CreditCardCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditCardChargesName()));
    end;

    procedure CreditCardChargesName(): Text[100]
    begin
        exit(CreditCardChargesTok);
    end;

    procedure BusinessEntertainingDeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingDeductibleName()));
    end;

    procedure BusinessEntertainingDeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingDeductibleTok);
    end;

    procedure BusinessEntertainingNondeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingNondeductibleName()));
    end;

    procedure BusinessEntertainingNondeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingNondeductibleTok);
    end;

    procedure TotalSalesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesExpensesName()));
    end;

    procedure TotalSalesExpensesName(): Text[100]
    begin
        exit(TotalSalesExpensesTok);
    end;

    procedure TotalMarketingAndSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMarketingAndSalesName()));
    end;

    procedure TotalMarketingAndSalesName(): Text[100]
    begin
        exit(TotalMarketingAndSalesTok);
    end;

    procedure OfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeExpensesName()));
    end;

    procedure OfficeExpensesName(): Text[100]
    begin
        exit(OfficeExpensesTok);
    end;

    procedure PhoneServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneServicesName()));
    end;

    procedure PhoneServicesName(): Text[100]
    begin
        exit(PhoneServicesTok);
    end;

    procedure DataServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DataServicesName()));
    end;

    procedure DataServicesName(): Text[100]
    begin
        exit(DataServicesTok);
    end;

    procedure PostalFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostalFeesName()));
    end;

    procedure PostalFeesName(): Text[100]
    begin
        exit(PostalFeesTok);
    end;

    procedure ConsumableExpensibleHardware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumableExpensibleHardwareName()));
    end;

    procedure ConsumableExpensibleHardwareName(): Text[100]
    begin
        exit(ConsumableExpensibleHardwareTok);
    end;

    procedure SoftwareAndSubscriptionFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareAndSubscriptionFeesName()));
    end;

    procedure SoftwareAndSubscriptionFeesName(): Text[100]
    begin
        exit(SoftwareAndSubscriptionFeesTok);
    end;

    procedure TotalOfficeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOfficeExpensesName()));
    end;

    procedure TotalOfficeExpensesName(): Text[100]
    begin
        exit(TotalOfficeExpensesTok);
    end;

    procedure InsurancesAndRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesAndRisksName()));
    end;

    procedure InsurancesAndRisksName(): Text[100]
    begin
        exit(InsurancesAndRisksTok);
    end;

    procedure CorporateInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateInsuranceName()));
    end;

    procedure CorporateInsuranceName(): Text[100]
    begin
        exit(CorporateInsuranceTok);
    end;

    procedure DamagesPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DamagesPaidName()));
    end;

    procedure DamagesPaidName(): Text[100]
    begin
        exit(DamagesPaidTok);
    end;

    procedure BadDebtLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BadDebtLossesName()));
    end;

    procedure BadDebtLossesName(): Text[100]
    begin
        exit(BadDebtLossesTok);
    end;

    procedure SecurityServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecurityServicesName()));
    end;

    procedure SecurityServicesName(): Text[100]
    begin
        exit(SecurityServicesTok);
    end;

    procedure OtherRiskExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRiskExpensesName()));
    end;

    procedure OtherRiskExpensesName(): Text[100]
    begin
        exit(OtherRiskExpensesTok);
    end;

    procedure TotalInsurancesAndRisks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesAndRisksName()));
    end;

    procedure TotalInsurancesAndRisksName(): Text[100]
    begin
        exit(TotalInsurancesAndRisksTok);
    end;

    procedure ManagementAndAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementAndAdminName()));
    end;

    procedure ManagementAndAdminName(): Text[100]
    begin
        exit(ManagementAndAdminTok);
    end;

    procedure Management(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementName()));
    end;

    procedure ManagementName(): Text[100]
    begin
        exit(ManagementTok);
    end;

    procedure RemunerationToDirectors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RemunerationToDirectorsName()));
    end;

    procedure RemunerationToDirectorsName(): Text[100]
    begin
        exit(RemunerationToDirectorsTok);
    end;

    procedure ManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeesName()));
    end;

    procedure ManagementFeesName(): Text[100]
    begin
        exit(ManagementFeesTok);
    end;

    procedure AnnualInterrimReports(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualInterrimReportsName()));
    end;

    procedure AnnualInterrimReportsName(): Text[100]
    begin
        exit(AnnualInterrimReportsTok);
    end;

    procedure AnnualGeneralMeeting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualGeneralMeetingName()));
    end;

    procedure AnnualGeneralMeetingName(): Text[100]
    begin
        exit(AnnualGeneralMeetingTok);
    end;

    procedure AuditAndAuditServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditAndAuditServicesName()));
    end;

    procedure AuditAndAuditServicesName(): Text[100]
    begin
        exit(AuditAndAuditServicesTok);
    end;

    procedure TaxAdvisoryServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAdvisoryServicesName()));
    end;

    procedure TaxAdvisoryServicesName(): Text[100]
    begin
        exit(TaxAdvisoryServicesTok);
    end;

    procedure TotalManagementFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementFeesName()));
    end;

    procedure TotalManagementFeesName(): Text[100]
    begin
        exit(TotalManagementFeesTok);
    end;

    procedure TotalManagementAndAdmin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManagementAndAdminName()));
    end;

    procedure TotalManagementAndAdminName(): Text[100]
    begin
        exit(TotalManagementAndAdminTok);
    end;

    procedure BankingAndInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingAndInterestName()));
    end;

    procedure BankingAndInterestName(): Text[100]
    begin
        exit(BankingAndInterestTok);
    end;

    procedure BankingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankingFeesName()));
    end;

    procedure BankingFeesName(): Text[100]
    begin
        exit(BankingFeesTok);
    end;

    procedure PayableInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayableInvoiceRoundingName()));
    end;

    procedure PayableInvoiceRoundingName(): Text[100]
    begin
        exit(PayableInvoiceRoundingTok);
    end;

    procedure TotalBankingAndInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBankingAndInterestName()));
    end;

    procedure TotalBankingAndInterestName(): Text[100]
    begin
        exit(TotalBankingAndInterestTok);
    end;

    procedure ExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesExpensesName()));
    end;

    procedure ExternalServicesExpensesName(): Text[100]
    begin
        exit(ExternalServicesExpensesTok);
    end;

    procedure ExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesName()));
    end;

    procedure ExternalServicesName(): Text[100]
    begin
        exit(ExternalServicesTok);
    end;

    procedure AccountingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingServicesName()));
    end;

    procedure AccountingServicesName(): Text[100]
    begin
        exit(AccountingServicesTok);
    end;

    procedure ITServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ITServicesName()));
    end;

    procedure ITServicesName(): Text[100]
    begin
        exit(ITServicesTok);
    end;

    procedure MediaServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MediaServicesName()));
    end;

    procedure MediaServicesName(): Text[100]
    begin
        exit(MediaServicesTok);
    end;

    procedure ConsultingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingServicesName()));
    end;

    procedure ConsultingServicesName(): Text[100]
    begin
        exit(ConsultingServicesTok);
    end;

    procedure LegalFeesAndAttorneyServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalFeesAndAttorneyServicesName()));
    end;

    procedure LegalFeesAndAttorneyServicesName(): Text[100]
    begin
        exit(LegalFeesAndAttorneyServicesTok);
    end;

    procedure OtherExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalServicesName()));
    end;

    procedure OtherExternalServicesName(): Text[100]
    begin
        exit(OtherExternalServicesTok);
    end;

    procedure TotalExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesName()));
    end;

    procedure TotalExternalServicesName(): Text[100]
    begin
        exit(TotalExternalServicesTok);
    end;

    procedure OtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalExpensesName()));
    end;

    procedure OtherExternalExpensesName(): Text[100]
    begin
        exit(OtherExternalExpensesTok);
    end;

    procedure LicenseFeesRoyalties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LicenseFeesRoyaltiesName()));
    end;

    procedure LicenseFeesRoyaltiesName(): Text[100]
    begin
        exit(LicenseFeesRoyaltiesTok);
    end;

    procedure TrademarksPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrademarksPatentsName()));
    end;

    procedure TrademarksPatentsName(): Text[100]
    begin
        exit(TrademarksPatentsTok);
    end;

    procedure AssociationFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssociationFeesName()));
    end;

    procedure AssociationFeesName(): Text[100]
    begin
        exit(AssociationFeesTok);
    end;

    procedure MiscExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscExternalExpensesName()));
    end;

    procedure MiscExternalExpensesName(): Text[100]
    begin
        exit(MiscExternalExpensesTok);
    end;

    procedure PurchaseDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDiscountsName()));
    end;

    procedure PurchaseDiscountsName(): Text[100]
    begin
        exit(PurchaseDiscountsTok);
    end;

    procedure TotalOtherExternalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherExternalExpensesName()));
    end;

    procedure TotalOtherExternalExpensesName(): Text[100]
    begin
        exit(TotalOtherExternalExpensesTok);
    end;

    procedure TotalExternalServicesExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExternalServicesExpensesName()));
    end;

    procedure TotalExternalServicesExpensesName(): Text[100]
    begin
        exit(TotalExternalServicesExpensesTok);
    end;

    procedure WagesAndSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesAndSalariesName()));
    end;

    procedure WagesAndSalariesName(): Text[100]
    begin
        exit(WagesAndSalariesTok);
    end;

    procedure HourlyWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HourlyWagesName()));
    end;

    procedure HourlyWagesName(): Text[100]
    begin
        exit(HourlyWagesTok);
    end;

    procedure OvertimeWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OvertimeWagesName()));
    end;

    procedure OvertimeWagesName(): Text[100]
    begin
        exit(OvertimeWagesTok);
    end;

    procedure Bonuses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BonusesName()));
    end;

    procedure BonusesName(): Text[100]
    begin
        exit(BonusesTok);
    end;

    procedure CommissionsPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsPaidName()));
    end;

    procedure CommissionsPaidName(): Text[100]
    begin
        exit(CommissionsPaidTok);
    end;

    procedure PTOAccrued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PTOAccruedName()));
    end;

    procedure PTOAccruedName(): Text[100]
    begin
        exit(PTOAccruedTok);
    end;

    procedure PayrollTaxExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollTaxExpenseName()));
    end;

    procedure PayrollTaxExpenseName(): Text[100]
    begin
        exit(PayrollTaxExpenseTok);
    end;

    procedure TotalWagesAndSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWagesAndSalariesName()));
    end;

    procedure TotalWagesAndSalariesName(): Text[100]
    begin
        exit(TotalWagesAndSalariesTok);
    end;

    procedure BenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsPensionName()));
    end;

    procedure BenefitsPensionName(): Text[100]
    begin
        exit(BenefitsPensionTok);
    end;

    procedure Benefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitsName()));
    end;

    procedure BenefitsName(): Text[100]
    begin
        exit(BenefitsTok);
    end;

    procedure TrainingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrainingCostsName()));
    end;

    procedure TrainingCostsName(): Text[100]
    begin
        exit(TrainingCostsTok);
    end;

    procedure HealthCareContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthCareContributionsName()));
    end;

    procedure HealthCareContributionsName(): Text[100]
    begin
        exit(HealthCareContributionsTok);
    end;

    procedure EntertainmentOfpersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntertainmentOfpersonnelName()));
    end;

    procedure EntertainmentOfpersonnelName(): Text[100]
    begin
        exit(EntertainmentOfpersonnelTok);
    end;

    procedure MandatoryClothingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MandatoryClothingExpensesName()));
    end;

    procedure MandatoryClothingExpensesName(): Text[100]
    begin
        exit(MandatoryClothingExpensesTok);
    end;

    procedure OtherCashRemunerationBenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCashRemunerationBenefitsName()));
    end;

    procedure OtherCashRemunerationBenefitsName(): Text[100]
    begin
        exit(OtherCashRemunerationBenefitsTok);
    end;

    procedure TotalBenefits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsName()));
    end;

    procedure TotalBenefitsName(): Text[100]
    begin
        exit(TotalBenefitsTok);
    end;

    procedure Pension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionName()));
    end;

    procedure PensionName(): Text[100]
    begin
        exit(PensionTok);
    end;

    procedure PensionFeesAndRecurringCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionFeesAndRecurringCostsName()));
    end;

    procedure PensionFeesAndRecurringCostsName(): Text[100]
    begin
        exit(PensionFeesAndRecurringCostsTok);
    end;

    procedure EmployerContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployerContributionsName()));
    end;

    procedure EmployerContributionsName(): Text[100]
    begin
        exit(EmployerContributionsTok);
    end;

    procedure TotalPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPensionName()));
    end;

    procedure TotalPensionName(): Text[100]
    begin
        exit(TotalPensionTok);
    end;

    procedure TotalBenefitsPension(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBenefitsPensionName()));
    end;

    procedure TotalBenefitsPensionName(): Text[100]
    begin
        exit(TotalBenefitsPensionTok);
    end;

    procedure InsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesPersonnelName()));
    end;

    procedure InsurancesPersonnelName(): Text[100]
    begin
        exit(InsurancesPersonnelTok);
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceTok);
    end;

    procedure DentalInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DentalInsuranceName()));
    end;

    procedure DentalInsuranceName(): Text[100]
    begin
        exit(DentalInsuranceTok);
    end;

    procedure WorkersCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkersCompensationName()));
    end;

    procedure WorkersCompensationName(): Text[100]
    begin
        exit(WorkersCompensationTok);
    end;

    procedure LifeInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LifeInsuranceName()));
    end;

    procedure LifeInsuranceName(): Text[100]
    begin
        exit(LifeInsuranceTok);
    end;

    procedure TotalInsurancesPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsurancesPersonnelName()));
    end;

    procedure TotalInsurancesPersonnelName(): Text[100]
    begin
        exit(TotalInsurancesPersonnelTok);
    end;

    procedure DepreciationLandAndProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationLandAndPropertyName()));
    end;

    procedure DepreciationLandAndPropertyName(): Text[100]
    begin
        exit(DepreciationLandAndPropertyTok);
    end;

    procedure DepreciationFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationFixedAssetsName()));
    end;

    procedure DepreciationFixedAssetsName(): Text[100]
    begin
        exit(DepreciationFixedAssetsTok);
    end;

    procedure MiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscExpensesName()));
    end;

    procedure MiscExpensesName(): Text[100]
    begin
        exit(MiscExpensesTok);
    end;

    procedure CurrencyLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyLossesName()));
    end;

    procedure CurrencyLossesName(): Text[100]
    begin
        exit(CurrencyLossesTok);
    end;

    procedure TotalMiscExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMiscExpensesName()));
    end;

    procedure TotalMiscExpensesName(): Text[100]
    begin
        exit(TotalMiscExpensesTok);
    end;

    procedure TotalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalExpensesName()));
    end;

    procedure TotalExpensesName(): Text[100]
    begin
        exit(TotalExpensesTok);
    end;

    procedure IntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleFixedAssetsName()));
    end;

    procedure IntangibleFixedAssetsName(): Text[100]
    begin
        exit(IntangibleFixedAssetsTok);
    end;

    procedure DevelopmentExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopmentExpenditureName()));
    end;

    procedure DevelopmentExpenditureName(): Text[100]
    begin
        exit(DevelopmentExpenditureTok);
    end;

    procedure TenancySiteLeaseholdAndSimilarRights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TenancySiteLeaseholdAndSimilarRightsName()));
    end;

    procedure TenancySiteLeaseholdAndSimilarRightsName(): Text[100]
    begin
        exit(TenancySiteLeaseholdAndSimilarRightsTok);
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillTok);
    end;

    procedure AdvancedPaymentsForIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsForIntangibleFixedAssetsName()));
    end;

    procedure AdvancedPaymentsForIntangibleFixedAssetsName(): Text[100]
    begin
        exit(AdvancedPaymentsForIntangibleFixedAssetsTok);
    end;

    procedure TotalIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIntangibleFixedAssetsName()));
    end;

    procedure TotalIntangibleFixedAssetsName(): Text[100]
    begin
        exit(TotalIntangibleFixedAssetsTok);
    end;

    procedure Building(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingName()));
    end;

    procedure BuildingName(): Text[100]
    begin
        exit(BuildingTok);
    end;

    procedure CostOfImprovementsToLeasedProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfImprovementsToLeasedPropertyName()));
    end;

    procedure CostOfImprovementsToLeasedPropertyName(): Text[100]
    begin
        exit(CostOfImprovementsToLeasedPropertyTok);
    end;

    procedure Land(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandName()));
    end;

    procedure LandName(): Text[100]
    begin
        exit(LandTok);
    end;

    procedure MachineryAndEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryAndEquipmentName()));
    end;

    procedure MachineryAndEquipmentName(): Text[100]
    begin
        exit(MachineryAndEquipmentTok);
    end;

    procedure EquipmentsAndTools(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentsAndToolsName()));
    end;

    procedure EquipmentsAndToolsName(): Text[100]
    begin
        exit(EquipmentsAndToolsTok);
    end;

    procedure Computers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersName()));
    end;

    procedure ComputersName(): Text[100]
    begin
        exit(ComputersTok);
    end;

    procedure CarsAndOtherTransportEquipments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsAndOtherTransportEquipmentsName()));
    end;

    procedure CarsAndOtherTransportEquipmentsName(): Text[100]
    begin
        exit(CarsAndOtherTransportEquipmentsTok);
    end;

    procedure LeasedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasedAssetsName()));
    end;

    procedure LeasedAssetsName(): Text[100]
    begin
        exit(LeasedAssetsTok);
    end;

    procedure TotalMachineryAndEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMachineryAndEquipmentName()));
    end;

    procedure TotalMachineryAndEquipmentName(): Text[100]
    begin
        exit(TotalMachineryAndEquipmentTok);
    end;

    procedure AccumulatedDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationName()));
    end;

    procedure AccumulatedDepreciationName(): Text[100]
    begin
        exit(AccumulatedDepreciationTok);
    end;

    procedure FinancialAndFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialAndFixedAssetsName()));
    end;

    procedure FinancialAndFixedAssetsName(): Text[100]
    begin
        exit(FinancialAndFixedAssetsTok);
    end;

    procedure LongTermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermReceivablesName()));
    end;

    procedure LongTermReceivablesName(): Text[100]
    begin
        exit(LongTermReceivablesTok);
    end;

    procedure ParticipationinGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ParticipationinGroupCompaniesName()));
    end;

    procedure ParticipationinGroupCompaniesName(): Text[100]
    begin
        exit(ParticipationinGroupCompaniesTok);
    end;

    procedure LoansToPartnersOrRelatedParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoansToPartnersOrRelatedPartiesName()));
    end;

    procedure LoansToPartnersOrRelatedPartiesName(): Text[100]
    begin
        exit(LoansToPartnersOrRelatedPartiesTok);
    end;

    procedure DeferredTaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredTaxAssetsName()));
    end;

    procedure DeferredTaxAssetsName(): Text[100]
    begin
        exit(DeferredTaxAssetsTok);
    end;

    procedure OtherLongTermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongTermReceivablesName()));
    end;

    procedure OtherLongTermReceivablesName(): Text[100]
    begin
        exit(OtherLongTermReceivablesTok);
    end;

    procedure TotalFinancialAndFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialAndFixedAssetsName()));
    end;

    procedure TotalFinancialAndFixedAssetsName(): Text[100]
    begin
        exit(TotalFinancialAndFixedAssetsTok);
    end;

    procedure InventoriesProductsAndWorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoriesProductsAndWorkInProgressName()));
    end;

    procedure InventoriesProductsAndWorkInProgressName(): Text[100]
    begin
        exit(InventoriesProductsAndWorkInProgressTok);
    end;

    procedure SuppliesAndConsumables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuppliesAndConsumablesName()));
    end;

    procedure SuppliesAndConsumablesName(): Text[100]
    begin
        exit(SuppliesAndConsumablesTok);
    end;

    procedure ProductsInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProductsInProgressName()));
    end;

    procedure ProductsInProgressName(): Text[100]
    begin
        exit(ProductsInProgressTok);
    end;

    procedure GoodsForResale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsForResaleName()));
    end;

    procedure GoodsForResaleName(): Text[100]
    begin
        exit(GoodsForResaleTok);
    end;

    procedure AdvancedPaymentsForGoodsAndServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsForGoodsAndServicesName()));
    end;

    procedure AdvancedPaymentsForGoodsAndServicesName(): Text[100]
    begin
        exit(AdvancedPaymentsForGoodsAndServicesTok);
    end;

    procedure OtherInventoryItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInventoryItemsName()));
    end;

    procedure OtherInventoryItemsName(): Text[100]
    begin
        exit(OtherInventoryItemsTok);
    end;

    procedure WorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProgressName()));
    end;

    procedure WorkInProgressName(): Text[100]
    begin
        exit(WorkInProgressTok);
    end;

    procedure WorkInProgressFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProgressFinishedGoodsName()));
    end;

    procedure WorkInProgressFinishedGoodsName(): Text[100]
    begin
        exit(WorkInProgressFinishedGoodsTok);
    end;

    procedure WIPAccruedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedCostsName()));
    end;

    procedure WIPAccruedCostsName(): Text[100]
    begin
        exit(WIPAccruedCostsTok);
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesTok);
    end;

    procedure TotalWorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWorkInProgressName()));
    end;

    procedure TotalWorkInProgressName(): Text[100]
    begin
        exit(TotalWorkInProgressTok);
    end;

    procedure TotalInventoryProductsAndWorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInventoryProductsAndWorkInProgressName()));
    end;

    procedure TotalInventoryProductsAndWorkInProgressName(): Text[100]
    begin
        exit(TotalInventoryProductsAndWorkInProgressTok);
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesTok);
    end;

    procedure ContractualReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualReceivablesName()));
    end;

    procedure ContractualReceivablesName(): Text[100]
    begin
        exit(ContractualReceivablesTok);
    end;

    procedure ConsignmentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsignmentReceivablesName()));
    end;

    procedure ConsignmentReceivablesName(): Text[100]
    begin
        exit(ConsignmentReceivablesTok);
    end;

    procedure CreditCardsAndVouchersReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditCardsAndVouchersReceivablesName()));
    end;

    procedure CreditCardsAndVouchersReceivablesName(): Text[100]
    begin
        exit(CreditCardsAndVouchersReceivablesTok);
    end;

    procedure OtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentReceivablesName()));
    end;

    procedure OtherCurrentReceivablesName(): Text[100]
    begin
        exit(OtherCurrentReceivablesTok);
    end;

    procedure CurrentReceivableFromEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivableFromEmployeesName()));
    end;

    procedure CurrentReceivableFromEmployeesName(): Text[100]
    begin
        exit(CurrentReceivableFromEmployeesTok);
    end;

    procedure AccruedIncomeNotYetInvoiced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedIncomeNotYetInvoicedName()));
    end;

    procedure AccruedIncomeNotYetInvoicedName(): Text[100]
    begin
        exit(AccruedIncomeNotYetInvoicedTok);
    end;

    procedure ClearingAccountsForTaxesAndcharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountsForTaxesAndchargesName()));
    end;

    procedure ClearingAccountsForTaxesAndchargesName(): Text[100]
    begin
        exit(ClearingAccountsForTaxesAndchargesTok);
    end;

    procedure TaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAssetsName()));
    end;

    procedure TaxAssetsName(): Text[100]
    begin
        exit(TaxAssetsTok);
    end;

    procedure PurchaseVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATReducedName()));
    end;

    procedure PurchaseVATReducedName(): Text[100]
    begin
        exit(PurchaseVATReducedTok);
    end;

    procedure PurchaseVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATNormalName()));
    end;

    procedure PurchaseVATNormalName(): Text[100]
    begin
        exit(PurchaseVATNormalTok);
    end;

    procedure MiscVATReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATReceivablesName()));
    end;

    procedure MiscVATReceivablesName(): Text[100]
    begin
        exit(MiscVATReceivablesTok);
    end;

    procedure CurrentReceivablesFromGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablesFromGroupCompaniesName()));
    end;

    procedure CurrentReceivablesFromGroupCompaniesName(): Text[100]
    begin
        exit(CurrentReceivablesFromGroupCompaniesTok);
    end;

    procedure TotalOtherCurrentReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentReceivablesName()));
    end;

    procedure TotalOtherCurrentReceivablesName(): Text[100]
    begin
        exit(TotalOtherCurrentReceivablesTok);
    end;

    procedure TotalReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalReceivablesName()));
    end;

    procedure TotalReceivablesName(): Text[100]
    begin
        exit(TotalReceivablesTok);
    end;

    procedure PrepaidExpensesAndAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidExpensesAndAccruedIncomeName()));
    end;

    procedure PrepaidExpensesAndAccruedIncomeName(): Text[100]
    begin
        exit(PrepaidExpensesAndAccruedIncomeTok);
    end;

    procedure PrepaidRent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidRentName()));
    end;

    procedure PrepaidRentName(): Text[100]
    begin
        exit(PrepaidRentTok);
    end;

    procedure PrepaidInterestExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidInterestExpenseName()));
    end;

    procedure PrepaidInterestExpenseName(): Text[100]
    begin
        exit(PrepaidInterestexpenseTok);
    end;

    procedure AccruedRentalIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedRentalIncomeName()));
    end;

    procedure AccruedRentalIncomeName(): Text[100]
    begin
        exit(AccruedRentalIncomeTok);
    end;

    procedure AccruedInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestIncomeName()));
    end;

    procedure AccruedInterestIncomeName(): Text[100]
    begin
        exit(AccruedInterestIncomeTok);
    end;

    procedure AssetsInTheFormOfPrepaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsInTheFormOfPrepaidExpensesName()));
    end;

    procedure AssetsInTheFormOfPrepaidExpensesName(): Text[100]
    begin
        exit(AssetsInTheFormOfPrepaidExpensesTok);
    end;

    procedure OtherPrepaidExpensesAndAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPrepaidExpensesAndAccruedIncomeName()));
    end;

    procedure OtherPrepaidExpensesAndAccruedIncomeName(): Text[100]
    begin
        exit(OtherPrepaidExpensesAndAccruedIncomeTok);
    end;

    procedure TotalPrepaidExpensesAndAccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPrepaidExpensesAndAccruedIncomeName()));
    end;

    procedure TotalPrepaidExpensesAndAccruedIncomeName(): Text[100]
    begin
        exit(TotalPrepaidExpensesAndAccruedIncomeTok);
    end;

    procedure ShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermInvestmentsName()));
    end;

    procedure ShortTermInvestmentsName(): Text[100]
    begin
        exit(ShortTermInvestmentsTok);
    end;

    procedure ConvertibleDebtInstruments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertibleDebtInstrumentsName()));
    end;

    procedure ConvertibleDebtInstrumentsName(): Text[100]
    begin
        exit(ConvertibleDebtInstrumentsTok);
    end;

    procedure OtherShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherShortTermInvestmentsName()));
    end;

    procedure OtherShortTermInvestmentsName(): Text[100]
    begin
        exit(OtherShortTermInvestmentsTok);
    end;

    procedure WriteDownOfShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownOfShortTermInvestmentsName()));
    end;

    procedure WriteDownOfShortTermInvestmentsName(): Text[100]
    begin
        exit(WriteDownOfShortTermInvestmentsTok);
    end;

    procedure TotalShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalShortTermInvestmentsName()));
    end;

    procedure TotalShortTermInvestmentsName(): Text[100]
    begin
        exit(TotalShortTermInvestmentsTok);
    end;

    procedure CashAndBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashAndBankName()));
    end;

    procedure CashAndBankName(): Text[100]
    begin
        exit(CashAndBankTok);
    end;

    procedure BusinessAccountOperatingDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessAccountOperatingDomesticName()));
    end;

    procedure BusinessAccountOperatingDomesticName(): Text[100]
    begin
        exit(BusinessAccountOperatingDomesticTok);
    end;

    procedure BusinessAccountOperatingForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessAccountOperatingForeignName()));
    end;

    procedure BusinessAccountOperatingForeignName(): Text[100]
    begin
        exit(BusinessAccountOperatingForeignTok);
    end;

    procedure OtherBankAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherBankAccountsName()));
    end;

    procedure OtherBankAccountsName(): Text[100]
    begin
        exit(OtherBankAccountsTok);
    end;

    procedure CertificateOfDeposit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CertificateOfDepositName()));
    end;

    procedure CertificateOfDepositName(): Text[100]
    begin
        exit(CertificateOfDepositTok);
    end;

    procedure TotalCashAndBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCashAndBankName()));
    end;

    procedure TotalCashAndBankName(): Text[100]
    begin
        exit(TotalCashAndBankTok);
    end;

    procedure BondsAndDebentureLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BondsAndDebentureLoansName()));
    end;

    procedure BondsAndDebentureLoansName(): Text[100]
    begin
        exit(BondsAndDebentureLoansTok);
    end;

    procedure ConvertiblesLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertiblesLoansName()));
    end;

    procedure ConvertiblesLoansName(): Text[100]
    begin
        exit(ConvertiblesLoansTok);
    end;

    procedure OtherLongTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongTermLiabilitiesName()));
    end;

    procedure OtherLongTermLiabilitiesName(): Text[100]
    begin
        exit(OtherLongTermLiabilitiesTok);
    end;

    procedure BankOverdraftFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOverdraftFacilitiesName()));
    end;

    procedure BankOverdraftFacilitiesName(): Text[100]
    begin
        exit(BankOverdraftFacilitiesTok);
    end;

    procedure CurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiesName()));
    end;

    procedure CurrentLiabilitiesName(): Text[100]
    begin
        exit(CurrentLiabilitiesTok);
    end;

    procedure AdvancesFromCustomers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesFromCustomersName()));
    end;

    procedure AdvancesFromCustomersName(): Text[100]
    begin
        exit(AdvancesFromCustomersTok);
    end;

    procedure ChangeInWorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeInWorkInProgressName()));
    end;

    procedure ChangeInWorkInProgressName(): Text[100]
    begin
        exit(ChangeInWorkInProgressTok);
    end;

    procedure BankOverdraftShortTerm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOverdraftShortTermName()));
    end;

    procedure BankOverdraftShortTermName(): Text[100]
    begin
        exit(BankOverdraftShortTermTok);
    end;

    procedure DeferredRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredRevenueName()));
    end;

    procedure DeferredRevenueName(): Text[100]
    begin
        exit(DeferredRevenueTok);
    end;

    procedure TotalCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCurrentLiabilitiesName()));
    end;

    procedure TotalCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalCurrentLiabilitiesTok);
    end;

    procedure TaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxLiabilitiesName()));
    end;

    procedure TaxLiabilitiesName(): Text[100]
    begin
        exit(TaxLiabilitiesTok);
    end;

    procedure TaxesLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesLiableName()));
    end;

    procedure TaxesLiableName(): Text[100]
    begin
        exit(TaxesLiableTok);
    end;

    procedure SalesVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATReducedName()));
    end;

    procedure SalesVATReducedName(): Text[100]
    begin
        exit(SalesVATReducedTok);
    end;

    procedure SalesVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATNormalName()));
    end;

    procedure SalesVATNormalName(): Text[100]
    begin
        exit(SalesVATNormalTok);
    end;

    procedure MiscVATPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATPayablesName()));
    end;

    procedure MiscVATPayablesName(): Text[100]
    begin
        exit(MiscVATPayablesTok);
    end;

    procedure EstimatedIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedIncomeTaxName()));
    end;

    procedure EstimatedIncomeTaxName(): Text[100]
    begin
        exit(EstimatedIncomeTaxTok);
    end;

    procedure EstimatedRealEstateTaxRealEstateCharge(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedRealEstateTaxRealEstateChargeName()));
    end;

    procedure EstimatedRealEstateTaxRealEstateChargeName(): Text[100]
    begin
        exit(EstimatedRealEstateTaxRealEstateChargeTok);
    end;

    procedure EstimatedPayrollTaxOnPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedPayrollTaxOnPensionCostsName()));
    end;

    procedure EstimatedPayrollTaxOnPensionCostsName(): Text[100]
    begin
        exit(EstimatedPayrollTaxOnPensionCostsTok);
    end;

    procedure TotalTaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTaxLiabilitiesName()));
    end;

    procedure TotalTaxLiabilitiesName(): Text[100]
    begin
        exit(TotalTaxLiabilitiesTok);
    end;

    procedure PayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollLiabilitiesName()));
    end;

    procedure PayrollLiabilitiesName(): Text[100]
    begin
        exit(PayrollLiabilitiesTok);
    end;

    procedure EmployeesWithholdingTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesWithholdingTaxesName()));
    end;

    procedure EmployeesWithholdingTaxesName(): Text[100]
    begin
        exit(EmployeesWithholdingTaxesTok);
    end;

    procedure StatutorySocialSecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialSecurityContributionsName()));
    end;

    procedure StatutorySocialSecurityContributionsName(): Text[100]
    begin
        exit(StatutorySocialSecurityContributionsTok);
    end;

    procedure ContractualSocialSecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualSocialSecurityContributionsName()));
    end;

    procedure ContractualSocialSecurityContributionsName(): Text[100]
    begin
        exit(ContractualSocialSecurityContributionsTok);
    end;

    procedure AttachmentsOfEarning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AttachmentsOfEarningName()));
    end;

    procedure AttachmentsOfEarningName(): Text[100]
    begin
        exit(AttachmentsOfEarningTok);
    end;

    procedure HolidayPayfund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HolidayPayfundName()));
    end;

    procedure HolidayPayfundName(): Text[100]
    begin
        exit(HolidayPayfundTok);
    end;

    procedure OtherSalaryWageDeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSalaryWageDeductionsName()));
    end;

    procedure OtherSalaryWageDeductionsName(): Text[100]
    begin
        exit(OtherSalaryWageDeductionsTok);
    end;

    procedure TotalPayrollLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPayrollLiabilitiesName()));
    end;

    procedure TotalPayrollLiabilitiesName(): Text[100]
    begin
        exit(TotalPayrollLiabilitiesTok);
    end;

    procedure OtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentLiabilitiesName()));
    end;

    procedure OtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(OtherCurrentLiabilitiesTok);
    end;

    procedure ClearingAccountForFactoringCurrentPortion(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountForFactoringCurrentPortionName()));
    end;

    procedure ClearingAccountForFactoringCurrentPortionName(): Text[100]
    begin
        exit(ClearingAccountForFactoringCurrentPortionTok);
    end;

    procedure CurrentLiabilitiesToEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiesToEmployeesName()));
    end;

    procedure CurrentLiabilitiesToEmployeesName(): Text[100]
    begin
        exit(CurrentLiabilitiesToEmployeesTok);
    end;

    procedure ClearingAccountForThirdParty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountForThirdPartyName()));
    end;

    procedure ClearingAccountForThirdPartyName(): Text[100]
    begin
        exit(ClearingAccountForThirdPartyTok);
    end;

    procedure CurrentLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLoansName()));
    end;

    procedure CurrentLoansName(): Text[100]
    begin
        exit(CurrentLoansTok);
    end;

    procedure LiabilitiesGrantsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesGrantsReceivedName()));
    end;

    procedure LiabilitiesGrantsReceivedName(): Text[100]
    begin
        exit(LiabilitiesGrantsReceivedTok);
    end;

    procedure TotalOtherCurrentLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherCurrentLiabilitiesName()));
    end;

    procedure TotalOtherCurrentLiabilitiesName(): Text[100]
    begin
        exit(TotalOtherCurrentLiabilitiesTok);
    end;

    procedure AccruedExpensesAndDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedExpensesAndDeferredIncomeName()));
    end;

    procedure AccruedExpensesAndDeferredIncomeName(): Text[100]
    begin
        exit(AccruedExpensesAndDeferredIncomeTok);
    end;

    procedure AccruedWagesSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedWagesSalariesName()));
    end;

    procedure AccruedWagesSalariesName(): Text[100]
    begin
        exit(AccruedWagesSalariesTok);
    end;

    procedure AccruedHolidayPay(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedHolidayPayName()));
    end;

    procedure AccruedHolidayPayName(): Text[100]
    begin
        exit(AccruedHolidayPayTok);
    end;

    procedure AccruedPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedPensionCostsName()));
    end;

    procedure AccruedPensionCostsName(): Text[100]
    begin
        exit(AccruedPensionCostsTok);
    end;

    procedure AccruedInterestExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestExpenseName()));
    end;

    procedure AccruedInterestExpenseName(): Text[100]
    begin
        exit(AccruedInterestExpenseTok);
    end;

    procedure DeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredIncomeName()));
    end;

    procedure DeferredIncomeName(): Text[100]
    begin
        exit(DeferredIncomeTok);
    end;

    procedure AccruedContractualCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedContractualCostsName()));
    end;

    procedure AccruedContractualCostsName(): Text[100]
    begin
        exit(AccruedContractualCostsTok);
    end;

    procedure OtherAccruedExpensesAndDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAccruedExpensesAndDeferredIncomeName()));
    end;

    procedure OtherAccruedExpensesAndDeferredIncomeName(): Text[100]
    begin
        exit(OtherAccruedExpensesAndDeferredIncomeTok);
    end;

    procedure TotalAccruedExpensesAndDeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccruedExpensesAndDeferredIncomeName()));
    end;

    procedure TotalAccruedExpensesAndDeferredIncomeName(): Text[100]
    begin
        exit(TotalAccruedExpensesAndDeferredIncomeTok);
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityTok);
    end;

    procedure EquityPartner(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityPartnerName()));
    end;

    procedure EquityPartnerName(): Text[100]
    begin
        exit(EquityPartnerTok);
    end;

    procedure NetResults(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetResultsName()));
    end;

    procedure NetResultsName(): Text[100]
    begin
        exit(NetResultsTok);
    end;

    procedure RestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RestrictedEquityName()));
    end;

    procedure RestrictedEquityName(): Text[100]
    begin
        exit(RestrictedEquityTok);
    end;

    procedure ShareCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareCapitalName()));
    end;

    procedure ShareCapitalName(): Text[100]
    begin
        exit(ShareCapitalTok);
    end;

    procedure Dividends(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DividendsName()));
    end;

    procedure DividendsName(): Text[100]
    begin
        exit(DividendsTok);
    end;

    procedure NonRestrictedEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRestrictedEquityName()));
    end;

    procedure NonRestrictedEquityName(): Text[100]
    begin
        exit(NonRestrictedEquityTok);
    end;

    procedure ProfitOrLossFromThePreviousYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitOrLossFromThePreviousYearName()));
    end;

    procedure ProfitOrLossFromThePreviousYearName(): Text[100]
    begin
        exit(ProfitOrLossFromThePreviousYearTok);
    end;

    procedure ResultsForTheFinancialYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResultsForTheFinancialYearName()));
    end;

    procedure ResultsForTheFinancialYearName(): Text[100]
    begin
        exit(ResultsForTheFinancialyearTok);
    end;

    procedure TotalEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEquityName()));
    end;

    procedure TotalEquityName(): Text[100]
    begin
        exit(TotalEquityTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        IncomeTok: Label 'Income', MaxLength = 100;
        SalesOfGoodsTok: Label 'Sales of Goods', MaxLength = 100;
        SaleOfFinishedGoodsTok: Label 'Sale of Finished Goods', MaxLength = 100;
        SaleOfRawMaterialsTok: Label 'Sale of Raw Materials', MaxLength = 100;
        ResaleOfGoodsTok: Label 'Resale of Goods', MaxLength = 100;
        TotalSalesOfGoodsTok: Label 'Total, Sales of Goods', MaxLength = 100;
        SaleOfResourcesTok: Label 'Sale of Resources', MaxLength = 100;
        SaleOfSubcontractingTok: Label 'Sale of Subcontracting', MaxLength = 100;
        TotalSalesOfResourcesTok: Label 'Total, Sales of Resources', MaxLength = 100;
        AdditionalRevenueTok: Label 'Additional Revenue', MaxLength = 100;
        IncomeFromSecuritiesTok: Label 'Income from securities', MaxLength = 100;
        ManagementFeeRevenueTok: Label 'Management Fee Revenue', MaxLength = 100;
        CurrencyGainsTok: Label 'Currency Gains', MaxLength = 100;
        OtherIncidentalRevenueTok: Label 'Other Incidental Revenue', MaxLength = 100;
        TotalAdditionalRevenueTok: Label 'Total, Additional Revenue', MaxLength = 100;
        JobsAndServicesTok: Label 'Jobs and Services', MaxLength = 100;
        JobSalesAppliedTok: Label 'Job Sales Applied', MaxLength = 100;
        SalesOfServiceContractsTok: Label 'Sales of Service Contracts', MaxLength = 100;
        SalesOfServiceWorkTok: Label 'Sales of Service Work', MaxLength = 100;
        TotalJobsAndServicesTok: Label 'Total, Jobs and Services', MaxLength = 100;
        RevenueReductionsTok: Label 'Revenue Reductions', MaxLength = 100;
        DiscountsAndAllowancesTok: Label 'Discounts and Allowances', MaxLength = 100;
        PaymentToleranceTok: Label 'Payment Tolerance', MaxLength = 100;
        SalesReturnsTok: Label 'Sales Returns', MaxLength = 100;
        TotalRevenueReductionsTok: Label 'Total, Revenue Reductions', MaxLength = 100;
        TotalIncomeTok: Label 'TOTAL INCOME', MaxLength = 100;
        CostOfGoodsSoldTok: Label 'COST OF GOODS SOLD', MaxLength = 100;
        CostOfGoodsTok: Label 'Cost of Goods', MaxLength = 100;
        CostOfMaterialsTok: Label 'Cost of Materials', MaxLength = 100;
        CostOfMaterialsProjectsTok: Label 'Cost of Materials, Projects', MaxLength = 100;
        TotalCostOfGoodsTok: Label 'Total, Cost of Goods', MaxLength = 100;
        CostOfResourcesAndServicesTok: Label 'Cost of Resources and Services', MaxLength = 100;
        CostOfLaborTok: Label 'Cost of Labor', MaxLength = 100;
        CostOfLaborProjectsTok: Label 'Cost of Labor, Projects', MaxLength = 100;
        CostOfLaborWarrantyContractTok: Label 'Cost of Labor, Warranty/Contract', MaxLength = 100;
        TotalCostOfResourcesTok: Label 'Total, Cost of Resources', MaxLength = 100;
        CostsOfJobsTok: Label 'Costs of Jobs', MaxLength = 100;
        JobCostsAppliedTok: Label 'Job Costs Applied', MaxLength = 100;
        TotalCostsOfJobsTok: Label 'Total, Costs of Jobs', MaxLength = 100;
        SubcontractedWorkTok: Label 'Subcontracted work', MaxLength = 100;
        CostOfVariancesTok: Label 'Cost of Variances', MaxLength = 100;
        TotalCostOfGoodsSoldTok: Label 'TOTAL COST OF GOODS SOLD', MaxLength = 100;
        ExpensesTok: Label 'EXPENSES', MaxLength = 100;
        FacilityExpensesTok: Label 'Facility Expenses', MaxLength = 100;
        RentalFacilitiesTok: Label 'Rental Facilities', MaxLength = 100;
        RentLeasesTok: Label 'Rent / Leases', MaxLength = 100;
        ElectricityForRentalTok: Label 'Electricity for Rental', MaxLength = 100;
        HeatingForRentalTok: Label 'Heating for Rental', MaxLength = 100;
        WaterAndSewerageForRentalTok: Label 'Water and Sewerage for Rental', MaxLength = 100;
        CleaningAndWasteForRentalTok: Label 'Cleaning and Waste for Rental', MaxLength = 100;
        RepairsAndMaintenanceForRentalTok: Label 'Repairs and Maintenance for Rental', MaxLength = 100;
        InsurancesRentalTok: Label 'Insurances, Rental', MaxLength = 100;
        OtherRentalExpensesTok: Label 'Other Rental Expenses', MaxLength = 100;
        TotalRentalFacilitiesTok: Label 'Total, Rental Facilities', MaxLength = 100;
        PropertyExpensesTok: Label 'Property Expenses', MaxLength = 100;
        SiteFeesLeasesTok: Label 'Site Fees / Leases', MaxLength = 100;
        ElectricityForPropertyTok: Label 'Electricity for Property', MaxLength = 100;
        HeatingForPropertyTok: Label 'Heating for Property', MaxLength = 100;
        WaterAndSewerageForPropertyTok: Label 'Water and Sewerage for Property', MaxLength = 100;
        CleaningAndWasteForPropertyTok: Label 'Cleaning and Waste for Property', MaxLength = 100;
        RepairsAndMaintenanceForPropertyTok: Label 'Repairs and Maintenance for Property', MaxLength = 100;
        InsurancesPropertyTok: Label 'Insurances, Property', MaxLength = 100;
        OtherPropertyExpensesTok: Label 'Other Property Expenses', MaxLength = 100;
        TotalPropertyExpensesTok: Label 'Total, Property Expenses', MaxLength = 100;
        TotalFacilityExpensesTok: Label 'Total, Facility Expenses', MaxLength = 100;
        FixedAssetsLeasesTok: Label 'Fixed Assets Leases', MaxLength = 100;
        HireOfMachineryTok: Label 'Hire of machinery', MaxLength = 100;
        HireOfComputersTok: Label 'Hire of computers', MaxLength = 100;
        HireOfOtherFixedAssetsTok: Label 'Hire of other fixed assets', MaxLength = 100;
        TotalFixedAssetLeasesTok: Label 'Total, Fixed Asset Leases', MaxLength = 100;
        LogisticsExpensesTok: Label 'Logistics Expenses', MaxLength = 100;
        PassengerCarCostsTok: Label 'Passenger Car Costs', MaxLength = 100;
        TruckCostsTok: Label 'Truck Costs', MaxLength = 100;
        OtherVehicleExpensesTok: Label 'Other vehicle expenses', MaxLength = 100;
        FreightCostsTok: Label 'Freight Costs', MaxLength = 100;
        FreightFeesForGoodsTok: Label 'Freight fees for goods', MaxLength = 100;
        CustomsAndForwardingTok: Label 'Customs and forwarding', MaxLength = 100;
        FreightFeesProjectsTok: Label 'Freight fees, projects', MaxLength = 100;
        TotalFreightCostsTok: Label 'Total, Freight Costs', MaxLength = 100;
        TravelExpensesTok: Label 'Travel Expenses', MaxLength = 100;
        TicketsTok: Label 'Tickets', MaxLength = 100;
        RentalVehiclesTok: Label 'Rental vehicles', MaxLength = 100;
        BoardAndLodgingTok: Label 'Board and lodging', MaxLength = 100;
        OtherTravelExpensesTok: Label 'Other travel expenses', MaxLength = 100;
        TotalTravelExpensesTok: Label 'Total, Travel Expenses', MaxLength = 100;
        TotalLogisticsExpensesTok: Label 'Total, Logistics Expenses', MaxLength = 100;
        MarketingAndSalesTok: Label 'Marketing and Sales', MaxLength = 100;
        AdvertisementDevelopmentTok: Label 'Advertisement Development', MaxLength = 100;
        OutdoorAndTransportationAdsTok: Label 'Outdoor and Transportation Ads', MaxLength = 100;
        AdMatterAndDirectMailingsTok: Label 'Ad matter and direct mailings', MaxLength = 100;
        ConferenceExhibitionSponsorshipTok: Label 'Conference/Exhibition Sponsorship', MaxLength = 100;
        SamplesContestsGiftsTok: Label 'Samples, contests, gifts', MaxLength = 100;
        FilmTvRadioInternetAdsTok: Label 'Film, TV, radio, internet ads', MaxLength = 100;
        PrAndAgencyFeesTok: Label 'PR and Agency Fees', MaxLength = 100;
        OtherAdvertisingFeesTok: Label 'Other advertising fees', MaxLength = 100;
        TotalAdvertisingTok: Label 'Total, Advertising', MaxLength = 100;
        OtherMarketingExpensesTok: Label 'Other Marketing Expenses', MaxLength = 100;
        CatalogsPriceListsTok: Label 'Catalogs, price lists', MaxLength = 100;
        TradePublicationsTok: Label 'Trade Publications', MaxLength = 100;
        TotalOtherMarketingExpensesTok: Label 'Total, Other Marketing Expenses', MaxLength = 100;
        SalesExpensesTok: Label 'Sales Expenses', MaxLength = 100;
        CreditCardChargesTok: Label 'Credit Card Charges', MaxLength = 100;
        BusinessEntertainingDeductibleTok: Label 'Business Entertaining, deductible', MaxLength = 100;
        BusinessEntertainingNondeductibleTok: Label 'Business Entertaining, nondeductible', MaxLength = 100;
        TotalSalesExpensesTok: Label 'Total, Sales Expenses', MaxLength = 100;
        TotalMarketingAndSalesTok: Label 'Total, Marketing and Sales', MaxLength = 100;
        OfficeExpensesTok: Label 'Office Expenses', MaxLength = 100;
        PhoneServicesTok: Label 'Phone Services', MaxLength = 100;
        DataServicesTok: Label 'Data services', MaxLength = 100;
        PostalFeesTok: Label 'Postal fees', MaxLength = 100;
        ConsumableExpensibleHardwareTok: Label 'Consumable/Expensible hardware', MaxLength = 100;
        SoftwareAndSubscriptionFeesTok: Label 'Software and subscription fees', MaxLength = 100;
        TotalOfficeExpensesTok: Label 'Total, Office Expenses', MaxLength = 100;
        InsurancesAndRisksTok: Label 'Insurances and Risks', MaxLength = 100;
        CorporateInsuranceTok: Label 'Corporate Insurance', MaxLength = 100;
        DamagesPaidTok: Label 'Damages Paid', MaxLength = 100;
        BadDebtLossesTok: Label 'Bad Debt Losses', MaxLength = 100;
        SecurityServicesTok: Label 'Security services', MaxLength = 100;
        OtherRiskExpensesTok: Label 'Other risk expenses', MaxLength = 100;
        TotalInsurancesAndRisksTok: Label 'Total, Insurances and Risks', MaxLength = 100;
        ManagementAndAdminTok: Label 'Management and Admin', MaxLength = 100;
        ManagementTok: Label 'Management', MaxLength = 100;
        RemunerationToDirectorsTok: Label 'Remuneration to Directors', MaxLength = 100;
        ManagementFeesTok: Label 'Management Fees', MaxLength = 100;
        AnnualInterrimReportsTok: Label 'Annual/interrim Reports', MaxLength = 100;
        AnnualGeneralMeetingTok: Label 'Annual/general meeting', MaxLength = 100;
        AuditAndAuditServicesTok: Label 'Audit and Audit Services', MaxLength = 100;
        TaxAdvisoryServicesTok: Label 'Tax advisory Services', MaxLength = 100;
        TotalManagementFeesTok: Label 'Total, Management Fees', MaxLength = 100;
        TotalManagementAndAdminTok: Label 'Total, Management and Admin', MaxLength = 100;
        BankingAndInterestTok: Label 'Banking and Interest', MaxLength = 100;
        BankingFeesTok: Label 'Banking fees', MaxLength = 100;
        PayableInvoiceRoundingTok: Label 'Payable Invoice Rounding', MaxLength = 100;
        TotalBankingAndInterestTok: Label 'Total, Banking and Interest', MaxLength = 100;
        ExternalServicesExpensesTok: Label 'External Services/Expenses', MaxLength = 100;
        ExternalServicesTok: Label 'External Services', MaxLength = 100;
        AccountingServicesTok: Label 'Accounting Services', MaxLength = 100;
        ITServicesTok: Label 'IT Services', MaxLength = 100;
        MediaServicesTok: Label 'Media Services', MaxLength = 100;
        ConsultingServicesTok: Label 'Consulting Services', MaxLength = 100;
        LegalFeesAndAttorneyServicesTok: Label 'Legal Fees and Attorney Services', MaxLength = 100;
        OtherExternalServicesTok: Label 'Other External Services', MaxLength = 100;
        TotalExternalServicesTok: Label 'Total, External Services', MaxLength = 100;
        OtherExternalExpensesTok: Label 'Other External Expenses', MaxLength = 100;
        LicenseFeesRoyaltiesTok: Label 'License Fees/Royalties', MaxLength = 100;
        TrademarksPatentsTok: Label 'Trademarks/Patents', MaxLength = 100;
        AssociationFeesTok: Label 'Association Fees', MaxLength = 100;
        MiscExternalExpensesTok: Label 'Misc. external expenses', MaxLength = 100;
        PurchaseDiscountsTok: Label 'Purchase Discounts', MaxLength = 100;
        TotalOtherExternalExpensesTok: Label 'Total, Other External Expenses', MaxLength = 100;
        TotalExternalServicesExpensesTok: Label 'Total, External Services/Expenses', MaxLength = 100;
        WagesAndSalariesTok: Label 'Wages and Salaries', MaxLength = 100;
        HourlyWagesTok: Label 'Hourly Wages', MaxLength = 100;
        OvertimeWagesTok: Label 'Overtime Wages', MaxLength = 100;
        BonusesTok: Label 'Bonuses', MaxLength = 100;
        CommissionsPaidTok: Label 'Commissions Paid', MaxLength = 100;
        PTOAccruedTok: Label 'PTO Accrued', MaxLength = 100;
        PayrollTaxExpenseTok: Label 'Payroll Tax Expense', MaxLength = 100;
        TotalWagesAndSalariesTok: Label 'Total, Wages and Salaries', MaxLength = 100;
        BenefitsPensionTok: Label 'Benefits/Pension', MaxLength = 100;
        BenefitsTok: Label 'Benefits', MaxLength = 100;
        TrainingCostsTok: Label 'Training Costs', MaxLength = 100;
        HealthCareContributionsTok: Label 'Health Care Contributions', MaxLength = 100;
        EntertainmentOfpersonnelTok: Label 'Entertainment of personnel', MaxLength = 100;
        MandatoryClothingExpensesTok: Label 'Mandatory clothing expenses', MaxLength = 100;
        OtherCashRemunerationBenefitsTok: Label 'Other cash/remuneration benefits', MaxLength = 100;
        TotalBenefitsTok: Label 'Total, Benefits', MaxLength = 100;
        PensionTok: Label 'Pension', MaxLength = 100;
        PensionFeesAndRecurringCostsTok: Label 'Pension fees and recurring costs', MaxLength = 100;
        EmployerContributionsTok: Label 'Employer Contributions', MaxLength = 100;
        TotalPensionTok: Label 'Total, Pension', MaxLength = 100;
        TotalBenefitsPensionTok: Label 'Total, Benefits/Pension', MaxLength = 100;
        InsurancesPersonnelTok: Label 'Insurances, Personnel', MaxLength = 100;
        HealthInsuranceTok: Label 'Health Insurance', MaxLength = 100;
        DentalInsuranceTok: Label 'Dental Insurance', MaxLength = 100;
        WorkersCompensationTok: Label 'Workers Compensation', MaxLength = 100;
        LifeInsuranceTok: Label 'Life Insurance', MaxLength = 100;
        TotalInsurancesPersonnelTok: Label 'Total, Insurances, Personnel', MaxLength = 100;
        DepreciationLandAndPropertyTok: Label 'Depreciation, Land and Property', MaxLength = 100;
        DepreciationFixedAssetsTok: Label 'Depreciation, Fixed Assets', MaxLength = 100;
        MiscExpensesTok: Label 'Misc. Expenses', MaxLength = 100;
        CurrencyLossesTok: Label 'Currency Losses', MaxLength = 100;
        TotalMiscExpensesTok: Label 'Total, Misc. Expenses', MaxLength = 100;
        TotalExpensesTok: Label 'TOTAL EXPENSES', MaxLength = 100;
        IntangibleFixedAssetsTok: Label 'Intangible Fixed Assets', MaxLength = 100;
        DevelopmentExpenditureTok: Label 'Development Expenditure', MaxLength = 100;
        TenancySiteLeaseholdAndSimilarRightsTok: Label 'Tenancy, Site Leasehold and similar rights', MaxLength = 100;
        GoodwillTok: Label 'Goodwill', MaxLength = 100;
        AdvancedPaymentsForIntangibleFixedAssetsTok: Label 'Advanced Payments for Intangible Fixed Assets', MaxLength = 100;
        TotalIntangibleFixedAssetsTok: Label 'Total, Intangible Fixed Assets', MaxLength = 100;
        BuildingTok: Label 'Building', MaxLength = 100;
        CostOfImprovementsToLeasedPropertyTok: Label 'Cost of Improvements to Leased Property', MaxLength = 100;
        LandTok: Label 'Land ', MaxLength = 100;
        MachineryAndEquipmentTok: Label 'Machinery and Equipment', MaxLength = 100;
        EquipmentsAndToolsTok: Label 'Equipments and Tools', MaxLength = 100;
        ComputersTok: Label 'Computers', MaxLength = 100;
        CarsAndOtherTransportEquipmentsTok: Label 'Cars and other Transport Equipments', MaxLength = 100;
        LeasedAssetsTok: Label 'Leased Assets', MaxLength = 100;
        TotalMachineryAndEquipmentTok: Label 'Total, Machinery and Equipment', MaxLength = 100;
        AccumulatedDepreciationTok: Label 'Accumulated Depreciation', MaxLength = 100;
        FinancialAndFixedAssetsTok: Label 'Financial and Fixed Assets', MaxLength = 100;
        LongTermReceivablesTok: Label 'Long-term Receivables ', MaxLength = 100;
        ParticipationinGroupCompaniesTok: Label 'Participation in Group Companies', MaxLength = 100;
        LoansToPartnersOrRelatedPartiesTok: Label 'Loans to Partners or related Parties', MaxLength = 100;
        DeferredTaxAssetsTok: Label 'Deferred Tax Assets', MaxLength = 100;
        OtherLongTermReceivablesTok: Label 'Other Long-term Receivables', MaxLength = 100;
        TotalFinancialAndFixedAssetsTok: Label 'Total, Financial and Fixed Assets', MaxLength = 100;
        InventoriesProductsAndWorkInProgressTok: Label 'Inventories, Products and work in Progress', MaxLength = 100;
        SuppliesAndConsumablesTok: Label 'Supplies and Consumables', MaxLength = 100;
        ProductsInProgressTok: Label 'Products in Progress', MaxLength = 100;
        GoodsForResaleTok: Label 'Goods for Resale', MaxLength = 100;
        AdvancedPaymentsForGoodsAndServicesTok: Label 'Advanced Payments for goods and services', MaxLength = 100;
        OtherInventoryItemsTok: Label 'Other Inventory Items', MaxLength = 100;
        WorkInProgressTok: Label 'Work in Progress', MaxLength = 100;
        WorkInProgressFinishedGoodsTok: Label 'Work in Progress, Finished Goods', MaxLength = 100;
        WIPAccruedCostsTok: Label 'WIP, Accrued Costs', MaxLength = 100;
        WIPInvoicedSalesTok: Label 'WIP, Invoiced Sales', MaxLength = 100;
        TotalWorkInProgressTok: Label 'Total, Work in Progress', MaxLength = 100;
        TotalInventoryProductsAndWorkInProgressTok: Label 'Total, Inventory, Products and Work in Progress', MaxLength = 100;
        ReceivablesTok: Label 'Receivables', MaxLength = 100;
        ContractualReceivablesTok: Label 'Contractual Receivables', MaxLength = 100;
        ConsignmentReceivablesTok: Label 'Consignment Receivables', MaxLength = 100;
        CreditCardsAndVouchersReceivablesTok: Label 'Credit cards and Vouchers Receivables', MaxLength = 100;
        OtherCurrentReceivablesTok: Label 'Other Current Receivables', MaxLength = 100;
        CurrentReceivableFromEmployeesTok: Label 'Current Receivable from Employees', MaxLength = 100;
        AccruedIncomeNotYetInvoicedTok: Label 'Accrued income not yet invoiced', MaxLength = 100;
        ClearingAccountsForTaxesAndchargesTok: Label 'Clearing Accounts for Taxes and charges', MaxLength = 100;
        TaxAssetsTok: Label 'Tax Assets', MaxLength = 100;
        PurchaseVATReducedTok: Label 'Purchase VAT Reduced', MaxLength = 100;
        PurchaseVATNormalTok: Label 'Purchase VAT Normal', MaxLength = 100;
        MiscVATReceivablesTok: Label 'Misc VAT Receivables', MaxLength = 100;
        CurrentReceivablesFromGroupCompaniesTok: Label 'Current Receivables from group companies', MaxLength = 100;
        TotalOtherCurrentReceivablesTok: Label 'Total, Other Current Receivables', MaxLength = 100;
        TotalReceivablesTok: Label 'Total, Receivables', MaxLength = 100;
        PrepaidExpensesAndAccruedIncomeTok: Label 'Prepaid expenses and Accrued Income', MaxLength = 100;
        PrepaidRentTok: Label 'Prepaid Rent', MaxLength = 100;
        PrepaidInterestexpenseTok: Label 'Prepaid Interest expense', MaxLength = 100;
        AccruedRentalIncomeTok: Label 'Accrued Rental Income', MaxLength = 100;
        AccruedInterestIncomeTok: Label 'Accrued Interest Income', MaxLength = 100;
        AssetsInTheFormOfPrepaidExpensesTok: Label 'Assets in the form of prepaid expenses', MaxLength = 100;
        OtherPrepaidExpensesAndAccruedIncomeTok: Label 'Other prepaid expenses and accrued income', MaxLength = 100;
        TotalPrepaidExpensesAndAccruedIncomeTok: Label 'Total, Prepaid expenses and Accrued Income', MaxLength = 100;
        ShortTermInvestmentsTok: Label 'Short-term investments', MaxLength = 100;
        ConvertibleDebtInstrumentsTok: Label 'Convertible debt instruments', MaxLength = 100;
        OtherShortTermInvestmentsTok: Label 'Other short-term Investments', MaxLength = 100;
        WriteDownOfShortTermInvestmentsTok: Label 'Write-down of Short-term investments', MaxLength = 100;
        TotalShortTermInvestmentsTok: Label 'Total, short term investments', MaxLength = 100;
        CashAndBankTok: Label 'Cash and Bank', MaxLength = 100;
        BusinessAccountOperatingDomesticTok: Label 'Business account, Operating, Domestic', MaxLength = 100;
        BusinessAccountOperatingForeignTok: Label 'Business account, Operating, Foreign', MaxLength = 100;
        OtherBankAccountsTok: Label 'Other bank accounts ', MaxLength = 100;
        CertificateOfDepositTok: Label 'Certificate of Deposit', MaxLength = 100;
        TotalCashAndBankTok: Label 'Total, Cash and Bank', MaxLength = 100;
        BondsAndDebentureLoansTok: Label 'Bonds and Debenture Loans', MaxLength = 100;
        ConvertiblesLoansTok: Label 'Convertibles Loans', MaxLength = 100;
        OtherLongTermLiabilitiesTok: Label 'Other Long-term Liabilities', MaxLength = 100;
        BankOverdraftFacilitiesTok: Label 'Bank overdraft Facilities', MaxLength = 100;
        CurrentLiabilitiesTok: Label 'Current Liabilities', MaxLength = 100;
        AdvancesFromCustomersTok: Label 'Advances from customers', MaxLength = 100;
        ChangeInWorkInProgressTok: Label 'Change in Work in Progress', MaxLength = 100;
        BankOverdraftShortTermTok: Label 'Bank overdraft short-term', MaxLength = 100;
        DeferredRevenueTok: Label 'Deferred Revenue', MaxLength = 100;
        TotalCurrentLiabilitiesTok: Label 'Total, Current Liabilities', MaxLength = 100;
        TaxLiabilitiesTok: Label 'Tax Liabilities', MaxLength = 100;
        TaxesLiableTok: Label 'Taxes Liable', MaxLength = 100;
        SalesVATReducedTok: Label 'Sales VAT Reduced', MaxLength = 100;
        SalesVATNormalTok: Label 'Sales VAT Normal', MaxLength = 100;
        MiscVATPayablesTok: Label 'Misc VAT Payables', MaxLength = 100;
        EstimatedIncomeTaxTok: Label 'Estimated Income Tax', MaxLength = 100;
        EstimatedRealEstateTaxRealEstateChargeTok: Label 'Estimated real-estate Tax/Real-estate charge ', MaxLength = 100;
        EstimatedPayrollTaxOnPensionCostsTok: Label 'Estimated Payroll tax on Pension Costs', MaxLength = 100;
        TotalTaxLiabilitiesTok: Label 'Total, Tax Liabilities', MaxLength = 100;
        PayrollLiabilitiesTok: Label 'Payroll Liabilities', MaxLength = 100;
        EmployeesWithholdingTaxesTok: Label 'Employees Withholding Taxes', MaxLength = 100;
        StatutorySocialSecurityContributionsTok: Label 'Statutory Social security Contributions', MaxLength = 100;
        ContractualSocialSecurityContributionsTok: Label 'Contractual Social security Contributions', MaxLength = 100;
        AttachmentsOfEarningTok: Label 'Attachments of Earning', MaxLength = 100;
        HolidayPayfundTok: Label 'Holiday Pay fund', MaxLength = 100;
        OtherSalaryWageDeductionsTok: Label 'Other Salary/wage Deductions', MaxLength = 100;
        TotalPayrollLiabilitiesTok: Label 'Total, Payroll Liabilities', MaxLength = 100;
        OtherCurrentLiabilitiesTok: Label 'Other Current Liabilities', MaxLength = 100;
        ClearingAccountForFactoringCurrentPortionTok: Label 'Clearing Account for Factoring, Current Portion', MaxLength = 100;
        CurrentLiabilitiesToEmployeesTok: Label 'Current Liabilities to Employees', MaxLength = 100;
        ClearingAccountForThirdPartyTok: Label 'Clearing Account for third party', MaxLength = 100;
        CurrentLoansTok: Label 'Current Loans', MaxLength = 100;
        LiabilitiesGrantsReceivedTok: Label 'Liabilities, Grants Received ', MaxLength = 100;
        TotalOtherCurrentLiabilitiesTok: Label 'Total, Other Current Liabilities', MaxLength = 100;
        AccruedExpensesAndDeferredIncomeTok: Label 'Accrued Expenses and Deferred Income', MaxLength = 100;
        AccruedWagesSalariesTok: Label 'Accrued wages/salaries', MaxLength = 100;
        AccruedHolidayPayTok: Label 'Accrued Holiday pay', MaxLength = 100;
        AccruedPensionCostsTok: Label 'Accrued Pension costs', MaxLength = 100;
        AccruedInterestExpenseTok: Label 'Accrued Interest Expense', MaxLength = 100;
        DeferredIncomeTok: Label 'Deferred Income', MaxLength = 100;
        AccruedContractualCostsTok: Label 'Accrued Contractual costs', MaxLength = 100;
        OtherAccruedExpensesAndDeferredIncomeTok: Label 'Other Accrued Expenses and Deferred Income', MaxLength = 100;
        TotalAccruedExpensesAndDeferredIncomeTok: Label 'Total, Accrued Expenses and Deferred Income', MaxLength = 100;
        EquityTok: Label 'Equity', MaxLength = 100;
        EquityPartnerTok: Label 'Equity Partner ', MaxLength = 100;
        NetResultsTok: Label 'Net Results ', MaxLength = 100;
        RestrictedEquityTok: Label 'Restricted Equity ', MaxLength = 100;
        ShareCapitalTok: Label 'Share Capital ', MaxLength = 100;
        DividendsTok: Label 'Dividends', MaxLength = 100;
        NonRestrictedEquityTok: Label 'Non-Restricted Equity', MaxLength = 100;
        ProfitOrLossFromThePreviousYearTok: Label 'Profit or loss from the previous year', MaxLength = 100;
        ResultsForTheFinancialyearTok: Label 'Results for the Financial year', MaxLength = 100;
        TotalEquityTok: Label ' Total, Equity', MaxLength = 100;
        InvoiceRoundingTok: Label 'Invoice Rounding, Sales', MaxLength = 100;
}