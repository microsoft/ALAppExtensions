codeunit 18273 "Jnl Bank Charges Tests"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentVoucherWithIntrastateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355954] [Check if the system is calculating GST in case of Intra-State Bank Payment with Bank Charges with GST where Input Tax Credit is available]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup
        CreateGSTSetup(GSTVendorType::Registered, true, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure CheckMultipleBankChargesNotAllowedAgainstBankChagreJournalLine()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeferralCode: Code[10];
        GLAccount: Code[20];
    begin
        // [SCENARIO] [445349] [Check that the system is not allowing to insert more than one line of Bank charges against Bank Charge journal line]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup
        CreateGSTSetup(GSTVendorType::Registered, true, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);
        GLAccount := CreateGLAccountWithStraightLineDeferral(DeferralCode);

        // [WHEN] Create Bank Payment Voucher with Multiple Bank Charges
        CreateGenJournalLineForGLToBank(GenJournalLine, GLAccount, DeferralCode, BankAccount."No.");
        UpdateBankCharges(GenJournalLine);
        CreateBankChargeForJournalBankChargeLine(GenJournalLine, true);
        asserterror CreateBankChargeForJournalBankChargeLine(GenJournalLine, false);

        // [THEN] Verify error message for Bank Charges.
        Assert.ExpectedError(GSTBankChargeBoolErr);
    end;


    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentVoucherWithInterstateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355955] [Check if the system is calculating GST in case of Inter-State Bank Payment with Bank Charges with GST where Input Tax Credit is available]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, false, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, false);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentVoucherWithInterstateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355956] [Check if the system is calculating GST in case of Inter-State Bank Payment with Bank Charges with GST where Input Tax Credit is not available]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, false, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, false);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentVoucherWithIntrastateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355956] [Check if the system is calculating GST in case of Intra-State Bank Payment with Bank Charges with GST where Input Tax Credit is not available]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, true, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankReceiptVoucherWithInterstateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] [355976] [Check if the system is calculating GST in case of Inter-state bank charges with GST where Input Tax Credit is available on Bank receipts]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTCustomerType::Registered, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Receipt Voucher", false, false);

        // [WHEN] Create and Post Bank Receipt Voucher with Bank Charges
        CreateGenJournalLineForCustomerToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankReceiptVoucherWithIntrastateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] [355975] [Check if the system is calculating GST in case of Intra-state bank charges with GST where Input Tax Credit is available on Bank receipts]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTCustomerType::Registered, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Receipt Voucher", false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Bank Charges
        CreateGenJournalLineForCustomerToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankReceiptVoucherWithIntrastateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] [355980] [Check if the system is calculating GST in case of Intra-state bank charges with GST where Input Tax Credit is not available on Bank receipts]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTCustomerType::Registered, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Receipt Voucher", false, true);

        // [WHEN] Create and Post Bank Receipt Voucher with Bank Charges
        CreateGenJournalLineForCustomerToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankReceiptVoucherWithInterstateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] [355981] [Check if the system is calculating GST in case of Inter-state bank charges with GST where Input Tax Credit is not available on Bank receipts]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTCustomerType::Registered, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Receipt Voucher", false, false);

        // [WHEN] Create and Post Bank Receipt Voucher with Bank Charges
        CreateGenJournalLineForCustomerToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentWithIntrastateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355982] [Check if the system is calculating GST in case of Intra-state bank charges with GST where Input Tax Credit is available on Bank payments]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, true, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 5);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentsWithInterstateBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355987] [Check if the system is calculating GST in case of Inter-state bank charges with GST where Input Tax Credit is available on Bank payments]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, false, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, false);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges.
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentsWithInterstateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355988] [Check if the system is calculating GST in case of Inter-state bank charges with GST where Input Tax Credit is not available on Bank payments]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, false, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, false);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentsWithIntrastateBankChargesNonAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [355989] [Check if the system is calculating GST in case of Intra-state bank charges with GST where Input Tax Credit is not available on Bank payments]
        Initialize();
        // [GIVEN] Created GST Setup and Bank Charges Setup 
        CreateGSTSetup(GSTVendorType::Registered, true, false);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges
        CreateGenJournalLineForVendorToBank(GenJournalLine, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage')]
    procedure PostFromBankPaymentVoucherWitheDeferralBankChargesAvailment()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeferralCode: Code[10];
        GLAccount: Code[20];
    begin
        // [SCENARIO] [Check if the system is Posting Bank Payment Voucher with Bank charges with Deferral Code with GST where Input Tax Credit is available]
        Initialize();
        // [GIVEN] Created GST Setup, Bank Charges Setup, GL Account and Deferral Template
        CreateGSTSetup(GSTVendorType::Registered, true, true);
        CreateBankChargeSetup(BankAccount, VoucherType::"Bank Payment Voucher", false, true);
        GLAccount := CreateGLAccountWithStraightLineDeferral(DeferralCode);

        // [WHEN] Create and Post Bank Payment Voucher with Bank Charges and Deferral Code
        CreateGenJournalLineForGLToBank(GenJournalLine, GLAccount, DeferralCode, BankAccount."No.");
        DocumentNo := CreateJournalBankCharge(GenJournalLine, LibraryRandom.RandDecInRange(1, 500, 0));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        VerifyGLEntryCount(GenJournalLine."Document Type"::Payment, DocumentNo, 34);
    end;

    local procedure Initialize()
    begin
        FillCompanyInformation();
        Clear(LibraryStorage);
    end;

    local procedure CreateGSTSetup(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean; InputCreditAvailment: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        GSTGroupType: Enum "GST Group Type";
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        LocationCode: Code[10];
        VendorStateCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryGST.CreateInitialSetup();
        LibraryStorage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.MODIFY(TRUE);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        LibraryStorage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType::Service, GSTGroup."GST Place Of Supply"::" ", false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::SAC);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);
        LibraryStorage.Set(InputCreditAvailmentLbl, Format(InputCreditAvailment));
        if IntraState then begin
            VendorNo := LibraryGST.CreateVendorSetup();
            UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
            CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);
            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else begin
                InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
                CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
                CreateGSTComponentAndPostingSetup(IntraState, VendorStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        LibraryStorage.Set(VendorNoLbl, VendorNo);

        CreateTaxRate();
    end;

    local procedure CreateGSTSetup(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        GSTGroupType: Enum "GST Group Type";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
        isInitialized: Boolean;
    begin
        if isInitialized then
            exit;
        FillCompanyInformation();
        CompanyInformation.Get();

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryGST.CreateInitialSetup();
        LibraryStorage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.MODIFY(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        LibraryStorage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType::Service, GSTGroup."GST Place Of Supply"::" ", false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::SAC);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);
        LibraryStorage.Set(InputCreditAvailmentLbl, format(false));

        if IntraState then begin
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
            CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            CustomerStateCode := LibraryGST.CreateGSTStateCode();
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);
            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development"] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else begin
                InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
                CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
                CreateGSTComponentAndPostingSetup(IntraState, CustomerStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        LibraryStorage.Set(CustomerNoLbl, CustomerNo);

        CreateTaxRate();
        isInitialized := true;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        LibraryStorage.Set(FromStateCodeLbl, FromState);
        LibraryStorage.Set(ToStateCodeLbl, ToState);

        GSTTaxPercent := LibraryRandom.RandIntInRange(1, 10);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent);
            ComponentPerArray[2] := (GSTTaxPercent);
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[3] := GSTTaxPercent;
    end;

    local procedure CreateGSTComponentAndPostingSetup(IntraState: Boolean; LocationStateCode: Code[10]; TaxComponent: Record "Tax Component"; GSTComponentCode: Text[30]);
    begin
        IF IntraState THEN begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure UpdateVendorSetupWithGST(VendorNo: Code[20]; GSTVendorType: Enum "GST Vendor Type"; AssociateEnterprise: boolean; StateCode: Code[10]; PANNo: Code[20]);
    var
        Vendor: Record Vendor;
        State: Record State;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", PANNo);
            if not ((GSTVendorType = GSTVendorType::" ") OR (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;
        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then
            Vendor.Validate("Associated Enterprises", AssociateEnterprise);
        Vendor.Modify(true);
    end;

    local procedure UpdateCustomerSetupWithGST(CustomerNo: Code[20]; GSTCustomerType: Enum "GST Customer Type"; StateCode: Code[10]; PANNo: Code[20]);
    var
        Customer: Record Customer;
        State: Record State;
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        Customer.Get(CustomerNo);
        if GSTCustomerType <> GSTCustomerType::Export then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") OR (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;
        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("GST Customer Type", GSTCustomerType);
        Customer.Modify(true);
    end;

    local procedure CreateJournalBankCharge(var GenJournalLine: Record "Gen. Journal Line"; ChargeAmount: Decimal): Code[20]
    var
        JournalBankCharges: Record "Journal Bank Charges";
    begin
        JournalBankCharges.Init();
        JournalBankCharges.Validate("Journal Template Name", GenJournalLine."Journal Template Name");
        JournalBankCharges.Validate("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JournalBankCharges.Validate("Line No.", GenJournalLine."Line No.");
        JournalBankCharges.Validate("Bank Charge", LibraryStorage.Get(BankChargeLbl));
        JournalBankCharges.Validate("GST Document Type", JournalBankCharges."GST Document Type"::Invoice);
        JournalBankCharges.Validate("External Document No.", GenJournalLine."Document No.");
        JournalBankCharges.Insert(true);
        JournalBankCharges.Validate(Amount, ChargeAmount);
        JournalBankCharges.Modify(true);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateBankChargeForJournalBankChargeLine(var GenJournalLine: Record "Gen. Journal Line"; FirstLine: Boolean)
    var
        JournalBankCharges: Record "Journal Bank Charges";
    begin
        JournalBankCharges.Init();
        JournalBankCharges.Validate("Journal Template Name", GenJournalLine."Journal Template Name");
        JournalBankCharges.Validate("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JournalBankCharges.Validate("Line No.", GenJournalLine."Line No.");
        if FirstLine then
            JournalBankCharges.Validate("Bank Charge", LibraryStorage.Get(BankChargeLbl))
        else
            JournalBankCharges.Validate("Bank Charge", LibraryStorage.Get(SecondBankChargeLbl));
        JournalBankCharges.Validate("External Document No.", GenJournalLine."Document No.");
        JournalBankCharges.Insert(true);
    end;

    local procedure CreateGenJournalLineForVendorToBank(var GenJournalLine: Record "Gen. Journal Line"; BankAccNo: code[20])
    begin
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            CopyStr(LibraryStorage.Get(TemplateNameLbl), 1, 10), CopyStr(LibraryStorage.Get(BatchNameLbl), 1, 10),
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Vendor, CopyStr(LibraryStorage.Get(VendorNoLbl), 1, 20),
            GenJournalLine."Bal. Account Type"::"Bank Account", BankAccNo,
            LibraryRandom.RandDecInRange(1000, 10000, 0));
        GenJournalLine.Validate("Location Code", CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, 10));
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJournalLineForCustomerToBank(var GenJournalLine: Record "Gen. Journal Line"; BankAccNo: code[20])
    begin
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            CopyStr(LibraryStorage.Get(TemplateNameLbl), 1, 10), CopyStr(LibraryStorage.Get(BatchNameLbl), 1, 10),
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer, CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, 20),
            GenJournalLine."Bal. Account Type"::"Bank Account", BankAccNo,
            -LibraryRandom.RandDecInRange(1000, 10000, 0));
        GenJournalLine.Validate("Location Code", CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, 10));
        GenJournalLine.Modify(true);
    end;

    local procedure CreateVoucherAccountSetup(SubType: Enum "Gen. Journal Template Type"; LocationCode: Code[10])
    var
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := CopyStr(LibraryStorage.Get(BankAccountLbl), 1, MaxStrLen(AccountNo));
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    TaxBaseTestPublishers.InsertVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBaseTestPublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
        end;
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        Noseries: Code[20];
    begin
        Noseries := LibraryERM.CreateNoSeriesCode();
        libraryStorage.Set(NoSeriesLbl, Noseries);
        exit(Noseries);
    end;

    local procedure CreateGenJnlTemplateAndBatch(var GenJournalTemplate: Record "Gen. Journal Template"; var GenJournalBatch: Record "Gen. Journal Batch"; LocationCode: code[20]; VoucherType: enum "Gen. Journal Template Type");
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryStorage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Validate("Posting No. Series", LibraryStorage.Get(NoSeriesLbl));
        GenJournalBatch.Modify(true);
        LibraryStorage.Set(BatchNameLbl, GenJournalBatch.Name);
    end;

    local procedure CreateBankChargeSetup(
        var BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        ForeignExchange: Boolean;
        IntraState: Boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        FromState: Record State;
        ToState: Record State;
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        FromState.Get(LibraryStorage.Get(FromStateCodeLbl));
        ToState.Get(LibraryStorage.Get(ToStateCodeLbl));
        if IntraState then
            BankAccount.Validate("State Code", LibraryStorage.Get(ToStateCodeLbl))
        else
            BankAccount.Validate("State Code", LibraryStorage.Get(FromStateCodeLbl));
        BankAccount.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(CopyStr(FromState."State Code (GST Reg. No.)", 1, 2), LibraryGST.CreatePANNos()));
        BankAccount.Validate("GST Registration Status", BankAccount."GST Registration Status"::Registered);
        BankAccount.Modify(true);
        LibraryStorage.Set(BankAccountLbl, BankAccount."No.");
        CreateNoSeries();
        CreateVoucherAccountSetup(VoucherType, CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, 10));
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, 10), VoucherType);
        CreateBankCharge(ForeignExchange);
        CreateSecondBankCharge(ForeignExchange);
    end;

    local procedure CreateBankCharge(ForeignExchange: Boolean)
    var
        BankCharge: Record "Bank Charge";
        GLAccount: Record "G/L Account";
        InputCreditAvailment: Boolean;
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        BankCharge.Init();
        BankCharge.Validate(Code, LibraryUtility.GenerateRandomCode(BankCharge.FieldNo(Code), Database::"Bank Charge"));
        BankCharge.Validate(Description, BankCharge.Code);
        BankCharge.Validate(Account, GLAccount."No.");
        BankCharge.Validate("Foreign Exchange", ForeignExchange);
        BankCharge.Validate("GST Group Code", LibraryStorage.Get(GSTGroupCodeLbl));
        BankCharge.Validate("HSN/SAC Code", LibraryStorage.Get(HSNSACCodeLbl));
        Evaluate(InputCreditAvailment, LibraryStorage.Get(InputCreditAvailmentLbl));
        if InputCreditAvailment then
            BankCharge.Validate("GST Credit", BankCharge."GST Credit"::Availment)
        else
            BankCharge.Validate("GST Credit", BankCharge."GST Credit"::"Non-Availment");
        BankCharge.Insert();
        LibraryStorage.Set(BankChargeLbl, BankCharge.Code);
        if ForeignExchange then
            CreateBankDeemedValueSetup();
    end;

    local procedure CreateSecondBankCharge(ForeignExchange: Boolean)
    var
        BankCharge: Record "Bank Charge";
        GLAccount: Record "G/L Account";
        InputCreditAvailment: Boolean;
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        BankCharge.Init();
        BankCharge.Validate(Code, LibraryUtility.GenerateRandomCode(BankCharge.FieldNo(Code), Database::"Bank Charge"));
        BankCharge.Validate(Description, BankCharge.Code);
        BankCharge.Validate(Account, GLAccount."No.");
        BankCharge.Validate("Foreign Exchange", ForeignExchange);
        BankCharge.Validate("GST Group Code", LibraryStorage.Get(GSTGroupCodeLbl));
        BankCharge.Validate("HSN/SAC Code", LibraryStorage.Get(HSNSACCodeLbl));
        Evaluate(InputCreditAvailment, LibraryStorage.Get(InputCreditAvailmentLbl));
        if InputCreditAvailment then
            BankCharge.Validate("GST Credit", BankCharge."GST Credit"::Availment)
        else
            BankCharge.Validate("GST Credit", BankCharge."GST Credit"::"Non-Availment");
        BankCharge.Insert();
        LibraryStorage.Set(SecondBankChargeLbl, BankCharge.Code);
        if ForeignExchange then
            CreateBankDeemedValueSetup();
    end;

    procedure CreateGLAccountWithStraightLineDeferral(var DeferralCode: Code[10]): Code[20]
    var
        GLAccount: Record "G/L Account";
        DeferralTemplate: Record "Deferral Template";
    begin
        DeferralCode := CreateDeferralTemplate(
            DeferralTemplate."Calc. Method"::"Straight-Line",
            DeferralTemplate."Start Date"::"Posting Date", 12, LibraryUtility.GenerateGUID(), 100);

        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount.Validate("Default Deferral Template Code", DeferralCode);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    procedure CreateDeferralTemplate(CalcMethod: Enum "Deferral Calculation Method"; StartDate: Enum "Deferral Calculation Start Date"; NumOfPeriods: Integer; PeriodDescription: Text[50]; DeferralPct: Decimal): Code[10]
    var
        DeferralTemplate: Record "Deferral Template";
    begin
        LibraryERM.CreateDeferralTemplate(DeferralTemplate, CalcMethod, StartDate, NumOfPeriods);
        DeferralTemplate.Validate("Period Description", PeriodDescription);
        DeferralTemplate.Validate("Deferral %", DeferralPct);
        DeferralTemplate.Modify(true);
        exit(DeferralTemplate."Deferral Code");
    end;

    local procedure CreateGenJournalLineForGLToBank(var GenJournalLine: Record "Gen. Journal Line"; GLAccount: Code[20]; DeferralCode: Code[10]; BankAccNo: code[20])
    begin
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            CopyStr(LibraryStorage.Get(TemplateNameLbl), 1, 10), CopyStr(LibraryStorage.Get(BatchNameLbl), 1, 10),
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"G/L Account", GLAccount,
            GenJournalLine."Bal. Account Type"::"Bank Account", BankAccNo,
            LibraryRandom.RandDecInRange(1000, 10000, 0));
        GenJournalLine.Validate("Location Code", CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, 10));
        GenJournalLine.Validate("Deferral Code", DeferralCode);
        GenJournalLine.Validate("GST Group Code", LibraryStorage.Get(GSTGroupCodeLbl));
        GenJournalLine.Validate("HSN/SAC Code", LibraryStorage.Get(HSNSACCodeLbl));
        GenJournalLine.Validate("GST Credit", GenJournalLine."GST Credit"::Availment);
        GenJournalLine.Modify(true);
    end;

    local procedure UpdateBankCharges(var GenJournalLine: Record "Gen. Journal Line")
    var
        BankCharge: Record "Bank Charge";
    begin
        GenJournalLine.Validate("Bank Charge", true);
        GenJournalLine.Modify(true);

        BankCharge.Get(LibraryStorage.Get(BankChargeLbl));
        BankCharge.Validate(Account, GenJournalLine."Account No.");
        BankCharge.Modify();

        BankCharge.Get(LibraryStorage.Get(SecondBankChargeLbl));
        BankCharge.Validate(Account, GenJournalLine."Account No.");
        BankCharge.Modify();
    end;

    local procedure VerifyGLEntryCount(
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        ExpectedCount: Integer)
    var
        GLEntry: Record "G/L Entry";
        LibraryAssert: Codeunit "Library Assert";
    begin
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.SetRange("External Document No.", DocumentNo);
        GLEntry.FindFirst();
        LibraryAssert.RecordCount(GLEntry, ExpectedCount);
    end;

    local procedure CreateBankDeemedValueSetup()
    var
        BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
    begin
        BankChargeDeemedValueSetup.Init();
        BankChargeDeemedValueSetup.Validate("Bank Charge Code", LibraryStorage.Get(BankChargeLbl));
        BankChargeDeemedValueSetup.Validate("Lower Limit", LibraryRandom.RandDecInRange(0, 500, 0));
        BankChargeDeemedValueSetup.Validate("Upper Limit", LibraryRandom.RandDecInRange(500, 1000, 0));
        BankChargeDeemedValueSetup.Validate(Formula, BankChargeDeemedValueSetup.Formula::Comparative);
        BankChargeDeemedValueSetup.Validate("Min. Deemed Value", LibraryRandom.RandDecInRange(500, 1000, 0));
        BankChargeDeemedValueSetup.Validate("Max. Deemed Value", LibraryRandom.RandDecInRange(500, 1000, 0));
        BankChargeDeemedValueSetup.Validate("Deemed %", LibraryRandom.RandDecInRange(500, 1000, 0));
        BankChargeDeemedValueSetup.Validate("Fixed Amount", LibraryRandom.RandDecInRange(100, 500, 0));
        BankChargeDeemedValueSetup.Insert();
    end;

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        CompanyInformation.Get();
        if CompanyInformation."GST Registration No." = '' then begin
            if GSTRegistrationNos.FindFirst() then
                CompanyInformation.Validate("P.A.N. No.", CopyStr(GSTRegistrationNos.Code, 3, 10))
            else
                CompanyInformation.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        end else
            CompanyInformation.Validate("P.A.N. No.", CopyStr(CompanyInformation."GST Registration No.", 3, 10));
        CompanyInformation.Modify(true);
    end;

    [PageHandler]
    procedure TaxRatesPage(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(LibraryStorage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]); // KFloodCess
        TaxRates.OK().Invoke();
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGST: Codeunit "Library GST";
        LibrarySales: Codeunit "Library - Sales";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryStorage: Dictionary of [Text, Text];
        ComponentPerArray: array[20] of Decimal;
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        TemplateNameLbl: Label 'TemplateName';
        BatchNameLbl: Label 'BatchName';
        NoSeriesLbl: Label 'NoSeries';
        VendorNoLbl: Label 'VendorNo';
        BankAccountLbl: Label 'BankAccount';
        BankChargeLbl: Label 'BankCharge';
        SecondBankChargeLbl: Label 'SecondBankCharge';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        LocationStateCodeLbl: Label 'LocationStateCode';
        GSTBankChargeBoolErr: Label 'You Can not have multiple Bank Charges, when Bank Charge Boolean in General Journal Line is True.';
}
