codeunit 11616 "Create CH VAT Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateVATProductPostingGroup();
        CreateVATPostingSetup();
    end;

    local procedure CreateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingSetup.InsertVATPostingSetup('', NOVAT(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Normal(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', OperatingExpense(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Reduced(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), HalfNormal(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), 'D', 3.66089, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Hotel(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'C', 3.6, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Import(), '', CreateCHGLAccounts.PurchVatOnImports100Percent(), 'H', 100, Enum::"Tax Calculation Type"::"Full VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NOVAT(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Normal(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'A', 8, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), OperatingExpense(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), 'A', 8, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Reduced(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'B', 2.4, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Hotel(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NOVAT(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Normal(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), OperatingExpense(), '', CreateCHGLAccounts.PurchVatInvOperatingExp(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Reduced(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NOVAT(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Normal(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), OperatingExpense(), '', CreateCHGLAccounts.PurchVatInvOperatingExp(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Reduced(), CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), 'Z', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        UpdateAdjustforPaymentDiscountOnVATPostingSetup();
    end;

    procedure CreateVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateCHPostingGroups: Codeunit "Create CH Posting Groups";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(HalfNormal(), HalfStandardRateLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Hotel(), HotelsLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Import(), ImportFullTaxLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), TaxExemptLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Normal(), NormalVATRateLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(OperatingExpense(), VATOperatingExpensesLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Reduced(), ReducedRateLbl);

        CreateCHPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroup.RawMatPostingGroup(), Normal());
        CreateCHPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroup.RetailPostingGroup(), Normal());
        CreateCHPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroup.MiscPostingGroup(), Normal());
        CreateCHPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroup.ServicesPostingGroup(), Normal());
        CreateCHPostingGroups.UpdateVATProdPostingGroup(CreateCHPostingGroups.NoVATPostingGroup(), NOVAT());

        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PurchVatOnImports100Percent(), Import());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.VendorPrepaymentsVat80Percent(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MachinesAndEquipment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.BusinessFurniture(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.OfficeMachines(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ItHardwareAndSoftware(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateGLAccount.Vehicles(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.VehiclesEquipment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PatentsKnowledgeRecipes(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.BrandsPrototypesModelsPlans(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CustomerPrepaymentsVat0Percent(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CustomerPrepaymentsVat80Percent(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ProdEarningsDomestic(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ProdEarningsEurope(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ProdEarningsInternat(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TradeDomestic(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TradeEurope(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TradeInternat(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ServiceEarningsDomestic(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ServiceEarningsEurope(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ServiceEarningsInternat(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ProjectEarnings(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.JobSalesAppliedAccount(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ConsultancyEarnings(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CashDiscounts(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.Discounts(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.RoundingDifferencesSales(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfMaterialDomestic(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfMaterialsEurope(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfMaterialsInternat(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfCommGoodsDomestic(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfCommGoodsEurope(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfCommGoodsIntl(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.SubcontrOfSpOperations(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateGLAccount.JobCosts(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.JobCostsWip(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.EnergyCostsCOGS(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PackagingCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.DirectPurchCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PurchaseDisc(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CostReductionDiscount(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.RoundingDifferencesPurchase(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MaintProductionPlants(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MaintSalesEquipment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MaintStorageFacilities(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MaintOfficeEquipment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.LeasingMobileFixedAssets(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.VehicleMaint(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.OpMaterials(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AutoInsurance(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TransportTaxRates(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TransportCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ShippingChargeCustomer(), Normal());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PropertyInsurance(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.OperatingLiability(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.DowntimeInsurance(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TaxRates(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PermitsPatents(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.EnergyCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.WasteCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AdministrativeCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.OfficeMatPrintSupplies(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TechDoc(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.CommunicationTelephone(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateGLAccount.Postage(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.Deductions(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AccountingConsultancy(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.BoardOfDirectorsGvRevision(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.InformationCosts(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ItLeasing(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ItProgramLicensesMaint(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ItSupplies(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ConsultingAndDevelopment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AdvertisementsAndMedia(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AdMaterials(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.Exhibits(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.TravelCostsCustomerService(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AdvertContribSponsoring(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.PublicRelationsPr(), NOVAT());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.AdConsultancyMarketAnaly(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.EconomicInformation(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.OperReliabilityMonitoring(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.ResearchAndDevelopment(), OperatingExpense());
        UpdateVATProductPostingGroupOnGLAccount(CreateCHGLAccounts.MiscCosts(), OperatingExpense());

        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.ProdEarningsEurope(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.ProdEarningsInternat(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.TradeEurope(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.TradeInternat(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.ServiceEarningsEurope(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.ServiceEarningsInternat(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.CostofMaterialsEurope(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.CostofMaterialsInternat(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.CostofCommGoodsEurope(), CreateVATPostingGroups.Export());
        UpdateVATBusPostingGroupOnGLAccount(CreateCHGLAccounts.CostOfCommGoodsIntl(), CreateVATPostingGroups.Export());
    end;

    local procedure UpdateVATProductPostingGroupOnGLAccount(GLAccountNo: Code[20]; VATProductPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(GLAccountNo) then
            exit;

        GLAccount.Validate("VAT Prod. Posting Group", VATProductPostingGroup);
        GLAccount.Modify(true);
    end;

    local procedure UpdateVATBusPostingGroupOnGLAccount(GLAccountNo: Code[20]; VATBusPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(GLAccountNo) then
            exit;

        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATPostingSetup(var Rec: Record "VAT Posting Setup")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        UpdateAdjustforPaymentDiscountOnGeneralLedgerSetup();

        case Rec."VAT Bus. Posting Group" of
            CreateVATPostingGroups.Domestic(),
            CreateVATPostingGroups.EU(),
            CreateVATPostingGroups.Export(),
            '':
                begin
                    Rec.Validate("Adjust for Payment Discount", false);
                    Rec.Validate(Description, '');
                end;
        end;
    end;

    local procedure UpdateAdjustforPaymentDiscountOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GeneralLedgerSetup.Get();

        if not GeneralLedgerSetup."Adjust for Payment Disc." then
            exit;

        if VATPostingSetup.Get('', '') then begin
            VATPostingSetup.Validate("Adjust for Payment Discount", false);
            VATPostingSetup.Modify(true);

            GeneralLedgerSetup.Validate("Adjust for Payment Disc.", false);
            GeneralLedgerSetup.Modify(true);
        end;
    end;

    local procedure UpdateAdjustforPaymentDiscountOnVATPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup."Adjust for Payment Discount" := true;
                VATPostingSetup.Modify(true);
            until VATPostingSetup.Next() = 0;
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure HalfNormal(): Code[20]
    begin
        exit(HalfNormalTok);
    end;

    procedure Hotel(): Code[20]
    begin
        exit(HotelTok);
    end;

    procedure Import(): Code[20]
    begin
        exit(ImportTok);
    end;

    procedure Normal(): Code[20]
    begin
        exit(NormalTok);
    end;

    procedure OperatingExpense(): Code[20]
    begin
        exit(OperatingExpenseTok);
    end;

    procedure Reduced(): Code[20]
    begin
        exit(ReducedTok);
    end;


    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        HalfNormalTok: Label 'HALF NORM', MaxLength = 20, Locked = true;
        HotelTok: Label 'HOTEL', MaxLength = 20, Locked = true;
        ImportTok: Label 'IMPORT', MaxLength = 20, Locked = true;
        NormalTok: Label 'NORMAL', MaxLength = 20, Locked = true;
        OperatingExpenseTok: Label 'OPEXP', MaxLength = 20, Locked = true;
        ReducedTok: Label 'RED', MaxLength = 20, Locked = true;
        HalfStandardRateLbl: Label 'Half Standard Rate', MaxLength = 100;
        NormalVATRateLbl: Label 'Normal VAT Rate, 8.0%', MaxLength = 100;
        HotelsLbl: Label 'Hotels, 3.6%', MaxLength = 100;
        ImportFullTaxLbl: Label 'Import, Full Tax 100%', MaxLength = 100;
        VATOperatingExpensesLbl: Label 'Purch. VAT Operating Expenses 8.0%', MaxLength = 100;
        ReducedRateLbl: Label 'Reduced Rate, 2.4%', MaxLength = 100;
        TaxExemptLbl: Label 'Tax Exempt', MaxLength = 100;
}