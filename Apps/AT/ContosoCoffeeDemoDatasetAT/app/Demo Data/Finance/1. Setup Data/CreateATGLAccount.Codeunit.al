codeunit 11148 "Create AT GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        AddGLAccountforAT();
    end;

    local procedure AddGLAccountforAT()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CreareVATPostingGrpAT: Codeunit "Create VAT Posting Group AT";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreatePostingGroupAT: Codeunit "Create Posting Groups AT";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OperatingEquipment(), CreateGLAccount.OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoodsBeginTotal(), FinishedGoodsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherReceivables(), CreateGLAccount.OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Securities(), CreateGLAccount.SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cash(), CreateGLAccount.CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankLcy(), CreateGLAccount.BankLcyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GiroAccount(), CreateGLAccount.GiroAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Mortgage(), CreateGLAccount.MortgageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelExpenses(), CreateGLAccount.PersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesBeginTotal(), WagesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Wages(), CreateGLAccount.WagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalariesBeginTotal(), SalariesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Salaries(), CreateGLAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelExpenses(), CreateGLAccount.TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6000..6998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Co2Tax(), CreateGLAccount.Co2TaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FuelTax(), CreateGLAccount.FuelTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', CreareVATPostingGrpAT.VAT20(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityAndHeating(), CreateGLAccount.ElectricityAndHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', CreareVATPostingGrpAT.VAT20(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', CreareVATPostingGrpAT.VAT20(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', CreareVATPostingGrpAT.VAT20(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', CreareVATPostingGrpAT.VAT20(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroupAT.NoVATPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceReceived(), CreateGLAccount.PaymentToleranceReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PaymentToleranceGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '8400..8497', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTax(), CreateGLAccount.CorporateTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.SetOverwriteData(false);

        ContosoGLAccount.InsertGLAccount(CommissioningAnOperation(), CommissioningAnOperationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CommissioningTheOperation(), CommissioningTheOperationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationFixedAsset(), AccumulatedDepreciationFixedAssetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommissioningTotal(), CommissioningTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0005..0099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssets(), IntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Concessions(), ConcessionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PatentAndLicenseRights(), PatentAndLicenseRightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DataProcessingPrograms(), DataProcessingProgramsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CompanyValue(), CompanyValueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsForIntangibleAssets(), AdvancePaymentsForIntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationIntangibleAsset(), AccumulatedDepreciationIntangibleAssetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIntangibleAssets(), TotalIntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0100..0199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RealEstate(), RealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DevelopedLand(), DevelopedLandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OperationalBuilding(), OperationalBuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionsDuringTheYearVehicle(), AcquisitionsDuringTheYearVehicleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DisposalsDuringTheYearVehicle(), DisposalsDuringTheYearVehicleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvestmentInLeasedBuilding(), InvestmentInLeasedBuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationBooked(), AccumulatedDepreciationBookedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UndevelopedLand(), UndevelopedLandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRealEstate(), TotalRealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0200..0399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MachineryAndEquipment(), MachineryAndEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LowValueMachinery(), LowValueMachineryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationOperEqupment(), AccumulatedDepreciationOperEqupmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeEquipment(), OfficeEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessFacilities(), BusinessFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeMachinesEDP(), OfficeMachinesEDPName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionsDuringTheYearRealEstate(), AcquisitionsDuringTheYearRealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DisposalsDuringTheYearRealEstate(), DisposalsDuringTheYearRealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumDepreciationOfBuilding(), AccumDepreciationOfBuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOperatingEquipment(), TotalOperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0400..0629', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehicleFleet(), VehicleFleetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Car(), CarName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Truck(), TruckName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionsDuringTheYearOperEquipment(), AcquisitionsDuringTheYearOperEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DisposalsDuringTheYearOperEquipment(), DisposalsDuringTheYearOperEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumDepreciation(), AccumDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVehicleFleet(), TotalVehicleFleetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0630..0679', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherFacilities(), OtherFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LowValueAssetsOperationalAndBusFacilities(), LowValueAssetsOperationalAndBusFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationOtherFacilities(), AccumulatedDepreciationOtherFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherFacilities(), TotalOtherFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0680..0699', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsMadeFacilitiesUnderConstr(), AdvancePaymentsMadeFacilitiesUnderConstrName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsMadeForTangibleFixedAssets(), AdvancePaymentsMadeForTangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FacilitiesUnderConstruction(), FacilitiesUnderConstructionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationAdvPayment(), AccumulatedDepreciationAdvPaymentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvPaymMadeFacilitiesUnderConstr(), TotalAdvPaymMadeFacilitiesUnderConstrName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0700..0799', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialAssets(), FinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquityInterestsInAssociatedCompanies(), EquityInterestsInAssociatedCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherEquityInterests(), OtherEquityInterestsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CompanySharesOrEquityInterests(), CompanySharesOrEquityInterestsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvestmentSecurities(), InvestmentSecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecuritiesProvisionsForSeverancePay(), SecuritiesProvisionsForSeverancePayName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecuritiesProvisionsForPensionPlan(), SecuritiesProvisionsForPensionPlanName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsMadeForFinancialAssets(), AdvancePaymentsMadeForFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationFinancialAsset(), AccumulatedDepreciationFinancialAssetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialAssets(), TotalFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0800..0995', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALFIXEDASSETS(), TOTALFIXEDASSETSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '0000..0998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SUPPLIES(), SUPPLIESName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseSettlementBeginTotal(), PurchaseSettlementBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseSettlement(), PurchaseSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OpeningInventory(), OpeningInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPurchaseSettlement(), TotalPurchaseSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1005..1099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialSupply(), RawMaterialSupplyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialSupplyInterim(), RawMaterialSupplyInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialsPostReceiptInterim(), RawMaterialsPostReceiptInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRawMaterials(), TotalRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1100..1199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PartsPurchasedBeginTotal(), PartsPurchasedBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PartsPurchased(), PartsPurchasedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPartsPurchased(), TotalPartsPurchasedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1200..1299', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliariesOperatingMaterials(), AuxiliariesOperatingMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliariesSupply(), AuxiliariesSupplyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingMaterialsSupply(), OperatingMaterialsSupplyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FuelOilSupply(), FuelOilSupplyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAuxiliariesOperatingMaterials(), TotalAuxiliariesOperatingMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1300..1399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WorkInProcessBeginTotal(), WorkInProcessBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WorkInProcess(), WorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostWorkInProcess(), CostWorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnticipatedCostWorkInProcess(), AnticipatedCostWorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesWorkInProcess(), SalesWorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnticipatedSalesWorkInProcess(), AnticipatedSalesWorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWorkInProcess(), TotalWorkInProcessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1400..1499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinishedGoods(), TotalFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1500..1599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Goods(), GoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SupplyTradeGoods(), SupplyTradeGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SupplyTradeGoodsInterim(), SupplyTradeGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsPostReceiptInterim(), TradeGoodsPostReceiptInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalGoods(), TotalGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1600..1699', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceNotBillableYet(), ServiceNotBillableYetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceNotBillableYes(), ServiceNotBillableYesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalServicesNotBillableYet(), TotalServicesNotBillableYetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1700..1799', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsMade(), AdvancePaymentsMadeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsMadeForSupplies(), AdvancePaymentsMadeForSuppliesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvancePaymentsMade(), TotalAdvancePaymentsMadeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1800..1899', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALSUPPLIES(), TOTALSUPPLIESName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1000..1998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCurrentAssets(), OtherCurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeReceivables(), TradeReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeReceivablesDomestic(), TradeReceivablesDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeReceivablesForeign(), TradeReceivablesForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesIntercompany(), ReceivablesIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesCashOnDelivery(), ReceivablesCashOnDeliveryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChangeOfOwnership(), ChangeOfOwnershipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterimAccountAdvancePaymentsReceived(), InterimAccountAdvancePaymentsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IndividualLossReservesForDomesticReceivables(), IndividualLossReservesForDomesticReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BlanketLossReservesForDomesticReceivables(), BlanketLossReservesForDomesticReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeReceivablesIntraCommunity(), TradeReceivablesIntraCommunityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IndivLossReservesForIntraCommunityReceivab(), IndivLossReservesForIntraCommunityReceivabName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BlanketLossReservesForIntraCommunityReceiv(), BlanketLossReservesForIntraCommunityReceivName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeReceivablesExport(), TradeReceivablesExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IndividualLossReservesForReceivablesExport(), IndividualLossReservesForReceivablesExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BlanketLossReservesForReceivablesExport(), BlanketLossReservesForReceivablesExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GrantedLoan(), GrantedLoanName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherAdvancePaymentsMade(), OtherAdvancePaymentsMadeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTradeReceivables(), TotalTradeReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2005..2499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesFromOffsettingOfLevies(), ReceivablesFromOffsettingOfLeviesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATReduced(), PurchaseVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATStandard(), PurchaseVATStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATAcquisitionReduced(), PurchaseVATAcquisitionReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATAcquisitionStandard(), PurchaseVATAcquisitionStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ImportSalesTax(), ImportSalesTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATClearingAccount(), PurchaseVATClearingAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapitalReturnsTaxAllowableOnIncomeTax(), CapitalReturnsTaxAllowableOnIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccountsReceivableOffsettingOfLevies(), TotalAccountsReceivableOffsettingOfLeviesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2500..2598', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAccountsReceivable(), TotalAccountsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2001..2599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MarketableSecurities(), MarketableSecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EndorsedCededBillOfExchange(), EndorsedCededBillOfExchangeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSecurities(), TotalSecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2600..2699', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashAndBank(), CashAndBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PostageStamp(), PostageStampName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueStamps(), RevenueStampsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountCashBank(), SettlementAccountCashBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChecksReceived(), ChecksReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivableFromCreditCardOrganization(), AccountsReceivableFromCreditCardOrganizationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankCurrencies(), BankCurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(TotalCashAndBank(), TotalCashAndBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2700..2899', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidExpenses(), PrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Accruals(), AccrualsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BorrowingCosts(), BorrowingCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPrepaidExpenses(), TotalPrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2900..2995', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALOTHERCURRENTASSETS(), TOTALOTHERCURRENTASSETSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2000..2998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LIABILITIESPROVISIONS(), LIABILITIESPROVISIONSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Provisions(), ProvisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForSeverancePayments(), ProvisionsForSeverancePaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForPensions(), ProvisionsForPensionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForCorporateTax(), ProvisionsForCorporateTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForWarranties(), ProvisionsForWarrantiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForCompensationForDamage(), ProvisionsForCompensationForDamageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionsForLegalAndConsultancyExpenses(), ProvisionsForLegalAndConsultancyExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalProvisions(), TotalProvisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3005..3099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AmountsOwedToCreditFinancialInstitutions(), AmountsOwedToCreditFinancialInstitutionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankWithCreditLimit(), BankWithCreditLimitName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChecksIssued(), ChecksIssuedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Loan(), LoanName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountCreditCards(), SettlementAccountCreditCardsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAmountsOwedToCreditFinancInstitutions(), TotalAmountsOwedToCreditFinancInstitutionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3100..3199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsReceivedBeginTotal(), AdvancePaymentsReceivedBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancePaymentsReceived(), AdvancePaymentsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HardwareContractsPaidInAdvance(), HardwareContractsPaidInAdvanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SoftwareContractsPaidInAdvance(), SoftwareContractsPaidInAdvanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvancePaymentsReceived(), TotalAdvancePaymentsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3200..3290', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PayablesToVendors(), PayablesToVendorsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsIntercompany(), VendorsIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NotePayable(), NotePayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterimAccountAdvancePaymentsMade(), InterimAccountAdvancePaymentsMadeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPayablesToVendors(), TotalPayablesToVendorsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3300..3499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxLiabilities(), TaxLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTax10(), SalesTax10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTax20(), SalesTax20Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxProfitAndIncomeTax10(), SalesTaxProfitAndIncomeTax10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxProfitAndIncomeTax20(), SalesTaxProfitAndIncomeTax20Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxOfficeTaxPayable(), TaxOfficeTaxPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxClearingAccount(), SalesTaxClearingAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProductionOrderPayrollTaxProfitDP(), ProductionOrderPayrollTaxProfitDPName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountTaxOffice(), SettlementAccountTaxOfficeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilitiesFromTaxes(), TotalLiabilitiesFromTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3500..3599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PayablesRelatedToSocialSecurity(), PayablesRelatedToSocialSecurityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountSocialInsurance(), SettlementAccountSocialInsuranceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountLocalTax(), SettlementAccountLocalTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SettlementAccountWagesSalaries(), SettlementAccountWagesSalariesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxPaymentsWithheld(), TaxPaymentsWithheldName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentOfTaxArrears(), PaymentOfTaxArrearsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollTaxPayments(), PayrollTaxPaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VacationCompensationPayments(), VacationCompensationPaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSocialSecurity(), TotalSocialSecurityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3600..3699', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLiabilitiesAndDeferrals(), OtherLiabilitiesAndDeferralsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredIncome(), DeferredIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherLiabilities(), TotalOtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3700..3997', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALLIABILITIESPROVISIONS(), TOTALLIABILITIESPROVISIONSName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3000..3998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OPERATINGINCOME(), OPERATINGINCOMEName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenuesAndRevenueReduction(), RevenuesAndRevenueReductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Revenues(), RevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesTrade(), SalesRevenuesTradeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesTradeDomestic(), SalesRevenuesTradeDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesTradeExport(), SalesRevenuesTradeExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesTradeEU(), SalesRevenuesTradeEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectSales(), ProjectSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectSalesCorrection(), ProjectSalesCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesRevenuesTrade(), TotalSalesRevenuesTradeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4007..4099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesRawMaterial(), SalesRevenuesRawMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesRawMaterialDomestic(), SalesRevenuesRawMaterialDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesRawMaterialExport(), SalesRevenuesRawMaterialExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesRawMaterialEU(), SalesRevenuesRawMaterialEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesRevenuesRawMaterial(), TotalSalesRevenuesRawMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4100..4199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesResources(), SalesRevenuesResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesResourcesDomestic(), SalesRevenuesResourcesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesResourcesExport(), SalesRevenuesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRevenuesResourcesEU(), SalesRevenuesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesRevenuesResources(), TotalSalesRevenuesResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4200..4239', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectRevenuesBeginTotal(), ProjectRevenuesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectRevenues(), ProjectRevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherProjectRevenues(), OtherProjectRevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalProjectRevenues(), TotalProjectRevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4240..4269', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenuesServiceContracts(), RevenuesServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueServiceContract(), RevenueServiceContractName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalServiceContracts(), TotalServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4270..4299', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ChargesAndInterest(), ChargesAndInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceCharges(), ServiceChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceInterest(), ServiceInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingFees(), ConsultingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalChargesAndInterest(), TotalChargesAndInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4300..4395', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenues(), TotalRevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4006..4396', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueAdjustments(), RevenueAdjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueAdjustmentDomestic10(), RevenueAdjustmentDomestic10Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueAdjustmentDomestic20(), RevenueAdjustmentDomestic20Name(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueAdjustmentExport(), RevenueAdjustmentExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueAdjustmentEU(), RevenueAdjustmentEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CashDiscountPaid(), CashDiscountPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CashDiscountPaidAdjustment(), CashDiscountPaidAdjustmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenueAdjustments(), TotalRevenueAdjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4400..4498', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenuesAndRevenueReduction(), TotalRevenuesAndRevenueReductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4005..4499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryChangesBeginTotal(), InventoryChangesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryChanges(), InventoryChangesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OwnCostCapitalized(), OwnCostCapitalizedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInventoryChanges(), TotalInventoryChangesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4500..4599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncomeBeginTotal(), OtherOperatingIncomeBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProceedsFromTheSaleOfAssets(), ProceedsFromTheSaleOfAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsuranceCompensations(), InsuranceCompensationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromTheDisposalOfAssets(), IncomeFromTheDisposalOfAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromTheAppreciationOfIntangibleAssets(), IncomeFromTheAppreciationOfIntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromAppreciationOfFixedAssets(), IncomeFromAppreciationOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncFromReleaseOfProvisionsForSeverPaym(), IncFromReleaseOfProvisionsForSeverPaymName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromTheReleaseOfProvForPensionPlan(), IncomeFromTheReleaseOfProvForPensionPlanName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromTheReleaseOfOtherProvisions(), IncomeFromTheReleaseOfOtherProvisionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncome(), OtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverageOfCash(), OverageOfCashName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BenefitInKind(), BenefitInKindName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RentalYield(), RentalYieldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExpenseReimbursement(), ExpenseReimbursementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FCYUnrealizedExchangeGains(), FCYUnrealizedExchangeGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FCYRealizedExchangeGains(), FCYRealizedExchangeGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInsuranceCompensation(), OtherInsuranceCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromReleaseOfLossReserves(), IncomeFromReleaseOfLossReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherOperatingIncome(), TotalOtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4600..4997', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALOPERATINGINCOME(), TOTALOPERATINGINCOMEName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4000..4998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COSTOFMATERIALS(), COSTOFMATERIALSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoods(), TradeGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsConsumption(), TradeGoodsConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsInventoryAdjustment(), TradeGoodsInventoryAdjustmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsDirectCost(), TradeGoodsDirectCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsOverheadExpenses(), TradeGoodsOverheadExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeGoodsPurchaseVarianceAccount(), TradeGoodsPurchaseVarianceAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountReceivedTrade(), DiscountReceivedTradeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeliveryExpensesTrade(), DeliveryExpensesTradeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountReceivedRawMaterials(), DiscountReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeliveryExpensesRawMaterial(), DeliveryExpensesRawMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTradeGoods(), TotalTradeGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5005..5099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterial(), RawMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialConsumption(), RawMaterialConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialInventoryAdjustment(), RawMaterialInventoryAdjustmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialDirectCost(), RawMaterialDirectCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialOverheadExpenses(), RawMaterialOverheadExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialPurchaseVarianceAccount(), RawMaterialPurchaseVarianceAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRawMaterial(), TotalRawMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5105..5199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Processing(), ProcessingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingConsumption(), ProcessingConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingInventoryAdjustment(), ProcessingInventoryAdjustmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingOverheadExpenses(), ProcessingOverheadExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingPurchaseVarianceAccount(), ProcessingPurchaseVarianceAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalProcessing(), TotalProcessingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5200..5249', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Projects(), ProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectCosts(), ProjectCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectCostsAllocated(), ProjectCostsAllocatedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectCostsCorrection(), ProjectCostsCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalProjects(), TotalProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5250..5299', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variance(), VarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManufacturingOverheadVariance(), ManufacturingOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVariance(), TotalVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5300..5399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Consumption(), ConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliariesConsumption(), AuxiliariesConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PackagingMaterialConsumption(), PackagingMaterialConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingMaterialsConsumption(), OperatingMaterialsConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningMaterialsConsumption(), CleaningMaterialsConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumptionOfIncidentals(), ConsumptionOfIncidentalsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumptionOfFuels(), ConsumptionOfFuelsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalConsumption(), TotalConsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5400..5499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseCurrentMaterial(), PurchaseCurrentMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseTradeDomestic(), PurchaseTradeDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseTradeImport(), PurchaseTradeImportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseTradeEU(), PurchaseTradeEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseRawMaterialsDomestic(), PurchaseRawMaterialsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseRawMaterialsImport(), PurchaseRawMaterialsImportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseRawMaterialsEU(), PurchaseRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPurchaseActiveMaterial(), TotalPurchaseActiveMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5500..5599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherServicesReceived(), OtherServicesReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServicesReceived(), ServicesReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceChargesPurchase(), ServiceChargesPurchaseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherServices(), TotalOtherServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5700..5799', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountRevenueBeginTotal(), PaymentDiscountRevenueBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountRevenue(), PaymentDiscountRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountRevenueCorrection(), PaymentDiscountRevenueCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPaymentDiscountRevenue(), TotalPaymentDiscountRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5800..5899', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALCOSTOFMATERIALS(), TOTALCOSTOFMATERIALSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5000..5998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesWithoutServices(), WagesWithoutServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWages(), TotalWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6005..6199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalariesWithoutServices(), SalariesWithoutServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalaries(), TotalSalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6200..6399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SeverancePaymentsBeginTotal(), SeverancePaymentsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SeverancePayments(), SeverancePaymentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SeverancePaymentProvisionFund(), SeverancePaymentProvisionFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PensionsPayments(), PensionsPaymentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PensionProvisionFund(), PensionProvisionFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSeverancePayments(), TotalSeverancePaymentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6400..6499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialExpenses(), StatutorySocialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialExpensesWorker(), StatutorySocialExpensesWorkerName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialExpensesEmployee(), StatutorySocialExpensesEmployeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalStatutorySocialExpenses(), TotalStatutorySocialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6500..6599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSocialExpenses(), OtherSocialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LocalTax(), LocalTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GDContributionFamilyAllowanceProfit(), GDContributionFamilyAllowanceProfitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdditionToProfit(), AdditionToProfitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LevyForTheEmployerVienna(), LevyForTheEmployerViennaName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VoluntarySocialExpenses(), VoluntarySocialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostCenterSettlementInsurance(), CostCenterSettlementInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherSocialExpenses(), TotalOtherSocialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6600..6997', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DEPRECIATIONOTHERCOSTOFOPERATIONS(), DEPRECIATIONOTHERCOSTOFOPERATIONSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ScheduledAmortizationOnIntangibleAssets(), ScheduledAmortizationOnIntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnscheduledAmortizationOnIntangibleAssets(), UnscheduledAmortizationOnIntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ScheduledDepreciationOfFixedAssets(), ScheduledDepreciationOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ScheduledDepreciationVehicles(), ScheduledDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnscheduledDepreciationOfFixedAssets(), UnscheduledDepreciationOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LowValueAssets(), LowValueAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalDepreciation(), TotalDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7005..7099', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherTaxes(), OtherTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyTax(), PropertyTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BeverageAndAlcoholTax(), BeverageAndAlcoholTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChargesAndRevenueStamps(), ChargesAndRevenueStampsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscOtherTaxes(), MiscOtherTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherTaxes(), TotalOtherTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7100..7199', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaintenanceCleaningEtc(), MaintenanceCleaningEtcName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ThirdPartyMaintenance(), ThirdPartyMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarOperatingExpenses(), CarOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TruckOperatingExpenses(), TruckOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarRepairsAndMaintenance(), CarRepairsAndMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Fuel(), FuelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMaintenanceEtc(), TotalMaintenanceEtcName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7200..7299', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TransportationTravelCommunications(), TransportationTravelCommunicationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TransportationThirdParties(), TransportationThirdPartiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpensesDomestic(), TravelExpensesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpensesAbroad(), TravelExpensesAbroadName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(KilometerAllowance(), KilometerAllowanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MealExpensesDomestic(), MealExpensesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MealExpensesAbroad(), MealExpensesAbroadName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HotelExpensesDomestic(), HotelExpensesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HotelExpensesAbroad(), HotelExpensesAbroadName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommunicationCharges(), CommunicationChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTransportationExpenses(), TotalTransportationExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7300..7399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalsLeasingBeginTotal(), RentalsLeasingBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalsLeasing(), RentalsLeasingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRentalsLeasingEtc(), TotalRentalsLeasingEtcName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7400..7499', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Commissions(), CommissionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CommissionsForThirdParties(), CommissionsForThirdPartiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCommissions(), TotalCommissionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7500..7599', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeAdvertisingAndMaintenanceExpenditure(), OfficeAdvertisingAndMaintenanceExpenditureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneAndInternetCharges(), PhoneAndInternetChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExternalServices(), ExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeductibleAdvertisingExpenses(), DeductibleAdvertisingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonDeductibleAdvertisingExpenses(), NonDeductibleAdvertisingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroupAT.NoVATPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HospitalityDomesticDeductibleAmount(), HospitalityDomesticDeductibleAmountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HospitalityDomesticNonDeductibleAmount(), HospitalityDomesticNonDeductibleAmountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HospitalityAbroadDeductibleAmount(), HospitalityAbroadDeductibleAmountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HospitalityAbroadNonDeductibleAmount(), HospitalityAbroadNonDeductibleAmountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DonationsAndTips(), DonationsAndTipsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOfficeAdvertisingMaintenanceExpenditure(), TotalOfficeAdvertisingMaintenanceExpenditureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7600..7699', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesAndOtherExpenses(), InsurancesAndOtherExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InsuranceExpenses(), InsuranceExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalAndConsultancyExpenses(), LegalAndConsultancyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForLegalAndConsultancyExpensesFund(), ProvisionForLegalAndConsultancyExpensesFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Other(), OtherName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TechnicalLiterature(), TechnicalLiteratureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExpenditureEducationAndTraining(), ExpenditureEducationAndTrainingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ChamberContribution(), ChamberContributionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExpensesThroughCirculationOfMoney(), ExpensesThroughCirculationOfMoneyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationOfSupplies(), DepreciationOfSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationExportReceivables(), DepreciationExportReceivablesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationDomesticReceivables(), DepreciationDomesticReceivablesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IndividualLossReservesForReceivables(), IndividualLossReservesForReceivablesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BlanketLossReservesForReceivables(), BlanketLossReservesForReceivablesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BookValueDisposalOfAssets(), BookValueDisposalOfAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossesFromDisposalOfAssets(), LossesFromDisposalOfAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperationalExpenditure(), OtherOperationalExpenditureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForWarrantiesFund(), ProvisionForWarrantiesFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForCompensationForDamagesFund(), ProvisionForCompensationForDamagesFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvisionForProductLiabilityFund(), ProvisionForProductLiabilityFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscProvisionsFund(), MiscProvisionsFundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CashDeficit(), CashDeficitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FCYUnrealizedExchangeLosses(), FCYUnrealizedExchangeLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FCYRealizedExchangeLosses(), FCYRealizedExchangeLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountRevenue0VAT(), PaymentDiscountRevenue0VATName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostCenterSettlementSocialExpense(), CostCenterSettlementSocialExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsuranceAndOtherExpenditures(), TotalInsuranceAndOtherExpendituresName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7700..7899', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALDEPRECIATIONOPERATIONALEXPENDITURE(), TOTALDEPRECIATIONOPERATIONALEXPENDITUREName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '7000..7998', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FINANCIALREVENUESANDEXPENDITURESBeginTotal(), FINANCIALREVENUESANDEXPENDITURESBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FINANCIALREVENUESANDEXPENDITURES(), FINANCIALREVENUESANDEXPENDITURESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromEquityInterests(), IncomeFromEquityInterestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestFromBankDeposits(), InterestFromBankDepositsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestFromLoansGranted(), InterestFromLoansGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PassThroughDiscountRates(), PassThroughDiscountRatesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromDefaultInterestAndExpenses(), IncomeFromDefaultInterestAndExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroupAT.NoVATPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInterestIncome(), OtherInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestIncomeFromFixedRateSecurities(), InterestIncomeFromFixedRateSecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSecuritiesIncome(), OtherSecuritiesIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProceedsFromTheDispOfOtherFinancialAssets(), ProceedsFromTheDispOfOtherFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PmtTolReceivedDecreasesCorrection(), PmtTolReceivedDecreasesCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromAppreciationOfFinancialAssets(), IncomeFromAppreciationOfFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromAppreciationOfMarketableSecurities(), IncomeFromAppreciationOfMarketableSecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationOtherFinancialAssets(), DepreciationOtherFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationOfMarketableSecurities(), DepreciationOfMarketableSecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossFromDisposalOfOtherFinancialAssets(), LossFromDisposalOfOtherFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestExpenseForBankLoans(), InterestExpenseForBankLoansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnscheduledDepreciationOfFinancialAssets(), UnscheduledDepreciationOfFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestExpenditureForLoans(), InterestExpenditureForLoansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationActivatedFundsAcquisitionCost(), DepreciationActivatedFundsAcquisitionCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountInterestExpenditure(), DiscountInterestExpenditureName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DefaultInterestExpenses(), DefaultInterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroupAT.NoVATPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnusedDeliveryDiscounts(), UnusedDeliveryDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PmtTolGrantedDecreasesCorrection(), PmtTolGrantedDecreasesCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialIncomeAndExpensesEndTotal(), TotalFinancialIncomeAndExpensesEndTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '8005..8399', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonRecurringIncomeNonRecurringExpenses(), NonRecurringIncomeNonRecurringExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonRecurringIncome(), NonRecurringIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonRecurringExpenses(), NonRecurringExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesBeforeIncomeAndEarnings(), TaxesBeforeIncomeAndEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CapitalReturnsTax(), CapitalReturnsTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTaxBeforeIncome(), TotalTaxBeforeIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ChangesInReserves(), ChangesInReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GainsFromReversalOfUntaxedReserves(), GainsFromReversalOfUntaxedReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainsFromReversalOfValuationReserves(), GainsFromReversalOfValuationReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssignmentReservesAccordingTo10EstgIFB(), AssignmentReservesAccordingTo10EstgIFBName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssignmentRLAccordingTo12Estg(), AssignmentRLAccordingTo12EstgName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssignmentToValuationReserves(), AssignmentToValuationReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalChangeInReserves(), TotalChangeInReservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALFINANCIALINCOMEANDEXPENSES(), TOTALFINANCIALINCOMEANDEXPENSESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EQUITYRESERVES(), EQUITYRESERVESName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxProvisions(), TaxProvisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreeReserves(), FreeReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetProfitNetLoss(), NetProfitNetLossName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ValuationReservesFor(), ValuationReservesForName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReservesAccordingTo10EstgIFB(), ReservesAccordingTo10EstgIFBName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReservesAccordingTo12Estg(), ReservesAccordingTo12EstgName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Private(), PrivateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EBK(), EBKName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SBK(), SBKName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitAndLossStatement(), ProfitAndLossStatementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALEQUITYRESERVES(), TOTALEQUITYRESERVESName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        GLAccountIndent.Indent();
        UpdateGLAccountCatagory();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforDE()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ModifyGLAccountForW1();
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '0000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '0400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '1100');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsBeginTotalName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '1520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '2600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '2710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLcyName(), '2800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '2820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '3160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '3310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '3320');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '3710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(WagesBeginTotalName(), '6005');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '6010');
        ContosoGLAccount.AddAccountForLocalization(SalariesBeginTotalName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '6998');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Co2TaxName(), '7140');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '7150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '7220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityAndHeatingName(), '7230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '7240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '7610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '7620');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '7635');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '7637');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '8060');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '8070');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '8160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '8340');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '8360');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '8497');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '8510');
        ContosoGLAccount.AddAccountForLocalization(CommissioningAnOperationName(), '0005');
        ContosoGLAccount.AddAccountForLocalization(CommissioningTheOperationName(), '0010');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationFixedAssetName(), '0090');
        ContosoGLAccount.AddAccountForLocalization(CommissioningTotalName(), '0099');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsName(), '0100');
        ContosoGLAccount.AddAccountForLocalization(ConcessionsName(), '0110');
        ContosoGLAccount.AddAccountForLocalization(PatentAndLicenseRightsName(), '0120');
        ContosoGLAccount.AddAccountForLocalization(DataProcessingProgramsName(), '0130');
        ContosoGLAccount.AddAccountForLocalization(CompanyValueName(), '0150');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsForIntangibleAssetsName(), '0180');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationIntangibleAssetName(), '0190');
        ContosoGLAccount.AddAccountForLocalization(TotalIntangibleAssetsName(), '0199');
        ContosoGLAccount.AddAccountForLocalization(RealEstateName(), '0200');
        ContosoGLAccount.AddAccountForLocalization(DevelopedLandName(), '0210');
        ContosoGLAccount.AddAccountForLocalization(OperationalBuildingName(), '0220');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionsDuringTheYearVehicleName(), '0230');
        ContosoGLAccount.AddAccountForLocalization(DisposalsDuringTheYearVehicleName(), '0240');
        ContosoGLAccount.AddAccountForLocalization(InvestmentInLeasedBuildingName(), '0260');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationBookedName(), '0290');
        ContosoGLAccount.AddAccountForLocalization(UndevelopedLandName(), '0300');
        ContosoGLAccount.AddAccountForLocalization(TotalRealEstateName(), '0399');
        ContosoGLAccount.AddAccountForLocalization(MachineryAndEquipmentName(), '0410');
        ContosoGLAccount.AddAccountForLocalization(LowValueMachineryName(), '0450');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationOperEqupmentName(), '0490');
        ContosoGLAccount.AddAccountForLocalization(OfficeEquipmentName(), '0500');
        ContosoGLAccount.AddAccountForLocalization(BusinessFacilitiesName(), '0510');
        ContosoGLAccount.AddAccountForLocalization(OfficeMachinesEDPName(), '0520');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionsDuringTheYearRealEstateName(), '0530');
        ContosoGLAccount.AddAccountForLocalization(DisposalsDuringTheYearRealEstateName(), '0540');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationOfBuildingName(), '0550');
        ContosoGLAccount.AddAccountForLocalization(TotalOperatingEquipmentName(), '0629');
        ContosoGLAccount.AddAccountForLocalization(VehicleFleetName(), '0630');
        ContosoGLAccount.AddAccountForLocalization(CarName(), '0640');
        ContosoGLAccount.AddAccountForLocalization(TruckName(), '0645');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionsDuringTheYearOperEquipmentName(), '0650');
        ContosoGLAccount.AddAccountForLocalization(DisposalsDuringTheYearOperEquipmentName(), '0660');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationName(), '0670');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleFleetName(), '0679');
        ContosoGLAccount.AddAccountForLocalization(OtherFacilitiesName(), '0680');
        ContosoGLAccount.AddAccountForLocalization(LowValueAssetsOperationalAndBusFacilitiesName(), '0690');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationOtherFacilitiesName(), '0695');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherFacilitiesName(), '0699');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsMadeFacilitiesUnderConstrName(), '0700');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsMadeForTangibleFixedAssetsName(), '0710');
        ContosoGLAccount.AddAccountForLocalization(FacilitiesUnderConstructionName(), '0720');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationAdvPaymentName(), '0790');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvPaymMadeFacilitiesUnderConstrName(), '0799');
        ContosoGLAccount.AddAccountForLocalization(FinancialAssetsName(), '0800');
        ContosoGLAccount.AddAccountForLocalization(EquityInterestsInAssociatedCompaniesName(), '0810');
        ContosoGLAccount.AddAccountForLocalization(OtherEquityInterestsName(), '0820');
        ContosoGLAccount.AddAccountForLocalization(CompanySharesOrEquityInterestsName(), '0900');
        ContosoGLAccount.AddAccountForLocalization(InvestmentSecuritiesName(), '0910');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesProvisionsForSeverancePayName(), '0920');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesProvisionsForPensionPlanName(), '0930');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsMadeForFinancialAssetsName(), '0940');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationFinancialAssetName(), '0950');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialAssetsName(), '0995');
        ContosoGLAccount.AddAccountForLocalization(TOTALFIXEDASSETSName(), '0998');
        ContosoGLAccount.AddAccountForLocalization(SUPPLIESName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(PurchaseSettlementBeginTotalName(), '1005');
        ContosoGLAccount.AddAccountForLocalization(PurchaseSettlementName(), '1010');
        ContosoGLAccount.AddAccountForLocalization(OpeningInventoryName(), '1020');
        ContosoGLAccount.AddAccountForLocalization(TotalPurchaseSettlementName(), '1099');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialSupplyName(), '1110');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialSupplyInterimName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialsPostReceiptInterimName(), '1130');
        ContosoGLAccount.AddAccountForLocalization(TotalRawMaterialsName(), '1199');
        ContosoGLAccount.AddAccountForLocalization(PartsPurchasedBeginTotalName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(PartsPurchasedName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(TotalPartsPurchasedName(), '1299');
        ContosoGLAccount.AddAccountForLocalization(AuxiliariesOperatingMaterialsName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(AuxiliariesSupplyName(), '1310');
        ContosoGLAccount.AddAccountForLocalization(OperatingMaterialsSupplyName(), '1320');
        ContosoGLAccount.AddAccountForLocalization(FuelOilSupplyName(), '1330');
        ContosoGLAccount.AddAccountForLocalization(TotalAuxiliariesOperatingMaterialsName(), '1399');
        ContosoGLAccount.AddAccountForLocalization(WorkInProcessBeginTotalName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(WorkInProcessName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CostWorkInProcessName(), '1420');
        ContosoGLAccount.AddAccountForLocalization(AnticipatedCostWorkInProcessName(), '1421');
        ContosoGLAccount.AddAccountForLocalization(SalesWorkInProcessName(), '1430');
        ContosoGLAccount.AddAccountForLocalization(AnticipatedSalesWorkInProcessName(), '1431');
        ContosoGLAccount.AddAccountForLocalization(TotalWorkInProcessName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(TotalFinishedGoodsName(), '1599');
        ContosoGLAccount.AddAccountForLocalization(GoodsName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(SupplyTradeGoodsName(), '1610');
        ContosoGLAccount.AddAccountForLocalization(SupplyTradeGoodsInterimName(), '1620');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsPostReceiptInterimName(), '1630');
        ContosoGLAccount.AddAccountForLocalization(TotalGoodsName(), '1699');
        ContosoGLAccount.AddAccountForLocalization(ServiceNotBillableYetName(), '1700');
        ContosoGLAccount.AddAccountForLocalization(ServiceNotBillableYesName(), '1710');
        ContosoGLAccount.AddAccountForLocalization(TotalServicesNotBillableYetName(), '1799');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsMadeName(), '1800');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsMadeForSuppliesName(), '1810');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvancePaymentsMadeName(), '1899');
        ContosoGLAccount.AddAccountForLocalization(TOTALSUPPLIESName(), '1998');
        ContosoGLAccount.AddAccountForLocalization(OtherCurrentAssetsName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '2001');
        ContosoGLAccount.AddAccountForLocalization(TradeReceivablesName(), '2005');
        ContosoGLAccount.AddAccountForLocalization(TradeReceivablesDomesticName(), '2010');
        ContosoGLAccount.AddAccountForLocalization(TradeReceivablesForeignName(), '2020');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesIntercompanyName(), '2030');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesCashOnDeliveryName(), '2040');
        ContosoGLAccount.AddAccountForLocalization(ChangeOfOwnershipName(), '2050');
        ContosoGLAccount.AddAccountForLocalization(InterimAccountAdvancePaymentsReceivedName(), '2070');
        ContosoGLAccount.AddAccountForLocalization(IndividualLossReservesForDomesticReceivablesName(), '2080');
        ContosoGLAccount.AddAccountForLocalization(BlanketLossReservesForDomesticReceivablesName(), '2090');
        ContosoGLAccount.AddAccountForLocalization(TradeReceivablesIntraCommunityName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(IndivLossReservesForIntraCommunityReceivabName(), '2180');
        ContosoGLAccount.AddAccountForLocalization(BlanketLossReservesForIntraCommunityReceivName(), '2190');
        ContosoGLAccount.AddAccountForLocalization(TradeReceivablesExportName(), '2200');
        ContosoGLAccount.AddAccountForLocalization(IndividualLossReservesForReceivablesExportName(), '2280');
        ContosoGLAccount.AddAccountForLocalization(BlanketLossReservesForReceivablesExportName(), '2290');
        ContosoGLAccount.AddAccountForLocalization(GrantedLoanName(), '2350');
        ContosoGLAccount.AddAccountForLocalization(OtherAdvancePaymentsMadeName(), '2390');
        ContosoGLAccount.AddAccountForLocalization(TotalTradeReceivablesName(), '2499');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesFromOffsettingOfLeviesName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATReducedName(), '2510');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATStandardName(), '2520');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATAcquisitionReducedName(), '2530');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATAcquisitionStandardName(), '2540');
        ContosoGLAccount.AddAccountForLocalization(ImportSalesTaxName(), '2550');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATClearingAccountName(), '2560');
        ContosoGLAccount.AddAccountForLocalization(CapitalReturnsTaxAllowableOnIncomeTaxName(), '2570');
        ContosoGLAccount.AddAccountForLocalization(TotalAccountsReceivableOffsettingOfLeviesName(), '2598');
        ContosoGLAccount.AddAccountForLocalization(TotalAccountsReceivableName(), '2599');
        ContosoGLAccount.AddAccountForLocalization(MarketableSecuritiesName(), '2650');
        ContosoGLAccount.AddAccountForLocalization(EndorsedCededBillOfExchangeName(), '2680');
        ContosoGLAccount.AddAccountForLocalization(TotalSecuritiesName(), '2699');
        ContosoGLAccount.AddAccountForLocalization(CashAndBankName(), '2700');
        ContosoGLAccount.AddAccountForLocalization(PostageStampName(), '2730');
        ContosoGLAccount.AddAccountForLocalization(RevenueStampsName(), '2740');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountCashBankName(), '2770');
        ContosoGLAccount.AddAccountForLocalization(ChecksReceivedName(), '2780');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivableFromCreditCardOrganizationName(), '2790');
        ContosoGLAccount.AddAccountForLocalization(BankCurrenciesName(), '2810');
        ContosoGLAccount.AddAccountForLocalization(TotalCashAndBankName(), '2899');
        ContosoGLAccount.AddAccountForLocalization(PrepaidExpensesName(), '2900');
        ContosoGLAccount.AddAccountForLocalization(AccrualsName(), '2910');
        ContosoGLAccount.AddAccountForLocalization(BorrowingCostsName(), '2950');
        ContosoGLAccount.AddAccountForLocalization(TotalPrepaidExpensesName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(TOTALOTHERCURRENTASSETSName(), '2998');
        ContosoGLAccount.AddAccountForLocalization(LIABILITIESPROVISIONSName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsName(), '3005');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForSeverancePaymentsName(), '3010');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForPensionsName(), '3020');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForCorporateTaxName(), '3030');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForWarrantiesName(), '3060');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForCompensationForDamageName(), '3070');
        ContosoGLAccount.AddAccountForLocalization(ProvisionsForLegalAndConsultancyExpensesName(), '3080');
        ContosoGLAccount.AddAccountForLocalization(TotalProvisionsName(), '3099');
        ContosoGLAccount.AddAccountForLocalization(AmountsOwedToCreditFinancialInstitutionsName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(BankWithCreditLimitName(), '3110');
        ContosoGLAccount.AddAccountForLocalization(ChecksIssuedName(), '3120');
        ContosoGLAccount.AddAccountForLocalization(LoanName(), '3150');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountCreditCardsName(), '3170');
        ContosoGLAccount.AddAccountForLocalization(TotalAmountsOwedToCreditFinancInstitutionsName(), '3199');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsReceivedBeginTotalName(), '3200');
        ContosoGLAccount.AddAccountForLocalization(AdvancePaymentsReceivedName(), '3210');
        ContosoGLAccount.AddAccountForLocalization(HardwareContractsPaidInAdvanceName(), '3220');
        ContosoGLAccount.AddAccountForLocalization(SoftwareContractsPaidInAdvanceName(), '3230');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvancePaymentsReceivedName(), '3290');
        ContosoGLAccount.AddAccountForLocalization(PayablesToVendorsName(), '3300');
        ContosoGLAccount.AddAccountForLocalization(VendorsIntercompanyName(), '3330');
        ContosoGLAccount.AddAccountForLocalization(NotePayableName(), '3360');
        ContosoGLAccount.AddAccountForLocalization(InterimAccountAdvancePaymentsMadeName(), '3370');
        ContosoGLAccount.AddAccountForLocalization(TotalPayablesToVendorsName(), '3499');
        ContosoGLAccount.AddAccountForLocalization(TaxLiabilitiesName(), '3500');
        ContosoGLAccount.AddAccountForLocalization(SalesTax10Name(), '3510');
        ContosoGLAccount.AddAccountForLocalization(SalesTax20Name(), '3520');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxProfitAndIncomeTax10Name(), '3530');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxProfitAndIncomeTax20Name(), '3540');
        ContosoGLAccount.AddAccountForLocalization(TaxOfficeTaxPayableName(), '3550');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxClearingAccountName(), '3560');
        ContosoGLAccount.AddAccountForLocalization(ProductionOrderPayrollTaxProfitDPName(), '3570');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountTaxOfficeName(), '3580');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesFromTaxesName(), '3599');
        ContosoGLAccount.AddAccountForLocalization(PayablesRelatedToSocialSecurityName(), '3600');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountSocialInsuranceName(), '3610');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountLocalTaxName(), '3620');
        ContosoGLAccount.AddAccountForLocalization(SettlementAccountWagesSalariesName(), '3630');
        ContosoGLAccount.AddAccountForLocalization(TaxPaymentsWithheldName(), '3640');
        ContosoGLAccount.AddAccountForLocalization(PaymentOfTaxArrearsName(), '3650');
        ContosoGLAccount.AddAccountForLocalization(PayrollTaxPaymentsName(), '3660');
        ContosoGLAccount.AddAccountForLocalization(VacationCompensationPaymentsName(), '3670');
        ContosoGLAccount.AddAccountForLocalization(TotalSocialSecurityName(), '3699');
        ContosoGLAccount.AddAccountForLocalization(OtherLiabilitiesAndDeferralsName(), '3700');
        ContosoGLAccount.AddAccountForLocalization(DeferredIncomeName(), '3900');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherLiabilitiesName(), '3997');
        ContosoGLAccount.AddAccountForLocalization(TOTALLIABILITIESPROVISIONSName(), '3998');
        ContosoGLAccount.AddAccountForLocalization(OPERATINGINCOMEName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(RevenuesAndRevenueReductionName(), '4005');
        ContosoGLAccount.AddAccountForLocalization(RevenuesName(), '4006');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesTradeName(), '4007');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesTradeDomesticName(), '4010');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesTradeExportName(), '4020');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesTradeEUName(), '4030');
        ContosoGLAccount.AddAccountForLocalization(ProjectSalesName(), '4040');
        ContosoGLAccount.AddAccountForLocalization(ProjectSalesCorrectionName(), '4050');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesRevenuesTradeName(), '4099');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesRawMaterialName(), '4100');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesRawMaterialDomesticName(), '4110');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesRawMaterialExportName(), '4120');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesRawMaterialEUName(), '4130');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesRevenuesRawMaterialName(), '4199');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesResourcesName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesResourcesDomesticName(), '4210');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesResourcesExportName(), '4220');
        ContosoGLAccount.AddAccountForLocalization(SalesRevenuesResourcesEUName(), '4230');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesRevenuesResourcesName(), '4239');
        ContosoGLAccount.AddAccountForLocalization(ProjectRevenuesBeginTotalName(), '4240');
        ContosoGLAccount.AddAccountForLocalization(ProjectRevenuesName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(OtherProjectRevenuesName(), '4260');
        ContosoGLAccount.AddAccountForLocalization(TotalProjectRevenuesName(), '4269');
        ContosoGLAccount.AddAccountForLocalization(RevenuesServiceContractsName(), '4270');
        ContosoGLAccount.AddAccountForLocalization(RevenueServiceContractName(), '4280');
        ContosoGLAccount.AddAccountForLocalization(TotalServiceContractsName(), '4299');
        ContosoGLAccount.AddAccountForLocalization(ChargesAndInterestName(), '4300');
        ContosoGLAccount.AddAccountForLocalization(ServiceChargesName(), '4310');
        ContosoGLAccount.AddAccountForLocalization(ServiceInterestName(), '4320');
        ContosoGLAccount.AddAccountForLocalization(ConsultingFeesName(), '4330');
        ContosoGLAccount.AddAccountForLocalization(TotalChargesAndInterestName(), '4395');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenuesName(), '4396');
        ContosoGLAccount.AddAccountForLocalization(RevenueAdjustmentsName(), '4400');
        ContosoGLAccount.AddAccountForLocalization(RevenueAdjustmentDomestic10Name(), '4410');
        ContosoGLAccount.AddAccountForLocalization(RevenueAdjustmentDomestic20Name(), '4420');
        ContosoGLAccount.AddAccountForLocalization(RevenueAdjustmentExportName(), '4430');
        ContosoGLAccount.AddAccountForLocalization(RevenueAdjustmentEUName(), '4440');
        ContosoGLAccount.AddAccountForLocalization(CashDiscountPaidName(), '4450');
        ContosoGLAccount.AddAccountForLocalization(CashDiscountPaidAdjustmentName(), '4455');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueAdjustmentsName(), '4498');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenuesAndRevenueReductionName(), '4499');
        ContosoGLAccount.AddAccountForLocalization(InventoryChangesBeginTotalName(), '4500');
        ContosoGLAccount.AddAccountForLocalization(InventoryChangesName(), '4510');
        ContosoGLAccount.AddAccountForLocalization(OwnCostCapitalizedName(), '4580');
        ContosoGLAccount.AddAccountForLocalization(TotalInventoryChangesName(), '4599');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeBeginTotalName(), '4600');
        ContosoGLAccount.AddAccountForLocalization(ProceedsFromTheSaleOfAssetsName(), '4610');
        ContosoGLAccount.AddAccountForLocalization(InsuranceCompensationsName(), '4620');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromTheDisposalOfAssetsName(), '4630');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromTheAppreciationOfIntangibleAssetsName(), '4640');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromAppreciationOfFixedAssetsName(), '4650');
        ContosoGLAccount.AddAccountForLocalization(IncFromReleaseOfProvisionsForSeverPaymName(), '4700');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromTheReleaseOfProvForPensionPlanName(), '4710');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromTheReleaseOfOtherProvisionsName(), '4760');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeName(), '4800');
        ContosoGLAccount.AddAccountForLocalization(OverageOfCashName(), '4810');
        ContosoGLAccount.AddAccountForLocalization(BenefitInKindName(), '4820');
        ContosoGLAccount.AddAccountForLocalization(RentalYieldName(), '4830');
        ContosoGLAccount.AddAccountForLocalization(ExpenseReimbursementName(), '4860');
        ContosoGLAccount.AddAccountForLocalization(FCYUnrealizedExchangeGainsName(), '4870');
        ContosoGLAccount.AddAccountForLocalization(FCYRealizedExchangeGainsName(), '4880');
        ContosoGLAccount.AddAccountForLocalization(OtherInsuranceCompensationName(), '4890');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromReleaseOfLossReservesName(), '4900');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherOperatingIncomeName(), '4997');
        ContosoGLAccount.AddAccountForLocalization(TOTALOPERATINGINCOMEName(), '4998');
        ContosoGLAccount.AddAccountForLocalization(COSTOFMATERIALSName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsName(), '5005');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsConsumptionName(), '5010');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsInventoryAdjustmentName(), '5020');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsDirectCostName(), '5030');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsOverheadExpensesName(), '5040');
        ContosoGLAccount.AddAccountForLocalization(TradeGoodsPurchaseVarianceAccountName(), '5045');
        ContosoGLAccount.AddAccountForLocalization(DiscountReceivedTradeName(), '5050');
        ContosoGLAccount.AddAccountForLocalization(DeliveryExpensesTradeName(), '5060');
        ContosoGLAccount.AddAccountForLocalization(DiscountReceivedRawMaterialsName(), '5070');
        ContosoGLAccount.AddAccountForLocalization(DeliveryExpensesRawMaterialName(), '5080');
        ContosoGLAccount.AddAccountForLocalization(TotalTradeGoodsName(), '5099');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialName(), '5105');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialConsumptionName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialInventoryAdjustmentName(), '5120');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialDirectCostName(), '5130');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialOverheadExpensesName(), '5140');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialPurchaseVarianceAccountName(), '5145');
        ContosoGLAccount.AddAccountForLocalization(TotalRawMaterialName(), '5199');
        ContosoGLAccount.AddAccountForLocalization(ProcessingName(), '5200');
        ContosoGLAccount.AddAccountForLocalization(ProcessingConsumptionName(), '5210');
        ContosoGLAccount.AddAccountForLocalization(ProcessingInventoryAdjustmentName(), '5230');
        ContosoGLAccount.AddAccountForLocalization(ProcessingOverheadExpensesName(), '5240');
        ContosoGLAccount.AddAccountForLocalization(ProcessingPurchaseVarianceAccountName(), '5245');
        ContosoGLAccount.AddAccountForLocalization(TotalProcessingName(), '5249');
        ContosoGLAccount.AddAccountForLocalization(ProjectsName(), '5250');
        ContosoGLAccount.AddAccountForLocalization(ProjectCostsName(), '5260');
        ContosoGLAccount.AddAccountForLocalization(ProjectCostsAllocatedName(), '5270');
        ContosoGLAccount.AddAccountForLocalization(ProjectCostsCorrectionName(), '5280');
        ContosoGLAccount.AddAccountForLocalization(TotalProjectsName(), '5299');
        ContosoGLAccount.AddAccountForLocalization(VarianceName(), '5300');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '5310');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '5320');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '5330');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '5340');
        ContosoGLAccount.AddAccountForLocalization(ManufacturingOverheadVarianceName(), '5350');
        ContosoGLAccount.AddAccountForLocalization(TotalVarianceName(), '5399');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionName(), '5400');
        ContosoGLAccount.AddAccountForLocalization(AuxiliariesConsumptionName(), '5410');
        ContosoGLAccount.AddAccountForLocalization(PackagingMaterialConsumptionName(), '5420');
        ContosoGLAccount.AddAccountForLocalization(OperatingMaterialsConsumptionName(), '5430');
        ContosoGLAccount.AddAccountForLocalization(CleaningMaterialsConsumptionName(), '5440');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionOfIncidentalsName(), '5450');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionOfFuelsName(), '5460');
        ContosoGLAccount.AddAccountForLocalization(TotalConsumptionName(), '5499');
        ContosoGLAccount.AddAccountForLocalization(PurchaseCurrentMaterialName(), '5500');
        ContosoGLAccount.AddAccountForLocalization(PurchaseTradeDomesticName(), '5510');
        ContosoGLAccount.AddAccountForLocalization(PurchaseTradeImportName(), '5520');
        ContosoGLAccount.AddAccountForLocalization(PurchaseTradeEUName(), '5530');
        ContosoGLAccount.AddAccountForLocalization(PurchaseRawMaterialsDomesticName(), '5540');
        ContosoGLAccount.AddAccountForLocalization(PurchaseRawMaterialsImportName(), '5550');
        ContosoGLAccount.AddAccountForLocalization(PurchaseRawMaterialsEUName(), '5560');
        ContosoGLAccount.AddAccountForLocalization(TotalPurchaseActiveMaterialName(), '5599');
        ContosoGLAccount.AddAccountForLocalization(OtherServicesReceivedName(), '5700');
        ContosoGLAccount.AddAccountForLocalization(ServicesReceivedName(), '5710');
        ContosoGLAccount.AddAccountForLocalization(ServiceChargesPurchaseName(), '5720');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherServicesName(), '5799');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountRevenueBeginTotalName(), '5800');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountRevenueName(), '5830');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountRevenueCorrectionName(), '5835');
        ContosoGLAccount.AddAccountForLocalization(TotalPaymentDiscountRevenueName(), '5899');
        ContosoGLAccount.AddAccountForLocalization(TOTALCOSTOFMATERIALSName(), '5998');
        ContosoGLAccount.AddAccountForLocalization(WagesWithoutServicesName(), '6040');
        ContosoGLAccount.AddAccountForLocalization(TotalWagesName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(SalariesWithoutServicesName(), '6240');
        ContosoGLAccount.AddAccountForLocalization(TotalSalariesName(), '6399');
        ContosoGLAccount.AddAccountForLocalization(SeverancePaymentsBeginTotalName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(SeverancePaymentsName(), '6410');
        ContosoGLAccount.AddAccountForLocalization(SeverancePaymentProvisionFundName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(PensionsPaymentsName(), '6450');
        ContosoGLAccount.AddAccountForLocalization(PensionProvisionFundName(), '6455');
        ContosoGLAccount.AddAccountForLocalization(TotalSeverancePaymentsName(), '6499');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialExpensesName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialExpensesWorkerName(), '6510');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialExpensesEmployeeName(), '6550');
        ContosoGLAccount.AddAccountForLocalization(TotalStatutorySocialExpensesName(), '6599');
        ContosoGLAccount.AddAccountForLocalization(OtherSocialExpensesName(), '6600');
        ContosoGLAccount.AddAccountForLocalization(LocalTaxName(), '6610');
        ContosoGLAccount.AddAccountForLocalization(GDContributionFamilyAllowanceProfitName(), '6620');
        ContosoGLAccount.AddAccountForLocalization(AdditionToProfitName(), '6630');
        ContosoGLAccount.AddAccountForLocalization(LevyForTheEmployerViennaName(), '6640');
        ContosoGLAccount.AddAccountForLocalization(VoluntarySocialExpensesName(), '6700');
        ContosoGLAccount.AddAccountForLocalization(CostCenterSettlementInsuranceName(), '6890');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherSocialExpensesName(), '6997');
        ContosoGLAccount.AddAccountForLocalization(DEPRECIATIONOTHERCOSTOFOPERATIONSName(), '7000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '7005');
        ContosoGLAccount.AddAccountForLocalization(ScheduledAmortizationOnIntangibleAssetsName(), '7010');
        ContosoGLAccount.AddAccountForLocalization(UnscheduledAmortizationOnIntangibleAssetsName(), '7020');
        ContosoGLAccount.AddAccountForLocalization(ScheduledDepreciationOfFixedAssetsName(), '7030');
        ContosoGLAccount.AddAccountForLocalization(ScheduledDepreciationVehiclesName(), '7040');
        ContosoGLAccount.AddAccountForLocalization(UnscheduledDepreciationOfFixedAssetsName(), '7050');
        ContosoGLAccount.AddAccountForLocalization(LowValueAssetsName(), '7060');
        ContosoGLAccount.AddAccountForLocalization(TotalDepreciationName(), '7099');
        ContosoGLAccount.AddAccountForLocalization(OtherTaxesName(), '7100');
        ContosoGLAccount.AddAccountForLocalization(PropertyTaxName(), '7110');
        ContosoGLAccount.AddAccountForLocalization(BeverageAndAlcoholTaxName(), '7120');
        ContosoGLAccount.AddAccountForLocalization(ChargesAndRevenueStampsName(), '7130');
        ContosoGLAccount.AddAccountForLocalization(MiscOtherTaxesName(), '7160');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherTaxesName(), '7199');
        ContosoGLAccount.AddAccountForLocalization(MaintenanceCleaningEtcName(), '7200');
        ContosoGLAccount.AddAccountForLocalization(ThirdPartyMaintenanceName(), '7210');
        ContosoGLAccount.AddAccountForLocalization(CarOperatingExpensesName(), '7250');
        ContosoGLAccount.AddAccountForLocalization(TruckOperatingExpensesName(), '7260');
        ContosoGLAccount.AddAccountForLocalization(CarRepairsAndMaintenanceName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(FuelName(), '7280');
        ContosoGLAccount.AddAccountForLocalization(TotalMaintenanceEtcName(), '7299');
        ContosoGLAccount.AddAccountForLocalization(TransportationTravelCommunicationsName(), '7300');
        ContosoGLAccount.AddAccountForLocalization(TransportationThirdPartiesName(), '7310');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesDomesticName(), '7320');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesAbroadName(), '7330');
        ContosoGLAccount.AddAccountForLocalization(KilometerAllowanceName(), '7340');
        ContosoGLAccount.AddAccountForLocalization(MealExpensesDomesticName(), '7350');
        ContosoGLAccount.AddAccountForLocalization(MealExpensesAbroadName(), '7360');
        ContosoGLAccount.AddAccountForLocalization(HotelExpensesDomesticName(), '7370');
        ContosoGLAccount.AddAccountForLocalization(HotelExpensesAbroadName(), '7380');
        ContosoGLAccount.AddAccountForLocalization(CommunicationChargesName(), '7390');
        ContosoGLAccount.AddAccountForLocalization(TotalTransportationExpensesName(), '7399');
        ContosoGLAccount.AddAccountForLocalization(RentalsLeasingBeginTotalName(), '7400');
        ContosoGLAccount.AddAccountForLocalization(RentalsLeasingName(), '7410');
        ContosoGLAccount.AddAccountForLocalization(TotalRentalsLeasingEtcName(), '7499');
        ContosoGLAccount.AddAccountForLocalization(CommissionsName(), '7500');
        ContosoGLAccount.AddAccountForLocalization(CommissionsForThirdPartiesName(), '7510');
        ContosoGLAccount.AddAccountForLocalization(TotalCommissionsName(), '7599');
        ContosoGLAccount.AddAccountForLocalization(OfficeAdvertisingAndMaintenanceExpenditureName(), '7600');
        ContosoGLAccount.AddAccountForLocalization(PhoneAndInternetChargesName(), '7630');
        ContosoGLAccount.AddAccountForLocalization(ExternalServicesName(), '7636');
        ContosoGLAccount.AddAccountForLocalization(DeductibleAdvertisingExpensesName(), '7650');
        ContosoGLAccount.AddAccountForLocalization(NonDeductibleAdvertisingExpensesName(), '7660');
        ContosoGLAccount.AddAccountForLocalization(HospitalityDomesticDeductibleAmountName(), '7680');
        ContosoGLAccount.AddAccountForLocalization(HospitalityDomesticNonDeductibleAmountName(), '7681');
        ContosoGLAccount.AddAccountForLocalization(HospitalityAbroadDeductibleAmountName(), '7682');
        ContosoGLAccount.AddAccountForLocalization(HospitalityAbroadNonDeductibleAmountName(), '7683');
        ContosoGLAccount.AddAccountForLocalization(DonationsAndTipsName(), '7690');
        ContosoGLAccount.AddAccountForLocalization(TotalOfficeAdvertisingMaintenanceExpenditureName(), '7699');
        ContosoGLAccount.AddAccountForLocalization(InsurancesAndOtherExpensesName(), '7700');
        ContosoGLAccount.AddAccountForLocalization(InsuranceExpensesName(), '7710');
        ContosoGLAccount.AddAccountForLocalization(LegalAndConsultancyExpensesName(), '7720');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForLegalAndConsultancyExpensesFundName(), '7730');
        ContosoGLAccount.AddAccountForLocalization(OtherName(), '7740');
        ContosoGLAccount.AddAccountForLocalization(TechnicalLiteratureName(), '7760');
        ContosoGLAccount.AddAccountForLocalization(ExpenditureEducationAndTrainingName(), '7770');
        ContosoGLAccount.AddAccountForLocalization(ChamberContributionName(), '7780');
        ContosoGLAccount.AddAccountForLocalization(ExpensesThroughCirculationOfMoneyName(), '7790');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOfSuppliesName(), '7800');
        ContosoGLAccount.AddAccountForLocalization(DepreciationExportReceivablesName(), '7810');
        ContosoGLAccount.AddAccountForLocalization(DepreciationDomesticReceivablesName(), '7812');
        ContosoGLAccount.AddAccountForLocalization(IndividualLossReservesForReceivablesName(), '7815');
        ContosoGLAccount.AddAccountForLocalization(BlanketLossReservesForReceivablesName(), '7818');
        ContosoGLAccount.AddAccountForLocalization(BookValueDisposalOfAssetsName(), '7820');
        ContosoGLAccount.AddAccountForLocalization(LossesFromDisposalOfAssetsName(), '7830');
        ContosoGLAccount.AddAccountForLocalization(OtherOperationalExpenditureName(), '7850');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForWarrantiesFundName(), '7851');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForCompensationForDamagesFundName(), '7852');
        ContosoGLAccount.AddAccountForLocalization(ProvisionForProductLiabilityFundName(), '7853');
        ContosoGLAccount.AddAccountForLocalization(MiscProvisionsFundName(), '7854');
        ContosoGLAccount.AddAccountForLocalization(CashDeficitName(), '7855');
        ContosoGLAccount.AddAccountForLocalization(FCYUnrealizedExchangeLossesName(), '7860');
        ContosoGLAccount.AddAccountForLocalization(FCYRealizedExchangeLossesName(), '7870');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountRevenue0VATName(), '7882');
        ContosoGLAccount.AddAccountForLocalization(CostCenterSettlementSocialExpenseName(), '7890');
        ContosoGLAccount.AddAccountForLocalization(TotalInsuranceAndOtherExpendituresName(), '7899');
        ContosoGLAccount.AddAccountForLocalization(TOTALDEPRECIATIONOPERATIONALEXPENDITUREName(), '7998');
        ContosoGLAccount.AddAccountForLocalization(FINANCIALREVENUESANDEXPENDITURESBeginTotalName(), '8000');
        ContosoGLAccount.AddAccountForLocalization(FINANCIALREVENUESANDEXPENDITURESName(), '8005');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromEquityInterestsName(), '8010');
        ContosoGLAccount.AddAccountForLocalization(InterestFromBankDepositsName(), '8020');
        ContosoGLAccount.AddAccountForLocalization(InterestFromLoansGrantedName(), '8030');
        ContosoGLAccount.AddAccountForLocalization(PassThroughDiscountRatesName(), '8040');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromDefaultInterestAndExpensesName(), '8050');
        ContosoGLAccount.AddAccountForLocalization(OtherInterestIncomeName(), '8090');
        ContosoGLAccount.AddAccountForLocalization(InterestIncomeFromFixedRateSecuritiesName(), '8100');
        ContosoGLAccount.AddAccountForLocalization(OtherSecuritiesIncomeName(), '8140');
        ContosoGLAccount.AddAccountForLocalization(ProceedsFromTheDispOfOtherFinancialAssetsName(), '8150');
        ContosoGLAccount.AddAccountForLocalization(PmtTolReceivedDecreasesCorrectionName(), '8170');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromAppreciationOfFinancialAssetsName(), '8180');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromAppreciationOfMarketableSecuritiesName(), '8185');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOtherFinancialAssetsName(), '8260');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOfMarketableSecuritiesName(), '8265');
        ContosoGLAccount.AddAccountForLocalization(LossFromDisposalOfOtherFinancialAssetsName(), '8270');
        ContosoGLAccount.AddAccountForLocalization(InterestExpenseForBankLoansName(), '8280');
        ContosoGLAccount.AddAccountForLocalization(UnscheduledDepreciationOfFinancialAssetsName(), '8285');
        ContosoGLAccount.AddAccountForLocalization(InterestExpenditureForLoansName(), '8290');
        ContosoGLAccount.AddAccountForLocalization(DepreciationActivatedFundsAcquisitionCostName(), '8300');
        ContosoGLAccount.AddAccountForLocalization(DiscountInterestExpenditureName(), '8310');
        ContosoGLAccount.AddAccountForLocalization(DefaultInterestExpensesName(), '8320');
        ContosoGLAccount.AddAccountForLocalization(UnusedDeliveryDiscountsName(), '8350');
        ContosoGLAccount.AddAccountForLocalization(PmtTolGrantedDecreasesCorrectionName(), '8370');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialIncomeAndExpensesEndTotalName(), '8399');
        ContosoGLAccount.AddAccountForLocalization(NonRecurringIncomeNonRecurringExpensesName(), '8400');
        ContosoGLAccount.AddAccountForLocalization(NonRecurringIncomeName(), '8410');
        ContosoGLAccount.AddAccountForLocalization(NonRecurringExpensesName(), '8450');
        ContosoGLAccount.AddAccountForLocalization(TaxesBeforeIncomeAndEarningsName(), '8500');
        ContosoGLAccount.AddAccountForLocalization(CapitalReturnsTaxName(), '8520');
        ContosoGLAccount.AddAccountForLocalization(TotalTaxBeforeIncomeName(), '8597');
        ContosoGLAccount.AddAccountForLocalization(ChangesInReservesName(), '8600');
        ContosoGLAccount.AddAccountForLocalization(GainsFromReversalOfUntaxedReservesName(), '8610');
        ContosoGLAccount.AddAccountForLocalization(GainsFromReversalOfValuationReservesName(), '8630');
        ContosoGLAccount.AddAccountForLocalization(AssignmentReservesAccordingTo10EstgIFBName(), '8810');
        ContosoGLAccount.AddAccountForLocalization(AssignmentRLAccordingTo12EstgName(), '8820');
        ContosoGLAccount.AddAccountForLocalization(AssignmentToValuationReservesName(), '8830');
        ContosoGLAccount.AddAccountForLocalization(TotalChangeInReservesName(), '8897');
        ContosoGLAccount.AddAccountForLocalization(TOTALFINANCIALINCOMEANDEXPENSESName(), '8998');
        ContosoGLAccount.AddAccountForLocalization(EQUITYRESERVESName(), '9000');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '9010');
        ContosoGLAccount.AddAccountForLocalization(TaxProvisionsName(), '9020');
        ContosoGLAccount.AddAccountForLocalization(FreeReservesName(), '9350');
        ContosoGLAccount.AddAccountForLocalization(NetProfitNetLossName(), '9390');
        ContosoGLAccount.AddAccountForLocalization(ValuationReservesForName(), '9400');
        ContosoGLAccount.AddAccountForLocalization(ReservesAccordingTo10EstgIFBName(), '9510');
        ContosoGLAccount.AddAccountForLocalization(ReservesAccordingTo12EstgName(), '9520');
        ContosoGLAccount.AddAccountForLocalization(PrivateName(), '9600');
        ContosoGLAccount.AddAccountForLocalization(EBKName(), '9800');
        ContosoGLAccount.AddAccountForLocalization(SBKName(), '9850');
        ContosoGLAccount.AddAccountForLocalization(ProfitAndLossStatementName(), '9890');
        ContosoGLAccount.AddAccountForLocalization(TOTALEQUITYRESERVESName(), '9999');
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeForTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelRelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelRelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsForTheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesAndChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneAndFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentAndPrName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineAndMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalAndAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationOfFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsAndLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsOfOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesFromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesToVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NiBeforeExtrItemsTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '');
    end;

    procedure UpdateGLAccountCatagory()
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
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.FixedAssets(), TOTALOTHERCURRENTASSETS());
            GLAccountCategory."Account Category"::Liabilities:
                UpdateGLAccounts(GLAccountCategory, LIABILITIESPROVISIONS(), TOTALLIABILITIESPROVISIONS());
            GLAccountCategory."Account Category"::Equity:
                begin
                    UpdateGLAccounts(GLAccountCategory, EQUITYRESERVES(), ProfitAndLossStatement());
                    UpdateGLAccounts(GLAccountCategory, TOTALEQUITYRESERVES(), TOTALEQUITYRESERVES());
                end;
            GLAccountCategory."Account Category"::Income:
                begin
                    UpdateGLAccounts(GLAccountCategory, OPERATINGINCOME(), TotalRevenueAdjustments());
                    UpdateGLAccounts(GLAccountCategory, TOTALOPERATINGINCOME(), TOTALOPERATINGINCOME());
                end;
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, COSTOFMATERIALS(), TOTALCOSTOFMATERIALS());
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, TotalRevenuesAndRevenueReduction(), TotalOtherOperatingIncome());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PersonnelExpenses(), TOTALFINANCIALINCOMEANDEXPENSES());
                end;
        end;
    end;

    procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            // GLAccountCategoryMgt.GetCurrentAssets():
            //     ;
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, CashAndBank(), TotalCashAndBank());
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, OtherCurrentAssets(), TotalAccountsReceivable());
            // GLAccountCategoryMgt.GetPrepaidExpenses():
            //     ;
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, SUPPLIES(), TOTALSUPPLIES());
            // GLAccountCategoryMgt.GetEquipment():
            //     ;
            // GLAccountCategoryMgt.GetAccumDeprec():
            //     ;
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, LIABILITIESPROVISIONS(), TotalProvisions());
                    UpdateGLAccounts(GLAccountCategory, AdvancePaymentsReceivedBeginTotal(), TotalLiabilitiesFromTaxes());
                    UpdateGLAccounts(GLAccountCategory, OtherLiabilitiesAndDeferrals(), TOTALLIABILITIESPROVISIONS());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, PayablesRelatedToSocialSecurity(), TotalSocialSecurity());
            GLAccountCategoryMgt.GetLongTermLiabilities():
                UpdateGLAccounts(GLAccountCategory, AmountsOwedToCreditFinancialInstitutions(), TotalAmountsOwedToCreditFinancInstitutions());
            GLAccountCategoryMgt.GetCommonStock():
                begin
                    UpdateGLAccounts(GLAccountCategory, EQUITYRESERVES(), ProfitAndLossStatement());
                    UpdateGLAccounts(GLAccountCategory, TOTALEQUITYRESERVES(), TOTALEQUITYRESERVES());
                end;
            GLAccountCategoryMgt.GetIncomeService():
                begin
                    UpdateGLAccounts(GLAccountCategory, OPERATINGINCOME(), TotalSalesRevenuesTrade());
                    UpdateGLAccounts(GLAccountCategory, SalesRevenuesResources(), TotalServiceContracts());
                end;
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, SalesRevenuesRawMaterial(), TotalSalesRevenuesRawMaterial());
            GLAccountCategoryMgt.GetIncomeSalesDiscounts():
                UpdateGLAccounts(GLAccountCategory, RevenueAdjustments(), TotalRevenueAdjustments());
            // GLAccountCategoryMgt.GetIncomeSalesReturns():
            //     ;
            GLAccountCategoryMgt.GetIncomeInterest():
                UpdateGLAccounts(GLAccountCategory, ChargesAndInterest(), TotalChargesAndInterest());
            // GLAccountCategoryMgt.GetCOGSLabor():
            //     ;
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, COSTOFMATERIALS(), TOTALCOSTOFMATERIALS());
            // GLAccountCategoryMgt.GetRentExpense():
            //     ;
            // GLAccountCategoryMgt.GetAdvertisingExpense():
            //     ;
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, FINANCIALREVENUESANDEXPENDITURESBeginTotal(), TotalFinancialIncomeAndExpensesEndTotal());
            // GLAccountCategoryMgt.GetFeesExpense():
            //     ;
            // GLAccountCategoryMgt.GetInsuranceExpense():
            //     ;
            GLAccountCategoryMgt.GetPayrollExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PersonnelExpenses(), CreateGLAccount.TotalPersonnelExpenses());
            // GLAccountCategoryMgt.GetBenefitsExpense():
            //     ;
            // GLAccountCategoryMgt.GetRepairsExpense():
            //     ;
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, OfficeAdvertisingAndMaintenanceExpenditure(), TotalOfficeAdvertisingMaintenanceExpenditure());
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, TotalRevenuesAndRevenueReduction(), TotalOtherOperatingIncome());
                    UpdateGLAccounts(GLAccountCategory, DEPRECIATIONOTHERCOSTOFOPERATIONS(), TotalCommissions());
                    UpdateGLAccounts(GLAccountCategory, InsurancesAndOtherExpenses(), TOTALDEPRECIATIONOPERATIONALEXPENDITURE());
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

    procedure WagesBeginTotalName(): Text[100]
    begin
        exit(WagesBeginTotalLbl);
    end;

    procedure SalariesBeginTotalName(): Text[100]
    begin
        exit(SalariesBeginTotalLbl);
    end;

    procedure FinishedGoodsBeginTotalName(): Text[100]
    begin
        exit(FinishedGoodsBeginTotalLbl);
    end;

    procedure CommissioningAnOperationName(): Text[100]
    begin
        exit(CommissioningAnOperationLbl);
    end;

    procedure CommissioningTheOperationName(): Text[100]
    begin
        exit(CommissioningTheOperationLbl);
    end;

    procedure AccumulatedDepreciationFixedAssetName(): Text[100]
    begin
        exit(AccumulatedDepreciationFixedAssetLbl);
    end;

    procedure CommissioningTotalName(): Text[100]
    begin
        exit(CommissioningTotalLbl);
    end;

    procedure IntangibleAssetsName(): Text[100]
    begin
        exit(IntangibleAssetsLbl);
    end;

    procedure ConcessionsName(): Text[100]
    begin
        exit(ConcessionsLbl);
    end;

    procedure PatentAndLicenseRightsName(): Text[100]
    begin
        exit(PatentAndLicenseRightsLbl);
    end;

    procedure DataProcessingProgramsName(): Text[100]
    begin
        exit(DataProcessingProgramsLbl);
    end;

    procedure CompanyValueName(): Text[100]
    begin
        exit(CompanyValueLbl);
    end;

    procedure AdvancePaymentsForIntangibleAssetsName(): Text[100]
    begin
        exit(AdvancePaymentsForIntangibleAssetsLbl);
    end;

    procedure AccumulatedDepreciationIntangibleAssetName(): Text[100]
    begin
        exit(AccumulatedDepreciationIntangibleAssetLbl);
    end;

    procedure TotalIntangibleAssetsName(): Text[100]
    begin
        exit(TotalIntangibleAssetsLbl);
    end;

    procedure RealEstateName(): Text[100]
    begin
        exit(RealEstateLbl);
    end;

    procedure DevelopedLandName(): Text[100]
    begin
        exit(DevelopedLandLbl);
    end;

    procedure OperationalBuildingName(): Text[100]
    begin
        exit(OperationalBuildingLbl);
    end;

    procedure AcquisitionsDuringTheYearVehicleName(): Text[100]
    begin
        exit(AcquisitionsDuringTheYearVehicleLbl);
    end;

    procedure DisposalsDuringTheYearVehicleName(): Text[100]
    begin
        exit(DisposalsDuringTheYearVehicleLbl);
    end;

    procedure InvestmentInLeasedBuildingName(): Text[100]
    begin
        exit(InvestmentInLeasedBuildingLbl);
    end;

    procedure AccumulatedDepreciationBookedName(): Text[100]
    begin
        exit(AccumulatedDepreciationBookedLbl);
    end;

    procedure UndevelopedLandName(): Text[100]
    begin
        exit(UndevelopedLandLbl);
    end;

    procedure TotalRealEstateName(): Text[100]
    begin
        exit(TotalRealEstateLbl);
    end;

    procedure MachineryAndEquipmentName(): Text[100]
    begin
        exit(MachineryAndEquipmentLbl);
    end;

    procedure LowValueMachineryName(): Text[100]
    begin
        exit(LowValueMachineryLbl);
    end;

    procedure AccumulatedDepreciationOperEqupmentName(): Text[100]
    begin
        exit(AccumulatedDepreciationOperEquipmentLbl);
    end;

    procedure OfficeEquipmentName(): Text[100]
    begin
        exit(OfficeEquipmentLbl);
    end;

    procedure BusinessFacilitiesName(): Text[100]
    begin
        exit(BusinessFacilitiesLbl);
    end;

    procedure OfficeMachinesEDPName(): Text[100]
    begin
        exit(OfficeMachinesEDPLbl);
    end;

    procedure AcquisitionsDuringTheYearRealEstateName(): Text[100]
    begin
        exit(AcquisitionsDuringTheYearRealEstateLbl);
    end;

    procedure DisposalsDuringTheYearRealEstateName(): Text[100]
    begin
        exit(DisposalsDuringTheYearRealEstateLbl);
    end;

    procedure AccumDepreciationOfBuildingName(): Text[100]
    begin
        exit(AccumDepreciationOfBuildingLbl);
    end;

    procedure TotalOperatingEquipmentName(): Text[100]
    begin
        exit(TotalOperatingEquipmentLbl);
    end;

    procedure VehicleFleetName(): Text[100]
    begin
        exit(VehicleFleetLbl);
    end;

    procedure CarName(): Text[100]
    begin
        exit(CarLbl);
    end;

    procedure TruckName(): Text[100]
    begin
        exit(TruckLbl);
    end;

    procedure AcquisitionsDuringTheYearOperEquipmentName(): Text[100]
    begin
        exit(AcquisitionsDuringTheYearOperEquipmentLbl);
    end;

    procedure DisposalsDuringTheYearOperEquipmentName(): Text[100]
    begin
        exit(DisposalsDuringTheYearOperEquipmentLbl);
    end;

    procedure AccumDepreciationName(): Text[100]
    begin
        exit(AccumDepreciationLbl);
    end;

    procedure TotalVehicleFleetName(): Text[100]
    begin
        exit(TotalVehicleFleetLbl);
    end;

    procedure OtherFacilitiesName(): Text[100]
    begin
        exit(OtherFacilitiesLbl);
    end;

    procedure LowValueAssetsOperationalAndBusFacilitiesName(): Text[100]
    begin
        exit(LowValueAssetsOperationalAndBusFacilitiesLbl);
    end;

    procedure AccumulatedDepreciationOtherFacilitiesName(): Text[100]
    begin
        exit(AccumulatedDepreciationOtherFacilitiesLbl);
    end;

    procedure TotalOtherFacilitiesName(): Text[100]
    begin
        exit(TotalOtherFacilitiesLbl);
    end;

    procedure AdvancePaymentsMadeFacilitiesUnderConstrName(): Text[100]
    begin
        exit(AdvancePaymentsMadeFacilitiesUnderConstrLbl);
    end;

    procedure AdvancePaymentsMadeForTangibleFixedAssetsName(): Text[100]
    begin
        exit(AdvancePaymentsMadeForTangibleFixedAssetsLbl);
    end;

    procedure FacilitiesUnderConstructionName(): Text[100]
    begin
        exit(FacilitiesUnderConstructionLbl);
    end;

    procedure AccumulatedDepreciationAdvPaymentName(): Text[100]
    begin
        exit(AccumulatedDepreciationAdvPaymentLbl);
    end;

    procedure TotalAdvPaymMadeFacilitiesUnderConstrName(): Text[100]
    begin
        exit(TotalAdvPaymMadeFacilitiesUnderConstrLbl);
    end;

    procedure FinancialAssetsName(): Text[100]
    begin
        exit(FinancialAssetsLbl);
    end;

    procedure EquityInterestsInAssociatedCompaniesName(): Text[100]
    begin
        exit(EquityInterestsInAssociatedCompaniesLbl);
    end;

    procedure OtherEquityInterestsName(): Text[100]
    begin
        exit(OtherEquityInterestsLbl);
    end;

    procedure CompanySharesOrEquityInterestsName(): Text[100]
    begin
        exit(CompanySharesOrEquityInterestsLbl);
    end;

    procedure InvestmentSecuritiesName(): Text[100]
    begin
        exit(InvestmentSecuritiesLbl);
    end;

    procedure SecuritiesProvisionsForSeverancePayName(): Text[100]
    begin
        exit(SecuritiesProvisionsForSeverancePayLbl);
    end;

    procedure SecuritiesProvisionsForPensionPlanName(): Text[100]
    begin
        exit(SecuritiesProvisionsForPensionPlanLbl);
    end;

    procedure AdvancePaymentsMadeForFinancialAssetsName(): Text[100]
    begin
        exit(AdvancePaymentsMadeForFinancialAssetsLbl);
    end;

    procedure AccumulatedDepreciationFinancialAssetName(): Text[100]
    begin
        exit(AccumulatedDepreciationFinancalAssetLbl);
    end;

    procedure TotalFinancialAssetsName(): Text[100]
    begin
        exit(TotalFinancialAssetsLbl);
    end;

    procedure TOTALFIXEDASSETSName(): Text[100]
    begin
        exit(TOTALFIXEDASSETSLbl);
    end;

    procedure SUPPLIESName(): Text[100]
    begin
        exit(SUPPLIESLbl);
    end;

    procedure PurchaseSettlementBeginTotalName(): Text[100]
    begin
        exit(PurchaseSettlementBeginTotalLbl);
    end;

    procedure PurchaseSettlementName(): Text[100]
    begin
        exit(PurchaseSettlementLbl);
    end;

    procedure OpeningInventoryName(): Text[100]
    begin
        exit(OpeningInventoryLbl);
    end;

    procedure TotalPurchaseSettlementName(): Text[100]
    begin
        exit(TotalPurchaseSettlementLbl);
    end;

    procedure RawMaterialSupplyName(): Text[100]
    begin
        exit(RawMaterialSupplyLbl);
    end;

    procedure RawMaterialSupplyInterimName(): Text[100]
    begin
        exit(RawMaterialSupplyInterimLbl);
    end;

    procedure RawMaterialsPostReceiptInterimName(): Text[100]
    begin
        exit(RawMaterialsPostReceiptInterimLbl);
    end;

    procedure TotalRawMaterialsName(): Text[100]
    begin
        exit(TotalRawMaterialsLbl);
    end;

    procedure PartsPurchasedBeginTotalName(): Text[100]
    begin
        exit(PartsPurchasedBeginTotalLbl);
    end;

    procedure PartsPurchasedName(): Text[100]
    begin
        exit(PartsPurchasedLbl);
    end;

    procedure TotalPartsPurchasedName(): Text[100]
    begin
        exit(TotalPartsPurchasedLbl);
    end;

    procedure AuxiliariesOperatingMaterialsName(): Text[100]
    begin
        exit(AuxiliariesOperatingMaterialsLbl);
    end;

    procedure AuxiliariesSupplyName(): Text[100]
    begin
        exit(AuxiliariesSupplyLbl);
    end;

    procedure OperatingMaterialsSupplyName(): Text[100]
    begin
        exit(OperatingMaterialsSupplyLbl);
    end;

    procedure FuelOilSupplyName(): Text[100]
    begin
        exit(FuelOilSupplyLbl);
    end;

    procedure TotalAuxiliariesOperatingMaterialsName(): Text[100]
    begin
        exit(TotalAuxiliariesOperatingMaterialsLbl);
    end;

    procedure WorkInProcessBeginTotalName(): Text[100]
    begin
        exit(WorkInProcessBeginTotalLbl);
    end;

    procedure WorkInProcessName(): Text[100]
    begin
        exit(WorkInProcessLbl);
    end;

    procedure CostWorkInProcessName(): Text[100]
    begin
        exit(CostWorkInProcessLbl);
    end;

    procedure AnticipatedCostWorkInProcessName(): Text[100]
    begin
        exit(AnticipatedCostWorkInProcessLbl);
    end;

    procedure SalesWorkInProcessName(): Text[100]
    begin
        exit(SalesWorkInProcessLbl);
    end;

    procedure AnticipatedSalesWorkInProcessName(): Text[100]
    begin
        exit(AnticipatedSalesWorkInProcessLbl);
    end;

    procedure TotalWorkInProcessName(): Text[100]
    begin
        exit(TotalWorkInProcessLbl);
    end;

    procedure TotalFinishedGoodsName(): Text[100]
    begin
        exit(TotalFinishedGoodsLbl);
    end;

    procedure GoodsName(): Text[100]
    begin
        exit(GoodsLbl);
    end;

    procedure SupplyTradeGoodsName(): Text[100]
    begin
        exit(SupplyTradeGoodsLbl);
    end;

    procedure SupplyTradeGoodsInterimName(): Text[100]
    begin
        exit(SupplyTradeGoodsInterimLbl);
    end;

    procedure TradeGoodsPostReceiptInterimName(): Text[100]
    begin
        exit(TradeGoodsPostReceiptInterimLbl);
    end;

    procedure TotalGoodsName(): Text[100]
    begin
        exit(TotalGoodsLbl);
    end;

    procedure ServiceNotBillableYetName(): Text[100]
    begin
        exit(ServiceNotBillableYetLbl);
    end;

    procedure ServiceNotBillableYesName(): Text[100]
    begin
        exit(ServiceNotBillableYesLbl);
    end;

    procedure TotalServicesNotBillableYetName(): Text[100]
    begin
        exit(TotalServicesNotBillableYetLbl);
    end;

    procedure AdvancePaymentsMadeName(): Text[100]
    begin
        exit(AdvancePaymentsMadeLbl);
    end;

    procedure AdvancePaymentsMadeForSuppliesName(): Text[100]
    begin
        exit(AdvancePaymentsMadeForSuppliesLbl);
    end;

    procedure TotalAdvancePaymentsMadeName(): Text[100]
    begin
        exit(TotalAdvancePaymentsMadeLbl);
    end;

    procedure TOTALSUPPLIESName(): Text[100]
    begin
        exit(TOTALSUPPLIESLbl);
    end;

    procedure OtherCurrentAssetsName(): Text[100]
    begin
        exit(OtherCurrentAssetsLbl);
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesLbl);
    end;

    procedure TradeReceivablesName(): Text[100]
    begin
        exit(TradeReceivablesLbl);
    end;

    procedure TradeReceivablesDomesticName(): Text[100]
    begin
        exit(TradeReceivablesDomesticLbl);
    end;

    procedure TradeReceivablesForeignName(): Text[100]
    begin
        exit(TradeReceivablesForeignLbl);
    end;

    procedure ReceivablesIntercompanyName(): Text[100]
    begin
        exit(ReceivablesIntercompanyLbl);
    end;

    procedure ReceivablesCashOnDeliveryName(): Text[100]
    begin
        exit(ReceivablesCashOnDeliveryLbl);
    end;

    procedure ChangeOfOwnershipName(): Text[100]
    begin
        exit(ChangeOfOwnershipLbl);
    end;

    procedure InterimAccountAdvancePaymentsReceivedName(): Text[100]
    begin
        exit(InterimAccountAdvancePaymentsReceivedLbl);
    end;

    procedure IndividualLossReservesForDomesticReceivablesName(): Text[100]
    begin
        exit(IndividualLossReservesForDomesticReceivablesLbl);
    end;

    procedure BlanketLossReservesForDomesticReceivablesName(): Text[100]
    begin
        exit(BlanketLossReservesForDomesticReceivablesLbl);
    end;

    procedure TradeReceivablesIntraCommunityName(): Text[100]
    begin
        exit(TradeReceivablesIntraCommunityLbl);
    end;

    procedure IndivLossReservesForIntraCommunityReceivabName(): Text[100]
    begin
        exit(IndivLossReservesForIntraCommunityReceivabLbl);
    end;

    procedure BlanketLossReservesForIntraCommunityReceivName(): Text[100]
    begin
        exit(BlanketLossReservesForIntraCommunityReceivLbl);
    end;

    procedure TradeReceivablesExportName(): Text[100]
    begin
        exit(TradeReceivablesExportLbl);
    end;

    procedure IndividualLossReservesForReceivablesExportName(): Text[100]
    begin
        exit(IndividualLossReservesForReceivablesExportLbl);
    end;

    procedure BlanketLossReservesForReceivablesExportName(): Text[100]
    begin
        exit(BlanketLossReservesForReceivablesExportLbl);
    end;

    procedure GrantedLoanName(): Text[100]
    begin
        exit(GrantedLoanLbl);
    end;

    procedure OtherAdvancePaymentsMadeName(): Text[100]
    begin
        exit(OtherAdvancePaymentsMadeLbl);
    end;

    procedure TotalTradeReceivablesName(): Text[100]
    begin
        exit(TotalTradeReceivablesLbl);
    end;

    procedure ReceivablesFromOffsettingOfLeviesName(): Text[100]
    begin
        exit(ReceivablesFromOffsettingOfLeviesLbl);
    end;

    procedure PurchaseVATReducedName(): Text[100]
    begin
        exit(PurchaseVATReducedLbl);
    end;

    procedure PurchaseVATStandardName(): Text[100]
    begin
        exit(PurchaseVATStandardLbl);
    end;

    procedure PurchaseVATAcquisitionReducedName(): Text[100]
    begin
        exit(PurchaseVATAcquisitionReducedLbl);
    end;

    procedure PurchaseVATAcquisitionStandardName(): Text[100]
    begin
        exit(PurchaseVATAcquisitionStandardLbl);
    end;

    procedure ImportSalesTaxName(): Text[100]
    begin
        exit(ImportSalesTaxLbl);
    end;

    procedure PurchaseVATClearingAccountName(): Text[100]
    begin
        exit(PurchaseVATClearingAccountLbl);
    end;

    procedure CapitalReturnsTaxAllowableOnIncomeTaxName(): Text[100]
    begin
        exit(CapitalReturnsTaxAllowableOnIncomeTaxLbl);
    end;

    procedure TotalAccountsReceivableOffsettingOfLeviesName(): Text[100]
    begin
        exit(TotalAccountsReceivableOffsettingOfLeviesLbl);
    end;

    procedure TotalAccountsReceivableName(): Text[100]
    begin
        exit(TotalAccountsReceivableLbl);
    end;

    procedure MarketableSecuritiesName(): Text[100]
    begin
        exit(MarketableSecuritiesLbl);
    end;

    procedure EndorsedCededBillOfExchangeName(): Text[100]
    begin
        exit(EndorsedCededBillOfExchangeLbl);
    end;

    procedure TotalSecuritiesName(): Text[100]
    begin
        exit(TotalSecuritiesLbl);
    end;

    procedure CashAndBankName(): Text[100]
    begin
        exit(CashAndBankLbl);
    end;

    procedure PostageStampName(): Text[100]
    begin
        exit(PostageStampLbl);
    end;

    procedure RevenueStampsName(): Text[100]
    begin
        exit(RevenueStampsLbl);
    end;

    procedure SettlementAccountCashBankName(): Text[100]
    begin
        exit(SettlementAccountCashBankLbl);
    end;

    procedure ChecksReceivedName(): Text[100]
    begin
        exit(ChecksReceivedLbl);
    end;

    procedure AccountsReceivableFromCreditCardOrganizationName(): Text[100]
    begin
        exit(AccountsReceivableFromCreditCardOrganizationLbl);
    end;

    procedure BankCurrenciesName(): Text[100]
    begin
        exit(BankCurrenciesLbl);
    end;

    procedure TotalCashAndBankName(): Text[100]
    begin
        exit(TotalCashAndBankLbl);
    end;

    procedure PrepaidExpensesName(): Text[100]
    begin
        exit(PrepaidExpensesLbl);
    end;

    procedure AccrualsName(): Text[100]
    begin
        exit(AccrualsLbl);
    end;

    procedure BorrowingCostsName(): Text[100]
    begin
        exit(BorrowingCostsLbl);
    end;

    procedure TotalPrepaidExpensesName(): Text[100]
    begin
        exit(TotalPrepaidExpensesLbl);
    end;

    procedure TOTALOTHERCURRENTASSETSName(): Text[100]
    begin
        exit(TOTALOTHERCURRENTASSETSLbl);
    end;

    procedure LIABILITIESPROVISIONSName(): Text[100]
    begin
        exit(LIABILITIESPROVISIONSLbl);
    end;

    procedure ProvisionsName(): Text[100]
    begin
        exit(ProvisionsLbl);
    end;

    procedure ProvisionsForSeverancePaymentsName(): Text[100]
    begin
        exit(ProvisionsForSeverancePaymentsLbl);
    end;

    procedure ProvisionsForPensionsName(): Text[100]
    begin
        exit(ProvisionsForPensionsLbl);
    end;

    procedure ProvisionsForCorporateTaxName(): Text[100]
    begin
        exit(ProvisionsForCorporateTaxLbl);
    end;

    procedure ProvisionsForWarrantiesName(): Text[100]
    begin
        exit(ProvisionsForWarrantiesLbl);
    end;

    procedure ProvisionsForCompensationForDamageName(): Text[100]
    begin
        exit(ProvisionsForCompensationForDamageLbl);
    end;

    procedure ProvisionsForLegalAndConsultancyExpensesName(): Text[100]
    begin
        exit(ProvisionsForLegalAndConsultancyExpensesLbl);
    end;

    procedure TotalProvisionsName(): Text[100]
    begin
        exit(TotalProvisionsLbl);
    end;

    procedure AmountsOwedToCreditFinancialInstitutionsName(): Text[100]
    begin
        exit(AmountsOwedToCreditFinancialInstitutionsLbl);
    end;

    procedure BankWithCreditLimitName(): Text[100]
    begin
        exit(BankWithCreditLimitLbl);
    end;

    procedure ChecksIssuedName(): Text[100]
    begin
        exit(ChecksIssuedLbl);
    end;

    procedure LoanName(): Text[100]
    begin
        exit(LoanLbl);
    end;

    procedure SettlementAccountCreditCardsName(): Text[100]
    begin
        exit(SettlementAccountCreditCardsLbl);
    end;

    procedure TotalAmountsOwedToCreditFinancInstitutionsName(): Text[100]
    begin
        exit(TotalAmountsOwedToCreditFinancInstitutionsLbl);
    end;

    procedure AdvancePaymentsReceivedBeginTotalName(): Text[100]
    begin
        exit(AdvancePaymentsReceivedBeginTotalLbl);
    end;

    procedure AdvancePaymentsReceivedName(): Text[100]
    begin
        exit(AdvancePaymentsReceivedLbl);
    end;

    procedure HardwareContractsPaidInAdvanceName(): Text[100]
    begin
        exit(HardwareContractsPaidInAdvanceLbl);
    end;

    procedure SoftwareContractsPaidInAdvanceName(): Text[100]
    begin
        exit(SoftwareContractsPaidInAdvanceLbl);
    end;

    procedure TotalAdvancePaymentsReceivedName(): Text[100]
    begin
        exit(TotalAdvancePaymentsReceivedLbl);
    end;

    procedure PayablesToVendorsName(): Text[100]
    begin
        exit(PayablesToVendorsLbl);
    end;

    procedure VendorsIntercompanyName(): Text[100]
    begin
        exit(VendorsIntercompanyLbl);
    end;

    procedure NotePayableName(): Text[100]
    begin
        exit(NotePayableLbl);
    end;

    procedure InterimAccountAdvancePaymentsMadeName(): Text[100]
    begin
        exit(InterimAccountAdvancePaymentsMadeLbl);
    end;

    procedure TotalPayablesToVendorsName(): Text[100]
    begin
        exit(TotalPayablesToVendorsLbl);
    end;

    procedure TaxLiabilitiesName(): Text[100]
    begin
        exit(TaxLiabilitiesLbl);
    end;

    procedure SalesTax10Name(): Text[100]
    begin
        exit(SalesTax10Lbl);
    end;

    procedure SalesTax20Name(): Text[100]
    begin
        exit(SalesTax20Lbl);
    end;

    procedure SalesTaxProfitAndIncomeTax10Name(): Text[100]
    begin
        exit(SalesTaxProfitAndIncomeTax10Lbl);
    end;

    procedure SalesTaxProfitAndIncomeTax20Name(): Text[100]
    begin
        exit(SalesTaxProfitAndIncomeTax20Lbl);
    end;

    procedure TaxOfficeTaxPayableName(): Text[100]
    begin
        exit(TaxOfficeTaxPayableLbl);
    end;

    procedure SalesTaxClearingAccountName(): Text[100]
    begin
        exit(SalesTaxClearingAccountLbl);
    end;

    procedure ProductionOrderPayrollTaxProfitDPName(): Text[100]
    begin
        exit(ProductionOrderPayrollTaxProfitDPLbl);
    end;

    procedure SettlementAccountTaxOfficeName(): Text[100]
    begin
        exit(SettlementAccountTaxOfficeLbl);
    end;

    procedure TotalLiabilitiesFromTaxesName(): Text[100]
    begin
        exit(TotalLiabilitiesFromTaxesLbl);
    end;

    procedure PayablesRelatedToSocialSecurityName(): Text[100]
    begin
        exit(PayablesRelatedToSocialSecurityLbl);
    end;

    procedure SettlementAccountSocialInsuranceName(): Text[100]
    begin
        exit(SettlementAccountSocialInsuranceLbl);
    end;

    procedure SettlementAccountLocalTaxName(): Text[100]
    begin
        exit(SettlementAccountLocalTaxLbl);
    end;

    procedure SettlementAccountWagesSalariesName(): Text[100]
    begin
        exit(SettlementAccountWagesSalariesLbl);
    end;

    procedure TaxPaymentsWithheldName(): Text[100]
    begin
        exit(TaxPaymentsWithheldLbl);
    end;

    procedure PaymentOfTaxArrearsName(): Text[100]
    begin
        exit(PaymentOfTaxArrearsLbl);
    end;

    procedure PayrollTaxPaymentsName(): Text[100]
    begin
        exit(PayrollTaxPaymentsLbl);
    end;

    procedure VacationCompensationPaymentsName(): Text[100]
    begin
        exit(VacationCompensationPaymentsLbl);
    end;

    procedure TotalSocialSecurityName(): Text[100]
    begin
        exit(TotalSocialSecurityLbl);
    end;

    procedure OtherLiabilitiesAndDeferralsName(): Text[100]
    begin
        exit(OtherLiabilitiesAndDeferralsLbl);
    end;

    procedure DeferredIncomeName(): Text[100]
    begin
        exit(DeferredIncomeLbl);
    end;

    procedure TotalOtherLiabilitiesName(): Text[100]
    begin
        exit(TotalOtherLiabilitiesLbl);
    end;

    procedure TOTALLIABILITIESPROVISIONSName(): Text[100]
    begin
        exit(TOTALLIABILITIESPROVISIONSLbl);
    end;

    procedure OPERATINGINCOMEName(): Text[100]
    begin
        exit(OPERATINGINCOMELbl);
    end;

    procedure RevenuesAndRevenueReductionName(): Text[100]
    begin
        exit(RevenuesAndRevenueReductionLbl);
    end;

    procedure RevenuesName(): Text[100]
    begin
        exit(RevenuesLbl);
    end;

    procedure SalesRevenuesTradeName(): Text[100]
    begin
        exit(SalesRevenuesTradeLbl);
    end;

    procedure SalesRevenuesTradeDomesticName(): Text[100]
    begin
        exit(SalesRevenuesTradeDomesticLbl);
    end;

    procedure SalesRevenuesTradeExportName(): Text[100]
    begin
        exit(SalesRevenuesTradeExportLbl);
    end;

    procedure SalesRevenuesTradeEUName(): Text[100]
    begin
        exit(SalesRevenuesTradeEULbl);
    end;

    procedure ProjectSalesName(): Text[100]
    begin
        exit(ProjectSalesLbl);
    end;

    procedure ProjectSalesCorrectionName(): Text[100]
    begin
        exit(ProjectSalesCorrectionLbl);
    end;

    procedure TotalSalesRevenuesTradeName(): Text[100]
    begin
        exit(TotalSalesRevenuesTradeLbl);
    end;

    procedure SalesRevenuesRawMaterialName(): Text[100]
    begin
        exit(SalesRevenuesRawMaterialLbl);
    end;

    procedure SalesRevenuesRawMaterialDomesticName(): Text[100]
    begin
        exit(SalesRevenuesRawMaterialDomesticLbl);
    end;

    procedure SalesRevenuesRawMaterialExportName(): Text[100]
    begin
        exit(SalesRevenuesRawMaterialExportLbl);
    end;

    procedure SalesRevenuesRawMaterialEUName(): Text[100]
    begin
        exit(SalesRevenuesRawMaterialEULbl);
    end;

    procedure TotalSalesRevenuesRawMaterialName(): Text[100]
    begin
        exit(TotalSalesRevenuesRawMaterialLbl);
    end;

    procedure SalesRevenuesResourcesName(): Text[100]
    begin
        exit(SalesRevenuesResourcesLbl);
    end;

    procedure SalesRevenuesResourcesDomesticName(): Text[100]
    begin
        exit(SalesRevenuesResourcesDomesticLbl);
    end;

    procedure SalesRevenuesResourcesExportName(): Text[100]
    begin
        exit(SalesRevenuesResourcesExportLbl);
    end;

    procedure SalesRevenuesResourcesEUName(): Text[100]
    begin
        exit(SalesRevenuesResourcesEULbl);
    end;

    procedure TotalSalesRevenuesResourcesName(): Text[100]
    begin
        exit(TotalSalesRevenuesResourcesLbl);
    end;

    procedure ProjectRevenuesBeginTotalName(): Text[100]
    begin
        exit(ProjectRevenuesBeginTotalLbl);
    end;

    procedure ProjectRevenuesName(): Text[100]
    begin
        exit(ProjectRevenuesLbl);
    end;

    procedure OtherProjectRevenuesName(): Text[100]
    begin
        exit(OtherProjectRevenuesLbl);
    end;

    procedure TotalProjectRevenuesName(): Text[100]
    begin
        exit(TotalProjectRevenuesLbl);
    end;

    procedure RevenuesServiceContractsName(): Text[100]
    begin
        exit(RevenuesServiceContractsLbl);
    end;

    procedure RevenueServiceContractName(): Text[100]
    begin
        exit(RevenueServiceContractLbl);
    end;

    procedure TotalServiceContractsName(): Text[100]
    begin
        exit(TotalServiceContractsLbl);
    end;

    procedure ChargesAndInterestName(): Text[100]
    begin
        exit(ChargesAndInterestLbl);
    end;

    procedure ServiceChargesName(): Text[100]
    begin
        exit(ServiceChargesLbl);
    end;

    procedure ServiceInterestName(): Text[100]
    begin
        exit(ServiceInterestLbl);
    end;

    procedure ConsultingFeesName(): Text[100]
    begin
        exit(ConsultingFeesLbl);
    end;

    procedure TotalChargesAndInterestName(): Text[100]
    begin
        exit(TotalChargesAndInterestLbl);
    end;

    procedure TotalRevenuesName(): Text[100]
    begin
        exit(TotalRevenuesLbl);
    end;

    procedure RevenueAdjustmentsName(): Text[100]
    begin
        exit(RevenueAdjustmentsLbl);
    end;

    procedure RevenueAdjustmentDomestic10Name(): Text[100]
    begin
        exit(RevenueAdjustmentDomestic10Lbl);
    end;

    procedure RevenueAdjustmentDomestic20Name(): Text[100]
    begin
        exit(RevenueAdjustmentDomestic20Lbl);
    end;

    procedure RevenueAdjustmentExportName(): Text[100]
    begin
        exit(RevenueAdjustmentExportLbl);
    end;

    procedure RevenueAdjustmentEUName(): Text[100]
    begin
        exit(RevenueAdjustmentEULbl);
    end;

    procedure CashDiscountPaidName(): Text[100]
    begin
        exit(CashDiscountPaidLbl);
    end;

    procedure CashDiscountPaidAdjustmentName(): Text[100]
    begin
        exit(CashDiscountPaidAdjustmentLbl);
    end;

    procedure TotalRevenueAdjustmentsName(): Text[100]
    begin
        exit(TotalRevenueAdjustmentsLbl);
    end;

    procedure TotalRevenuesAndRevenueReductionName(): Text[100]
    begin
        exit(TotalRevenuesAndRevenueReductionLbl);
    end;

    procedure InventoryChangesBeginTotalName(): Text[100]
    begin
        exit(InventoryChangesBeginTotalLbl);
    end;

    procedure InventoryChangesName(): Text[100]
    begin
        exit(InventoryChangesLbl);
    end;

    procedure OwnCostCapitalizedName(): Text[100]
    begin
        exit(OwnCostCapitalizedLbl);
    end;

    procedure TotalInventoryChangesName(): Text[100]
    begin
        exit(TotalInventoryChangesLbl);
    end;

    procedure OtherOperatingIncomeBeginTotalName(): Text[100]
    begin
        exit(OtherOperatingIncomeBeginTotalLbl);
    end;

    procedure ProceedsFromTheSaleOfAssetsName(): Text[100]
    begin
        exit(ProceedsFromTheSaleOfAssetsLbl);
    end;

    procedure InsuranceCompensationsName(): Text[100]
    begin
        exit(InsuranceCompensationsLbl);
    end;

    procedure IncomeFromTheDisposalOfAssetsName(): Text[100]
    begin
        exit(IncomeFromTheDisposalOfAssetsLbl);
    end;

    procedure IncomeFromTheAppreciationOfIntangibleAssetsName(): Text[100]
    begin
        exit(IncomeFromTheAppreciationOfIntangibleAssetsLbl);
    end;

    procedure IncomeFromAppreciationOfFixedAssetsName(): Text[100]
    begin
        exit(IncomeFromAppreciationOfFixedAssetsLbl);
    end;

    procedure IncFromReleaseOfProvisionsForSeverPaymName(): Text[100]
    begin
        exit(IncFromReleaseOfProvisionsForSeverPaymLbl);
    end;

    procedure IncomeFromTheReleaseOfProvForPensionPlanName(): Text[100]
    begin
        exit(IncomeFromTheReleaseOfProvForPensionPlanLbl);
    end;

    procedure IncomeFromTheReleaseOfOtherProvisionsName(): Text[100]
    begin
        exit(IncomeFromTheReleaseOfOtherProvisionsLbl);
    end;

    procedure OtherOperatingIncomeName(): Text[100]
    begin
        exit(OtherOperatingIncomeLbl);
    end;

    procedure OverageOfCashName(): Text[100]
    begin
        exit(OverageOfCashLbl);
    end;

    procedure BenefitInKindName(): Text[100]
    begin
        exit(BenefitInKindLbl);
    end;

    procedure RentalYieldName(): Text[100]
    begin
        exit(RentalYieldLbl);
    end;

    procedure ExpenseReimbursementName(): Text[100]
    begin
        exit(ExpenseReimbursementLbl);
    end;

    procedure FCYUnrealizedExchangeGainsName(): Text[100]
    begin
        exit(FCYUnrealizedExchangeGainsLbl);
    end;

    procedure FCYRealizedExchangeGainsName(): Text[100]
    begin
        exit(FCYRealizedExchangeGainsLbl);
    end;

    procedure OtherInsuranceCompensationName(): Text[100]
    begin
        exit(OtherInsuranceCompensationLbl);
    end;

    procedure IncomeFromReleaseOfLossReservesName(): Text[100]
    begin
        exit(IncomeFromReleaseOfLossReservesLbl);
    end;

    procedure TotalOtherOperatingIncomeName(): Text[100]
    begin
        exit(TotalOtherOperatingIncomeLbl);
    end;

    procedure TOTALOPERATINGINCOMEName(): Text[100]
    begin
        exit(TOTALOPERATINGINCOMELbl);
    end;

    procedure COSTOFMATERIALSName(): Text[100]
    begin
        exit(COSTOFMATERIALSLbl);
    end;

    procedure TradeGoodsName(): Text[100]
    begin
        exit(TradeGoodsLbl);
    end;

    procedure TradeGoodsConsumptionName(): Text[100]
    begin
        exit(TradeGoodsConsumptionLbl);
    end;

    procedure TradeGoodsInventoryAdjustmentName(): Text[100]
    begin
        exit(TradeGoodsInventoryAdjustmentLbl);
    end;

    procedure TradeGoodsDirectCostName(): Text[100]
    begin
        exit(TradeGoodsDirectCostLbl);
    end;

    procedure TradeGoodsOverheadExpensesName(): Text[100]
    begin
        exit(TradeGoodsOverheadExpensesLbl);
    end;

    procedure TradeGoodsPurchaseVarianceAccountName(): Text[100]
    begin
        exit(TradeGoodsPurchaseVarianceAccountLbl);
    end;

    procedure DiscountReceivedTradeName(): Text[100]
    begin
        exit(DiscountReceivedTradeLbl);
    end;

    procedure DeliveryExpensesTradeName(): Text[100]
    begin
        exit(DeliveryExpensesTradeLbl);
    end;

    procedure DiscountReceivedRawMaterialsName(): Text[100]
    begin
        exit(DiscountReceivedRawMaterialsLbl);
    end;

    procedure DeliveryExpensesRawMaterialName(): Text[100]
    begin
        exit(DeliveryExpensesRawMaterialLbl);
    end;

    procedure TotalTradeGoodsName(): Text[100]
    begin
        exit(TotalTradeGoodsLbl);
    end;

    procedure RawMaterialName(): Text[100]
    begin
        exit(RawMaterialLbl);
    end;

    procedure RawMaterialConsumptionName(): Text[100]
    begin
        exit(RawMaterialConsumptionLbl);
    end;

    procedure RawMaterialInventoryAdjustmentName(): Text[100]
    begin
        exit(RawMaterialInventoryAdjustmentLbl);
    end;

    procedure RawMaterialDirectCostName(): Text[100]
    begin
        exit(RawMaterialDirectCostLbl);
    end;

    procedure RawMaterialOverheadExpensesName(): Text[100]
    begin
        exit(RawMaterialOverheadExpensesLbl);
    end;

    procedure RawMaterialPurchaseVarianceAccountName(): Text[100]
    begin
        exit(RawMaterialPurchaseVarianceAccountLbl);
    end;

    procedure TotalRawMaterialName(): Text[100]
    begin
        exit(TotalRawMaterialLbl);
    end;

    procedure ProcessingName(): Text[100]
    begin
        exit(ProcessingLbl);
    end;

    procedure ProcessingConsumptionName(): Text[100]
    begin
        exit(ProcessingConsumptionLbl);
    end;

    procedure ProcessingInventoryAdjustmentName(): Text[100]
    begin
        exit(ProcessingInventoryAdjustmentLbl);
    end;

    procedure ProcessingOverheadExpensesName(): Text[100]
    begin
        exit(ProcessingOverheadExpensesLbl);
    end;

    procedure ProcessingPurchaseVarianceAccountName(): Text[100]
    begin
        exit(ProcessingPurchaseVarianceAccountLbl);
    end;

    procedure TotalProcessingName(): Text[100]
    begin
        exit(TotalProcessingLbl);
    end;

    procedure ProjectsName(): Text[100]
    begin
        exit(ProjectsLbl);
    end;

    procedure ProjectCostsName(): Text[100]
    begin
        exit(ProjectCostsLbl);
    end;

    procedure ProjectCostsAllocatedName(): Text[100]
    begin
        exit(ProjectCostsAllocatedLbl);
    end;

    procedure ProjectCostsCorrectionName(): Text[100]
    begin
        exit(ProjectCostsCorrectionLbl);
    end;

    procedure TotalProjectsName(): Text[100]
    begin
        exit(TotalProjectsLbl);
    end;

    procedure VarianceName(): Text[100]
    begin
        exit(VarianceLbl);
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceLbl);
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceLbl);
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceLbl);
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceLbl);
    end;

    procedure ManufacturingOverheadVarianceName(): Text[100]
    begin
        exit(ManufacturingOverheadVarianceLbl);
    end;

    procedure TotalVarianceName(): Text[100]
    begin
        exit(TotalVarianceLbl);
    end;

    procedure ConsumptionName(): Text[100]
    begin
        exit(ConsumptionLbl);
    end;

    procedure AuxiliariesConsumptionName(): Text[100]
    begin
        exit(AuxiliariesConsumptionLbl);
    end;

    procedure PackagingMaterialConsumptionName(): Text[100]
    begin
        exit(PackagingMaterialConsumptionLbl);
    end;

    procedure OperatingMaterialsConsumptionName(): Text[100]
    begin
        exit(OperatingMaterialsConsumptionLbl);
    end;

    procedure CleaningMaterialsConsumptionName(): Text[100]
    begin
        exit(CleaningMaterialsConsumptionLbl);
    end;

    procedure ConsumptionOfIncidentalsName(): Text[100]
    begin
        exit(ConsumptionOfIncidentalsLbl);
    end;

    procedure ConsumptionOfFuelsName(): Text[100]
    begin
        exit(ConsumptionOfFuelsLbl);
    end;

    procedure TotalConsumptionName(): Text[100]
    begin
        exit(TotalConsumptionLbl);
    end;

    procedure PurchaseCurrentMaterialName(): Text[100]
    begin
        exit(PurchaseCurrentMaterialLbl);
    end;

    procedure PurchaseTradeDomesticName(): Text[100]
    begin
        exit(PurchaseTradeDomesticLbl);
    end;

    procedure PurchaseTradeImportName(): Text[100]
    begin
        exit(PurchaseTradeImportLbl);
    end;

    procedure PurchaseTradeEUName(): Text[100]
    begin
        exit(PurchaseTradeEULbl);
    end;

    procedure PurchaseRawMaterialsDomesticName(): Text[100]
    begin
        exit(PurchaseRawMaterialsDomesticLbl);
    end;

    procedure PurchaseRawMaterialsImportName(): Text[100]
    begin
        exit(PurchaseRawMaterialsImportLbl);
    end;

    procedure PurchaseRawMaterialsEUName(): Text[100]
    begin
        exit(PurchaseRawMaterialsEULbl);
    end;

    procedure TotalPurchaseActiveMaterialName(): Text[100]
    begin
        exit(TotalPurchaseActiveMaterialLbl);
    end;

    procedure OtherServicesReceivedName(): Text[100]
    begin
        exit(OtherServicesReceivedLbl);
    end;

    procedure ServicesReceivedName(): Text[100]
    begin
        exit(ServicesReceivedLbl);
    end;

    procedure ServiceChargesPurchaseName(): Text[100]
    begin
        exit(ServiceChargesPurchaseLbl);
    end;

    procedure TotalOtherServicesName(): Text[100]
    begin
        exit(TotalOtherServicesLbl);
    end;

    procedure PaymentDiscountRevenueBeginTotalName(): Text[100]
    begin
        exit(PaymentDiscountRevenueBeginTotalLbl);
    end;

    procedure PaymentDiscountRevenueName(): Text[100]
    begin
        exit(PaymentDiscountRevenueLbl);
    end;

    procedure PaymentDiscountRevenueCorrectionName(): Text[100]
    begin
        exit(PaymentDiscountRevenueCorrectionLbl);
    end;

    procedure TotalPaymentDiscountRevenueName(): Text[100]
    begin
        exit(TotalPaymentDiscountRevenueLbl);
    end;

    procedure TOTALCOSTOFMATERIALSName(): Text[100]
    begin
        exit(TOTALCOSTOFMATERIALSLbl);
    end;

    procedure WagesWithoutServicesName(): Text[100]
    begin
        exit(WagesWithoutServicesLbl);
    end;

    procedure TotalWagesName(): Text[100]
    begin
        exit(TotalWagesLbl);
    end;

    procedure SalariesWithoutServicesName(): Text[100]
    begin
        exit(SalariesWithoutServicesLbl);
    end;

    procedure TotalSalariesName(): Text[100]
    begin
        exit(TotalSalariesLbl);
    end;

    procedure SeverancePaymentsBeginTotalName(): Text[100]
    begin
        exit(SeverancePaymentsBeginTotalLbl);
    end;

    procedure SeverancePaymentsName(): Text[100]
    begin
        exit(SeverancePaymentsLbl);
    end;

    procedure SeverancePaymentProvisionFundName(): Text[100]
    begin
        exit(SeverancePaymentProvisionFundLbl);
    end;

    procedure PensionsPaymentsName(): Text[100]
    begin
        exit(PensionsPaymentsLbl);
    end;

    procedure PensionProvisionFundName(): Text[100]
    begin
        exit(PensionProvisionFundLbl);
    end;

    procedure TotalSeverancePaymentsName(): Text[100]
    begin
        exit(TotalSeverancePaymentsLbl);
    end;

    procedure StatutorySocialExpensesName(): Text[100]
    begin
        exit(StatutorySocialExpensesLbl);
    end;

    procedure StatutorySocialExpensesWorkerName(): Text[100]
    begin
        exit(StatutorySocialExpensesWorkerLbl);
    end;

    procedure StatutorySocialExpensesEmployeeName(): Text[100]
    begin
        exit(StatutorySocialExpensesEmployeeLbl);
    end;

    procedure TotalStatutorySocialExpensesName(): Text[100]
    begin
        exit(TotalStatutorySocialExpensesLbl);
    end;

    procedure OtherSocialExpensesName(): Text[100]
    begin
        exit(OtherSocialExpensesLbl);
    end;

    procedure LocalTaxName(): Text[100]
    begin
        exit(LocalTaxLbl);
    end;

    procedure GDContributionFamilyAllowanceProfitName(): Text[100]
    begin
        exit(GDContributionFamilyAllowanceProfitLbl);
    end;

    procedure AdditionToProfitName(): Text[100]
    begin
        exit(AdditionToProfitLbl);
    end;

    procedure LevyForTheEmployerViennaName(): Text[100]
    begin
        exit(LevyForTheEmployerViennaLbl);
    end;

    procedure VoluntarySocialExpensesName(): Text[100]
    begin
        exit(VoluntarySocialExpensesLbl);
    end;

    procedure CostCenterSettlementInsuranceName(): Text[100]
    begin
        exit(CostCenterSettlementInsuranceLbl);
    end;

    procedure TotalOtherSocialExpensesName(): Text[100]
    begin
        exit(TotalOtherSocialExpensesLbl);
    end;

    procedure DEPRECIATIONOTHERCOSTOFOPERATIONSName(): Text[100]
    begin
        exit(DEPRECIATIONOTHERCOSTOFOPERATIONSLbl);
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationLbl);
    end;

    procedure ScheduledAmortizationOnIntangibleAssetsName(): Text[100]
    begin
        exit(ScheduledAmortizationOnIntangibleAssetsLbl);
    end;

    procedure UnscheduledAmortizationOnIntangibleAssetsName(): Text[100]
    begin
        exit(UnscheduledAmortizationOnIntangibleAssetsLbl);
    end;

    procedure ScheduledDepreciationOfFixedAssetsName(): Text[100]
    begin
        exit(ScheduledDepreciationOfFixedAssetsLbl);
    end;

    procedure ScheduledDepreciationVehiclesName(): Text[100]
    begin
        exit(ScheduledDepreciationVehiclesLbl);
    end;

    procedure UnscheduledDepreciationOfFixedAssetsName(): Text[100]
    begin
        exit(UnscheduledDepreciationOfFixedAssetsLbl);
    end;

    procedure LowValueAssetsName(): Text[100]
    begin
        exit(LowValueAssetsLbl);
    end;

    procedure TotalDepreciationName(): Text[100]
    begin
        exit(TotalDepreciationLbl);
    end;

    procedure OtherTaxesName(): Text[100]
    begin
        exit(OtherTaxesLbl);
    end;

    procedure PropertyTaxName(): Text[100]
    begin
        exit(PropertyTaxLbl);
    end;

    procedure BeverageAndAlcoholTaxName(): Text[100]
    begin
        exit(BeverageAndAlcoholTaxLbl);
    end;

    procedure ChargesAndRevenueStampsName(): Text[100]
    begin
        exit(ChargesAndRevenueStampsLbl);
    end;

    procedure MiscOtherTaxesName(): Text[100]
    begin
        exit(MiscOtherTaxesLbl);
    end;

    procedure TotalOtherTaxesName(): Text[100]
    begin
        exit(TotalOtherTaxesLbl);
    end;

    procedure MaintenanceCleaningEtcName(): Text[100]
    begin
        exit(MaintenanceCleaningEtcLbl);
    end;

    procedure ThirdPartyMaintenanceName(): Text[100]
    begin
        exit(ThirdPartyMaintenanceLbl);
    end;

    procedure CarOperatingExpensesName(): Text[100]
    begin
        exit(CarOperatingExpensesLbl);
    end;

    procedure TruckOperatingExpensesName(): Text[100]
    begin
        exit(TruckOperatingExpensesLbl);
    end;

    procedure CarRepairsAndMaintenanceName(): Text[100]
    begin
        exit(CarRepairsAndMaintenanceLbl);
    end;

    procedure FuelName(): Text[100]
    begin
        exit(FuelLbl);
    end;

    procedure TotalMaintenanceEtcName(): Text[100]
    begin
        exit(TotalMaintenanceEtcLbl);
    end;

    procedure TransportationTravelCommunicationsName(): Text[100]
    begin
        exit(TransportationTravelCommunicationsLbl);
    end;

    procedure TransportationThirdPartiesName(): Text[100]
    begin
        exit(TransportationThirdPartiesLbl);
    end;

    procedure TravelExpensesDomesticName(): Text[100]
    begin
        exit(TravelExpensesDomesticLbl);
    end;

    procedure TravelExpensesAbroadName(): Text[100]
    begin
        exit(TravelExpensesAbroadLbl);
    end;

    procedure KilometerAllowanceName(): Text[100]
    begin
        exit(KilometerAllowanceLbl);
    end;

    procedure MealExpensesDomesticName(): Text[100]
    begin
        exit(MealExpensesDomesticLbl);
    end;

    procedure MealExpensesAbroadName(): Text[100]
    begin
        exit(MealExpensesAbroadLbl);
    end;

    procedure HotelExpensesDomesticName(): Text[100]
    begin
        exit(HotelExpensesDomesticLbl);
    end;

    procedure HotelExpensesAbroadName(): Text[100]
    begin
        exit(HotelExpensesAbroadLbl);
    end;

    procedure CommunicationChargesName(): Text[100]
    begin
        exit(CommunicationChargesLbl);
    end;

    procedure TotalTransportationExpensesName(): Text[100]
    begin
        exit(TotalTransportationExpensesLbl);
    end;

    procedure RentalsLeasingBeginTotalName(): Text[100]
    begin
        exit(RentalsLeasingBeginTotalLbl);
    end;

    procedure RentalsLeasingName(): Text[100]
    begin
        exit(RentalsLeasingLbl);
    end;

    procedure TotalRentalsLeasingEtcName(): Text[100]
    begin
        exit(TotalRentalsLeasingEtcLbl);
    end;

    procedure CommissionsName(): Text[100]
    begin
        exit(CommissionsLbl);
    end;

    procedure CommissionsForThirdPartiesName(): Text[100]
    begin
        exit(CommissionsForThirdPartiesLbl);
    end;

    procedure TotalCommissionsName(): Text[100]
    begin
        exit(TotalCommissionsLbl);
    end;

    procedure OfficeAdvertisingAndMaintenanceExpenditureName(): Text[100]
    begin
        exit(OfficeAdvertisingAndMaintenanceExpenditureLbl);
    end;

    procedure PhoneAndInternetChargesName(): Text[100]
    begin
        exit(PhoneAndInternetChargesLbl);
    end;

    procedure ExternalServicesName(): Text[100]
    begin
        exit(ExternalServicesLbl);
    end;

    procedure DeductibleAdvertisingExpensesName(): Text[100]
    begin
        exit(DeductibleAdvertisingExpensesLbl);
    end;

    procedure NonDeductibleAdvertisingExpensesName(): Text[100]
    begin
        exit(NonDeductibleAdvertisingExpensesLbl);
    end;

    procedure HospitalityDomesticDeductibleAmountName(): Text[100]
    begin
        exit(HospitalityDomesticDeductibleAmountLbl);
    end;

    procedure HospitalityDomesticNonDeductibleAmountName(): Text[100]
    begin
        exit(HospitalityDomesticNonDeductibleAmountLbl);
    end;

    procedure HospitalityAbroadDeductibleAmountName(): Text[100]
    begin
        exit(HospitalityAbroadDeductibleAmountLbl);
    end;

    procedure HospitalityAbroadNonDeductibleAmountName(): Text[100]
    begin
        exit(HospitalityAbroadNonDeductibleAmountLbl);
    end;

    procedure DonationsAndTipsName(): Text[100]
    begin
        exit(DonationsAndTipsLbl);
    end;

    procedure TotalOfficeAdvertisingMaintenanceExpenditureName(): Text[100]
    begin
        exit(TotalOfficeAdvertisingMaintenanceExpenditureLbl);
    end;

    procedure InsurancesAndOtherExpensesName(): Text[100]
    begin
        exit(InsurancesAndOtherExpensesLbl);
    end;

    procedure InsuranceExpensesName(): Text[100]
    begin
        exit(InsuranceExpensesLbl);
    end;

    procedure LegalAndConsultancyExpensesName(): Text[100]
    begin
        exit(LegalAndConsultancyExpensesLbl);
    end;

    procedure ProvisionForLegalAndConsultancyExpensesFundName(): Text[100]
    begin
        exit(ProvisionForLegalAndConsultancyExpensesFundLbl);
    end;

    procedure OtherName(): Text[100]
    begin
        exit(OtherLbl);
    end;

    procedure TechnicalLiteratureName(): Text[100]
    begin
        exit(TechnicalLiteratureLbl);
    end;

    procedure ExpenditureEducationAndTrainingName(): Text[100]
    begin
        exit(ExpenditureEducationAndTrainingLbl);
    end;

    procedure ChamberContributionName(): Text[100]
    begin
        exit(ChamberContributionLbl);
    end;

    procedure ExpensesThroughCirculationOfMoneyName(): Text[100]
    begin
        exit(ExpensesThroughCirculationOfMoneyLbl);
    end;

    procedure DepreciationOfSuppliesName(): Text[100]
    begin
        exit(DepreciationOfSuppliesLbl);
    end;

    procedure DepreciationExportReceivablesName(): Text[100]
    begin
        exit(DepreciationExportReceivablesLbl);
    end;

    procedure DepreciationDomesticReceivablesName(): Text[100]
    begin
        exit(DepreciationDomesticReceivablesLbl);
    end;

    procedure IndividualLossReservesForReceivablesName(): Text[100]
    begin
        exit(IndividualLossReservesForReceivablesLbl);
    end;

    procedure BlanketLossReservesForReceivablesName(): Text[100]
    begin
        exit(BlanketLossReservesForReceivablesLbl);
    end;

    procedure BookValueDisposalOfAssetsName(): Text[100]
    begin
        exit(BookValueDisposalOfAssetsLbl);
    end;

    procedure LossesFromDisposalOfAssetsName(): Text[100]
    begin
        exit(LossesFromDisposalOfAssetsLbl);
    end;

    procedure OtherOperationalExpenditureName(): Text[100]
    begin
        exit(OtherOperationalExpenditureLbl);
    end;

    procedure ProvisionForWarrantiesFundName(): Text[100]
    begin
        exit(ProvisionForWarrantiesFundLbl);
    end;

    procedure ProvisionForCompensationForDamagesFundName(): Text[100]
    begin
        exit(ProvisionForCompensationForDamagesFundLbl);
    end;

    procedure ProvisionForProductLiabilityFundName(): Text[100]
    begin
        exit(ProvisionForProductLiabilityFundLbl);
    end;

    procedure MiscProvisionsFundName(): Text[100]
    begin
        exit(MiscProvisionsFundLbl);
    end;

    procedure CashDeficitName(): Text[100]
    begin
        exit(CashDeficitLbl);
    end;

    procedure FCYUnrealizedExchangeLossesName(): Text[100]
    begin
        exit(FCYUnrealizedExchangeLossesLbl);
    end;

    procedure FCYRealizedExchangeLossesName(): Text[100]
    begin
        exit(FCYRealizedExchangeLossesLbl);
    end;

    procedure PaymentDiscountRevenue0VATName(): Text[100]
    begin
        exit(PaymentDiscountRevenue0VATLbl);
    end;

    procedure CostCenterSettlementSocialExpenseName(): Text[100]
    begin
        exit(CostCenterSettlementSocialExpenseLbl);
    end;

    procedure TotalInsuranceAndOtherExpendituresName(): Text[100]
    begin
        exit(TotalInsuranceAndOtherExpendituresLbl);
    end;

    procedure TOTALDEPRECIATIONOPERATIONALEXPENDITUREName(): Text[100]
    begin
        exit(TOTALDEPRECIATIONOPERATIONALEXPENDITURELbl);
    end;

    procedure FINANCIALREVENUESANDEXPENDITURESBeginTotalName(): Text[100]
    begin
        exit(FINANCIALREVENUESANDEXPENDITURESBeginTotalLbl);
    end;

    procedure FINANCIALREVENUESANDEXPENDITURESName(): Text[100]
    begin
        exit(FINANCIALREVENUESANDEXPENDITURESLbl);
    end;

    procedure IncomeFromEquityInterestsName(): Text[100]
    begin
        exit(IncomeFromEquityInterestsLbl);
    end;

    procedure InterestFromBankDepositsName(): Text[100]
    begin
        exit(InterestFromBankDepositsLbl);
    end;

    procedure InterestFromLoansGrantedName(): Text[100]
    begin
        exit(InterestFromLoansGrantedLbl);
    end;

    procedure PassThroughDiscountRatesName(): Text[100]
    begin
        exit(PassThroughDiscountRatesLbl);
    end;

    procedure IncomeFromDefaultInterestAndExpensesName(): Text[100]
    begin
        exit(IncomeFromDefaultInterestAndExpensesLbl);
    end;

    procedure OtherInterestIncomeName(): Text[100]
    begin
        exit(OtherInterestIncomeLbl);
    end;

    procedure InterestIncomeFromFixedRateSecuritiesName(): Text[100]
    begin
        exit(InterestIncomeFromFixedRateSecuritiesLbl);
    end;

    procedure OtherSecuritiesIncomeName(): Text[100]
    begin
        exit(OtherSecuritiesIncomeLbl);
    end;

    procedure ProceedsFromTheDispOfOtherFinancialAssetsName(): Text[100]
    begin
        exit(ProceedsFromTheDispOfOtherFinancialAssetsLbl);
    end;

    procedure PmtTolReceivedDecreasesCorrectionName(): Text[100]
    begin
        exit(PmtTolReceivedDecreasesCorrectionLbl);
    end;

    procedure IncomeFromAppreciationOfFinancialAssetsName(): Text[100]
    begin
        exit(IncomeFromAppreciationOfFinancialAssetsLbl);
    end;

    procedure IncomeFromAppreciationOfMarketableSecuritiesName(): Text[100]
    begin
        exit(IncomeFromAppreciationOfMarketableSecuritiesLbl);
    end;

    procedure DepreciationOtherFinancialAssetsName(): Text[100]
    begin
        exit(DepreciationOtherFinancialAssetsLbl);
    end;

    procedure DepreciationOfMarketableSecuritiesName(): Text[100]
    begin
        exit(DepreciationOfMarketableSecuritiesLbl);
    end;

    procedure LossFromDisposalOfOtherFinancialAssetsName(): Text[100]
    begin
        exit(LossFromDisposalOfOtherFinancialAssetsLbl);
    end;

    procedure InterestExpenseForBankLoansName(): Text[100]
    begin
        exit(InterestExpenseForBankLoansLbl);
    end;

    procedure UnscheduledDepreciationOfFinancialAssetsName(): Text[100]
    begin
        exit(UnscheduledDepreciationOfFinancialAssetsLbl);
    end;

    procedure InterestExpenditureForLoansName(): Text[100]
    begin
        exit(InterestExpenditureForLoansLbl);
    end;

    procedure DepreciationActivatedFundsAcquisitionCostName(): Text[100]
    begin
        exit(DepreciationActivatedFundsAcquisitionCostLbl);
    end;

    procedure DiscountInterestExpenditureName(): Text[100]
    begin
        exit(DiscountInterestExpenditureLbl);
    end;

    procedure DefaultInterestExpensesName(): Text[100]
    begin
        exit(DefaultInterestExpensesLbl);
    end;

    procedure UnusedDeliveryDiscountsName(): Text[100]
    begin
        exit(UnusedDeliveryDiscountsLbl);
    end;

    procedure PmtTolGrantedDecreasesCorrectionName(): Text[100]
    begin
        exit(PmtTolGrantedDecreasesCorrectionLbl);
    end;

    procedure TotalFinancialIncomeAndExpensesEndTotalName(): Text[100]
    begin
        exit(TotalFinancialIncomeAndExpensesEndTotalLbl);
    end;

    procedure NonRecurringIncomeNonRecurringExpensesName(): Text[100]
    begin
        exit(NonRecurringIncomeNonRecurringExpensesLbl);
    end;

    procedure NonRecurringIncomeName(): Text[100]
    begin
        exit(NonRecurringIncomeLbl);
    end;

    procedure NonRecurringExpensesName(): Text[100]
    begin
        exit(NonRecurringExpensesLbl);
    end;

    procedure TaxesBeforeIncomeAndEarningsName(): Text[100]
    begin
        exit(TaxesBeforeIncomeAndEarningsLbl);
    end;

    procedure CapitalReturnsTaxName(): Text[100]
    begin
        exit(CapitalReturnsTaxLbl);
    end;

    procedure TotalTaxBeforeIncomeName(): Text[100]
    begin
        exit(TotalTaxBeforeIncomeLbl);
    end;

    procedure ChangesInReservesName(): Text[100]
    begin
        exit(ChangesInReservesLbl);
    end;

    procedure GainsFromReversalOfUntaxedReservesName(): Text[100]
    begin
        exit(GainsFromReversalOfUntaxedReservesLbl);
    end;

    procedure GainsFromReversalOfValuationReservesName(): Text[100]
    begin
        exit(GainsFromReversalOfValuationReservesLbl);
    end;

    procedure AssignmentReservesAccordingTo10EstgIFBName(): Text[100]
    begin
        exit(AssignmentReservesAccordingTo10EstgIFBLbl);
    end;

    procedure AssignmentRLAccordingTo12EstgName(): Text[100]
    begin
        exit(AssignmentRLAccordingTo12EstgLbl);
    end;

    procedure AssignmentToValuationReservesName(): Text[100]
    begin
        exit(AssignmentToValuationReservesLbl);
    end;

    procedure TotalChangeInReservesName(): Text[100]
    begin
        exit(TotalChangeInReservesLbl);
    end;

    procedure TOTALFINANCIALINCOMEANDEXPENSESName(): Text[100]
    begin
        exit(TOTALFINANCIALINCOMEANDEXPENSESLbl);
    end;

    procedure EQUITYRESERVESName(): Text[100]
    begin
        exit(EQUITYRESERVESLbl);
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityLbl);
    end;

    procedure TaxProvisionsName(): Text[100]
    begin
        exit(TaxProvisionsLbl);
    end;

    procedure FreeReservesName(): Text[100]
    begin
        exit(FreeReservesLbl);
    end;

    procedure NetProfitNetLossName(): Text[100]
    begin
        exit(NetProfitNetLossLbl);
    end;

    procedure ValuationReservesForName(): Text[100]
    begin
        exit(ValuationReservesForLbl);
    end;

    procedure ReservesAccordingTo10EstgIFBName(): Text[100]
    begin
        exit(ReservesAccordingTo10EstgIFBLbl);
    end;

    procedure ReservesAccordingTo12EstgName(): Text[100]
    begin
        exit(ReservesAccordingTo12EstgLbl);
    end;

    procedure PrivateName(): Text[100]
    begin
        exit(PrivateLbl);
    end;

    procedure EBKName(): Text[100]
    begin
        exit(EBKLbl);
    end;

    procedure SBKName(): Text[100]
    begin
        exit(SBKLbl);
    end;

    procedure ProfitAndLossStatementName(): Text[100]
    begin
        exit(ProfitAndLossStatementLbl);
    end;

    procedure TOTALEQUITYRESERVESName(): Text[100]
    begin
        exit(TOTALEQUITYRESERVESLbl);
    end;

    procedure CommissioningAnOperation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissioningAnOperationName()));
    end;

    procedure CommissioningTheOperation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissioningTheOperationName()));
    end;

    procedure AccumulatedDepreciationFixedAsset(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationFixedAssetName()));
    end;

    procedure CommissioningTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissioningTotalName()));
    end;

    procedure IntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsName()));
    end;

    procedure Concessions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConcessionsName()));
    end;

    procedure PatentAndLicenseRights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PatentAndLicenseRightsName()));
    end;

    procedure DataProcessingPrograms(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DataProcessingProgramsName()));
    end;

    procedure CompanyValue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CompanyValueName()));
    end;

    procedure AdvancePaymentsForIntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsForIntangibleAssetsName()));
    end;

    procedure AccumulatedDepreciationIntangibleAsset(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationIntangibleAssetName()));
    end;

    procedure TotalIntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIntangibleAssetsName()));
    end;

    procedure RealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealEstateName()));
    end;

    procedure DevelopedLand(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopedLandName()));
    end;

    procedure OperationalBuilding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperationalBuildingName()));
    end;

    procedure AcquisitionsDuringTheYearVehicle(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionsDuringTheYearVehicleName()));
    end;

    procedure DisposalsDuringTheYearVehicle(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DisposalsDuringTheYearVehicleName()));
    end;

    procedure InvestmentInLeasedBuilding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentInLeasedBuildingName()));
    end;

    procedure AccumulatedDepreciationBooked(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationBookedName()));
    end;

    procedure UndevelopedLand(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UndevelopedLandName()));
    end;

    procedure TotalRealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRealEstateName()));
    end;

    procedure MachineryAndEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryAndEquipmentName()));
    end;

    procedure LowValueMachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LowValueMachineryName()));
    end;

    procedure AccumulatedDepreciationOperEqupment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationOperEqupmentName()));
    end;

    procedure OfficeEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeEquipmentName()));
    end;

    procedure BusinessFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessFacilitiesName()));
    end;

    procedure OfficeMachinesEDP(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeMachinesEDPName()));
    end;

    procedure AcquisitionsDuringTheYearRealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionsDuringTheYearRealEstateName()));
    end;

    procedure DisposalsDuringTheYearRealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DisposalsDuringTheYearRealEstateName()));
    end;

    procedure AccumDepreciationOfBuilding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationOfBuildingName()));
    end;

    procedure TotalOperatingEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOperatingEquipmentName()));
    end;

    procedure VehicleFleet(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehicleFleetName()));
    end;

    procedure Car(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarName()));
    end;

    procedure Truck(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckName()));
    end;

    procedure AcquisitionsDuringTheYearOperEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionsDuringTheYearOperEquipmentName()));
    end;

    procedure DisposalsDuringTheYearOperEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DisposalsDuringTheYearOperEquipmentName()));
    end;

    procedure AccumDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationName()));
    end;

    procedure TotalVehicleFleet(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleFleetName()));
    end;

    procedure OtherFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherFacilitiesName()));
    end;

    procedure LowValueAssetsOperationalAndBusFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LowValueAssetsOperationalAndBusFacilitiesName()));
    end;

    procedure AccumulatedDepreciationOtherFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationOtherFacilitiesName()));
    end;

    procedure TotalOtherFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherFacilitiesName()));
    end;

    procedure AdvancePaymentsMadeFacilitiesUnderConstr(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsMadeFacilitiesUnderConstrName()));
    end;

    procedure AdvancePaymentsMadeForTangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsMadeForTangibleFixedAssetsName()));
    end;

    procedure FacilitiesUnderConstruction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FacilitiesUnderConstructionName()));
    end;

    procedure AccumulatedDepreciationAdvPayment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationAdvPaymentName()));
    end;

    procedure TotalAdvPaymMadeFacilitiesUnderConstr(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvPaymMadeFacilitiesUnderConstrName()));
    end;

    procedure FinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialAssetsName()));
    end;

    procedure EquityInterestsInAssociatedCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityInterestsInAssociatedCompaniesName()));
    end;

    procedure OtherEquityInterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherEquityInterestsName()));
    end;

    procedure CompanySharesOrEquityInterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CompanySharesOrEquityInterestsName()));
    end;

    procedure InvestmentSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentSecuritiesName()));
    end;

    procedure SecuritiesProvisionsForSeverancePay(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesProvisionsForSeverancePayName()));
    end;

    procedure SecuritiesProvisionsForPensionPlan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesProvisionsForPensionPlanName()));
    end;

    procedure AdvancePaymentsMadeForFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsMadeForFinancialAssetsName()));
    end;

    procedure AccumulatedDepreciationFinancialAsset(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationFinancialAssetName()));
    end;

    procedure TotalFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialAssetsName()));
    end;

    procedure TOTALFIXEDASSETS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALFIXEDASSETSName()));
    end;

    procedure SUPPLIES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SUPPLIESName()));
    end;

    procedure PurchaseSettlementBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseSettlementBeginTotalName()));
    end;

    procedure PurchaseSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseSettlementName()));
    end;

    procedure OpeningInventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningInventoryName()));
    end;

    procedure TotalPurchaseSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPurchaseSettlementName()));
    end;

    procedure RawMaterialSupply(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialSupplyName()));
    end;

    procedure RawMaterialSupplyInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialSupplyInterimName()));
    end;

    procedure RawMaterialsPostReceiptInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialsPostReceiptInterimName()));
    end;

    procedure TotalRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRawMaterialsName()));
    end;

    procedure PartsPurchasedBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PartsPurchasedBeginTotalName()));
    end;

    procedure PartsPurchased(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PartsPurchasedName()));
    end;

    procedure TotalPartsPurchased(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPartsPurchasedName()));
    end;

    procedure AuxiliariesOperatingMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliariesOperatingMaterialsName()));
    end;

    procedure AuxiliariesSupply(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliariesSupplyName()));
    end;

    procedure OperatingMaterialsSupply(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingMaterialsSupplyName()));
    end;

    procedure FuelOilSupply(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FuelOilSupplyName()));
    end;

    procedure TotalAuxiliariesOperatingMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAuxiliariesOperatingMaterialsName()));
    end;

    procedure WorkInProcessBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProcessBeginTotalName()));
    end;

    procedure WorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProcessName()));
    end;

    procedure CostWorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostWorkInProcessName()));
    end;

    procedure AnticipatedCostWorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnticipatedCostWorkInProcessName()));
    end;

    procedure SalesWorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesWorkInProcessName()));
    end;

    procedure AnticipatedSalesWorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnticipatedSalesWorkInProcessName()));
    end;

    procedure TotalWorkInProcess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWorkInProcessName()));
    end;

    procedure TotalFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinishedGoodsName()));
    end;

    procedure Goods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsName()));
    end;

    procedure SupplyTradeGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SupplyTradeGoodsName()));
    end;

    procedure SupplyTradeGoodsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SupplyTradeGoodsInterimName()));
    end;

    procedure TradeGoodsPostReceiptInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsPostReceiptInterimName()));
    end;

    procedure TotalGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalGoodsName()));
    end;

    procedure ServiceNotBillableYet(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceNotBillableYetName()));
    end;

    procedure ServiceNotBillableYes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceNotBillableYesName()));
    end;

    procedure TotalServicesNotBillableYet(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalServicesNotBillableYetName()));
    end;

    procedure AdvancePaymentsMade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsMadeName()));
    end;

    procedure AdvancePaymentsMadeForSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsMadeForSuppliesName()));
    end;

    procedure TotalAdvancePaymentsMade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvancePaymentsMadeName()));
    end;

    procedure TOTALSUPPLIES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALSUPPLIESName()));
    end;

    procedure OtherCurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCurrentAssetsName()));
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure TradeReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeReceivablesName()));
    end;

    procedure TradeReceivablesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeReceivablesDomesticName()));
    end;

    procedure TradeReceivablesForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeReceivablesForeignName()));
    end;

    procedure ReceivablesIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesIntercompanyName()));
    end;

    procedure ReceivablesCashOnDelivery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesCashOnDeliveryName()));
    end;

    procedure ChangeOfOwnership(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeOfOwnershipName()));
    end;

    procedure InterimAccountAdvancePaymentsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterimAccountAdvancePaymentsReceivedName()));
    end;

    procedure IndividualLossReservesForDomesticReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IndividualLossReservesForDomesticReceivablesName()));
    end;

    procedure BlanketLossReservesForDomesticReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BlanketLossReservesForDomesticReceivablesName()));
    end;

    procedure TradeReceivablesIntraCommunity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeReceivablesIntraCommunityName()));
    end;

    procedure IndivLossReservesForIntraCommunityReceivab(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IndivLossReservesForIntraCommunityReceivabName()));
    end;

    procedure BlanketLossReservesForIntraCommunityReceiv(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BlanketLossReservesForIntraCommunityReceivName()));
    end;

    procedure TradeReceivablesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeReceivablesExportName()));
    end;

    procedure IndividualLossReservesForReceivablesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IndividualLossReservesForReceivablesExportName()));
    end;

    procedure BlanketLossReservesForReceivablesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BlanketLossReservesForReceivablesExportName()));
    end;

    procedure GrantedLoan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GrantedLoanName()));
    end;

    procedure OtherAdvancePaymentsMade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherAdvancePaymentsMadeName()));
    end;

    procedure TotalTradeReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTradeReceivablesName()));
    end;

    procedure ReceivablesFromOffsettingOfLevies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesFromOffsettingOfLeviesName()));
    end;

    procedure PurchaseVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATReducedName()));
    end;

    procedure PurchaseVATStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATStandardName()));
    end;

    procedure PurchaseVATAcquisitionReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATAcquisitionReducedName()));
    end;

    procedure PurchaseVATAcquisitionStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATAcquisitionStandardName()));
    end;

    procedure ImportSalesTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ImportSalesTaxName()));
    end;

    procedure PurchaseVATClearingAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATClearingAccountName()));
    end;

    procedure CapitalReturnsTaxAllowableOnIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalReturnsTaxAllowableOnIncomeTaxName()));
    end;

    procedure TotalAccountsReceivableOffsettingOfLevies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccountsReceivableOffsettingOfLeviesName()));
    end;

    procedure TotalAccountsReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAccountsReceivableName()));
    end;

    procedure MarketableSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketableSecuritiesName()));
    end;

    procedure EndorsedCededBillOfExchange(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EndorsedCededBillOfExchangeName()));
    end;

    procedure TotalSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSecuritiesName()));
    end;

    procedure CashAndBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashAndBankName()));
    end;

    procedure PostageStamp(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostageStampName()));
    end;

    procedure RevenueStamps(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueStampsName()));
    end;

    procedure SettlementAccountCashBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountCashBankName()));
    end;

    procedure ChecksReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChecksReceivedName()));
    end;

    procedure AccountsReceivableFromCreditCardOrganization(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivableFromCreditCardOrganizationName()));
    end;

    procedure BankCurrencies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCurrenciesName()));
    end;

    procedure TotalCashAndBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCashAndBankName()));
    end;

    procedure PrepaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidExpensesName()));
    end;

    procedure Accruals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccrualsName()));
    end;

    procedure BorrowingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BorrowingCostsName()));
    end;

    procedure TotalPrepaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPrepaidExpensesName()));
    end;

    procedure TOTALOTHERCURRENTASSETS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALOTHERCURRENTASSETSName()));
    end;

    procedure LIABILITIESPROVISIONS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LIABILITIESPROVISIONSName()));
    end;

    procedure Provisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsName()));
    end;

    procedure ProvisionsForSeverancePayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForSeverancePaymentsName()));
    end;

    procedure ProvisionsForPensions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForPensionsName()));
    end;

    procedure ProvisionsForCorporateTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForCorporateTaxName()));
    end;

    procedure ProvisionsForWarranties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForWarrantiesName()));
    end;

    procedure ProvisionsForCompensationForDamage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForCompensationForDamageName()));
    end;

    procedure ProvisionsForLegalAndConsultancyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionsForLegalAndConsultancyExpensesName()));
    end;

    procedure TotalProvisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalProvisionsName()));
    end;

    procedure AmountsOwedToCreditFinancialInstitutions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AmountsOwedToCreditFinancialInstitutionsName()));
    end;

    procedure BankWithCreditLimit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankWithCreditLimitName()));
    end;

    procedure ChecksIssued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChecksIssuedName()));
    end;

    procedure Loan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanName()));
    end;

    procedure SettlementAccountCreditCards(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountCreditCardsName()));
    end;

    procedure TotalAmountsOwedToCreditFinancInstitutions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAmountsOwedToCreditFinancInstitutionsName()));
    end;

    procedure AdvancePaymentsReceivedBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsReceivedBeginTotalName()));
    end;

    procedure AdvancePaymentsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancePaymentsReceivedName()));
    end;

    procedure HardwareContractsPaidInAdvance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HardwareContractsPaidInAdvanceName()));
    end;

    procedure SoftwareContractsPaidInAdvance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareContractsPaidInAdvanceName()));
    end;

    procedure TotalAdvancePaymentsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvancePaymentsReceivedName()));
    end;

    procedure PayablesToVendors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayablesToVendorsName()));
    end;

    procedure VendorsIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsIntercompanyName()));
    end;

    procedure NotePayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NotePayableName()));
    end;

    procedure InterimAccountAdvancePaymentsMade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterimAccountAdvancePaymentsMadeName()));
    end;

    procedure TotalPayablesToVendors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPayablesToVendorsName()));
    end;

    procedure TaxLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxLiabilitiesName()));
    end;

    procedure SalesTax10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTax10Name()));
    end;

    procedure SalesTax20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTax20Name()));
    end;

    procedure SalesTaxProfitAndIncomeTax10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxProfitAndIncomeTax10Name()));
    end;

    procedure SalesTaxProfitAndIncomeTax20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxProfitAndIncomeTax20Name()));
    end;

    procedure TaxOfficeTaxPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxOfficeTaxPayableName()));
    end;

    procedure SalesTaxClearingAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxClearingAccountName()));
    end;

    procedure ProductionOrderPayrollTaxProfitDP(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProductionOrderPayrollTaxProfitDPName()));
    end;

    procedure SettlementAccountTaxOffice(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountTaxOfficeName()));
    end;

    procedure TotalLiabilitiesFromTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesFromTaxesName()));
    end;

    procedure PayablesRelatedToSocialSecurity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayablesRelatedToSocialSecurityName()));
    end;

    procedure SettlementAccountSocialInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountSocialInsuranceName()));
    end;

    procedure SettlementAccountLocalTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountLocalTaxName()));
    end;

    procedure SettlementAccountWagesSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SettlementAccountWagesSalariesName()));
    end;

    procedure TaxPaymentsWithheld(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxPaymentsWithheldName()));
    end;

    procedure PaymentOfTaxArrears(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentOfTaxArrearsName()));
    end;

    procedure PayrollTaxPayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollTaxPaymentsName()));
    end;

    procedure VacationCompensationPayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VacationCompensationPaymentsName()));
    end;

    procedure TotalSocialSecurity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSocialSecurityName()));
    end;

    procedure OtherLiabilitiesAndDeferrals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLiabilitiesAndDeferralsName()));
    end;

    procedure DeferredIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredIncomeName()));
    end;

    procedure TotalOtherLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherLiabilitiesName()));
    end;

    procedure TOTALLIABILITIESPROVISIONS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALLIABILITIESPROVISIONSName()));
    end;

    procedure OPERATINGINCOME(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OPERATINGINCOMEName()));
    end;

    procedure RevenuesAndRevenueReduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesAndRevenueReductionName()));
    end;

    procedure Revenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesName()));
    end;

    procedure SalesRevenuesTrade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesTradeName()));
    end;

    procedure SalesRevenuesTradeDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesTradeDomesticName()));
    end;

    procedure SalesRevenuesTradeExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesTradeExportName()));
    end;

    procedure SalesRevenuesTradeEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesTradeEUName()));
    end;

    procedure ProjectSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectSalesName()));
    end;

    procedure ProjectSalesCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectSalesCorrectionName()));
    end;

    procedure TotalSalesRevenuesTrade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesRevenuesTradeName()));
    end;

    procedure SalesRevenuesRawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesRawMaterialName()));
    end;

    procedure SalesRevenuesRawMaterialDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesRawMaterialDomesticName()));
    end;

    procedure SalesRevenuesRawMaterialExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesRawMaterialExportName()));
    end;

    procedure SalesRevenuesRawMaterialEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesRawMaterialEUName()));
    end;

    procedure TotalSalesRevenuesRawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesRevenuesRawMaterialName()));
    end;

    procedure SalesRevenuesResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesResourcesName()));
    end;

    procedure SalesRevenuesResourcesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesResourcesDomesticName()));
    end;

    procedure SalesRevenuesResourcesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesResourcesExportName()));
    end;

    procedure SalesRevenuesResourcesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRevenuesResourcesEUName()));
    end;

    procedure TotalSalesRevenuesResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesRevenuesResourcesName()));
    end;

    procedure ProjectRevenuesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectRevenuesBeginTotalName()));
    end;

    procedure ProjectRevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectRevenuesName()));
    end;

    procedure OtherProjectRevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherProjectRevenuesName()));
    end;

    procedure TotalProjectRevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalProjectRevenuesName()));
    end;

    procedure RevenuesServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesServiceContractsName()));
    end;

    procedure RevenueServiceContract(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueServiceContractName()));
    end;

    procedure TotalServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalServiceContractsName()));
    end;

    procedure ChargesAndInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargesAndInterestName()));
    end;

    procedure ServiceCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceChargesName()));
    end;

    procedure ServiceInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceInterestName()));
    end;

    procedure ConsultingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingFeesName()));
    end;

    procedure TotalChargesAndInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalChargesAndInterestName()));
    end;

    procedure TotalRevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenuesName()));
    end;

    procedure RevenueAdjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueAdjustmentsName()));
    end;

    procedure RevenueAdjustmentDomestic10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueAdjustmentDomestic10Name()));
    end;

    procedure RevenueAdjustmentDomestic20(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueAdjustmentDomestic20Name()));
    end;

    procedure RevenueAdjustmentExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueAdjustmentExportName()));
    end;

    procedure RevenueAdjustmentEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueAdjustmentEUName()));
    end;

    procedure CashDiscountPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDiscountPaidName()));
    end;

    procedure CashDiscountPaidAdjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDiscountPaidAdjustmentName()));
    end;

    procedure TotalRevenueAdjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueAdjustmentsName()));
    end;

    procedure TotalRevenuesAndRevenueReduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenuesAndRevenueReductionName()));
    end;

    procedure InventoryChangesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryChangesBeginTotalName()));
    end;

    procedure InventoryChanges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryChangesName()));
    end;

    procedure OwnCostCapitalized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OwnCostCapitalizedName()));
    end;

    procedure TotalInventoryChanges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInventoryChangesName()));
    end;

    procedure OtherOperatingIncomeBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeBeginTotalName()));
    end;

    procedure ProceedsFromTheSaleOfAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProceedsFromTheSaleOfAssetsName()));
    end;

    procedure InsuranceCompensations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceCompensationsName()));
    end;

    procedure IncomeFromTheDisposalOfAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromTheDisposalOfAssetsName()));
    end;

    procedure IncomeFromTheAppreciationOfIntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromTheAppreciationOfIntangibleAssetsName()));
    end;

    procedure IncomeFromAppreciationOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromAppreciationOfFixedAssetsName()));
    end;

    procedure IncFromReleaseOfProvisionsForSeverPaym(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncFromReleaseOfProvisionsForSeverPaymName()));
    end;

    procedure IncomeFromTheReleaseOfProvForPensionPlan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromTheReleaseOfProvForPensionPlanName()));
    end;

    procedure IncomeFromTheReleaseOfOtherProvisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromTheReleaseOfOtherProvisionsName()));
    end;

    procedure OtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeName()));
    end;

    procedure OverageOfCash(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverageOfCashName()));
    end;

    procedure BenefitInKind(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitInKindName()));
    end;

    procedure RentalYield(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalYieldName()));
    end;

    procedure ExpenseReimbursement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpenseReimbursementName()));
    end;

    procedure FCYUnrealizedExchangeGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FCYUnrealizedExchangeGainsName()));
    end;

    procedure FCYRealizedExchangeGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FCYRealizedExchangeGainsName()));
    end;

    procedure OtherInsuranceCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInsuranceCompensationName()));
    end;

    procedure IncomeFromReleaseOfLossReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromReleaseOfLossReservesName()));
    end;

    procedure TotalOtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherOperatingIncomeName()));
    end;

    procedure TOTALOPERATINGINCOME(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALOPERATINGINCOMEName()));
    end;

    procedure COSTOFMATERIALS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COSTOFMATERIALSName()));
    end;

    procedure TradeGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsName()));
    end;

    procedure TradeGoodsConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsConsumptionName()));
    end;

    procedure TradeGoodsInventoryAdjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsInventoryAdjustmentName()));
    end;

    procedure TradeGoodsDirectCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsDirectCostName()));
    end;

    procedure TradeGoodsOverheadExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsOverheadExpensesName()));
    end;

    procedure TradeGoodsPurchaseVarianceAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeGoodsPurchaseVarianceAccountName()));
    end;

    procedure DiscountReceivedTrade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountReceivedTradeName()));
    end;

    procedure DeliveryExpensesTrade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeliveryExpensesTradeName()));
    end;

    procedure DiscountReceivedRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountReceivedRawMaterialsName()));
    end;

    procedure DeliveryExpensesRawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeliveryExpensesRawMaterialName()));
    end;

    procedure TotalTradeGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTradeGoodsName()));
    end;

    procedure RawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialName()));
    end;

    procedure RawMaterialConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialConsumptionName()));
    end;

    procedure RawMaterialInventoryAdjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialInventoryAdjustmentName()));
    end;

    procedure RawMaterialDirectCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialDirectCostName()));
    end;

    procedure RawMaterialOverheadExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialOverheadExpensesName()));
    end;

    procedure RawMaterialPurchaseVarianceAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialPurchaseVarianceAccountName()));
    end;

    procedure TotalRawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRawMaterialName()));
    end;

    procedure Processing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingName()));
    end;

    procedure ProcessingConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingConsumptionName()));
    end;

    procedure ProcessingInventoryAdjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingInventoryAdjustmentName()));
    end;

    procedure ProcessingOverheadExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingOverheadExpensesName()));
    end;

    procedure ProcessingPurchaseVarianceAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingPurchaseVarianceAccountName()));
    end;

    procedure TotalProcessing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalProcessingName()));
    end;

    procedure Projects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectsName()));
    end;

    procedure ProjectCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectCostsName()));
    end;

    procedure ProjectCostsAllocated(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectCostsAllocatedName()));
    end;

    procedure ProjectCostsCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectCostsCorrectionName()));
    end;

    procedure TotalProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalProjectsName()));
    end;

    procedure Variance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceName()));
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure ManufacturingOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManufacturingOverheadVarianceName()));
    end;

    procedure TotalVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVarianceName()));
    end;

    procedure Consumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionName()));
    end;

    procedure AuxiliariesConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliariesConsumptionName()));
    end;

    procedure PackagingMaterialConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PackagingMaterialConsumptionName()));
    end;

    procedure OperatingMaterialsConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingMaterialsConsumptionName()));
    end;

    procedure CleaningMaterialsConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningMaterialsConsumptionName()));
    end;

    procedure ConsumptionOfIncidentals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionOfIncidentalsName()));
    end;

    procedure ConsumptionOfFuels(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionOfFuelsName()));
    end;

    procedure TotalConsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalConsumptionName()));
    end;

    procedure PurchaseCurrentMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseCurrentMaterialName()));
    end;

    procedure PurchaseTradeDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseTradeDomesticName()));
    end;

    procedure PurchaseTradeImport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseTradeImportName()));
    end;

    procedure PurchaseTradeEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseTradeEUName()));
    end;

    procedure PurchaseRawMaterialsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseRawMaterialsDomesticName()));
    end;

    procedure PurchaseRawMaterialsImport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseRawMaterialsImportName()));
    end;

    procedure PurchaseRawMaterialsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseRawMaterialsEUName()));
    end;

    procedure TotalPurchaseActiveMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPurchaseActiveMaterialName()));
    end;

    procedure OtherServicesReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherServicesReceivedName()));
    end;

    procedure ServicesReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServicesReceivedName()));
    end;

    procedure ServiceChargesPurchase(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceChargesPurchaseName()));
    end;

    procedure TotalOtherServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherServicesName()));
    end;

    procedure PaymentDiscountRevenueBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountRevenueBeginTotalName()));
    end;

    procedure PaymentDiscountRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountRevenueName()));
    end;

    procedure PaymentDiscountRevenueCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountRevenueCorrectionName()));
    end;

    procedure TotalPaymentDiscountRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPaymentDiscountRevenueName()));
    end;

    procedure TOTALCOSTOFMATERIALS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALCOSTOFMATERIALSName()));
    end;

    procedure WagesWithoutServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesWithoutServicesName()));
    end;

    procedure TotalWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWagesName()));
    end;

    procedure SalariesWithoutServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesWithoutServicesName()));
    end;

    procedure TotalSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalariesName()));
    end;

    procedure SeverancePaymentsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SeverancePaymentsBeginTotalName()));
    end;

    procedure SeverancePayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SeverancePaymentsName()));
    end;

    procedure SeverancePaymentProvisionFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SeverancePaymentProvisionFundName()));
    end;

    procedure PensionsPayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionsPaymentsName()));
    end;

    procedure PensionProvisionFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionProvisionFundName()));
    end;

    procedure TotalSeverancePayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSeverancePaymentsName()));
    end;

    procedure StatutorySocialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialExpensesName()));
    end;

    procedure StatutorySocialExpensesWorker(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialExpensesWorkerName()));
    end;

    procedure StatutorySocialExpensesEmployee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialExpensesEmployeeName()));
    end;

    procedure TotalStatutorySocialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalStatutorySocialExpensesName()));
    end;

    procedure OtherSocialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSocialExpensesName()));
    end;

    procedure LocalTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LocalTaxName()));
    end;

    procedure GDContributionFamilyAllowanceProfit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GDContributionFamilyAllowanceProfitName()));
    end;

    procedure AdditionToProfit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionToProfitName()));
    end;

    procedure LevyForTheEmployerVienna(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LevyForTheEmployerViennaName()));
    end;

    procedure VoluntarySocialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VoluntarySocialExpensesName()));
    end;

    procedure CostCenterSettlementInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostCenterSettlementInsuranceName()));
    end;

    procedure TotalOtherSocialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherSocialExpensesName()));
    end;

    procedure DEPRECIATIONOTHERCOSTOFOPERATIONS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DEPRECIATIONOTHERCOSTOFOPERATIONSName()));
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure ScheduledAmortizationOnIntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ScheduledAmortizationOnIntangibleAssetsName()));
    end;

    procedure UnscheduledAmortizationOnIntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnscheduledAmortizationOnIntangibleAssetsName()));
    end;

    procedure ScheduledDepreciationOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ScheduledDepreciationOfFixedAssetsName()));
    end;

    procedure ScheduledDepreciationVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ScheduledDepreciationVehiclesName()));
    end;

    procedure UnscheduledDepreciationOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnscheduledDepreciationOfFixedAssetsName()));
    end;

    procedure LowValueAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LowValueAssetsName()));
    end;

    procedure TotalDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalDepreciationName()));
    end;

    procedure OtherTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherTaxesName()));
    end;

    procedure PropertyTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyTaxName()));
    end;

    procedure BeverageAndAlcoholTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BeverageAndAlcoholTaxName()));
    end;

    procedure ChargesAndRevenueStamps(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargesAndRevenueStampsName()));
    end;

    procedure MiscOtherTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscOtherTaxesName()));
    end;

    procedure TotalOtherTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherTaxesName()));
    end;

    procedure MaintenanceCleaningEtc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceCleaningEtcName()));
    end;

    procedure ThirdPartyMaintenance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ThirdPartyMaintenanceName()));
    end;

    procedure CarOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarOperatingExpensesName()));
    end;

    procedure TruckOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckOperatingExpensesName()));
    end;

    procedure CarRepairsAndMaintenance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarRepairsAndMaintenanceName()));
    end;

    procedure Fuel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FuelName()));
    end;

    procedure TotalMaintenanceEtc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMaintenanceEtcName()));
    end;

    procedure TransportationTravelCommunications(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportationTravelCommunicationsName()));
    end;

    procedure TransportationThirdParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportationThirdPartiesName()));
    end;

    procedure TravelExpensesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesDomesticName()));
    end;

    procedure TravelExpensesAbroad(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesAbroadName()));
    end;

    procedure KilometerAllowance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(KilometerAllowanceName()));
    end;

    procedure MealExpensesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MealExpensesDomesticName()));
    end;

    procedure MealExpensesAbroad(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MealExpensesAbroadName()));
    end;

    procedure HotelExpensesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HotelExpensesDomesticName()));
    end;

    procedure HotelExpensesAbroad(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HotelExpensesAbroadName()));
    end;

    procedure CommunicationCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommunicationChargesName()));
    end;

    procedure TotalTransportationExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTransportationExpensesName()));
    end;

    procedure RentalsLeasingBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalsLeasingBeginTotalName()));
    end;

    procedure RentalsLeasing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalsLeasingName()));
    end;

    procedure TotalRentalsLeasingEtc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRentalsLeasingEtcName()));
    end;

    procedure Commissions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsName()));
    end;

    procedure CommissionsForThirdParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsForThirdPartiesName()));
    end;

    procedure TotalCommissions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCommissionsName()));
    end;

    procedure OfficeAdvertisingAndMaintenanceExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeAdvertisingAndMaintenanceExpenditureName()));
    end;

    procedure PhoneAndInternetCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneAndInternetChargesName()));
    end;

    procedure ExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExternalServicesName()));
    end;

    procedure DeductibleAdvertisingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeductibleAdvertisingExpensesName()));
    end;

    procedure NonDeductibleAdvertisingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonDeductibleAdvertisingExpensesName()));
    end;

    procedure HospitalityDomesticDeductibleAmount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HospitalityDomesticDeductibleAmountName()));
    end;

    procedure HospitalityDomesticNonDeductibleAmount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HospitalityDomesticNonDeductibleAmountName()));
    end;

    procedure HospitalityAbroadDeductibleAmount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HospitalityAbroadDeductibleAmountName()));
    end;

    procedure HospitalityAbroadNonDeductibleAmount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HospitalityAbroadNonDeductibleAmountName()));
    end;

    procedure DonationsAndTips(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DonationsAndTipsName()));
    end;

    procedure TotalOfficeAdvertisingMaintenanceExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOfficeAdvertisingMaintenanceExpenditureName()));
    end;

    procedure InsurancesAndOtherExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesAndOtherExpensesName()));
    end;

    procedure InsuranceExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceExpensesName()));
    end;

    procedure LegalAndConsultancyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalAndConsultancyExpensesName()));
    end;

    procedure ProvisionForLegalAndConsultancyExpensesFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForLegalAndConsultancyExpensesFundName()));
    end;

    procedure Other(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherName()));
    end;

    procedure TechnicalLiterature(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TechnicalLiteratureName()));
    end;

    procedure ExpenditureEducationAndTraining(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpenditureEducationAndTrainingName()));
    end;

    procedure ChamberContribution(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChamberContributionName()));
    end;

    procedure ExpensesThroughCirculationOfMoney(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesThroughCirculationOfMoneyName()));
    end;

    procedure DepreciationOfSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOfSuppliesName()));
    end;

    procedure DepreciationExportReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExportReceivablesName()));
    end;

    procedure DepreciationDomesticReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationDomesticReceivablesName()));
    end;

    procedure IndividualLossReservesForReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IndividualLossReservesForReceivablesName()));
    end;

    procedure BlanketLossReservesForReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BlanketLossReservesForReceivablesName()));
    end;

    procedure BookValueDisposalOfAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueDisposalOfAssetsName()));
    end;

    procedure LossesFromDisposalOfAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesFromDisposalOfAssetsName()));
    end;

    procedure OtherOperationalExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperationalExpenditureName()));
    end;

    procedure ProvisionForWarrantiesFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForWarrantiesFundName()));
    end;

    procedure ProvisionForCompensationForDamagesFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForCompensationForDamagesFundName()));
    end;

    procedure ProvisionForProductLiabilityFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvisionForProductLiabilityFundName()));
    end;

    procedure MiscProvisionsFund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscProvisionsFundName()));
    end;

    procedure CashDeficit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDeficitName()));
    end;

    procedure FCYUnrealizedExchangeLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FCYUnrealizedExchangeLossesName()));
    end;

    procedure FCYRealizedExchangeLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FCYRealizedExchangeLossesName()));
    end;

    procedure PaymentDiscountRevenue0VAT(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountRevenue0VATName()));
    end;

    procedure CostCenterSettlementSocialExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostCenterSettlementSocialExpenseName()));
    end;

    procedure TotalInsuranceAndOtherExpenditures(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsuranceAndOtherExpendituresName()));
    end;

    procedure TOTALDEPRECIATIONOPERATIONALEXPENDITURE(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALDEPRECIATIONOPERATIONALEXPENDITUREName()));
    end;

    procedure FINANCIALREVENUESANDEXPENDITURESBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FINANCIALREVENUESANDEXPENDITURESBeginTotalName()));
    end;

    procedure FINANCIALREVENUESANDEXPENDITURES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FINANCIALREVENUESANDEXPENDITURESName()));
    end;

    procedure IncomeFromEquityInterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromEquityInterestsName()));
    end;

    procedure InterestFromBankDeposits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestFromBankDepositsName()));
    end;

    procedure InterestFromLoansGranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestFromLoansGrantedName()));
    end;

    procedure PassThroughDiscountRates(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PassThroughDiscountRatesName()));
    end;

    procedure IncomeFromDefaultInterestAndExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromDefaultInterestAndExpensesName()));
    end;

    procedure OtherInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInterestIncomeName()));
    end;

    procedure InterestIncomeFromFixedRateSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestIncomeFromFixedRateSecuritiesName()));
    end;

    procedure OtherSecuritiesIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSecuritiesIncomeName()));
    end;

    procedure ProceedsFromTheDispOfOtherFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProceedsFromTheDispOfOtherFinancialAssetsName()));
    end;

    procedure PmtTolReceivedDecreasesCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtTolReceivedDecreasesCorrectionName()));
    end;

    procedure IncomeFromAppreciationOfFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromAppreciationOfFinancialAssetsName()));
    end;

    procedure IncomeFromAppreciationOfMarketableSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromAppreciationOfMarketableSecuritiesName()));
    end;

    procedure DepreciationOtherFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOtherFinancialAssetsName()));
    end;

    procedure DepreciationOfMarketableSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOfMarketableSecuritiesName()));
    end;

    procedure LossFromDisposalOfOtherFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossFromDisposalOfOtherFinancialAssetsName()));
    end;

    procedure InterestExpenseForBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestExpenseForBankLoansName()));
    end;

    procedure UnscheduledDepreciationOfFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnscheduledDepreciationOfFinancialAssetsName()));
    end;

    procedure InterestExpenditureForLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestExpenditureForLoansName()));
    end;

    procedure DepreciationActivatedFundsAcquisitionCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationActivatedFundsAcquisitionCostName()));
    end;

    procedure DiscountInterestExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountInterestExpenditureName()));
    end;

    procedure DefaultInterestExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DefaultInterestExpensesName()));
    end;

    procedure UnusedDeliveryDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnusedDeliveryDiscountsName()));
    end;

    procedure PmtTolGrantedDecreasesCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtTolGrantedDecreasesCorrectionName()));
    end;

    procedure TotalFinancialIncomeAndExpensesEndTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialIncomeAndExpensesEndTotalName()));
    end;

    procedure NonRecurringIncomeNonRecurringExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRecurringIncomeNonRecurringExpensesName()));
    end;

    procedure NonRecurringIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRecurringIncomeName()));
    end;

    procedure NonRecurringExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRecurringExpensesName()));
    end;

    procedure TaxesBeforeIncomeAndEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesBeforeIncomeAndEarningsName()));
    end;

    procedure CapitalReturnsTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalReturnsTaxName()));
    end;

    procedure TotalTaxBeforeIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTaxBeforeIncomeName()));
    end;

    procedure ChangesInReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangesInReservesName()));
    end;

    procedure GainsFromReversalOfUntaxedReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsFromReversalOfUntaxedReservesName()));
    end;

    procedure GainsFromReversalOfValuationReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsFromReversalOfValuationReservesName()));
    end;

    procedure AssignmentReservesAccordingTo10EstgIFB(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssignmentReservesAccordingTo10EstgIFBName()));
    end;

    procedure AssignmentRLAccordingTo12Estg(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssignmentRLAccordingTo12EstgName()));
    end;

    procedure AssignmentToValuationReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssignmentToValuationReservesName()));
    end;

    procedure TotalChangeInReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalChangeInReservesName()));
    end;

    procedure TOTALFINANCIALINCOMEANDEXPENSES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALFINANCIALINCOMEANDEXPENSESName()));
    end;

    procedure EQUITYRESERVES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EQUITYRESERVESName()));
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure TaxProvisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxProvisionsName()));
    end;

    procedure FreeReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreeReservesName()));
    end;

    procedure NetProfitNetLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetProfitNetLossName()));
    end;

    procedure ValuationReservesFor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ValuationReservesForName()));
    end;

    procedure ReservesAccordingTo10EstgIFB(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservesAccordingTo10EstgIFBName()));
    end;

    procedure ReservesAccordingTo12Estg(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservesAccordingTo12EstgName()));
    end;

    procedure Private(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrivateName()));
    end;

    procedure EBK(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EBKName()));
    end;

    procedure SBK(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SBKName()));
    end;

    procedure ProfitAndLossStatement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitAndLossStatementName()));
    end;

    procedure TOTALEQUITYRESERVES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALEQUITYRESERVESName()));
    end;

    procedure WagesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesBeginTotalName()));
    end;

    procedure SalariesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesBeginTotalName()));
    end;

    procedure FinishedGoodsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsBeginTotalName()));
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CommissioningAnOperationLbl: Label 'Commissioning an operation', MaxLength = 100;
        CommissioningTheOperationLbl: Label 'Commissioning the operation', MaxLength = 100;
        AccumulatedDepreciationFixedAssetLbl: Label 'Accumulated depreciation-Fixed Asset', MaxLength = 100;
        CommissioningTotalLbl: Label 'Commissioning total', MaxLength = 100;
        IntangibleAssetsLbl: Label 'Intangible assets', MaxLength = 100;
        ConcessionsLbl: Label 'Concessions', MaxLength = 100;
        PatentAndLicenseRightsLbl: Label 'Patent and license rights', MaxLength = 100;
        DataProcessingProgramsLbl: Label 'Data processing programs', MaxLength = 100;
        CompanyValueLbl: Label 'Company value', MaxLength = 100;
        AdvancePaymentsForIntangibleAssetsLbl: Label 'Advance payments for intangible assets', MaxLength = 100;
        AccumulatedDepreciationIntangibleAssetLbl: Label 'Accumulated depreciation-Intengible Asset', MaxLength = 100;
        TotalIntangibleAssetsLbl: Label 'Total intangible assets', MaxLength = 100;
        RealEstateLbl: Label 'Real estate', MaxLength = 100;
        DevelopedLandLbl: Label 'Developed land', MaxLength = 100;
        OperationalBuildingLbl: Label 'Operational building', MaxLength = 100;
        AcquisitionsDuringTheYearRealEstateLbl: Label 'Acquisitions during the year - Real Estate', MaxLength = 100;
        DisposalsDuringTheYearRealEstateLbl: Label 'Disposals during the year - Real Estate', MaxLength = 100;
        InvestmentInLeasedBuildingLbl: Label 'Investment in leased building', MaxLength = 100;
        AccumulatedDepreciationBookedLbl: Label 'Accumulated depreciation booked', MaxLength = 100;
        UndevelopedLandLbl: Label 'Undeveloped land', MaxLength = 100;
        TotalRealEstateLbl: Label 'Total real estate', MaxLength = 100;
        MachineryAndEquipmentLbl: Label 'Machinery and equipment', MaxLength = 100;
        LowValueMachineryLbl: Label 'Low-value machinery', MaxLength = 100;
        AccumulatedDepreciationOperEquipmentLbl: Label 'Accumulated depreciation-Oper. Equip', MaxLength = 100;
        OfficeEquipmentLbl: Label 'Office equipment', MaxLength = 100;
        BusinessFacilitiesLbl: Label 'Business facilities', MaxLength = 100;
        OfficeMachinesEDPLbl: Label 'Office machines, EDP', MaxLength = 100;
        AcquisitionsDuringTheYearOperEquipmentLbl: Label 'Acquisitions during the year - Oper Equipment', MaxLength = 100;
        DisposalsDuringTheYearOperEquipmentLbl: Label 'Disposals during the year - Oper Equipment', MaxLength = 100;
        AccumDepreciationOfBuildingLbl: Label 'Accum. Depreciation of building', MaxLength = 100;
        TotalOperatingEquipmentLbl: Label 'Total operating equipment', MaxLength = 100;
        VehicleFleetLbl: Label 'Vehicle fleet', MaxLength = 100;
        CarLbl: Label 'Car', MaxLength = 100;
        TruckLbl: Label 'Truck', MaxLength = 100;
        AcquisitionsDuringTheYearVehicleLbl: Label 'Acquisitions during the year - Vehicle', MaxLength = 100;
        DisposalsDuringTheYearVehicleLbl: Label 'Disposals during the year - Vehicle', MaxLength = 100;
        AccumDepreciationLbl: Label 'Accum. Depreciation', MaxLength = 100;
        TotalVehicleFleetLbl: Label 'Total vehicle fleet', MaxLength = 100;
        OtherFacilitiesLbl: Label 'Other facilities', MaxLength = 100;
        LowValueAssetsOperationalAndBusFacilitiesLbl: Label 'Low-value assets (operational and bus. facilities)', MaxLength = 100;
        AccumulatedDepreciationOtherFacilitiesLbl: Label 'Accumulated depreciation-Other Facilities', MaxLength = 100;
        TotalOtherFacilitiesLbl: Label 'Total other facilities', MaxLength = 100;
        AdvancePaymentsMadeFacilitiesUnderConstrLbl: Label 'Advance payments made/facilities under constr.', MaxLength = 100;
        AdvancePaymentsMadeForTangibleFixedAssetsLbl: Label 'Advance payments made for tangible fixed assets', MaxLength = 100;
        FacilitiesUnderConstructionLbl: Label 'Facilities under construction', MaxLength = 100;
        AccumulatedDepreciationAdvPaymentLbl: Label 'Accumulated depreciation-Adv. Payment', MaxLength = 100;
        TotalAdvPaymMadeFacilitiesUnderConstrLbl: Label 'Total adv. paym. made/facilities under constr.', MaxLength = 100;
        FinancialAssetsLbl: Label 'Financial assets', MaxLength = 100;
        EquityInterestsInAssociatedCompaniesLbl: Label 'Equity interests in associated companies', MaxLength = 100;
        OtherEquityInterestsLbl: Label 'Other equity interests', MaxLength = 100;
        CompanySharesOrEquityInterestsLbl: Label 'Company shares or equity interests', MaxLength = 100;
        InvestmentSecuritiesLbl: Label 'Investment securities', MaxLength = 100;
        SecuritiesProvisionsForSeverancePayLbl: Label 'Securities provisions for severance pay', MaxLength = 100;
        SecuritiesProvisionsForPensionPlanLbl: Label 'Securities provisions for pension plan', MaxLength = 100;
        AdvancePaymentsMadeForFinancialAssetsLbl: Label 'Advance payments made for financial assets', MaxLength = 100;
        AccumulatedDepreciationFinancalAssetLbl: Label 'Accumulated depreciation - Financial Asset', MaxLength = 100;
        TotalFinancialAssetsLbl: Label 'Total financial assets', MaxLength = 100;
        TOTALFIXEDASSETSLbl: Label 'TOTAL FIXED ASSETS', MaxLength = 100;
        SUPPLIESLbl: Label 'SUPPLIES', MaxLength = 100;
        PurchaseSettlementBeginTotalLbl: Label 'Purchase settlement - Begin Total', MaxLength = 100;
        PurchaseSettlementLbl: Label 'Purchase settlement', MaxLength = 100;
        OpeningInventoryLbl: Label 'Opening inventory', MaxLength = 100;
        TotalPurchaseSettlementLbl: Label 'Total purchase settlement', MaxLength = 100;
        RawMaterialSupplyLbl: Label 'Raw material supply', MaxLength = 100;
        RawMaterialSupplyInterimLbl: Label 'Raw material supply (interim)', MaxLength = 100;
        RawMaterialsPostReceiptInterimLbl: Label 'Raw materials post receipt (interim)', MaxLength = 100;
        TotalRawMaterialsLbl: Label 'Total raw materials', MaxLength = 100;
        PartsPurchasedBeginTotalLbl: Label 'Parts purchased - Begin Total', MaxLength = 100;
        PartsPurchasedLbl: Label 'Parts purchased', MaxLength = 100;
        TotalPartsPurchasedLbl: Label 'Total parts purchased', MaxLength = 100;
        AuxiliariesOperatingMaterialsLbl: Label 'Auxiliaries, operating materials', MaxLength = 100;
        AuxiliariesSupplyLbl: Label 'Auxiliaries supply', MaxLength = 100;
        OperatingMaterialsSupplyLbl: Label 'Operating materials supply', MaxLength = 100;
        FuelOilSupplyLbl: Label 'Fuel oil supply', MaxLength = 100;
        TotalAuxiliariesOperatingMaterialsLbl: Label 'Total auxiliaries, operating materials', MaxLength = 100;
        WorkInProcessBeginTotalLbl: Label 'Work in process - Begin Total', MaxLength = 100;
        WorkInProcessLbl: Label 'Work in process', MaxLength = 100;
        CostWorkInProcessLbl: Label 'Cost work in process', MaxLength = 100;
        AnticipatedCostWorkInProcessLbl: Label 'Anticipated cost work in process', MaxLength = 100;
        SalesWorkInProcessLbl: Label 'Sales work in process', MaxLength = 100;
        AnticipatedSalesWorkInProcessLbl: Label 'Anticipated sales work in process', MaxLength = 100;
        TotalWorkInProcessLbl: Label 'Total work in process', MaxLength = 100;
        TotalFinishedGoodsLbl: Label 'Total finished goods', MaxLength = 100;
        GoodsLbl: Label 'Goods', MaxLength = 100;
        SupplyTradeGoodsLbl: Label 'Supply trade goods', MaxLength = 100;
        SupplyTradeGoodsInterimLbl: Label 'Supply trade goods (interim)', MaxLength = 100;
        TradeGoodsPostReceiptInterimLbl: Label 'Trade goods post receipt (interim)', MaxLength = 100;
        TotalGoodsLbl: Label 'Total goods', MaxLength = 100;
        ServiceNotBillableYetLbl: Label 'Service not billable yet', MaxLength = 100;
        ServiceNotBillableYesLbl: Label 'Service not billable yes', MaxLength = 100;
        TotalServicesNotBillableYetLbl: Label 'Total services not billable yet', MaxLength = 100;
        AdvancePaymentsMadeLbl: Label 'Advance payments made', MaxLength = 100;
        AdvancePaymentsMadeForSuppliesLbl: Label 'Advance payments made for supplies', MaxLength = 100;
        TotalAdvancePaymentsMadeLbl: Label 'Total advance payments made', MaxLength = 100;
        TOTALSUPPLIESLbl: Label 'TOTAL SUPPLIES', MaxLength = 100;
        OtherCurrentAssetsLbl: Label 'Other current assets', MaxLength = 100;
        ReceivablesLbl: Label 'Receivables', MaxLength = 100;
        TradeReceivablesLbl: Label 'Trade receivables', MaxLength = 100;
        TradeReceivablesDomesticLbl: Label 'Trade receivables domestic', MaxLength = 100;
        TradeReceivablesForeignLbl: Label 'Trade receivables foreign', MaxLength = 100;
        ReceivablesIntercompanyLbl: Label 'Receivables intercompany', MaxLength = 100;
        ReceivablesCashOnDeliveryLbl: Label 'Receivables cash on delivery', MaxLength = 100;
        ChangeOfOwnershipLbl: Label 'Change of ownership', MaxLength = 100;
        InterimAccountAdvancePaymentsReceivedLbl: Label 'Interim account advance payments received', MaxLength = 100;
        IndividualLossReservesForDomesticReceivablesLbl: Label 'Individual loss reserves for domestic receivables', MaxLength = 100;
        BlanketLossReservesForDomesticReceivablesLbl: Label 'Blanket loss reserves for domestic receivables', MaxLength = 100;
        TradeReceivablesIntraCommunityLbl: Label 'Trade receivables intra-community', MaxLength = 100;
        IndivLossReservesForIntraCommunityReceivabLbl: Label 'Indiv. loss reserves for intra-community receivab.', MaxLength = 100;
        BlanketLossReservesForIntraCommunityReceivLbl: Label 'Blanket loss reserves for intra-community receiv.', MaxLength = 100;
        TradeReceivablesExportLbl: Label 'Trade receivables export', MaxLength = 100;
        IndividualLossReservesForReceivablesExportLbl: Label 'Individual loss reserves for receivables export', MaxLength = 100;
        BlanketLossReservesForReceivablesExportLbl: Label 'Blanket loss reserves for receivables export', MaxLength = 100;
        GrantedLoanLbl: Label 'Granted loan', MaxLength = 100;
        OtherAdvancePaymentsMadeLbl: Label 'Other advance payments made', MaxLength = 100;
        TotalTradeReceivablesLbl: Label 'Total trade receivables', MaxLength = 100;
        ReceivablesFromOffsettingOfLeviesLbl: Label 'Receivables from offsetting of levies', MaxLength = 100;
        PurchaseVATReducedLbl: Label 'Purchase VAT 10%', MaxLength = 100;
        PurchaseVATStandardLbl: Label 'Purchase VAT 20%', MaxLength = 100;
        PurchaseVATAcquisitionReducedLbl: Label 'Purchase VAT  acquisition 10%', MaxLength = 100;
        PurchaseVATAcquisitionStandardLbl: Label 'Purchase VAT  acquisition 20%', MaxLength = 100;
        ImportSalesTaxLbl: Label 'Import sales tax', MaxLength = 100;
        PurchaseVATClearingAccountLbl: Label 'Purchase VAT clearing account', MaxLength = 100;
        CapitalReturnsTaxAllowableOnIncomeTaxLbl: Label 'Capital returns tax (allowable on income tax)', MaxLength = 100;
        TotalAccountsReceivableOffsettingOfLeviesLbl: Label 'Total accounts receivable offsetting of levies', MaxLength = 100;
        TotalAccountsReceivableLbl: Label 'Total accounts receivable', MaxLength = 100;
        MarketableSecuritiesLbl: Label 'Marketable securities', MaxLength = 100;
        EndorsedCededBillOfExchangeLbl: Label 'endorsed, ceded bill of exchange', MaxLength = 100;
        TotalSecuritiesLbl: Label 'Total securities', MaxLength = 100;
        CashAndBankLbl: Label 'Cash and bank', MaxLength = 100;
        PostageStampLbl: Label 'Postage stamp', MaxLength = 100;
        RevenueStampsLbl: Label 'Revenue stamps', MaxLength = 100;
        SettlementAccountCashBankLbl: Label 'Settlement account cash bank', MaxLength = 100;
        ChecksReceivedLbl: Label 'Checks received', MaxLength = 100;
        AccountsReceivableFromCreditCardOrganizationLbl: Label 'Accounts receivable from credit card organization', MaxLength = 100;
        BankCurrenciesLbl: Label 'Bank, currencies', MaxLength = 100;
        TotalCashAndBankLbl: Label 'Total cash and bank', MaxLength = 100;
        PrepaidExpensesLbl: Label 'Prepaid expenses', MaxLength = 100;
        AccrualsLbl: Label 'Accruals', MaxLength = 100;
        BorrowingCostsLbl: Label 'Borrowing costs', MaxLength = 100;
        TotalPrepaidExpensesLbl: Label 'Total prepaid expenses', MaxLength = 100;
        TOTALOTHERCURRENTASSETSLbl: Label 'TOTAL OTHER CURRENT ASSETS', MaxLength = 100;
        LIABILITIESPROVISIONSLbl: Label 'LIABILITIES, PROVISIONS', MaxLength = 100;
        ProvisionsLbl: Label 'Provisions ', MaxLength = 100;
        ProvisionsForSeverancePaymentsLbl: Label 'Provisions for severance payments', MaxLength = 100;
        ProvisionsForPensionsLbl: Label 'Provisions for pensions', MaxLength = 100;
        ProvisionsForCorporateTaxLbl: Label 'Provisions for corporate tax', MaxLength = 100;
        ProvisionsForWarrantiesLbl: Label 'Provisions for warranties', MaxLength = 100;
        ProvisionsForCompensationForDamageLbl: Label 'Provisions for compensation for damage', MaxLength = 100;
        ProvisionsForLegalAndConsultancyExpensesLbl: Label 'Provisions for legal and consultancy expenses', MaxLength = 100;
        TotalProvisionsLbl: Label 'Total provisions', MaxLength = 100;
        AmountsOwedToCreditFinancialInstitutionsLbl: Label 'Amounts owed to credit / financial institutions', MaxLength = 100;
        BankWithCreditLimitLbl: Label 'Bank (with credit limit)', MaxLength = 100;
        ChecksIssuedLbl: Label 'Checks (issued)', MaxLength = 100;
        LoanLbl: Label 'Loan', MaxLength = 100;
        SettlementAccountCreditCardsLbl: Label 'Settlement account credit cards', MaxLength = 100;
        TotalAmountsOwedToCreditFinancInstitutionsLbl: Label 'Total amounts owed to credit/financ. institutions', MaxLength = 100;
        AdvancePaymentsReceivedBeginTotalLbl: Label 'Advance payments received - Begin Total', MaxLength = 100;
        AdvancePaymentsReceivedLbl: Label 'Advance payments received', MaxLength = 100;
        HardwareContractsPaidInAdvanceLbl: Label 'Hardware contracts paid in advance', MaxLength = 100;
        SoftwareContractsPaidInAdvanceLbl: Label 'Software contracts paid in advance', MaxLength = 100;
        TotalAdvancePaymentsReceivedLbl: Label 'Total advance payments received', MaxLength = 100;
        PayablesToVendorsLbl: Label 'Payables to vendors', MaxLength = 100;
        VendorsIntercompanyLbl: Label 'Vendors, intercompany', MaxLength = 100;
        NotePayableLbl: Label 'Note payable', MaxLength = 100;
        InterimAccountAdvancePaymentsMadeLbl: Label 'Interim account advance payments made', MaxLength = 100;
        TotalPayablesToVendorsLbl: Label 'Total payables to vendors', MaxLength = 100;
        TaxLiabilitiesLbl: Label 'Tax liabilities', MaxLength = 100;
        SalesTax10Lbl: Label 'Sales tax 10%', MaxLength = 100;
        SalesTax20Lbl: Label 'Sales tax 20%', MaxLength = 100;
        SalesTaxProfitAndIncomeTax10Lbl: Label 'Sales tax profit and income tax 10%', MaxLength = 100;
        SalesTaxProfitAndIncomeTax20Lbl: Label 'Sales tax profit and income tax 20%', MaxLength = 100;
        TaxOfficeTaxPayableLbl: Label 'Tax Office - tax payable', MaxLength = 100;
        SalesTaxClearingAccountLbl: Label 'Sales tax clearing account', MaxLength = 100;
        ProductionOrderPayrollTaxProfitDPLbl: Label 'Production order payroll tax, profit, D/P', MaxLength = 100;
        SettlementAccountTaxOfficeLbl: Label 'Settlement account Tax Office', MaxLength = 100;
        TotalLiabilitiesFromTaxesLbl: Label 'Total liabilities from taxes', MaxLength = 100;
        PayablesRelatedToSocialSecurityLbl: Label 'Payables related to social security', MaxLength = 100;
        SettlementAccountSocialInsuranceLbl: Label 'Settlement account social insurance', MaxLength = 100;
        SettlementAccountLocalTaxLbl: Label 'Settlement account local tax', MaxLength = 100;
        SettlementAccountWagesSalariesLbl: Label 'Settlement account wages + salaries', MaxLength = 100;
        TaxPaymentsWithheldLbl: Label 'Tax payments withheld', MaxLength = 100;
        PaymentOfTaxArrearsLbl: Label 'Payment of tax arrears', MaxLength = 100;
        PayrollTaxPaymentsLbl: Label 'Payroll tax payments', MaxLength = 100;
        VacationCompensationPaymentsLbl: Label 'Vacation compensation payments', MaxLength = 100;
        TotalSocialSecurityLbl: Label 'Total social security', MaxLength = 100;
        OtherLiabilitiesAndDeferralsLbl: Label 'Other liabilities and deferrals', MaxLength = 100;
        DeferredIncomeLbl: Label 'Deferred income', MaxLength = 100;
        TotalOtherLiabilitiesLbl: Label 'Total other liabilities', MaxLength = 100;
        TOTALLIABILITIESPROVISIONSLbl: Label 'TOTAL LIABILITIES, PROVISIONS', MaxLength = 100;
        OPERATINGINCOMELbl: Label 'OPERATING INCOME', MaxLength = 100;
        RevenuesAndRevenueReductionLbl: Label 'Revenues and revenue reduction', MaxLength = 100;
        RevenuesLbl: Label 'Revenues', MaxLength = 100;
        SalesRevenuesTradeLbl: Label 'Sales revenues trade', MaxLength = 100;
        SalesRevenuesTradeDomesticLbl: Label 'Sales revenues trade domestic', MaxLength = 100;
        SalesRevenuesTradeExportLbl: Label 'Sales revenues trade export', MaxLength = 100;
        SalesRevenuesTradeEULbl: Label 'Sales revenues trade EU', MaxLength = 100;
        ProjectSalesLbl: Label 'Project sales', MaxLength = 100;
        ProjectSalesCorrectionLbl: Label 'Project sales correction', MaxLength = 100;
        TotalSalesRevenuesTradeLbl: Label 'Total sales revenues trade', MaxLength = 100;
        SalesRevenuesRawMaterialLbl: Label 'Sales revenues raw material', MaxLength = 100;
        SalesRevenuesRawMaterialDomesticLbl: Label 'Sales revenues raw material domestic', MaxLength = 100;
        SalesRevenuesRawMaterialExportLbl: Label 'Sales revenues raw material export', MaxLength = 100;
        SalesRevenuesRawMaterialEULbl: Label 'Sales revenues raw material EU', MaxLength = 100;
        TotalSalesRevenuesRawMaterialLbl: Label 'Total sales revenues raw material', MaxLength = 100;
        SalesRevenuesResourcesLbl: Label 'Sales revenues resources', MaxLength = 100;
        SalesRevenuesResourcesDomesticLbl: Label 'Sales revenues resources domestic', MaxLength = 100;
        SalesRevenuesResourcesExportLbl: Label 'Sales revenues resources export', MaxLength = 100;
        SalesRevenuesResourcesEULbl: Label 'Sales revenues resources EU', MaxLength = 100;
        TotalSalesRevenuesResourcesLbl: Label 'Total sales revenues resources', MaxLength = 100;
        ProjectRevenuesBeginTotalLbl: Label 'Project revenues - Begin Total', MaxLength = 100;
        ProjectRevenuesLbl: Label 'Project revenues', MaxLength = 100;
        OtherProjectRevenuesLbl: Label 'Other project revenues', MaxLength = 100;
        TotalProjectRevenuesLbl: Label 'Total project revenues', MaxLength = 100;
        RevenuesServiceContractsLbl: Label 'Revenues service contracts', MaxLength = 100;
        RevenueServiceContractLbl: Label 'Revenue service contract', MaxLength = 100;
        TotalServiceContractsLbl: Label 'Total service contracts', MaxLength = 100;
        ChargesAndInterestLbl: Label 'Charges and interest', MaxLength = 100;
        ServiceChargesLbl: Label 'Service charges', MaxLength = 100;
        ServiceInterestLbl: Label 'Service interest', MaxLength = 100;
        ConsultingFeesLbl: Label 'Consulting fees', MaxLength = 100;
        TotalChargesAndInterestLbl: Label 'Total charges and interest', MaxLength = 100;
        TotalRevenuesLbl: Label 'Total revenues', MaxLength = 100;
        RevenueAdjustmentsLbl: Label 'Revenue adjustments', MaxLength = 100;
        RevenueAdjustmentDomestic10Lbl: Label 'Revenue adjustment domestic (10%)', MaxLength = 100;
        RevenueAdjustmentDomestic20Lbl: Label 'Revenue adjustment domestic (20%)', MaxLength = 100;
        RevenueAdjustmentExportLbl: Label 'Revenue adjustment export', MaxLength = 100;
        RevenueAdjustmentEULbl: Label 'Revenue adjustment EU', MaxLength = 100;
        CashDiscountPaidLbl: Label 'Cash discount paid', MaxLength = 100;
        CashDiscountPaidAdjustmentLbl: Label 'Cash discount paid - adjustment', MaxLength = 100;
        TotalRevenueAdjustmentsLbl: Label 'Total revenue adjustments', MaxLength = 100;
        TotalRevenuesAndRevenueReductionLbl: Label 'Total revenues and revenue reduction', MaxLength = 100;
        InventoryChangesBeginTotalLbl: Label 'Inventory changes - Begin Total', MaxLength = 100;
        InventoryChangesLbl: Label 'Inventory changes', MaxLength = 100;
        OwnCostCapitalizedLbl: Label 'Own cost capitalized', MaxLength = 100;
        TotalInventoryChangesLbl: Label 'Total inventory changes', MaxLength = 100;
        OtherOperatingIncomeBeginTotalLbl: Label 'Other operating income - Begin Total', MaxLength = 100;
        ProceedsFromTheSaleOfAssetsLbl: Label 'Proceeds from the sale of assets', MaxLength = 100;
        InsuranceCompensationsLbl: Label 'Insurance compensations', MaxLength = 100;
        IncomeFromTheDisposalOfAssetsLbl: Label 'Income from the disposal of assets', MaxLength = 100;
        IncomeFromTheAppreciationOfIntangibleAssetsLbl: Label 'Income from the appreciation of intangible assets', MaxLength = 100;
        IncomeFromAppreciationOfFixedAssetsLbl: Label 'Income from appreciation of fixed assets', MaxLength = 100;
        IncFromReleaseOfProvisionsForSeverPaymLbl: Label 'Inc. from release of provisions for sever. paym.', MaxLength = 100;
        IncomeFromTheReleaseOfProvForPensionPlanLbl: Label 'Income from the release of prov. for pension plan', MaxLength = 100;
        IncomeFromTheReleaseOfOtherProvisionsLbl: Label 'Income from the release of other provisions', MaxLength = 100;
        OtherOperatingIncomeLbl: Label 'Other operating income', MaxLength = 100;
        OverageOfCashLbl: Label 'Overage of cash', MaxLength = 100;
        BenefitInKindLbl: Label 'Benefit in kind', MaxLength = 100;
        RentalYieldLbl: Label 'Rental yield', MaxLength = 100;
        ExpenseReimbursementLbl: Label 'Expense reimbursement', MaxLength = 100;
        FCYUnrealizedExchangeGainsLbl: Label 'FCY - unrealized exchange gains', MaxLength = 100;
        FCYRealizedExchangeGainsLbl: Label 'FCY - realized exchange gains', MaxLength = 100;
        OtherInsuranceCompensationLbl: Label 'Other insurance compensation', MaxLength = 100;
        IncomeFromReleaseOfLossReservesLbl: Label 'Income from release of loss reserves', MaxLength = 100;
        TotalOtherOperatingIncomeLbl: Label 'Total other operating income', MaxLength = 100;
        TOTALOPERATINGINCOMELbl: Label 'TOTAL OPERATING INCOME', MaxLength = 100;
        COSTOFMATERIALSLbl: Label 'COST OF MATERIALS', MaxLength = 100;
        TradeGoodsLbl: Label 'Trade goods', MaxLength = 100;
        TradeGoodsConsumptionLbl: Label 'Trade goods consumption', MaxLength = 100;
        TradeGoodsInventoryAdjustmentLbl: Label 'Trade goods inventory adjustment', MaxLength = 100;
        TradeGoodsDirectCostLbl: Label 'Trade goods direct cost', MaxLength = 100;
        TradeGoodsOverheadExpensesLbl: Label 'Trade goods overhead expenses', MaxLength = 100;
        TradeGoodsPurchaseVarianceAccountLbl: Label 'Trade goods purchase variance account', MaxLength = 100;
        DiscountReceivedTradeLbl: Label 'Discount received, trade', MaxLength = 100;
        DeliveryExpensesTradeLbl: Label 'Delivery expenses, trade', MaxLength = 100;
        DiscountReceivedRawMaterialsLbl: Label 'Discount received, raw materials', MaxLength = 100;
        DeliveryExpensesRawMaterialLbl: Label 'Delivery expenses, raw material', MaxLength = 100;
        TotalTradeGoodsLbl: Label 'Total trade goods', MaxLength = 100;
        RawMaterialLbl: Label 'Raw material', MaxLength = 100;
        RawMaterialConsumptionLbl: Label 'Raw material consumption', MaxLength = 100;
        RawMaterialInventoryAdjustmentLbl: Label 'Raw material inventory adjustment', MaxLength = 100;
        RawMaterialDirectCostLbl: Label 'Raw material direct cost', MaxLength = 100;
        RawMaterialOverheadExpensesLbl: Label 'Raw material overhead expenses', MaxLength = 100;
        RawMaterialPurchaseVarianceAccountLbl: Label 'Raw material purchase variance account', MaxLength = 100;
        TotalRawMaterialLbl: Label 'Total raw material', MaxLength = 100;
        ProcessingLbl: Label 'Processing', MaxLength = 100;
        ProcessingConsumptionLbl: Label 'Processing consumption', MaxLength = 100;
        ProcessingInventoryAdjustmentLbl: Label 'Processing inventory adjustment', MaxLength = 100;
        ProcessingOverheadExpensesLbl: Label 'Processing overhead expenses', MaxLength = 100;
        ProcessingPurchaseVarianceAccountLbl: Label 'Processing purchase variance account', MaxLength = 100;
        TotalProcessingLbl: Label 'Total processing', MaxLength = 100;
        ProjectsLbl: Label 'Projects', MaxLength = 100;
        ProjectCostsLbl: Label 'Project costs', MaxLength = 100;
        ProjectCostsAllocatedLbl: Label 'Project costs allocated', MaxLength = 100;
        ProjectCostsCorrectionLbl: Label 'Project costs correction', MaxLength = 100;
        TotalProjectsLbl: Label 'Total projects', MaxLength = 100;
        VarianceLbl: Label 'Variance', MaxLength = 100;
        MaterialVarianceLbl: Label 'Material variance', MaxLength = 100;
        CapacityVarianceLbl: Label 'Capacity variance', MaxLength = 100;
        SubcontractedVarianceLbl: Label 'Subcontracted variance', MaxLength = 100;
        CapOverheadVarianceLbl: Label 'Cap. overhead variance', MaxLength = 100;
        ManufacturingOverheadVarianceLbl: Label 'Manufacturing overhead variance', MaxLength = 100;
        TotalVarianceLbl: Label 'Total variance', MaxLength = 100;
        ConsumptionLbl: Label 'Consumption', MaxLength = 100;
        AuxiliariesConsumptionLbl: Label 'Auxiliaries consumption', MaxLength = 100;
        PackagingMaterialConsumptionLbl: Label 'Packaging material consumption', MaxLength = 100;
        OperatingMaterialsConsumptionLbl: Label 'Operating materials consumption', MaxLength = 100;
        CleaningMaterialsConsumptionLbl: Label 'Cleaning materials consumption', MaxLength = 100;
        ConsumptionOfIncidentalsLbl: Label 'Consumption of incidentals', MaxLength = 100;
        ConsumptionOfFuelsLbl: Label 'Consumption of fuels', MaxLength = 100;
        TotalConsumptionLbl: Label 'Total consumption', MaxLength = 100;
        PurchaseCurrentMaterialLbl: Label 'Purchase current material', MaxLength = 100;
        PurchaseTradeDomesticLbl: Label 'Purchase trade domestic', MaxLength = 100;
        PurchaseTradeImportLbl: Label 'Purchase trade import', MaxLength = 100;
        PurchaseTradeEULbl: Label 'Purchase trade EU', MaxLength = 100;
        PurchaseRawMaterialsDomesticLbl: Label 'Purchase raw materials domestic', MaxLength = 100;
        PurchaseRawMaterialsImportLbl: Label 'Purchase raw materials import', MaxLength = 100;
        PurchaseRawMaterialsEULbl: Label 'Purchase raw materials EU', MaxLength = 100;
        TotalPurchaseActiveMaterialLbl: Label 'Total purchase active material', MaxLength = 100;
        OtherServicesReceivedLbl: Label 'Other services received', MaxLength = 100;
        ServicesReceivedLbl: Label 'Services received', MaxLength = 100;
        ServiceChargesPurchaseLbl: Label 'Service charges purchase', MaxLength = 100;
        TotalOtherServicesLbl: Label 'Total other services', MaxLength = 100;
        PaymentDiscountRevenueBeginTotalLbl: Label 'Payment discount revenue - Begin Total', MaxLength = 100;
        PaymentDiscountRevenueLbl: Label 'Payment discount revenue', MaxLength = 100;
        PaymentDiscountRevenueCorrectionLbl: Label 'Payment discount revenue - correction', MaxLength = 100;
        TotalPaymentDiscountRevenueLbl: Label 'Total payment discount revenue', MaxLength = 100;
        TOTALCOSTOFMATERIALSLbl: Label 'TOTAL COST OF MATERIALS', MaxLength = 100;
        WagesWithoutServicesLbl: Label 'Wages without services', MaxLength = 100;
        TotalWagesLbl: Label 'Total wages', MaxLength = 100;
        SalariesWithoutServicesLbl: Label 'Salaries without services', MaxLength = 100;
        TotalSalariesLbl: Label 'Total salaries', MaxLength = 100;
        SeverancePaymentsBeginTotalLbl: Label 'Severance payments - Begin Total', MaxLength = 100;
        SeverancePaymentsLbl: Label 'Severance payments', MaxLength = 100;
        SeverancePaymentProvisionFundLbl: Label 'Severance payment provision fund', MaxLength = 100;
        PensionsPaymentsLbl: Label 'Pensions payments', MaxLength = 100;
        PensionProvisionFundLbl: Label 'Pension provision fund', MaxLength = 100;
        TotalSeverancePaymentsLbl: Label 'Total severance payments', MaxLength = 100;
        StatutorySocialExpensesLbl: Label 'Statutory social expenses', MaxLength = 100;
        StatutorySocialExpensesWorkerLbl: Label 'Statutory social expenses worker', MaxLength = 100;
        StatutorySocialExpensesEmployeeLbl: Label 'Statutory social expenses employee', MaxLength = 100;
        TotalStatutorySocialExpensesLbl: Label 'Total statutory social expenses', MaxLength = 100;
        OtherSocialExpensesLbl: Label 'Other social expenses', MaxLength = 100;
        LocalTaxLbl: Label 'Local tax', MaxLength = 100;
        GDContributionFamilyAllowanceProfitLbl: Label 'GD contribution family allowance (Profit)', MaxLength = 100;
        AdditionToProfitLbl: Label 'Addition to profit', MaxLength = 100;
        LevyForTheEmployerViennaLbl: Label 'Levy for the employer Vienna', MaxLength = 100;
        VoluntarySocialExpensesLbl: Label 'Voluntary social expenses', MaxLength = 100;
        CostCenterSettlementSocialExpenseLbl: Label 'Cost center settlement Social Exp.', MaxLength = 100;
        TotalOtherSocialExpensesLbl: Label 'Total other social expenses', MaxLength = 100;
        DEPRECIATIONOTHERCOSTOFOPERATIONSLbl: Label 'DEPRECIATION,OTHER COST OF OPERATIONS', MaxLength = 100;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
        ScheduledAmortizationOnIntangibleAssetsLbl: Label 'Scheduled amortization on intangible assets', MaxLength = 100;
        UnscheduledAmortizationOnIntangibleAssetsLbl: Label 'Unscheduled amortization on intangible assets', MaxLength = 100;
        ScheduledDepreciationOfFixedAssetsLbl: Label 'Scheduled depreciation of fixed assets', MaxLength = 100;
        ScheduledDepreciationVehiclesLbl: Label 'Scheduled depreciation vehicles', MaxLength = 100;
        UnscheduledDepreciationOfFixedAssetsLbl: Label 'Unscheduled depreciation of fixed assets', MaxLength = 100;
        LowValueAssetsLbl: Label 'Low-value assets', MaxLength = 100;
        TotalDepreciationLbl: Label 'Total depreciation', MaxLength = 100;
        OtherTaxesLbl: Label 'other taxes', MaxLength = 100;
        PropertyTaxLbl: Label 'Property tax', MaxLength = 100;
        BeverageAndAlcoholTaxLbl: Label 'Beverage and alcohol tax', MaxLength = 100;
        ChargesAndRevenueStampsLbl: Label 'Charges and revenue stamps', MaxLength = 100;
        MiscOtherTaxesLbl: Label 'Misc. other taxes', MaxLength = 100;
        TotalOtherTaxesLbl: Label 'Total other taxes', MaxLength = 100;
        MaintenanceCleaningEtcLbl: Label 'Maintenance, cleaning, etc.', MaxLength = 100;
        ThirdPartyMaintenanceLbl: Label 'Third-party maintenance', MaxLength = 100;
        CarOperatingExpensesLbl: Label 'Car operating expenses', MaxLength = 100;
        TruckOperatingExpensesLbl: Label 'Truck operating expenses', MaxLength = 100;
        CarRepairsAndMaintenanceLbl: Label 'Car repairs and maintenance', MaxLength = 100;
        FuelLbl: Label 'Fuel', MaxLength = 100;
        TotalMaintenanceEtcLbl: Label 'Total maintenance, etc.', MaxLength = 100;
        TransportationTravelCommunicationsLbl: Label 'Transportation, travel, communications', MaxLength = 100;
        TransportationThirdPartiesLbl: Label 'Transportation third parties', MaxLength = 100;
        TravelExpensesDomesticLbl: Label 'Travel expenses - domestic', MaxLength = 100;
        TravelExpensesAbroadLbl: Label 'Travel expenses - abroad', MaxLength = 100;
        KilometerAllowanceLbl: Label 'Kilometer allowance', MaxLength = 100;
        MealExpensesDomesticLbl: Label 'Meal expenses domestic', MaxLength = 100;
        MealExpensesAbroadLbl: Label 'Meal expenses abroad', MaxLength = 100;
        HotelExpensesDomesticLbl: Label 'Hotel expenses domestic', MaxLength = 100;
        HotelExpensesAbroadLbl: Label 'Hotel expenses abroad', MaxLength = 100;
        CommunicationChargesLbl: Label 'Communication charges', MaxLength = 100;
        TotalTransportationExpensesLbl: Label 'Total transportation expenses', MaxLength = 100;
        RentalsLeasingBeginTotalLbl: Label 'Rentals, leasing - Begin Total', MaxLength = 100;
        RentalsLeasingLbl: Label 'Rentals, leasing', MaxLength = 100;
        TotalRentalsLeasingEtcLbl: Label 'Total rentals, leasing, etc.', MaxLength = 100;
        CommissionsLbl: Label 'Commissions', MaxLength = 100;
        CommissionsForThirdPartiesLbl: Label 'Commissions for third parties', MaxLength = 100;
        TotalCommissionsLbl: Label 'Total commissions', MaxLength = 100;
        OfficeAdvertisingAndMaintenanceExpenditureLbl: Label 'Office, advertising and maintenance expenditure', MaxLength = 100;
        PhoneAndInternetChargesLbl: Label 'Phone and internet charges', MaxLength = 100;
        ExternalServicesLbl: Label 'External Services', MaxLength = 100;
        DeductibleAdvertisingExpensesLbl: Label 'Deductible advertising expenses', MaxLength = 100;
        NonDeductibleAdvertisingExpensesLbl: Label 'Non-deductible advertising expenses', MaxLength = 100;
        HospitalityDomesticDeductibleAmountLbl: Label 'Hospitality domestic deductible amount', MaxLength = 100;
        HospitalityDomesticNonDeductibleAmountLbl: Label 'Hospitality domestic non-deductible amount', MaxLength = 100;
        HospitalityAbroadDeductibleAmountLbl: Label 'Hospitality abroad deductible amount', MaxLength = 100;
        HospitalityAbroadNonDeductibleAmountLbl: Label 'Hospitality abroad non-deductible amount', MaxLength = 100;
        DonationsAndTipsLbl: Label 'Donations and tips', MaxLength = 100;
        TotalOfficeAdvertisingMaintenanceExpenditureLbl: Label 'Total office/advertising/maintenance expenditure', MaxLength = 100;
        InsurancesAndOtherExpensesLbl: Label 'Insurances and other expenses', MaxLength = 100;
        InsuranceExpensesLbl: Label 'Insurance expenses', MaxLength = 100;
        LegalAndConsultancyExpensesLbl: Label 'Legal and consultancy expenses', MaxLength = 100;
        ProvisionForLegalAndConsultancyExpensesFundLbl: Label 'Provision for legal and consultancy expenses fund', MaxLength = 100;
        OtherLbl: Label 'Other', MaxLength = 100;
        TechnicalLiteratureLbl: Label 'Technical literature', MaxLength = 100;
        ExpenditureEducationAndTrainingLbl: Label 'Expenditure education and training', MaxLength = 100;
        ChamberContributionLbl: Label 'Chamber contribution', MaxLength = 100;
        ExpensesThroughCirculationOfMoneyLbl: Label 'Expenses through circulation of money', MaxLength = 100;
        DepreciationOfSuppliesLbl: Label 'Depreciation of supplies', MaxLength = 100;
        DepreciationExportReceivablesLbl: Label 'Depreciation export receivables', MaxLength = 100;
        DepreciationDomesticReceivablesLbl: Label 'Depreciation domestic receivables', MaxLength = 100;
        IndividualLossReservesForReceivablesLbl: Label 'Individual loss reserves for receivables ', MaxLength = 100;
        BlanketLossReservesForReceivablesLbl: Label 'Blanket loss reserves for receivables ', MaxLength = 100;
        BookValueDisposalOfAssetsLbl: Label 'Book value disposal of assets', MaxLength = 100;
        LossesFromDisposalOfAssetsLbl: Label 'Losses from disposal of assets', MaxLength = 100;
        OtherOperationalExpenditureLbl: Label 'Other operational expenditure', MaxLength = 100;
        ProvisionForWarrantiesFundLbl: Label 'Provision for warranties fund', MaxLength = 100;
        ProvisionForCompensationForDamagesFundLbl: Label 'Provision for compensation for damages fund', MaxLength = 100;
        ProvisionForProductLiabilityFundLbl: Label 'Provision for product liability fund', MaxLength = 100;
        MiscProvisionsFundLbl: Label 'Misc. provisions fund', MaxLength = 100;
        CashDeficitLbl: Label 'Cash deficit', MaxLength = 100;
        FCYUnrealizedExchangeLossesLbl: Label 'FCY - unrealized exchange losses', MaxLength = 100;
        FCYRealizedExchangeLossesLbl: Label 'FCY - realized exchange losses', MaxLength = 100;
        PaymentDiscountRevenue0VATLbl: Label 'Payment discount revenue (0% VAT)', MaxLength = 100;
        CostCenterSettlementInsuranceLbl: Label 'Cost center settlement Insurance', MaxLength = 100;
        TotalInsuranceAndOtherExpendituresLbl: Label 'Total insurance and other expenditures', MaxLength = 100;
        TOTALDEPRECIATIONOPERATIONALEXPENDITURELbl: Label 'TOTAL DEPRECIATION, OPERATIONAL EXPENDITURE', MaxLength = 100;
        FINANCIALREVENUESANDEXPENDITURESBeginTotalLbl: Label 'FINANCIAL REVENUES AND EXPENDITURES - BeginTotal', MaxLength = 100;
        FINANCIALREVENUESANDEXPENDITURESLbl: Label 'FINANCIAL REVENUES AND EXPENDITURES', MaxLength = 100;
        IncomeFromEquityInterestsLbl: Label 'Income from equity interests', MaxLength = 100;
        InterestFromBankDepositsLbl: Label 'Interest from bank deposits', MaxLength = 100;
        InterestFromLoansGrantedLbl: Label 'Interest from loans granted', MaxLength = 100;
        PassThroughDiscountRatesLbl: Label 'Pass through discount rates', MaxLength = 100;
        IncomeFromDefaultInterestAndExpensesLbl: Label 'Income from default interest and expenses', MaxLength = 100;
        OtherInterestIncomeLbl: Label 'Other interest income', MaxLength = 100;
        InterestIncomeFromFixedRateSecuritiesLbl: Label 'Interest income from fixed-rate securities', MaxLength = 100;
        OtherSecuritiesIncomeLbl: Label 'Other securities income', MaxLength = 100;
        ProceedsFromTheDispOfOtherFinancialAssetsLbl: Label 'Proceeds from the disp. of other financial assets', MaxLength = 100;
        PmtTolReceivedDecreasesCorrectionLbl: Label 'Pmt. tol. received decreases - correction', MaxLength = 100;
        IncomeFromAppreciationOfFinancialAssetsLbl: Label 'Income from appreciation of financial assets', MaxLength = 100;
        IncomeFromAppreciationOfMarketableSecuritiesLbl: Label 'Income from appreciation of marketable securities', MaxLength = 100;
        DepreciationOtherFinancialAssetsLbl: Label 'Depreciation other financial assets', MaxLength = 100;
        DepreciationOfMarketableSecuritiesLbl: Label 'Depreciation of marketable securities', MaxLength = 100;
        LossFromDisposalOfOtherFinancialAssetsLbl: Label 'Loss from disposal of other financial assets', MaxLength = 100;
        InterestExpenseForBankLoansLbl: Label 'Interest expense for bank loans', MaxLength = 100;
        UnscheduledDepreciationOfFinancialAssetsLbl: Label 'Unscheduled depreciation of financial assets', MaxLength = 100;
        InterestExpenditureForLoansLbl: Label 'Interest expenditure for loans', MaxLength = 100;
        DepreciationActivatedFundsAcquisitionCostLbl: Label 'Depreciation activated funds acquisition cost', MaxLength = 100;
        DiscountInterestExpenditureLbl: Label 'Discount interest - expenditure', MaxLength = 100;
        DefaultInterestExpensesLbl: Label 'Default interest - expenses', MaxLength = 100;
        UnusedDeliveryDiscountsLbl: Label 'unused delivery discounts', MaxLength = 100;
        PmtTolGrantedDecreasesCorrectionLbl: Label 'Pmt. Tol. Granted Decreases - correction', MaxLength = 100;
        TotalFinancialIncomeAndExpensesEndTotalLbl: Label 'Total financial income and expenses End Total', MaxLength = 100;
        NonRecurringIncomeNonRecurringExpensesLbl: Label 'Non-recurring income,Non-recurring expenses', MaxLength = 100;
        NonRecurringIncomeLbl: Label 'Non-recurring income ', MaxLength = 100;
        NonRecurringExpensesLbl: Label 'Non-recurring expenses', MaxLength = 100;
        TaxesBeforeIncomeAndEarningsLbl: Label 'Taxes before income and earnings', MaxLength = 100;
        CapitalReturnsTaxLbl: Label 'Capital returns tax', MaxLength = 100;
        TotalTaxBeforeIncomeLbl: Label 'Total tax before income', MaxLength = 100;
        ChangesInReservesLbl: Label 'Changes in reserves', MaxLength = 100;
        GainsFromReversalOfUntaxedReservesLbl: Label 'Gains from reversal of untaxed reserves', MaxLength = 100;
        GainsFromReversalOfValuationReservesLbl: Label 'Gains from reversal of valuation reserves', MaxLength = 100;
        AssignmentReservesAccordingTo10EstgIFBLbl: Label 'Assignment Reserves according to § 10 EStG (IFB)', MaxLength = 100;
        AssignmentRLAccordingTo12EstgLbl: Label 'Assignment RL according to § 12 EStG', MaxLength = 100;
        AssignmentToValuationReservesLbl: Label 'Assignment to valuation reserves', MaxLength = 100;
        TotalChangeInReservesLbl: Label 'Total change in reserves', MaxLength = 100;
        TOTALFINANCIALINCOMEANDEXPENSESLbl: Label 'TOTAL FINANCIAL INCOME AND EXPENSES', MaxLength = 100;
        EQUITYRESERVESLbl: Label 'EQUITY, RESERVES, ...', MaxLength = 100;
        EquityLbl: Label 'Equity', MaxLength = 100;
        TaxProvisionsLbl: Label 'Tax provisions', MaxLength = 100;
        FreeReservesLbl: Label 'Free reserves', MaxLength = 100;
        NetProfitNetLossLbl: Label 'Net profit/net loss', MaxLength = 100;
        ValuationReservesForLbl: Label 'Valuation reserves for...', MaxLength = 100;
        ReservesAccordingTo10EstgIFBLbl: Label 'Reserves according to § 10 EStG (IFB)', MaxLength = 100;
        ReservesAccordingTo12EstgLbl: Label 'Reserves according to § 12 EStG', MaxLength = 100;
        PrivateLbl: Label 'Private', MaxLength = 100;
        EBKLbl: Label 'EBK', MaxLength = 100;
        SBKLbl: Label 'SBK', MaxLength = 100;
        ProfitAndLossStatementLbl: Label 'Profit and loss statement', MaxLength = 100;
        TOTALEQUITYRESERVESLbl: Label 'TOTAL EQUITY, RESERVES', MaxLength = 100;
        FinishedGoodsBeginTotalLbl: Label 'Finished Goods - BeginTotal', MaxLength = 100;
        WagesBeginTotalLbl: Label 'Wages - BeginTotal', MaxLength = 100;
        SalariesBeginTotalLbl: Label 'Salaries - BeginTotal', MaxLength = 100;
}