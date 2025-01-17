codeunit 18786 "Library-TDS"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";

    procedure CreateTDSSetup(
        var Vendor: Record Vendor;
        var TDSPostingSetup: Record "TDS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TDSSection: Record "TDS Section";
    begin
        CreateCommonSetup(AssesseeCode, ConcessionalCode);
        CreateTDSPostingSetupWithSection(TDSPostingSetup, TDSSection);
        CreateTDSVendor(Vendor, AssesseeCode.Code, TDSSection.Code);
        AttachConcessionalWithVendor(Vendor."No.", ConcessionalCode.Code, TDSSection.Code);
    end;

    procedure UpdateVendorWithPANWithConcessional(
        var Vendor: Record Vendor;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        Vendor.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Vendor.FieldNo("P.A.N. No."), Database::Vendor));
        Vendor.Modify(true);
        UpdateTDSSectionOnVendor(Vendor."No.", ThresholdOverlook, SurchargeOverlook);
    end;

    procedure UpdateVendorWithPANWithOutConcessional(
        var Vendor: Record Vendor;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        TDSConcessionalCode: Record "TDS Concessional Code";
    begin
        Vendor.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Vendor.FieldNo("P.A.N. No."), Database::Vendor));
        Vendor.Modify(true);
        UpdateTDSSectionOnVendor(Vendor."No.", ThresholdOverlook, SurchargeOverlook);

        TDSConcessionalCode.SetRange("Vendor No.", Vendor."No.");
        TDSConcessionalCode.DeleteAll(true);
    end;

    procedure UpdateVendorWithoutPANWithConcessional(
        var Vendor: Record Vendor;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        Vendor.Validate("P.A.N. Status", Vendor."P.A.N. Status"::PANAPPLIED);
        Vendor.Validate("P.A.N. Reference No.", LibraryRandom.RandText(10));
        Vendor.Modify(true);
        UpdateTDSSectionOnVendor(Vendor."No.", ThresholdOverlook, SurchargeOverlook);
    end;

    procedure UpdateVendorWithoutPANWithoutConcessional(
        var Vendor: Record Vendor;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        TDSConcessionalCode: Record "TDS Concessional Code";
    begin
        Vendor.Validate("P.A.N. Status", Vendor."P.A.N. Status"::PANAPPLIED);
        Vendor.Validate("P.A.N. Reference No.", LibraryRandom.RandText(10));
        Vendor.Modify(true);
        UpdateTDSSectionOnVendor(Vendor."No.", ThresholdOverlook, SurchargeOverlook);

        TDSConcessionalCode.SetRange("Vendor No.", Vendor."No.");
        TDSConcessionalCode.DeleteAll(true);
    end;

    procedure AttachConcessionalWithVendor(
        VendorNo: Code[20];
        ConcessionalCode: Code[10];
        TDSSection: Code[10])
    var
        TDSConcessionalCode: Record "TDS Concessional Code";
    begin
        TDSConcessionalCode.Init();
        TDSConcessionalCode.Validate("Vendor No.", VendorNo);
        TDSConcessionalCode.Validate(Section, TDSSection);
        TDSConcessionalCode.Validate("Concessional Code", ConcessionalCode);
        TDSConcessionalCode.Validate("Certificate No.", LibraryUtility.GenerateRandomCode(TDSConcessionalCode.FieldNo("Certificate No."),
            Database::"TDS Concessional Code"));
        TDSConcessionalCode.Insert(true);
    end;

    procedure CreateAssesseeCode(var AssesseeCode: Record "Assessee Code")
    begin
        AssesseeCode.Init();
        AssesseeCode.Validate(Code, LibraryUtility.GenerateRandomCode(AssesseeCode.FieldNo(Code), Database::"Assessee Code"));
        AssesseeCode.Validate(Description, AssesseeCode.Code);
        AssesseeCode.Insert(true);
    end;

    procedure CreateTANNo(): Code[10]
    var
        TANNos: Record "TAN Nos.";
    begin
        TANNos.Init();
        TANNos.Validate(Code, LibraryUtility.GenerateRandomCode(TANNos.FieldNo(Code), Database::"TAN Nos."));
        TANNos.Validate(Description, TANNos.Code);
        TANNos.Insert(true);
        exit(TANNos.Code);
    end;

    procedure CreateTDSSection(var TDSSection: Record "TDS Section")
    begin
        TDSSection.Init();
        TDSSection.Validate(Code,
            CopyStr(
            LibraryUtility.GenerateRandomCode(TDSSection.FieldNo(Code), Database::"TDS Section"),
            1, LibraryUtility.GetFieldLength(Database::"TDS Section", TDSSection.FieldNo(Code))));
        TDSSection.Validate(Description, TDSSection.Code);
        TDSSection.Validate(ecode,
            CopyStr(
            LibraryUtility.GenerateRandomCode(TDSSection.FieldNo(Code), Database::"TDS Section"),
            1, LibraryUtility.GetFieldLength(Database::"TDS Section", TDSSection.FieldNo(Code))));
        TDSSection.Insert(true);
    end;

    procedure AttachSectionWithVendor(
        Section: Code[10];
        VendorNo: Code[20];
        DefaultSection: Boolean;
        SurchargeOverLook: Boolean;
        ThresholdOverlook: Boolean)
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.Init();
        AllowedSections.Validate("Vendor No", VendorNo);
        AllowedSections.Validate("TDS Section", Section);
        AllowedSections.Validate("Default Section", DefaultSection);
        AllowedSections.Validate("Surcharge Overlook", SurchargeOverLook);
        AllowedSections.Validate("Threshold Overlook", ThresholdOverlook);
        AllowedSections.Insert(true);
    end;

    procedure CreateTDSPostingSetup(var TDSPostingSetup: Record "TDS Posting Setup"; TDSSection: Code[20])
    begin
        TDSPostingSetup.Init();
        TDSPostingSetup.Validate("TDS Section", TDSSection);
        TDSPostingSetup.Validate("Effective Date", WorkDate());
        TDSPostingSetup.Validate("TDS Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        TDSPostingSetup.Insert(true);
    end;

    procedure CreateTDSPostingSetupWithSection(
        var TDSPostingSetup: Record "TDS Posting Setup";
        var TDSSection: Record "TDS Section")
    begin
        CreateTDSSection(TDSSection);
        CreateTDSPostingSetup(TDSPostingSetup, TDSSection.Code);
    end;

    procedure CreateNatureOfRemittance(var TDSNatureOfRemittance: Record "TDS Nature of Remittance")
    begin
        TDSNatureOfRemittance.Init();
        TDSNatureOfRemittance.Validate(Code,
            LibraryUtility.GenerateRandomCode(TDSNatureOfRemittance.FieldNo(Code), Database::"TDS Nature of Remittance"));
        TDSNatureOfRemittance.Validate(Description, LibraryUtility.GenerateRandomText(50));
        TDSNatureOfRemittance.Insert(true);
    end;

    procedure CreateActApplicable(var ActApplicable: Record "Act Applicable")
    begin
        ActApplicable.Init();
        ActApplicable.Validate(Code,
            LibraryUtility.GenerateRandomCode(ActApplicable.FieldNo(Code), Database::"Act Applicable"));
        ActApplicable.Validate(Description, LibraryUtility.GenerateRandomText(50));
        ActApplicable.Insert(true);
    end;

    procedure AttachSectionWithForeignVendor(
        Section: Code[10];
        VendorNo: Code[20];
        DefaultSection: Boolean;
        SurchargeOverLook: Boolean;
        ThresholdOverlook: Boolean;
        NonResidentPayments: Boolean;
        NatureofRemittance: Code[10];
        ActApplicable: Code[10])
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.SetRange("Vendor No", VendorNo);
        AllowedSections.SetRange("TDS Section", Section);
        if AllowedSections.FindFirst() then begin
            AllowedSections.Validate("Non Resident Payments", NonResidentPayments);
            AllowedSections.Validate("Nature of Remittance", NatureofRemittance);
            AllowedSections.Validate("Act Applicable", ActApplicable);
            AllowedSections.Modify(true);
        end;
    end;

    procedure CreateForeignVendorWithPANNoandWithoutConcessional(var Vendor: Record Vendor)
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        ActApplicable: Record "Act Applicable";
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        CreateNatureOfRemittance(TDSNatureOfRemittance);
        CreateActApplicable(ActApplicable);
        LibraryERM.CreateCountryRegion(CountryRegion);
        vendor.Validate("Currency Code", CreateCurrencyCode());
        Vendor.Validate("P.A.N. No.",
            LibraryUtility.GenerateRandomCode(Vendor.FieldNo("P.A.N. No."), Database::Vendor));
        Vendor.Validate("Country/Region Code", CountryRegion.Code);
        Vendor.Modify(true);
    end;

    procedure CreateForeignVendorWithoutPANNoandWithoutConcessional(var Vendor: Record Vendor)
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        ActApplicable: Record "Act Applicable";
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        CreateNatureOfRemittance(TDSNatureOfRemittance);
        CreateActApplicable(ActApplicable);
        LibraryERM.CreateCountryRegion(CountryRegion);
        Vendor.Validate("Currency Code", CreateCurrencyCode());
        Vendor.Validate("P.A.N. Status", Vendor."P.A.N. Status"::PANAPPLIED);
        Vendor.Validate("P.A.N. Reference No.", LibraryRandom.RandText(10));
        Vendor.Validate("Country/Region Code", CountryRegion.Code);
        Vendor.Modify(true);
    end;

    procedure CreateConcessionalCode(var ConCode: Record "Concessional Code")
    begin
        ConCode.Init();
        ConCode.Validate(
            Code,
            CopyStr(
            LibraryUtility.GenerateRandomCode(ConCode.FieldNo(Code), Database::"TDS Concessional Code"),
            1, LibraryUtility.GetFieldLength(Database::"TDS Concessional Code", ConCode.FieldNo(Code))));
        ConCode.Validate(Description, ConCode.Code);
        ConCode.Insert(true)
    end;

    procedure CreateTDSPostingSetupWithDifferentEffectiveDate(
        TDSSectionCode: Code[20];
        EffectiveDate: Date;
        AccountNo: Code[20])
    var
        TDSPostingSetup: Record "TDS Posting Setup";
    begin
        TDSPostingSetup.Init();
        TDSPostingSetup.Validate("TDS Section", TDSSectionCode);
        TDSPostingSetup.Validate("Effective Date", EffectiveDate);
        TDSPostingSetup.Validate("TDS Account", AccountNo);
        TDSPostingSetup.Insert(true);
    end;

    procedure CreateTDSPostingSetupForMultipleSection(
        var TDSPostingSetup: Record "TDS Posting Setup";
        var TDSSection: Record "TDS Section")
    begin
        CreateTDSSection(TDSSection);
        CreateTDSPostingSetup(TDSPostingSetup, TDSSection.Code);
    end;

    procedure InsertCompanyInformationDetails()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then
            CompanyInformation."P.A.N. No." := LibraryUtility.GenerateRandomCode(CompanyInformation.FieldNo("P.A.N. No."), Database::"Company Information");
        CompanyInformation.Validate("Deductor Category", CreateDeductorCategory());
        CompanyInformation.Validate("PAO Code", LibraryUtility.GenerateRandomText(20));
        CompanyInformation.Validate("PAO Registration No.", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("DDO Code", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("DDO Registration No.", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("T.A.N. No.", CreateTANNo());
        if CompanyInformation."State Code" = '' then
            CompanyInformation.Validate("State Code", CreateStateCode());
        CompanyInformation.Validate("T.A.N. No.", CreateTANNo());
        CompanyInformation.Modify(true);
    end;

    procedure RemoveTANOnCompInfo()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("T.A.N. No.", '');
        CompanyInformation.Modify(true);
    end;

    procedure CreateTDSAccountingPeriod()
    var
        TaxType: Record "Tax Type";
        TDSSetup: Record "TDS Setup";
        Date: Record Date;
        CreateTaxAccountingPeriod: Report "Create Tax Accounting Period";
        PeriodLength: DateFormula;
    begin
        if not TDSSetup.Get() then
            exit;
        TaxType.Get(TDSSetup."Tax Type");
        Date.SetRange("Period Type", Date."Period Type"::Year);
        Date.SetRange("Period No.", Date2DMY(WorkDate(), 3));
        Date.FindFirst();

        Clear(CreateTaxAccountingPeriod);
        Evaluate(PeriodLength, '<1M>');
        CreateTaxAccountingPeriod.InitializeRequest(12, PeriodLength, Date."Period Start", TaxType."Accounting Period");
        CreateTaxAccountingPeriod.HideConfirmationDialog(true);
        CreateTaxAccountingPeriod.USEREQUESTPAGE(false);
        CreateTaxAccountingPeriod.Run();
    end;

    procedure VerifyGLEntryWithTDS(DocumentNo: Code[20]; TDSAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocumentNo, TDSAccountNo);
        GLEntry.TestField(Amount, GetTDSAmount(DocumentNo));
    end;

    procedure FindGLEntry(
        var GLEntry: Record "G/L Entry";
        DocumentNo: Code[20];
        TDSAccountNo: Code[20])
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", TDSAccountNo);
        GLEntry.FindSet();
    end;

    procedure GetTDSAmount(DocumentNo: Code[20]): Decimal
    var
        TDSEntry: Record "TDS Entry";
        TDSAmount: Decimal;
    begin
        TDSEntry.SetRange("Document No.", DocumentNo);
        if TDSEntry.FindSet() then
            repeat
                TDSAmount += TDSEntry."Total TDS Including SHE CESS";
            until TDSEntry.Next() = 0;
        exit(-TDSAmount);
    end;

    procedure GetTDSRoundingPrecision(): Decimal
    var
        TaxComponent: Record "Tax Component";
        TDSSetup: Record "TDS Setup";
        TDSRoundingPrecision: Decimal;
    begin
        if not TDSSetup.Get() then
            exit;
        TDSSetup.TestField("Tax Type");
        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange(Name, TDSSetup."Tax Type");
        TaxComponent.FindFirst();
        if TaxComponent."Rounding Precision" <> 0 then
            TDSRoundingPrecision := TaxComponent."Rounding Precision"
        else
            TDSRoundingPrecision := 1;
        exit(TDSRoundingPrecision);
    end;

    procedure RoundTDSAmount(TDSAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        TDSSetup: Record "TDS Setup";
        TDSRoundingPrecision: Decimal;
        TDSRoundingDirection: Text[1];
    begin
        if not TDSSetup.Get() then
            exit;
        TDSSetup.TestField("Tax Type");
        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange(Name, TDSSetup."Tax Type");
        TaxComponent.FindFirst();

        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                TDSRoundingPrecision := '=';
            TaxComponent.Direction::Up:
                TDSRoundingPrecision := '>';
            TaxComponent.Direction::Down:
                TDSRoundingPrecision := '<';
        end;
        if TaxComponent."Rounding Precision" <> 0 then
            TDSRoundingPrecision := TaxComponent."Rounding Precision"
        else
            TDSRoundingPrecision := 1;
        exit(Round(TDSAmount, TDSRoundingPrecision, TDSRoundingDirection));
    end;

    procedure FindStartDateOnAccountingPeriod(): Date
    var
        TDSSetup: Record "TDS Setup";
        TaxType: Record "Tax Type";
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TDSSetup.Get();
        TaxType.Get(TDSSetup."Tax Type");
        TaxAccountingPeriod.SetCurrentKey("Tax Type Code");
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetRange(Closed, false);
        TaxAccountingPeriod.Ascending(true);
        if TaxAccountingPeriod.FindFirst() then
            exit(TaxAccountingPeriod."Starting Date");
    end;

    procedure CreateCurrencyCode(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 100, LibraryRandom.RandDecInDecimalRange(70, 80, 2));
        exit(Currency.Code);
    end;

    procedure CreateZeroVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
    end;

    local procedure CreateCommonSetup(
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code")
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateTDSAccountingPeriod();
        CreateAssesseeCode(AssesseeCode);
        InsertCompanyInformationDetails();
        CreateConcessionalCode(ConcessionalCode);
    end;

    local procedure CreateTDSVendor(
        var Vendor: Record Vendor;
        AssesseeCode: Code[10];
        TDSSection: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateZeroVATPostingSetup(VATPostingSetup);
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Validate("Assessee Code", AssesseeCode);
        UpdateTDSSectionOnVendor(Vendor."No.", TDSSection);
        Vendor.Modify(true);
    end;

    local procedure UpdateTDSSectionOnVendor(
        VendorNo: Code[20];
        ThresholdOverLook: Boolean;
        SurchargeOverlook: Boolean)
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.SetRange("Vendor No", VendorNo);
        AllowedSections.FindFirst();
        AllowedSections.Validate("Threshold Overlook", ThresholdOverlook);
        AllowedSections.Validate("Surcharge Overlook", SurchargeOverlook);
        AllowedSections.Modify(true);
    end;

    local procedure UpdateTDSSectionOnVendor(
        VendorNo: Code[20];
        TDSSection: Code[10])
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.Init();
        AllowedSections.Validate("Vendor No", VendorNo);
        AllowedSections.Validate("TDS Section", TDSSection);
        AllowedSections.Validate("Default Section", true);
        AllowedSections.Insert(true);
    end;

    local procedure CreateDeductorCategory(): Code[20]
    var
        DeductorCategory: Record "Deductor Category";
    begin
        DeductorCategory.SetRange("DDO Code Mandatory", false);
        DeductorCategory.SetRange("PAO Code Mandatory", false);
        DeductorCategory.SetRange("State Code Mandatory", false);
        DeductorCategory.SetRange("Ministry Details Mandatory", false);
        DeductorCategory.SetRange("Transfer Voucher No. Mandatory", false);
        if DeductorCategory.FindFirst() then
            exit(DeductorCategory.Code)
        else begin
            DeductorCategory.Init();
            DeductorCategory.Validate(Code, LibraryUtility.GenerateRandomText(1));
            DeductorCategory.Insert(true);
            exit(DeductorCategory.Code);
        end;
    end;

    local procedure CreateStateCode(): Code[10]
    var
        State: Record State;
    begin
        if State.FindFirst() then
            exit(State.Code)
        else begin
            State.Init();
            State.Validate(Code, LibraryRandom.RandText(2));
            State.Validate(Description, State.Code);
            State.Insert(true);
            exit(State.Code);
        end;
    end;

    local procedure IsTaxAccountingPeriodEmpty(): Boolean
    var
        TDSSetup: Record "TDS Setup";
        TaxType: Record "Tax Type";
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        if not TDSSetup.Get() then
            exit;
        TDSSetup.TestField("Tax Type");

        TaxType.Get(TDSSetup."Tax Type");

        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', WorkDate());
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', WorkDate());
        if TaxAccountingPeriod.IsEmpty then
            exit(true);
    end;

    local procedure GetVATBusPostingWithNOVAT(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT %", '%1', 0);
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Bus. Posting Group");
    end;

    procedure CreateGSTTDSCommmonSetup(
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code")
    var
        CompanyInformation: Record "Company Information";
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateTDSAccountingPeriod();
        CompanyInformation.Get();
        CompanyInformation.Validate("Deductor Category", CreateDeductorCategory());
        CompanyInformation.Validate("PAO Code", LibraryUtility.GenerateRandomText(20));
        CompanyInformation.Validate("PAO Registration No.", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("DDO Code", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("DDO Registration No.", LibraryUtility.GenerateRandomText(7));
        CompanyInformation.Validate("T.A.N. No.", CreateTANNo());
        CompanyInformation.Modify(true);
        CreateConcessionalCode(ConcessionalCode);
        CreateAssesseeCode(AssesseeCode);
    end;

    local procedure CreateGSTTDSVendor(
        var Vendor: Record Vendor;
        AssesseeCode: Code[10];
        TDSSection: Code[10])
    begin
        Vendor.Validate("VAT Bus. Posting Group", GetVATBusPostingWithNOVAT());
        Vendor.Validate("Assessee Code", AssesseeCode);
        UpdateTDSSectionOnVendor(Vendor."No.", TDSSection);
        Vendor.Modify(true);
    end;

    procedure CreateGSTTDSSetup(
        var Vendor: Record Vendor;
        var TDSPostingSetup: Record "TDS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TDSSection: Record "TDS Section";
    begin
        CreateGSTTDSCommmonSetup(AssesseeCode, ConcessionalCode);
        CreateTDSPostingSetupWithSection(TDSPostingSetup, TDSSection);
        CreateGSTTDSVendor(Vendor, AssesseeCode.Code, TDSSection.Code);
        AttachConcessionalWithVendor(Vendor."No.", ConcessionalCode.Code, TDSSection.Code);
    end;

    procedure UpdateSectionOnVendor(VendorNo: Code[20]; TDSSection: Code[10])
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.Init();
        AllowedSections.Validate("Vendor No", VendorNo);
        AllowedSections.Validate("TDS Section", TDSSection);
        AllowedSections.Validate("Default Section", true);
        AllowedSections.Insert(true);
    end;

    procedure CreateTDSSetupWithMultipleSection(
        var Vendor: Record Vendor;
        var TDSPostingSetup: Record "TDS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TDSSection: Record "TDS Section";
    begin
        CreateCommonSetup(AssesseeCode, ConcessionalCode);
        CreateTDSPostingSetupWithSection(TDSPostingSetup, TDSSection);
        CreateTDSVendor(Vendor, AssesseeCode.Code, TDSSection.Code);
        CreateTDSPostingSetupWithSection(TDSPostingSetup, TDSSection);
        UpdateTDSSectionOnVendorWithThresholdOverlook(Vendor."No.", TDSSection.Code);
        AttachConcessionalWithVendor(Vendor."No.", ConcessionalCode.Code, TDSSection.Code);
    end;

    local procedure UpdateTDSSectionOnVendorWithThresholdOverlook(
        VendorNo: Code[20];
        TDSSection: Code[10])
    var
        AllowedSections: Record "Allowed Sections";
    begin
        AllowedSections.Init();
        AllowedSections.Validate("Vendor No", VendorNo);
        AllowedSections.Validate("TDS Section", TDSSection);
        AllowedSections.Validate("Threshold Overlook", true);
        AllowedSections.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'CreateTDSSetupStale', '', false, false)]
    local procedure CreateTDSSetupForStaleCheck(var Vendor: Record Vendor; var TDSSection: Code[10])
    var
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        TDSSection := TDSPostingSetup."TDS Section";
        UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'CreateGenJournalLineWithTDSStale', '', false, false)]
    local procedure CreateGenJournalLineWithTDS(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; var TDSSection: Code[10])
    var
        TDSOnGeneralJnl: Codeunit "TDS On General Jnl";
    begin
        TDSOnGeneralJnl.CreateTaxRateSetup(TDSSection, Vendor."Assessee Code", '', WorkDate());
        TDSOnGeneralJnl.CreateTDSPaymentWithBankAccount(GenJournalLine, Vendor, WorkDate());
    end;
}