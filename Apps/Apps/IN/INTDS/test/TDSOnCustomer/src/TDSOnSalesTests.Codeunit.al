codeunit 18683 "TDS On Sales Tests"
{
    Subtype = Test;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTDSOnCustomer: Codeunit "Library TDS On Customer";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
        Storage: Dictionary of [Text, Code[20]];
        StorageEnum: Dictionary of [Text, Text];
        RowNotFoundErr: Label 'The row does not exist on the TestPage.', Locked = true;
        CertifcateValidationErr: Label 'TDS Certificate Receivable is false', Locked = true;
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        SectionCodeLbl: Label 'SectionCode', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        AccountTypeLbl: Label 'AccountType', Locked = true;
        AccountNoLbl: Label 'AccountNo', Locked = true;
        DocumentNoLbl: Label 'DocumentNo', Locked = true;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckTDSCertificateReceivableInGeneralJournal()
    var
        Customer: Record Customer;
        TDSPostingSetup: Record "TDS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [357191] [Check if the system is allowing to place check mark in TDS Certificate receivable field in General Journal.]
        // [Given] Customer Setup &  G/L Account Setups
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");

        // [Then] Verification of Feild value.
        Assert.IsTrue(GenJournalLine."TDS Certificate Receivable", CertifcateValidationErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateCashReceiptVoucherWithTDSReceivable()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO] [357204] [Check if the system is allowing to place check mark in TDS Certificate receivable field in Cash Receipt Journals - TDSC016/TDSC017.]
        // [Given] Customer Setup &  G/L Account Setups & Cash Receipt Voucher.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [When] Creation of GenjnlLine and Marking TDS Certificate True.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            TDSPostingSetup."TDS Section", Location.Code);

        // [Then] Verification of Feild value.
        Assert.IsTrue(GenJournalLine."TDS Certificate Receivable", CertifcateValidationErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdatePage,RectifyTDSCertificate')]
    procedure CheckRectifyTDSCertificateWhenTDSCertificateSetFalse()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357239]	[Check if the system is deleting entry from Rectify TDS Cert. Details window when check mark removed from TDS Certificate Received field of Rectify TDS Cert. Details window - TDSC052]
        // [Given] Customer Setup &  G/L Account Setups & TDS Tax Setups.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True & Posting.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [Then] Verification of Certificate Update Page & Rectify TDS Certificate Page.
        UpdateAndRectifyCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdatePage,RectifyTDSCertificateView')]
    procedure CheckIfSystemIsDeletingEntryInUpdateWindow()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [357238] [Check if the system is deleting entry in Update TDS Cert. Details window and generating entry in Rectify TDS Cert. Details window, when check mark is placed in TDS Certificate Received field of Update TDS Cert. Details window - TDSC051]
        // [Given] Customer Setup &  G/L Account Setups & TCS Setup,TCS Section Created Tax Rate Setup.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True with TDS Section.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");

        // [When] Posting of General journal Line 
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN]  Update and Rectify TDS Certificate.
        UpdateAndRectifyCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdatePage,RectifyTDSCertificateFalse')]
    procedure CheckIfSystemIsGeneratingEntryInUpdateTDSCertficateWindow()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [357240] [Check if the system is generating entry in Update TDS Cert. Details window when check mark removed from TDS Certificate Received field of Rectify TDS Cert. Details window - TDSC053]
        // [Given] Customer Setup &  G/L Account Setups & TCS Setup,TCS Section Created Tax Rate Setup.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True with TDS Section.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");

        // [When] Posting of GenjnlLine 
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN]  Update and Rectify TDS Certificate.
        UpdateAndRectifyCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,UncheckCertificateUpdatePage,CertificateAssignHandlerView')]
    procedure AssingCertificateIfCheckMarkRemovedFromUpdateDetials()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357241[Check if the system is generating entry in Assign TDS Cert. Details window when check mark removed from TDS Certificate Receivable field of Update TDS Cert. Details window -TDSC054.]
        // [Given] Customer Setup &  G/L Account Setups & TCS Setup,TCS Section Created Tax Rate Setup.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True with TDS Section.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");

        // [When] Posting of GenjnlLine 
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        UpdateAndAssignCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckTDSCertificateReceivableInCustomerLedger()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VoucherType: Enum "Gen. Journal Template Type";
        ReceivableFalseErr: Label 'The feild value is false';
    begin
        //[SCENARIO ] [357214] [Check if the system is flowing TDS Certificate receivable field in Customer Ledger Entry -TDSC027]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post General Journal
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.IsTrue(CustLedgEntry."TDS Certificate Receivable", ReceivableFalseErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandler')]
    procedure IncaseofTrueCheckVisibleinAssignPageofCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        //[SCENARIO ] [357194] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in General Journals - TDSC005]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [When] Creation of GenjnlLine and Marking TDS Certificate True & Posting.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verification of Entry in Assign TDS Certificate
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DisplayCertificateAssignPage')]
    procedure IncaseofFalseCheckVisibleinAssignPageofCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357195] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in General Journals - TDSC006]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post General Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, '');
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assign TDS Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DisplayCertificateAssignPageReceived')]
    procedure IncaseofFalseAssignCertificateTrue()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357237] [Check if the system is deleting entry from Assign TDS Cert details window and generating entry in Update TDS Cert. Details window when check mark is placed  in Assign TDS Cert details window - TDSC050]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post General Journals
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, '');
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assign TDS Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ViewCertificateUpdatePage')]
    procedure CheckInCaseOfCertificateReceivableIsTrue()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357192] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in General Journals - TDSC003]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post GenJournalLine with TDSCertifcateReceivable
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdateDetials')]
    procedure CheckInCaseOfCertificateReceivableISFlase()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        //[SCENARIO ] [357193] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in General Journals -TDSC004]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post GenJournalLine with TDSCertifcateReceivable
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, '');
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ViewCertificateUpdatePage')]
    procedure CheckInCaseOfCertificateReceivableISTrueInCashReceiptJournal()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357242] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Cash Receipt Journals - TDSC055]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            TDSPostingSetup."TDS Section", Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ViewCertificateUpdatePage')]
    procedure CheckInCaseOfCertificateReceivableISTrueInJournalVoucher()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357210] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Journal Voucher - TDSC023]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Journal Voucher", GLAccount, Location);

        // [WHEN] Create and Post Journal Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Journal Voucher",
            TDSPostingSetup."TDS Section", Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdateDetials')]
    procedure CheckInCaseOfCertificateReceivableIsFalseInJournalVoucher()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        //[SCENARIO ] [357211] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Journal Voucher - TDSC024]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Journal Voucher", GLAccount, Location);

        // [WHEN] Create and Post Journal Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Journal Voucher",
            '', Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandler')]
    procedure CheckInCaseOfCertificateReceivableIsTrueInJournalVoucherAssignPage()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357212]	[Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Journal Voucher - TDSC025]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Journal Voucher", GLAccount, Location);

        // [WHEN] Create and Post Journal Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Journal Voucher",
            TDSPostingSetup."TDS Section", Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assign TDS Certificate Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandlerView')]
    procedure CheckInCaseOfCertificateReceivableIsFalseInJournalVoucherAssignPage()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357213] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Journal Voucher -TDSC026]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Journal Voucher", GLAccount, Location);

        // [WHEN] Create and Post Journal Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Journal Voucher",
            '', Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assign TDS Certificate Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateUpdateDetials')]
    procedure CheckInCaseOfCertificateReceivableIsFalseInCashReceiptJournal()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        AccountType: Enum "Gen. Journal Account Type";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO ] [357243] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Cash Receipt Journals - TDSC056]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            '', Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Update TDS Certificate Page
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandler')]
    procedure CheckInAssingTDSCaseOfCertificateReceivableIsTrueInCashReceiptJournal()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357244] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Cash Receipt Journals -TDSC057]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            TDSPostingSetup."TDS Section", Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assing TDS Certificate Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandlerView')]
    procedure CheckInAssingTDSCaseOfCertificateReceivableIsFalseInCashReceiptJournal()
    var
        Customer: Record Customer;
        Location: Record Location;
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO ] [357245] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed in TDS Certificate receivable field in Cash Receipt Journals -TDSC058]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            '', Location.Code);
        Storage.Set(DocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify  for TDS Certificate Receivable on Assing TDS Certificate Page
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DisplayCertificateAssignPage')]
    procedure SalesOrderWithTDSCertReceFlaseWithAssignTDSCertificate()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        DocumentNo: Code[20];
    begin
        // [SCENARIO ] [357229]	[Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Sales Order header - TDSC042]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithoutTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        Storage.Set(DocumentNoLbl, DocumentNo);
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure SalesInvoiceWithoutTDSCertReceWithUpdateTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        //[SCENARIO ] [357231] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Sales Invoice header - TDSC044]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithoutTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,AssignHandlerForFlase')]
    procedure SalesInvoiceWithoutTDSCertReceWithAssignTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        //[SCENARIO ] [357233] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Sales Invoice header -TDSC046]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithoutTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Assign TDS Certificate Page
        Storage.Set(DocumentNoLbl, DocumentNo);
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure SalesInvoiceWithTDSCertReceWithUpdateTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // [SCENARIO ] [357230] [Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Sales Invoice header -TDSC043]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        Storage.Set(DocumentNoLbl, DocumentNo);
        UpdateCertificate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CertificateAssignHandler')]
    procedure SalesInvoiceWithTDSCertReceWithAssignTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        //[SCENARIO ] [357232] [Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Sales Invoice header -TDSC045]
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Assign TDS Certificate Page
        LibraryVariableStorage.Enqueue(DocumentNo);
        AssignCertifcate(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    local procedure CreateTaxRateSetup(
        TDSSection: Code[10];
        AssesseeCode: Code[10];
        ConcessionlCode: Code[10];
        EffectiveDate: Date)
    var
        Section: Code[10];
        TDSAssesseeCode: Code[10];
        TDSConcessionlCode: Code[10];
    begin
        Section := TDSSection;
        Storage.Set(SectionCodeLbl, Section);
        TDSAssesseeCode := AssesseeCode;
        Storage.Set(TDSAssesseeCodeLbl, TDSAssesseeCode);
        TDSConcessionlCode := ConcessionlCode;
        Storage.Set(TDSConcessionalCodeLbl, TDSConcessionlCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure CreateTaxRate()
    var
        TDSSetup: Record "TDS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TDSSetup.Get() then
            exit;
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TDSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure UpdateCertificate(
        CustomerCode: Code[20];
        TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue("CustomerCode");
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100000, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Update TDS Cert. Details".Invoke();
    end;

    local procedure UpdateAndRectifyCertificate(
        CustomerCode: Code[20];
        TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue("CustomerCode");
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100000, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Update TDS Cert. Details".Invoke();
        UpdateCertifcate."Rectify TDS Cert. Details".Invoke();
    end;

    local procedure UpdateAndAssignCertificate(
        CustomerCode: Code[20];
        TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue("CustomerCode");
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100000, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Update TDS Cert. Details".Invoke();
        UpdateCertifcate."Assign TDS Cert. Details".Invoke();
    end;

    local procedure AssignCertifcate(CustomerCode: Code[20]; TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue(CustomerCode);
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Assign TDS Cert. Details".Invoke();
    end;

    local procedure CreateGLAccWithVoucherAccount(
        AccountType: Enum "Gen. Journal Account Type";
        VoucherType: Enum "Gen. Journal Template Type";
        var GLAccount: Record "G/L Account";
        var Location: Record Location): Code[20]
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryTDSOnCustomer.CreateLocationWithTANNo(Location);
        StorageEnum.Set(AccountTypeLbl, Format(AccountType));
        Storage.Set(AccountNoLbl, GLAccount."No.");
        CreateVoucherAccountSetup(VoucherType, Location.Code);
        exit(GLAccount."No.");
    end;

    local procedure CreateVoucherAccountSetup(SubType: Enum "Gen. Journal Template Type"; LocationCode: Code[10])
    var
        TaxBasePublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := Storage.Get(AccountNoLbl);
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBasePublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    TaxBasePublishers.InsertVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBasePublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBasePublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
        end;
    end;

    [PageHandler]
    procedure CheckTDSCertRecOnUpdateTDSCertDetailsPage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        DocumentNo: Code[20];
    begin
        DocumentNo := Storage.Get(DocumentNoLbl);
        CustomerLedgerEntry.SetRange("Document No.", DocumentNo);
        CustomerLedgerEntry.SetRange("TDS Certificate Receivable", true);
        CustomerLedgerEntry.FindFirst();
        UpdateTDSCertDetails.GoToRecord(CustomerLedgerEntry);
        Assert.Equal(true, UpdateTDSCertDetails."TDS Certificate Receivable".AsBoolean());
    end;

    [PageHandler]
    procedure CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentNo: Code[20];
        Value: Variant;
    begin
        LibraryVariableStorage.Dequeue(Value);
        DocumentNo := Value;
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange("TDS Certificate Receivable", false);
        CustLedgerEntry.FindFirst();
        asserterror UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
        Assert.ExpectedError(RowNotFoundErr);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        EffectiveDate: Date;
        TDSPercentage: Decimal;
        NonPANTDSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        TDSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        GenerateTaxComponentsPercentage();
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(SectionCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(TDSAssesseeCodeLbl));
        TaxRates.AttributeValue3.SetValue(EffectiveDate);
        TaxRates.AttributeValue4.SetValue(Storage.Get(TDSConcessionalCodeLbl));
        TaxRates.AttributeValue5.SetValue('');
        TaxRates.AttributeValue6.SetValue('');
        TaxRates.AttributeValue7.SetValue('');
        TaxRates.AttributeValue8.SetValue(TDSPercentage);
        TaxRates.AttributeValue9.SetValue(NonPANTDSPercentage);
        TaxRates.AttributeValue10.SetValue(SurchargePercentage);
        TaxRates.AttributeValue11.SetValue(eCessPercentage);
        TaxRates.AttributeValue12.SetValue(SHECessPercentage);
        TaxRates.AttributeValue13.SetValue(TDSThresholdAmount);
        TaxRates.AttributeValue14.SetValue(SurchargeThresholdAmount);
        TaxRates.AttributeValue15.SetValue(0);
        TaxRates.OK().Invoke();
    end;

    [PageHandler]
    procedure UncheckCertificateUpdatePage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentNo: Code[20];
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if not CustLedgerEntry.IsEmpty then
            UpdateTDSCertDetails."TDS Certificate Receivable".SetValue(false);
        LibraryVariableStorage.Enqueue(DocumentNo);
    end;

    [PageHandler]
    procedure ViewCertificateUpdatePage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if CustLedgerEntry.FindFirst() then
            UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
    end;

    [PageHandler]
    procedure CertificateUpdatePage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if CustLedgerEntry.FindFirst() then
            UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
        UpdateTDSCertDetails."TDS Certificate Received".SetValue(true);
        UpdateTDSCertDetails."Update TDS Cert. Details".Invoke();
    end;

    [PageHandler]
    procedure RectifyTDSCertificate(var RectifyTDSCertDetails: TestPage "Rectify TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if CustLedgerEntry.FindFirst() then
            RectifyTDSCertDetails.GoToRecord(CustLedgerEntry);
        RectifyTDSCertDetails."TDS Certificate Received".SetValue(false);
    end;

    [PageHandler]
    procedure RectifyTDSCertificateFalse(var RectifyTDSCertDetails: TestPage "Rectify TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if CustLedgerEntry.FindFirst() then
            RectifyTDSCertDetails.GoToRecord(CustLedgerEntry);
        RectifyTDSCertDetails."TDS Certificate Received".SetValue(false);
    end;

    [PageHandler]
    procedure RectifyTDSCertificateView(var RectifyTDSCertDetails: TestPage "Rectify TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        if CustLedgerEntry.FindFirst() then
            RectifyTDSCertDetails.GoToRecord(CustLedgerEntry);
    end;

    [PageHandler]
    procedure CertificateUpdateDetials(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        asserterror UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
        LibraryAssert.ExpectedError(RowNotFoundErr);
    end;

    [PageHandler]
    procedure DisplayCertificateAssignPage(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
    end;

    [PageHandler]
    procedure DisplayCertificateAssignPageReceived(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
        AssignTDSCertDetails."TDS Certificate Receivable".SetValue(true);
        AssignTDSCertDetails.Close();
    end;

    [PageHandler]
    procedure CertificateAssignHandlerView(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
    end;

    [PageHandler]
    procedure CertificateAssignHandler(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        asserterror AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
        LibraryAssert.ExpectedError(RowNotFoundErr);
    end;

    [PageHandler]
    procedure AssignHandlerForFlase(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := LibraryTDSOnCustomer.GetEntryNo(Storage.Get(DocumentNoLbl));
        CustLedgerEntry.SetRange("Entry No.", EntryNo);
        CustLedgerEntry.FindFirst();
        AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
    end;
}