// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.DirectDebit;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 144038 "UT SEPA"
{
    //  1 -  8. Purpose of the test is to verify error of Report ID - 10827 (SEPA ISO20022).
    //  9 - 12. Purpose of the test is to verify error of Table ID - 10806 (Payment Line).
    //      13. Purpose of the test is to verify trigger Modify on page ID - 10808 (Payment Line List).
    // 14 - 15. Purpose of the test is to verify OnValidate trigger of IBAN on Table ID - 10805, 10807 (Payment Header Archive, Payment Line Archive).
    //
    // Covers Test Cases for WI -  343904
    // ----------------------------------------------------------------------------------------------
    // Test Function Name                                                                      TFS ID
    // ----------------------------------------------------------------------------------------------
    // OnAfterGetRecPmtHeaderSEPAISO20022Error                                                216877
    // OnAfterGetRecPmtHeaderBankAccSEPAISO20022Error                                         216871
    // OnAfterGetRecPmtHdrLocCurrEUROSEPAISO20022Error                                 216932,216870
    // OnAfterGetRecPmtHdrIBANSEPAISO20022Error                                        216875,216873
    // OnAfterGetRecPmtHdrSWIFTCodeSEPAISO20022Error                                          216872
    // OnAfterGetRecPmtHeaderCutomerSEPAISO20022Error                                         216874
    // OnAfterGetRecPmtHeaderVendorSEPAISO20022Error                                          216868
    // OnAfterGetRecPmtHdrLocCurrOtherSEPAISO20022Error                                216930,216869
    // OnValidateIBANPaymentLineError                                                         216928
    // OnDeletePaymentLineError                                                               216931
    // OnInsertPaymentLineError                                                               216929
    // OnModifyPaymentLineError                                                               216876
    //
    // Covers Test Cases for WI -  344437
    // ----------------------------------------------------------------------------------------------
    // Test Function Name                                                                      TFS ID
    // ----------------------------------------------------------------------------------------------
    // OnActionModifyPaymentLineList
    // OnValidateIBANPaymentHeaderArchive
    // OnValidateIBANPaymentLineArchive

    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
        // [FEATURE] [SEPA]
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryXMLReadOnServer: Codeunit "Library - XML Read OnServer";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        FileManagement: Codeunit "File Management";
        DialogErr: Label 'Dialog';
        IBANTxt: Text;
        TestFieldLbl: Label 'TestField';
        WrongIBANErr: Label 'Wrong number in the field IBAN.';
        isInitialized: Boolean;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHeaderSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with SEPA Allowed as False on Country/Region.
        // Verify actual error: "SEPA Allowed is not enabled for Country/Region."
        CreatePaymentSlipForReportSEPAISO20022(
          false, PaymentHeader."Account Type"::Vendor, '', LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode(), DialogErr);  // SEPA Allowed as False. Currency Code as blank.    
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHeaderBankAccSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with Account Type other than Customer or Vendor on Payment Line.
        // Verify actual error: "Payment Lines can only be of type Customer or Vendor for SEPA."
        CreatePaymentSlipForReportSEPAISO20022(
          true, PaymentHeader."Account Type"::"Bank Account", '', LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode(), DialogErr);  // SEPA Allowed as True. Currency Code as blank.    
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHdrLocCurrEUROSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with Local Currency EURO on General Ledger Setup.
        // Verify actual error: "Currency is not Euro in the Payment Line."
        CreatePaymentSlipForReportSEPAISO20022(
          true, PaymentHeader."Account Type"::Vendor, CreateCurrency(), LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode(), DialogErr);  // SEPA Allowed as True.    
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHdrIBANSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with IBAN as blank on Payment Header.
        // Verify actual error: "IBAN must have a value in Payment Header"
        CreatePaymentSlipForReportSEPAISO20022(
          true, PaymentHeader."Account Type"::Vendor, CreateCurrency(), '', LibraryUTUtility.GetNewCode(), TestFieldLbl);  // SEPA Allowed as True. Currency Code and IBAN as blank.    
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHdrSWIFTCodeSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with SWIFT Code as blank on Payment Header.
        // Verify actual error: "SWIFT Code must have a value in Payment Header"
        CreatePaymentSlipForReportSEPAISO20022(
          true, PaymentHeader."Account Type"::Vendor, CreateCurrency(), LibraryUTUtility.GetNewCode(), '', TestFieldLbl);  // SEPA Allowed as True. Currency Code and SWIFT Code as blank.    
    end;

    [TransactionModel(TransactionModel::AutoRollback)]
    local procedure CreatePaymentSlipForReportSEPAISO20022(SEPAAllowed: Boolean; AccountType: Enum "Gen. Journal Account Type"; CurrencyCode: Code[10]; IBAN: Code[50]; SWIFTCode: Code[20]; ErrorCode: Text[50])
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // Setup: Create Vendor Bank Account. Create Payment Slip.
        Initialize();

        CreateVendorBankAccount(VendorBankAccount, SEPAAllowed);

        // Enqueue Payment Slip No. for SEPAISO20022RequestPageHandler.
        LibraryVariableStorage.Enqueue(
          CreatePaymentSlip(
            AccountType, VendorBankAccount."Vendor No.", VendorBankAccount.Code, CurrencyCode, VendorBankAccount."Country/Region Code",
            IBAN, SWIFTCode));

        // Exercise.
        asserterror REPORT.Run(REPORT::"SEPA ISO20022 FR");

        // Verify.
        Assert.ExpectedErrorCode(ErrorCode);
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHeaderCutomerSEPAISO20022Error()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with Account Type Customer on Payment Line.

        // Setup: Create Customer Bank Account. Create Payment Slip.
        Initialize();

        CreateCustomerBankAccount(CustomerBankAccount);

        // Enqueue Payment Slip No. for SEPAISO20022RequestPageHandler.
        LibraryVariableStorage.Enqueue(
          CreatePaymentSlip(
            PaymentHeader."Account Type"::Customer, CustomerBankAccount."Customer No.", CustomerBankAccount.Code, '',
            CreateCountryRegion(true), LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode()));  // SEPA Allowed as True. Currency Code as blank.

        // Exercise.
        asserterror REPORT.Run(REPORT::"SEPA ISO20022 FR");

        // Verify: Verify actual error: "SEPA Allowed is not enabled for Country/Region."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHeaderVendorSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with Account Type Vendor on Payment Line.

        // Setup: Create Vendor Bank Account. Create Payment Slip.
        Initialize();

        CreateVendorBankAccount(VendorBankAccount, false);  // SEPA Allowed as False.

        // Enqueue Payment Slip No. for SEPAISO20022RequestPageHandler.
        LibraryVariableStorage.Enqueue(
          CreatePaymentSlip(
            PaymentHeader."Account Type"::Vendor, VendorBankAccount."Vendor No.", VendorBankAccount.Code, '',
            CreateCountryRegion(true), LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode()));  // SEPA Allowed as True. Currency Code as blank.

        // Exercise.
        asserterror REPORT.Run(REPORT::"SEPA ISO20022 FR");

        // Verify: Verify actual error: "SEPA Allowed is not enabled for Country/Region."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecPmtHdrLocCurrOtherSEPAISO20022Error()
    var
        PaymentHeader: Record "Payment Header FR";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // Purpose of the test is to verify error of Report 10883 (SEPA ISO20022) with Local Currency Other on General Ledger Setup.

        // Setup: Create Vendor Bank Account. Create Payment Slip.
        Initialize();

        UpdateGeneralLedgerSetup();
        CreateVendorBankAccount(VendorBankAccount, true);  // SEPA Allowed as True.

        // Enqueue Payment Slip No. for SEPAISO20022RequestPageHandler.
        LibraryVariableStorage.Enqueue(
          CreatePaymentSlip(
            PaymentHeader."Account Type"::Vendor, VendorBankAccount."Vendor No.", VendorBankAccount.Code, CreateCurrency(),
            VendorBankAccount."Country/Region Code", LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode()));

        // Exercise.
        asserterror REPORT.Run(REPORT::"SEPA ISO20022 FR");

        // Verify: Verify actual error: "Currency is not Euro in the Payment Line."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('IBANConfirmHandler')]
    procedure CheckPaymentLineIBANConfirmYes()
    var
        PaymentLine: Record "Payment Line FR";
        IBANNumber: Code[50];
    begin
        // [SCENARIO] Invalid IBAN for Payment Line is set in case of Stan confirms its setting.
        // [GIVEN] Payment Line.

        PaymentLine.Init();
        IBANNumber := LibraryUtility.GenerateGUID();

        // [WHEN] Set invalid IBAN for Payment Line. Confim setting of IBAN in the dialog.
        LibraryVariableStorage.Enqueue(true);
        PaymentLine.Validate(IBAN, IBANNumber);

        // [THEN] New IBAN is set.
        VerifyIBAN(PaymentLine.IBAN, IBANNumber);
    end;

    [Test]
    [HandlerFunctions('IBANConfirmHandler')]
    procedure CheckPaymentLineIBANConfirmNo()
    var
        PaymentLine: Record "Payment Line FR";
        OldIBAN: Code[50];
    begin
        // [SCENARIO] Invalid IBAN for Payment Line is not set in case of Stan rejects its setting.
        // [GIVEN] Payment Line.

        PaymentLine.Init();
        OldIBAN := PaymentLine.IBAN;

        // [WHEN] Set invalid IBAN for Payment Line. Reject setting of IBAN in the dialog.
        LibraryVariableStorage.Enqueue(false);
        asserterror PaymentLine.Validate(IBAN, LibraryUtility.GenerateGUID());

        // [THEN] New IBAN is not set.
        VerifyIBAN(PaymentLine.IBAN, OldIBAN);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnDeletePaymentLineError()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to verify error of Table ID - 10806 (Payment Line) when delete Payment Line.

        // Setup: Create Payment Slip.
        Initialize();

        CreatePaymentHeader(PaymentHeader, '', '', '');  // IBAN, SWIFT Code and Country Region Code as blank.
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine."Copied To No." := LibraryUTUtility.GetNewCode();
        PaymentLine.Insert();

        // Exercise.
        asserterror PaymentLine.Delete(true);

        // Verify: Verify actual error: "You cannot delete this payment line."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnInsertPaymentLineError()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to verify error of Table ID - 10806 (Payment Line) when Currency is different on Payment Header and Payment Line.

        // Setup: Create Payment Slip.
        Initialize();

        CreatePaymentHeader(PaymentHeader, '', '', '');  // IBAN, SWIFT Code and Country Region Code as blank.
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine.IsCopy := true;
        PaymentLine."Currency Code" := CreateCurrency();

        // Exercise.
        asserterror PaymentLine.Insert(true);

        // Verify: Verify actual error: "You cannot use different currencies on the same payment header."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnInsertPaymentLineAfterFileGeneratedErr()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        RecRef: RecordRef;
    begin
        // [SCENARIO 363057] Error message when inserting Payment Line in Payment Header with "File Export Completed" = TRUE
        Initialize();


        // [GIVEN] Create Payment Header with "File Export Completed" = TRUE
        CreatePaymentHeader(PaymentHeader, '', '', '');
        PaymentHeader.Validate("File Export Completed", true);
        PaymentHeader.Modify(true);

        // [GIVEN] Create Payment Line
        PaymentLine.Init();
        PaymentLine."No." := PaymentHeader."No.";
        RecRef.GetTable(PaymentLine);
        PaymentLine."Line No." := LibraryUtility.GetNewLineNo(RecRef, PaymentLine.FieldNo("Line No."));

        // [WHEN] Payment Line is inserted
        asserterror PaymentLine.Insert(true);

        // [THEN] An error is thrown indicating an error with Payment Header field "File Export Completed"
        Assert.ExpectedErrorCode(TestFieldLbl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnModifyPaymentLineError()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to verify error of Table ID - 10806 (Payment Line) when modify Payment Line which is already posted.

        // Setup: Create Payment Slip.
        Initialize();

        CreatePaymentHeader(PaymentHeader, '', '', '');  // IBAN, SWIFT Code and Country Region Code as blank.
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine.Insert();
        PaymentLine.Posted := true;

        // Exercise.
        asserterror PaymentLine.Modify(true);

        // Verify: Verify actual error: "You cannot modify this payment line."
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('PaymentLineModificationPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnActionModifyPaymentLineList()
    var
        PaymentHeader: Record "Payment Header FR";
        VendorBankAccount: Record "Vendor Bank Account";
        PaymentLinesList: TestPage "Payment Lines List FR";
        No: Code[20];
    begin
        // Purpose of the test is to validate action Modify on Payment Line List page ID - 10808.

        // Setup: Create Vendor Bank Account and Payment Slip.
        Initialize();

        CreateVendorBankAccount(VendorBankAccount, true);  // SEPA Allowed as True.
        No :=
          CreatePaymentSlip(
            PaymentHeader."Account Type"::Vendor, VendorBankAccount."Vendor No.", VendorBankAccount.Code, CreateCurrency(),
            VendorBankAccount."Country/Region Code", LibraryUTUtility.GetNewCode(), LibraryUTUtility.GetNewCode());
        PaymentLinesList.OpenEdit();
        PaymentLinesList.FILTER.SetFilter("No.", No);
        LibraryVariableStorage.Enqueue(No);  // Enqueue Payment No. for PaymentLineModificationPageHandler.

        // Exercise: call action Modify on Payment Line List page.
        PaymentLinesList.Modify.Invoke();  // Call PaymentLineModificationPageHandler.

        // Verify: Verify updated value on Payment Line List page after action Modify.
        PaymentLinesList."Drawee Reference".AssertEquals(CopyStr(No, 1, 10));
        PaymentLinesList.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateIBANPaymentHeaderArchive()
    var
        PaymentHeaderArchive: Record "Payment Header Archive FR";
        PaymentHeaderArchive2: Record "Payment Header Archive FR";
    begin
        IBANTxt := 'FR14 2004 1010 0505 0001 3M02 606';
        // Purpose of the test is to validate trigger OnValidate of IBAN field on Table IDs - 10867 (Payment Header Archive).

        // Setup: Create Payment Header Archive with IBAN.
        Initialize();

        PaymentHeaderArchive."No." := LibraryUTUtility.GetNewCode();

        // Exercise.
        PaymentHeaderArchive.Validate(IBAN, IBANTxt);  // Validate required for check the trigger.
        PaymentHeaderArchive.Insert();

        // Verify: Verify updated value on Payment Header Archive table.
        PaymentHeaderArchive2.Get(PaymentHeaderArchive."No.");
        PaymentHeaderArchive2.TestField(IBAN, IBANTxt);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateIBANPaymentLineArchive()
    var
        PaymentLineArchive: Record "Payment Line Archive FR";
        PaymentLineArchive2: Record "Payment Line Archive FR";
    begin
        IBANTxt := 'FR14 2004 1010 0505 0001 3M02 606';
        // Purpose of the test is to validate trigger OnValidate of IBAN field on Table IDs - 10868 (Payment Line Archive).

        // Setup: Create Payment Line Archive with IBAN.
        Initialize();

        PaymentLineArchive."No." := LibraryUTUtility.GetNewCode();
        PaymentLineArchive."Line No." := LibraryRandom.RandInt(1000);  // Using Random Int for Line No.

        // Exercise.
        PaymentLineArchive.Validate(IBAN, IBANTxt);  // Validate required for check the trigger.
        PaymentLineArchive.Insert();

        // Verify: Verify updated value on Payment Line archive table.
        PaymentLineArchive2.Get(PaymentLineArchive."No.", PaymentLineArchive."Line No.");
        PaymentLineArchive2.TestField(IBAN, IBANTxt);
    end;

    [Test]
    procedure MessagetoRecipientGenJournalLineFromCustLedgerEntries()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[10];
        CustomerNo: Code[20];
        PaymentNo: Code[20];
        Result: Text;
    begin
        // [FEATURE] [UT][Customer]
        // [SCENARIO 377537] "Message to Recipient" of "Gen. Journal Line" should contain "Document No." from payment applied to Customer Ledger Entries
        Initialize();


        // [GIVEN] 20 records of Customer ledger entries
        // [GIVEN] Length of merged "Document No." is more than 140 symbols
        Result := CreateCustLedgerEntries(LibraryRandom.RandIntInRange(15, 20), CustomerNo, DocumentNo);
        // [GIVEN] Customer payment general journal line, applied to 20 customer ledger entries
        PaymentNo := CreatePaymentDocument(GenJournalLine."Account Type"::Customer, CustomerNo, DocumentNo);

        // [WHEN] Invoke "SEPA CT-Prepare Source"
        GenJournalLine.SetFilter("Document No.", PaymentNo);
        CODEUNIT.Run(CODEUNIT::"SEPA CT-Prepare Source", GenJournalLine);

        // [THEN] "Gen. Journal Line"."Message to Recipient" is equal to first 140 symbols of merged "Document No."s from Customer Ledger Entries
        GenJournalLine.Find();
        GenJournalLine.TestField("Message to Recipient",
          CopyStr(Result, MaxStrLen(GenJournalLine.Description) + 9, MaxStrLen(GenJournalLine."Message to Recipient")));

        // TearDown
        GenJournalLine.Delete(true);
    end;

    [Test]
    procedure MessagetoRecipientGenJournalLineFromVendLedgerEntries()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[10];
        VendorNo: Code[20];
        PaymentNo: Code[20];
        Result: Text;
    begin
        // [FEATURE] [UT][Vendor]
        // [SCENARIO 377537] "Message to Recipient" of "Gen. Journal Line" should contain "Document No." from payment applied to Vendor Ledger Entries
        Initialize();


        // [GIVEN] 20 records of Vendor ledger entries
        // [GIVEN] Length of merged "Document No." is more than 140 symbols
        Result := CreateVendLedgerEntries(LibraryRandom.RandIntInRange(15, 20), VendorNo, DocumentNo);
        // [GIVEN] Vendor payment general journal line, applied to 20 vendor ledger entries
        PaymentNo := CreatePaymentDocument(GenJournalLine."Account Type"::Vendor, VendorNo, DocumentNo);

        // [WHEN] Invoke "SEPA CT-Prepare Source"
        GenJournalLine.SetFilter("Document No.", PaymentNo);
        CODEUNIT.Run(CODEUNIT::"SEPA CT-Prepare Source", GenJournalLine);

        // [THEN] "Gen. Journal Line"."Message to Recipient" is equal to first 140 symbols of merged "Document No."s from Vendor Ledger Entries
        GenJournalLine.Find();
        GenJournalLine.TestField("Message to Recipient",
          CopyStr(Result, MaxStrLen(GenJournalLine.Description) + 9, MaxStrLen(GenJournalLine."Message to Recipient")));

        // TearDown
        GenJournalLine.Delete(true);
    end;

    [Test]
    [HandlerFunctions('SEPAISO20022RequestPageHandler')]
    procedure PstlAdrInInitgPtyFromCompanyInfoAdressSEPAISO20022()
    var
        PaymentHeader: Record "Payment Header FR";
        VendorBankAccount: Record "Vendor Bank Account";
        FileName: Text;
    begin
        // [FEATURE] [Credit Transfer]
        // [SCENARIO 312137] There is no company postal address inside <InitgPty> node in the report "SEPA ISO20022" results.
        Initialize();


        // [GIVEN] Payment Slip for Vendor. Address fields of Company Information are filled.
        UpdateCompanyInfoAddressToMaxValues();
        CreateVendorBankAccount(VendorBankAccount, true);
        LibraryVariableStorage.Enqueue(
          CreatePaymentSlip(
            PaymentHeader."Account Type"::Vendor, VendorBankAccount."Vendor No.", VendorBankAccount.Code, '',
            VendorBankAccount."Country/Region Code", LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID()));
        Commit();
        FileName := FileManagement.ServerTempFileName('.xml');

        // [WHEN] Run "SEPA ISO20022" report.
        RunSEPAISO20022(FileName);

        // [THEN] Node <InitgPty> does not have a child nodes <PstlAdr> and <StrtNm>, <PstCd>, <TwnNm>, <Ctry>.
        LibraryXMLReadOnServer.Initialize(FileName);
        LibraryXMLReadOnServer.VerifyNodeAbsenceInSubtree('InitgPty', 'PstlAdr');
        LibraryXMLReadOnServer.VerifyElementAbsenceInSubtree('InitgPty', 'StrtNm');
        LibraryXMLReadOnServer.VerifyElementAbsenceInSubtree('InitgPty', 'PstCd');
        LibraryXMLReadOnServer.VerifyElementAbsenceInSubtree('InitgPty', 'TwnNm');
        LibraryXMLReadOnServer.VerifyNodeAbsenceInSubtree('InitgPty', 'Ctry');
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if isInitialized then
            exit;

        LibrarySetupStorage.Save(DATABASE::"Company Information");

        isInitialized := true;
    end;

    local procedure CreateCountryRegion(SEPAAllowed: Boolean): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.Code := LibraryUTUtility.GetNewCode10();
        CountryRegion."SEPA Allowed" := SEPAAllowed;
        CountryRegion.Insert();
        exit(CountryRegion.Code);
    end;

    local procedure CreateCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        Currency.Code := LibraryUTUtility.GetNewCode10();
        Currency.Insert();
        exit(Currency.Code);
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account")
    begin
        CustomerBankAccount."Customer No." := CreateCustomer();
        CustomerBankAccount.Code := LibraryUTUtility.GetNewCode10();
        CustomerBankAccount."Country/Region Code" := CreateCountryRegion(false);  // SEPA Allowed as False.
        CustomerBankAccount.Insert();
    end;

    local procedure CreatePaymentHeader(var PaymentHeader: Record "Payment Header FR"; BankCountryRegionCode: Code[10]; IBAN: Code[50]; SWIFTCode: Code[20])
    begin
        PaymentHeader."No." := LibraryUTUtility.GetNewCode();
        PaymentHeader.IBAN := IBAN;
        PaymentHeader."Currency Code" := CreateCurrency();
        PaymentHeader."SWIFT Code" := SWIFTCode;
        PaymentHeader."Bank Country/Region Code" := BankCountryRegionCode;
        PaymentHeader.Insert();
    end;

    local procedure CreatePaymentLine(PaymentHeaderNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DocumentNo: Code[10])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        PaymentLine.Init();
        PaymentLine."No." := PaymentHeaderNo;
        PaymentLine."Line No." := LibraryUtility.GetNewRecNo(PaymentLine, PaymentLine.FieldNo("Line No."));
        PaymentLine."Applies-to Doc. No." := DocumentNo;
        PaymentLine."Account Type" := AccountType;
        PaymentLine."Account No." := AccountNo;
        PaymentLine.Insert();
    end;

    local procedure CreatePaymentSlip(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BankAccountCode: Code[20]; CurrencyCode: Code[10]; BankCountryRegionCode: Code[10]; IBAN: Code[50]; SWIFTCode: Code[20]): Code[20]
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        CreatePaymentHeader(PaymentHeader, BankCountryRegionCode, IBAN, SWIFTCode);
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine."Account Type" := AccountType;
        PaymentLine."Account No." := AccountNo;
        PaymentLine.IBAN := PaymentHeader.IBAN;
        PaymentLine."SWIFT Code" := PaymentHeader."SWIFT Code";
        PaymentLine."Currency Code" := CurrencyCode;
        PaymentLine."Bank Account Code" := BankAccountCode;
        PaymentLine.Insert();
        exit(PaymentHeader."No.");
    end;

    local procedure CreateVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Insert();
        exit(Vendor."No.");
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; SEPAAllowed: Boolean)
    begin
        VendorBankAccount."Vendor No." := CreateVendor();
        VendorBankAccount.Code := LibraryUTUtility.GetNewCode10();
        VendorBankAccount."Country/Region Code" := CreateCountryRegion(SEPAAllowed);
        VendorBankAccount.Insert();
    end;

    local procedure CreatePaymentDocument(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DocumentNo: Code[10]): Code[20]
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        CreatePaymentHeader(PaymentHeader, LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID());
        CreatePaymentLine(PaymentHeader."No.", AccountType, AccountNo, DocumentNo);
        exit(PaymentHeader."No.");
    end;

    local procedure CreateCustLedgerEntries(CountofEntries: Integer; var CustomerNo: Code[20]; var DocumentNo: Code[10]) Result: Text
    var
        i: Integer;
    begin
        DocumentNo := LibraryUtility.GenerateGUID();
        CustomerNo := CreateCustomer();
        Result := DocumentNo;
        for i := 0 to CountofEntries do begin
            MockCustLedgerEntry(CustomerNo, DocumentNo);
            Result += ', ' + DocumentNo;
        end;
    end;

    local procedure CreateVendLedgerEntries(CountofEntries: Integer; var VendorNo: Code[20]; var DocumentNo: Code[10]) Result: Text
    var
        i: Integer;
    begin
        DocumentNo := LibraryUtility.GenerateGUID();
        VendorNo := CreateVendor();
        Result := DocumentNo;
        for i := 0 to CountofEntries do begin
            MockVendLedgerEntry(VendorNo, DocumentNo);
            Result += ', ' + DocumentNo;
        end;
    end;

    local procedure MockCustLedgerEntry(CustomerNo: Code[20]; DocumentNo: Code[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(CustLedgerEntry, CustLedgerEntry.FieldNo("Entry No."));
        CustLedgerEntry."Customer No." := CustomerNo;
        CustLedgerEntry."Document No." := DocumentNo;
        CustLedgerEntry.Insert();
    end;

    local procedure MockVendLedgerEntry(VendorNo: Code[20]; DocumentNo: Code[10])
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.Init();
        VendLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(VendLedgerEntry, VendLedgerEntry.FieldNo("Entry No."));
        VendLedgerEntry."Vendor No." := VendorNo;
        VendLedgerEntry."Document No." := DocumentNo;
        VendLedgerEntry.Insert();
    end;

    local procedure RunSEPAISO20022(FileName: Text)
    var
        SEPAISO20022: Report "SEPA ISO20022 FR";
    begin
        SEPAISO20022.SetFilePath(FileName);
        SEPAISO20022.Run();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Local Currency" := GeneralLedgerSetup."Local Currency"::Other;
        GeneralLedgerSetup."Currency Euro" := CreateCurrency();
        GeneralLedgerSetup.Modify();
    end;

    local procedure UpdateCompanyInfoAddressToMaxValues()
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion."ISO Code" :=
          CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CountryRegion."ISO Code")), 1, MaxStrLen(CountryRegion."ISO Code"));
        CountryRegion.Modify();

        CompanyInformation.Get();
        CompanyInformation.Address :=
          CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInformation.Address)), 1, MaxStrLen(CompanyInformation.Address));
        CompanyInformation."Post Code" :=
          CopyStr(
            LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInformation."Post Code")), 1, MaxStrLen(CompanyInformation."Post Code"));
        CompanyInformation.City :=
          CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInformation.City)), 1, MaxStrLen(CompanyInformation.City));
        CompanyInformation."Country/Region Code" := CountryRegion.Code;
        CompanyInformation.Modify();
    end;

    local procedure VerifyIBAN(CurrentIBAN: Code[50]; CheckIBAN: Code[50])
    begin
        Assert.AreEqual(CurrentIBAN, CheckIBAN, WrongIBANErr);
    end;

    [ModalPageHandler]
    procedure PaymentLineModificationPageHandler(var PaymentLineModification: TestPage "Payment Line Modification FR")
    var
        DraweeReference: Variant;
    begin
        LibraryVariableStorage.Dequeue(DraweeReference);
        PaymentLineModification."Drawee Reference".SetValue(CopyStr(DraweeReference, 1, 10));
        PaymentLineModification.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure SEPAISO20022RequestPageHandler(var SEPAISO20022: TestRequestPage "SEPA ISO20022 FR")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SEPAISO20022."Payment Header".SetFilter("No.", No);
        SEPAISO20022.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure IBANConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    var
        StoredReply: Variant;
    begin
        LibraryVariableStorage.Dequeue(StoredReply);
        Reply := StoredReply;
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}
