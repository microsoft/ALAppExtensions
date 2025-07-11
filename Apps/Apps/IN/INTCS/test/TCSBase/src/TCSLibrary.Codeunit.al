codeunit 18911 "TCS - Library"
{
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS% and TCS field Caption';

    procedure CreateTCSSetup(
        var Customer: Record Customer;
        var TCSPostingSetup: Record "TCS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
    begin
        CreateCommmonSetup(AssesseeCode, ConcessionalCode);
        CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);
        CreateTCSCustomer(Customer, AssesseeCode.Code, TCSNatureOfCollection.Code);
        AttachConcessionalWithCustomer(Customer."No.", ConcessionalCode.Code, TCSNatureOfCollection.Code);
    end;

    procedure UpdateCustomerWithPANWithConcessional(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        Customer.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Customer.FieldNo("P.A.N. No."), Database::"Customer"));
        Customer.Modify(true);
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);
    end;

    procedure UpdateCustomerWithPANWithOutConcessional(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        CustomerConcessionalCode: Record "Customer Concessional Code";
    begin
        Customer.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Customer.FieldNo("P.A.N. No."), Database::"Customer"));
        Customer.Modify(true);
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);

        CustomerConcessionalCode.SetRange("Customer No.", Customer."No.");
        CustomerConcessionalCode.DeleteAll(true);
    end;

    procedure UpdateCustomerWithoutPANWithConcessional(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        Customer.Validate("P.A.N. Status", Customer."P.A.N. Status"::PANAPPLIED);
        Customer.Validate("P.A.N. Reference No.", LibraryRandom.RandText(10));
        Customer.Modify();
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);
    end;

    procedure UpdateCustomerWithoutPANWithoutConcessional(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        CustomerConcessionalCode: Record "Customer Concessional Code";
    begin
        Customer.Validate("P.A.N. Status", Customer."P.A.N. Status"::PANAPPLIED);
        Customer.Validate("P.A.N. Reference No.", LibraryRandom.RandText(10));
        Customer.Modify();
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);

        CustomerConcessionalCode.SetRange("Customer No.", Customer."No.");
        CustomerConcessionalCode.DeleteAll(true);
    end;

    procedure UpdateCustomerWithNOCWithOutConcessional(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        CustomerConcessionalCode: Record "Customer Concessional Code";
    begin
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);
        CustomerConcessionalCode.SetRange("Customer No.", Customer."No.");
        CustomerConcessionalCode.DeleteAll(true);
    end;

    procedure CreateAssesseeCode(var AssesseeCode: Record "Assessee Code")
    begin
        AssesseeCode.Init();
        AssesseeCode.Validate(Code, LibraryUtility.GenerateRandomCode(AssesseeCode.FieldNo(Code), Database::"Assessee Code"));
        AssesseeCode.Validate(Description, AssesseeCode.Code);
        AssesseeCode.Insert(true);
    end;

    procedure CreateTCANNo(): Code[10]
    var
        TCANNo: Record "T.C.A.N. No.";
    begin
        TCANNo.Init();
        TCANNo.Validate(Code, LibraryUtility.GenerateRandomCode(TCANNo.FieldNo(Code), Database::"T.C.A.N. No."));
        TCANNo.Validate(Description, TCANNo.Code);
        TCANNo.Insert(true);
        exit(TCANNo.Code);
    end;

    procedure CreateTCSNatureOfCollection(var TCSNatureOfCollection: Record "TCS Nature Of Collection")
    begin
        TCSNatureOfCollection.Init();
        TCSNatureOfCollection.Validate(Code, LibraryUtility.GenerateRandomCode(TCSNatureOfCollection.FieldNo(Code), Database::"TCS Nature Of Collection"));
        TCSNatureOfCollection.Validate(Description, TCSNatureOfCollection.Code);
        TCSNatureOfCollection.Insert(true);
    end;

    procedure CreateTCSPostingSetup(
        var TCSPostingSetup: Record "TCS Posting Setup";
        TCSNatureOfCollectionCode: Code[20])
    begin
        TCSPostingSetup.Init();
        TCSPostingSetup.Validate("TCS Nature of Collection", TCSNatureOfCollectionCode);
        TCSPostingSetup.Validate("Effective Date", WorkDate());
        TCSPostingSetup.Validate("TCS Account No.", LibraryERM.CreateGLAccountNoWithDirectPosting());
        TCSPostingSetup.Insert(true);
    end;

    procedure CreateTCSPostingSetupWithNOC(
        var TCSPostingSetup: Record "TCS Posting Setup";
        var TCSNOC: Record "TCS Nature Of Collection")
    begin
        CreateTCSNatureOfCollection(TCSNOC);
        CreateTCSPostingSetup(TCSPostingSetup, TCSNOC.Code);
    end;

    procedure AttachNOCWithCustomer(
        NOCType: Code[10];
        CustomerNo: Code[20];
        DefaultNOC: Boolean;
        SurchargeOverLook: Boolean;
        ThresholdOverlook: Boolean)
    var
        AllowedNOC: Record "Allowed Noc";
    begin
        AllowedNOC.Init();
        AllowedNOC.Validate("Customer No.", CustomerNo);
        AllowedNOC.Validate("TCS Nature of Collection", NOCType);
        AllowedNOC.Validate("Default Noc", DefaultNOC);
        AllowedNOC.Validate("Surcharge Overlook", SurchargeOverLook);
        AllowedNOC.Validate("Threshold Overlook", ThresholdOverlook);
        AllowedNOC.Insert(true);
    end;

    procedure CreateConcessionalCode(var ConcessionalCode: Record "Concessional Code")
    begin
        ConcessionalCode.Init();
        ConcessionalCode.Validate(Code, LibraryUtility.GenerateRandomCode(ConcessionalCode.FieldNo(Code), Database::"Concessional Code"));
        ConcessionalCode.Validate(Description, ConcessionalCode.Code);
        ConcessionalCode.Insert(true);
    end;

    procedure AttachConcessionalWithCustomer(
        CustomerNo: Code[20];
        ConcessionalCode: Code[10];
        TCSNatureOfCollection: Code[10])
    var
        CustomerConcessionalCode: Record "Customer Concessional Code";
    begin
        CustomerConcessionalCode.Init();
        CustomerConcessionalCode.Validate("Customer No.", CustomerNo);
        CustomerConcessionalCode.Validate("TCS Nature of Collection", TCSNatureOfCollection);
        CustomerConcessionalCode.Validate("Concessional Code", ConcessionalCode);
        CustomerConcessionalCode.Validate("Concessional Form No.", LibraryUtility.GenerateRandomCode(CustomerConcessionalCode.FieldNo("Concessional Form No."), Database::"Customer Concessional Code"));
        CustomerConcessionalCode.Insert(true);
    end;

    procedure CreateTCSAccountingPeriod()
    var
        TaxType: Record "Tax Type";
        TCSSetup: Record "TCS Setup";
        Date: Record Date;
        CreateTaxAccountingPeriod: Report "Create Tax Accounting Period";
        PeriodLength: DateFormula;
    begin
        if not TCSSetup.Get() then
            exit;
        TaxType.Get(TCSSetup."Tax Type");

        Date.SetRange("Period Type", Date."Period Type"::Year);
        Date.SetRange("Period No.", Date2DMY(WorkDate(), 3));
        Date.FindFirst();

        Clear(CreateTaxAccountingPeriod);
        Evaluate(PeriodLength, '<1M>');
        CreateTaxAccountingPeriod.InitializeRequest(12, PeriodLength, Date."Period Start", TaxType."Accounting Period");
        CreateTaxAccountingPeriod.HideConfirmationDialog(true);
        CreateTaxAccountingPeriod.UseRequestPage(false);
        CreateTaxAccountingPeriod.Run();
    end;

    procedure FillCompanyInformation()
    var
        CompInfo: Record "Company Information";
    begin
        Compinfo.Get();
        if CompInfo."P.A.N. No." = '' then
            CompInfo."P.A.N. No." := LibraryUtility.GenerateRandomCode(CompInfo.FieldNo("P.A.N. No."), Database::"Company Information");
        CompInfo.Validate("Circle No.", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Ward No.", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Assessing Officer", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Deductor Category", CreateDeductorCategory());
        if CompInfo."State Code" = '' then
            CompInfo.Validate("State Code", CreateStateCode());
        CompInfo.Validate("T.C.A.N. No.", CreateTCANNo());
        CompInfo.Modify(true);
    end;

    procedure CreateDeductorCategory(): Code[20]
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

    procedure VerifyTCSEntry(
        DocumentNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        TCSBaseAmount: Decimal)
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document Type", DocumentType);
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.FindFirst();
        Assert.AreNearlyEqual(
          TCSBaseAmount, TCSEntry."TCS Base Amount", GetTCSRoundingPrecision(),
           StrSubstNo(AmountErr, TCSBaseAmount, TCSEntry.FieldCaption("TCS Base Amount")));
    end;

    procedure VerifyGLEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
    begin
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(DummyGLEntry, ExpectedCount);
    end;

    procedure VerifyGLEntryWithTCS(DocumentNo: Code[20]; TCSAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocumentNo, TCSAccountNo);
        GLEntry.TestField(Amount, GetTCSAmount(DocumentNo));
    end;

    procedure FindGLEntry(var GLEntry: Record "G/L Entry"; DocumentNo: Code[20]; TCSAccountNo: Code[20])
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", TCSAccountNo);
        GLEntry.FindFirst();
    end;

    procedure GetTCSAmount(DocumentNo: Code[20]): Decimal
    var
        TCSEntry: Record "TCS Entry";
        TCSAmount: Decimal;
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        if TCSEntry.FindSet() then
            repeat
                TCSAmount += TCSEntry."Total TCS Including SHE CESS";
            until TCSEntry.Next() = 0;
        exit(-TCSAmount);
    end;

    procedure RemoveTCANOnCompInfo()
    var
        CompInfo: Record "Company Information";
    begin
        CompInfo.Get();
        CompInfo.Validate("T.C.A.N. No.", '');
        CompInfo.Modify(true);
    end;

    procedure VerifyTCSEntryCount(
        DocumentNo: Code[20];
        FilterOnBaseAmount: Boolean;
        TCSBaseAmount: Decimal;
        ExpectedCount: Integer)
    var
        DummyTCSEntry: Record "TCS Entry";
    begin
        DummyTCSEntry.SetRange("Document No.", DocumentNo);
        if FilterOnBaseAmount then
            DummyTCSEntry.SetRange("TCS Base Amount", TCSBaseAmount);
        Assert.RecordCount(DummyTCSEntry, ExpectedCount);
    end;

    procedure CreateTCSPostingSetupWithDifferentEffectiveDate(TCSNatureOfCollectionCode: Code[20]; EffectiveDate: Date; AccountNo: Code[20])
    var
        TCSPostingSetup: Record "TCS Posting Setup";
    begin
        TCSPostingSetup.Init();
        TCSPostingSetup.Validate("TCS Nature of Collection", TCSNatureOfCollectionCode);
        TCSPostingSetup.Validate("Effective Date", EffectiveDate);
        TCSPostingSetup.Validate("TCS Account No.", AccountNo);
        TCSPostingSetup.Insert(true);
    end;

    procedure CreateAccPeriodAndFillCompInfo()
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateTCSAccountingPeriod();
        FillCompanyInformation();
    end;

    procedure CreateNOCWithCustomer(NOCType: Code[10]; var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", '');
        Customer.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Customer.FieldNo("P.A.N. No."), Database::"Customer"));
        Customer.Modify(true);
        if NOCType <> '' then
            UpdateDefaultNOConCustomer(Customer."No.", NOCType);
    end;

    procedure UpdateDefaultNOConCustomer(CustomerNo: Code[20]; NOCType: Code[10])
    var
        AllowedNOC: Record "Allowed Noc";
    begin
        AllowedNOC.Init();
        AllowedNOC.Validate("Customer No.", CustomerNo);
        AllowedNOC.Validate("TCS Nature of Collection", NOCType);
        AllowedNOC.Validate("Default Noc", true);
        AllowedNOC.Insert(true);
    end;

    procedure CreateGSTTCSSetup(
        var Customer: Record Customer;
        var TCSPostingSetup: Record "TCS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
    begin
        CreateGSTTCSCommmonSetup(AssesseeCode, ConcessionalCode);
        CreateTCSPostingSetupWithNOC(TCSPostingSetup, TCSNatureOfCollection);
        CreateGSTTCSCustomer(Customer, AssesseeCode.Code, TCSNatureOfCollection.Code);
        AttachConcessionalWithCustomer(Customer."No.", ConcessionalCode.Code, TCSNatureOfCollection.Code);
    end;

    procedure UpdateCustomerWithNOCWithOutConcessionalGST(
        var Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    var
        CustomerConcessionalCode: Record "Customer Concessional Code";
    begin
        UpdateNOCOnCustomer(Customer."No.", ThresholdOverlook, SurchargeOverlook);
        CustomerConcessionalCode.SetRange("Customer No.", Customer."No.");
        CustomerConcessionalCode.DeleteAll(true);
    end;

    procedure UpdateCustomerAssesseeAndConcessionalCode(
        var Customer: Record Customer;
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code";
        NOCType: Code[10])
    begin
        CreateAssesseeCode(AssesseeCode);
        Customer.Validate("Assessee Code", AssesseeCode.Code);
        CreateConcessionalCode(ConcessionalCode);
        AttachConcessionalWithCustomer(Customer."No.", ConcessionalCode.Code, NOCType);
        Customer.Modify(true);
    end;

    procedure VerifyTCSEntryForAssesseeCode(DocumentNo: Code[20]; AssesseeCode: Code[10])
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.SetRange("Assessee Code", AssesseeCode);
        TCSEntry.FindFirst();
        Assert.IsSubstring(AssesseeCode, TCSEntry."Assessee Code");
    end;

    procedure UpdateGenLedSetupForAddReportingCurrency()
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdjustAddReportingCurrency: Report "Adjust Add. Reporting Currency";
    begin
        CreateCurrencyAndExchangeRate(Currency);
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Additional Reporting Currency" := Currency.Code;
        GeneralLedgerSetup.Modify(true);
        Clear(AdjustAddReportingCurrency);
        AdjustAddReportingCurrency.InitializeRequest('Test123', LibraryERM.CreateGLAccountNoWithDirectPosting());
        AdjustAddReportingCurrency.SetAddCurr(Currency.Code);
        AdjustAddReportingCurrency.USEREQUESTPAGE(false);
        AdjustAddReportingCurrency.Run();
    end;

    procedure CreateCurrencyAndExchangeRate(var Currency: Record Currency)
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.FindGLAccount(GLAccount);
        Currency.Validate("Residual Gains Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        Currency.Validate("Residual Losses Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        Currency.Modify(true);
        LibraryERM.CreateRandomExchangeRate(Currency.Code);
    end;

    procedure VerifyGLEntryAdditionalCurrencyAmt(JnlBatchName: Code[10]; DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        if DocumentNo <> '' then
            GLEntry.SetRange("Document No.", DocumentNo)
        else
            GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.SetFilter("Additional-Currency Amount", '<>%1', 0);
        GLEntry.FindFirst();
        Assert.RecordIsNotEmpty(GLEntry);
    end;

    procedure RoundTCSAmount(TCSAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        TCSSetup: Record "TCS Setup";
        TCSRoundingPrecision: Decimal;
        TCSRoundingDirection: Text[1];
    begin
        if not TCSSetup.Get() then
            exit;
        TCSSetup.TestField("Tax Type");
        TaxComponent.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxComponent.SetRange(Name, TCSSetup."Tax Type");
        TaxComponent.FindFirst();

        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                TCSRoundingDirection := '=';
            TaxComponent.Direction::Up:
                TCSRoundingDirection := '>';
            TaxComponent.Direction::Down:
                TCSRoundingDirection := '<';
        end;
        if TaxComponent."Rounding Precision" <> 0 then
            TCSRoundingPrecision := TaxComponent."Rounding Precision"
        else
            TCSRoundingPrecision := 1;

        exit(Round(TCSAmount, TCSRoundingPrecision, TCSRoundingDirection));
    end;

    procedure GetTCSRoundingPrecision(): Decimal
    var
        TaxComponent: Record "Tax Component";
        TCSSetup: Record "TCS Setup";
        TCSRoundingPrecision: Decimal;
    begin
        if not TCSSetup.Get() then
            exit;
        TCSSetup.TestField("Tax Type");
        TaxComponent.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxComponent.SetRange(Name, TCSSetup."Tax Type");
        TaxComponent.FindFirst();

        if TaxComponent."Rounding Precision" <> 0 then
            TCSRoundingPrecision := TaxComponent."Rounding Precision"
        else
            TCSRoundingPrecision := 1;
        exit(TCSRoundingPrecision);
    end;

    local procedure CreateCommmonSetup(
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code")
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateTCSAccountingPeriod();
        FillCompanyInformation();
        CreateConcessionalCode(ConcessionalCode);
        CreateAssesseeCode(AssesseeCode);
    end;

    local procedure IsTaxAccountingPeriodEmpty(): Boolean
    var
        TCSSetup: Record "TCS Setup";
        TaxType: Record "Tax Type";
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        if not TCSSetup.Get() then
            exit;
        TCSSetup.TestField("Tax Type");

        TaxType.Get(TCSSetup."Tax Type");

        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', WorkDate());
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', WorkDate());
        if TaxAccountingPeriod.IsEmpty then
            exit(true);
    end;

    local procedure CreateTCSCustomer(var Customer: Record Customer; AssesseeCode: Code[10]; TCSNOC: Code[10])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", GetVATBusPostingWithNOVAT());
        Customer.Validate("Assessee Code", AssesseeCode);
        UpdateNOCOnCustomer(Customer."No.", TCSNOC);
        Customer.Modify(true);
    end;

    procedure UpdateNOCOnCustomer(
        CustomerNo: Code[20];
        ThresholdOverLook: Boolean;
        SurchargeOverlook: Boolean)
    var
        AllowedNOC: Record "Allowed NOC";
    begin
        AllowedNOC.SetRange("Customer No.", CustomerNo);
        AllowedNOC.FindFirst();
        AllowedNOC.Validate("Threshold Overlook", ThresholdOverlook);
        AllowedNOC.Validate("Surcharge Overlook", SurchargeOverlook);
        AllowedNOC.Modify(true);
    end;

    procedure UpdateNOCOnCustomer(CustomerNo: Code[20]; NOCType: Code[10])
    var
        AllowedNOC: Record "Allowed Noc";
    begin
        AllowedNOC.Init();
        AllowedNOC.Validate("Customer No.", CustomerNo);
        AllowedNOC.Validate("TCS Nature of Collection", NOCType);
        AllowedNOC.Validate("Default Noc", true);
        AllowedNOC.Insert(true);
    end;

    local procedure GetVATBusPostingWithNOVAT(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT %", '%1', 0);
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Bus. Posting Group");
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

    procedure CreateGSTTCSCommmonSetup(
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code")
    var
        CompanyInfo: Record "Company Information";
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateTCSAccountingPeriod();
        CompanyInfo.Get();
        CompanyInfo.Validate("Circle No.", LibraryUtility.GenerateRandomText(30));
        CompanyInfo.Validate("Ward No.", LibraryUtility.GenerateRandomText(30));
        CompanyInfo.Validate("Assessing Officer", LibraryUtility.GenerateRandomText(30));
        CompanyInfo.Validate("Deductor Category", CreateDeductorCategory());
        CompanyInfo.Validate("T.C.A.N. No.", CreateTCANNo());
        CompanyInfo.Modify(true);
        CreateConcessionalCode(ConcessionalCode);
        CreateAssesseeCode(AssesseeCode);
    end;

    local procedure CreateGSTTCSCustomer(
        var Customer: Record Customer;
        AssesseeCode: Code[10];
        TCSNOC: Code[10])
    begin
        Customer.Validate("VAT Bus. Posting Group", GetVATBusPostingWithNOVAT());
        Customer.Validate("Assessee Code", AssesseeCode);
        UpdateNOCOnCustomer(Customer."No.", TCSNOC);
        Customer.Modify(true);
    end;
}