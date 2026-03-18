// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;
using System.Text;

codeunit 144030 "SEPA.09 CT Functional Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
        // [FEATURE] [SEPA] [Credit Transfer]    
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFRLocalization: Codeunit "Library - Localization FR";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        StringConversionManagement: Codeunit StringConversionManagement;
        LibraryXMLRead: Codeunit "Library - XML Read";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        isInitialized: Boolean;
        UnexpectedEmptyNodeErr: Label 'Unexpected empty value for node <%1> of subtree <%2>.', Comment = '%1 = Node Name, %2 = Subtree Root Name';
        SEPACTCode: Code[20];
        ElementIsMissingErr: Label 'Element <%1> is missing.', Comment = '%1 = Ustrd';
        FileExportHasErrorsErr: Label 'The file export has one or more errors';

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandlerYes')]
    procedure LocalDataExported()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        PaymentStep: Record "Payment Step FR";
        PaymentMgt: Codeunit "Payment Management FR";
    begin
        Initialize();


        CreatePaymentSlip(PaymentHeader, PaymentLine);
        PaymentLine.Amount := -PaymentLine.Amount; // Inject an error
        PaymentLine.Modify();

        PaymentStep.Init();
        PaymentStep."Payment Class" := PaymentHeader."Payment Class";
        PaymentStep."Previous Status" := PaymentHeader."Status No.";
        PaymentStep."Action Type" := PaymentStep."Action Type"::File;
        PaymentStep."Export Type" := PaymentStep."Export Type"::XMLport;
        PaymentStep."Export No." := XMLPORT::"SEPA CT pain.001.001.09";
        PaymentStep.Insert();

        // Must exist a rec with same Document No.
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.FindGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(
            GenJnlLine, GenJournalTemplate.Name, GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
            "Gen. Journal Account Type"::"G/L Account", '', 0);
        GenJnlLine."Document No." := PaymentHeader."No.";
        GenJnlLine.Modify();

        // Excercise
        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::File);
        asserterror PaymentMgt.ProcessPaymentSteps(PaymentHeader, PaymentStep);

        // Verify. Error message is about File Export Errors
        Assert.ExpectedError(FileExportHasErrorsErr);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileDeclarationAndVersion()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyXmlFileDeclarationAndVersion();
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileGroupHeader()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyGroupHeader(PaymentLine);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileInitiatingParty()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyInitiatingParty();
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFilePaymentInformationHeader()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyPaymentInformationHeader(PaymentLine);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileDebitor()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyDebitor(PaymentHeader);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileCreditor()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyCreditor(PaymentLine);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure XmlFileCreditorPreserveNonLatinChars()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin

        SetPreserveNonLatinCharacters(true);
        InitializeTestDataAndExportSEPAFile(PaymentHeader, PaymentLine);
        VerifyCreditor(PaymentLine);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler')]
    procedure ExportSEPACTSvcLvlCd()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        ExportedFilePath: Text;
    begin
        // [SCENARIO 344720] SEPA Export File contains element PmtInf/PmtTpInf/SvcLvl/Cd with value 'SEPA'.
        Initialize();


        // [GIVEN] Payment Slip.
        CreatePaymentSlip(PaymentHeader, PaymentLine);

        // [WHEN] Export SEPA CT file.
        ExportedFilePath := ExportSEPAFile(PaymentHeader);

        // [THEN] SEPA CT file contains element PmtInf/PmtTpInf/SvcLvl/Cd with value 'SEPA'.
        LibraryXPathXMLReader.Initialize(ExportedFilePath, GetISO20022V03NameSpace());
        LibraryXPathXMLReader.VerifyNodeValueByXPath('//PmtInf/PmtTpInf/SvcLvl/Cd', 'SEPA');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SEPA.09 CT Functional Test");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SEPA.09 CT Functional Test");

        SEPACTCode := FindSEPACTPaymentFormat();
        AllowSEPAOnCompanyCountryCode();
        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SEPA.09 CT Functional Test");
    end;

    [TransactionModel(TransactionModel::None)]
    local procedure AllowSEPAOnCountryCode(CountryRegionCode: Code[10])
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.Get(CountryRegionCode);
        if not CountryRegion."SEPA Allowed" then begin
            CountryRegion.Validate("SEPA Allowed", true);
            CountryRegion.Modify(true);
        end;
    end;

    local procedure AllowSEPAOnCompanyCountryCode()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        AllowSEPAOnCountryCode(CompanyInfo."Country/Region Code");
    end;

    local procedure CreateSEPABankAccount(var BankAccount: Record "Bank Account")
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate(Balance, LibraryRandom.RandIntInRange(100000, 1000000));
        BankAccount.Validate("Bank Account No.", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Bank Account No."), DATABASE::"Bank Account"));
        BankAccount.Validate("Country/Region Code", GetASEPACountryCode());
        BankAccount.Validate(IBAN, 'ES7620770024003102575766');
        BankAccount.Validate("Payment Export Format", SEPACTCode);
        BankAccount.Validate("Credit Transfer Msg. Nos.", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("SWIFT Code", 'BSCHESMM');
        BankAccount.Modify(true);
    end;

    local procedure CreatePaymentClass(): Text[30]
    var
        NoSeries: Record "No. Series";
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
    begin
        NoSeries.FindFirst();
        LibraryFRLocalization.CreatePaymentClass(PaymentClass);
        PaymentClass.Validate(Name, '');
        PaymentClass.Validate("Header No. Series", NoSeries.Code);
        PaymentClass.Validate(Enable, true);
        PaymentClass.Validate(Suggestions, PaymentClass.Suggestions::Vendor);
        PaymentClass.Validate("SEPA Transfer Type", PaymentClass."SEPA Transfer Type"::"Credit Transfer");
        PaymentClass.Modify(true);
        LibraryFRLocalization.CreatePaymentStatus(PaymentStatus, PaymentClass.Code);
        exit(PaymentClass.Code);
    end;

    local procedure CreatePaymentSlip(var PaymentHeader: Record "Payment Header FR"; var PaymentLine: Record "Payment Line FR")
    var
        BankAccount: Record "Bank Account";
        PaymentClassCode: Code[30];
    begin
        PaymentClassCode := CreatePaymentClass();
        LibraryVariableStorage.Enqueue(PaymentClassCode);

        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        PaymentHeader.Validate("Account Type", PaymentHeader."Account Type"::"Bank Account");
        CreateSEPABankAccount(BankAccount);
        PaymentHeader.Validate("Account No.", BankAccount."No.");
        PaymentHeader.Validate("Bank Country/Region Code", BankAccount."Country/Region Code");
        PaymentHeader.Validate(IBAN, 'CH6309000000250097798');
        PaymentHeader.Validate("SWIFT Code", 'INGBNL2A');
        PaymentHeader.Modify(true);

        LibraryFRLocalization.CreatePaymentLine(PaymentLine, PaymentHeader."No.");
        PaymentLine.Validate("Account Type", PaymentLine."Account Type"::Vendor);
        PaymentLine.Validate("Account No.", CreateVendor());
        PaymentLine.Validate(Amount, LibraryRandom.RandDecInRange(1, 1000, 1));
        PaymentLine.Validate("Due Date", CalcDate('<1D>', PaymentLine."Due Date"));
        PaymentLine.Modify(true);
    end;

    local procedure CreateVendor(): Code[20]
    var
        BankAccount: Record "Bank Account";
        PostCode: Record "Post Code";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        CreateSEPABankAccount(BankAccount);

        LibraryPurchase.CreateVendor(Vendor);
        VendorBankAccount.Init();
        VendorBankAccount.Validate(Code, BankAccount.Name);
        VendorBankAccount.Validate("Vendor No.", Vendor."No.");
        VendorBankAccount.Insert(true);

        VendorBankAccount.Validate(Name, BankAccount.Name);
        VendorBankAccount.Validate("Bank Account No.", BankAccount.Name);
        VendorBankAccount.Validate("Country/Region Code", BankAccount."Country/Region Code");
        VendorBankAccount.Validate(IBAN, BankAccount.IBAN);
        VendorBankAccount.Validate("SWIFT Code", BankAccount."SWIFT Code");
        VendorBankAccount.Modify(true);

        Vendor.Validate("Country/Region Code", BankAccount."Country/Region Code");
        Vendor.Validate("Preferred Bank Account Code", BankAccount."No.");
        Vendor.Validate(Address, '´Š¢sterbrogade ´Š¢´Š¢');
        // for testing non latin characters
        PostCode.SetRange("Country/Region Code", Vendor."Country/Region Code");
        Assert.IsTrue(not PostCode.IsEmpty(), 'Post code must exist');
        Vendor.Validate("Post Code", PostCode.Code);
        Vendor.Validate(City, PostCode.City);
        Vendor.Modify(true);

        exit(Vendor."No.");
    end;

    local procedure ExportSEPAFile(var PaymentHeader: Record "Payment Header FR") ExportedFilePath: Text
    var
        GenJnlLine: Record "Gen. Journal Line";
        OutStr: OutStream;
        File: File;
    begin
        GenJnlLine.SetRange("Journal Template Name", '');
        GenJnlLine.SetRange("Journal Batch Name", '');
        GenJnlLine.SetRange("Document No.", PaymentHeader."No.");
        ExportedFilePath := TemporaryPath + LibraryUtility.GenerateGUID() + '.xml';
        File.Create(ExportedFilePath);
        File.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPORT::"SEPA CT pain.001.001.09", OutStr, GenJnlLine);
        File.Close();
    end;

    local procedure FindSEPACTPaymentFormat(): Code[20]
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.SetFilter("Processing XMLport ID", '%1', XMLPORT::"SEPA CT pain.001.001.09");

        if BankExportImportSetup.IsEmpty() then
            Error('Bank Export/Import Setup not found.');

        exit(BankExportImportSetup.Code);
    end;

    local procedure GetASEPACountryCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
        PostCode: Record "Post Code";
    begin
        PostCode.Reset();
        PostCode.FindSet();
        PostCode.Next(LibraryRandom.RandInt(PostCode.Count));
        CountryRegion.Get(PostCode."Country/Region Code");
        AllowSEPAOnCountryCode(CountryRegion.Code);
        exit(CountryRegion.Code);
    end;

    local procedure GetPreserveNonLatinCharacters(): Boolean
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.Get(SEPACTCode);
        exit(BankExportImportSetup."Preserve Non-Latin Characters");
    end;

    local procedure GetISO20022V03NameSpace(): Text
    begin
        exit('urn:iso:std:iso:20022:tech:xsd:pain.001.001.09');
    end;

    local procedure InitializeTestDataAndExportSEPAFile(var PaymentHeader: Record "Payment Header FR"; var PaymentLine: Record "Payment Line FR")
    var
        ExportedFilePath: Text;
    begin
        Initialize();
        CreatePaymentSlip(PaymentHeader, PaymentLine);
        ExportedFilePath := ExportSEPAFile(PaymentHeader);
        LibraryXMLRead.Initialize(ExportedFilePath);
    end;

    [ModalPageHandler]
    procedure PaymentClassHandler(var PaymentClassList: TestPage "Payment Class List FR")
    var
        PaymentClassCode: Variant;
    begin
        LibraryVariableStorage.Dequeue(PaymentClassCode);
        PaymentClassList.GotoKey(PaymentClassCode);
        PaymentClassList.OK().Invoke();
    end;

    local procedure SetPreserveNonLatinCharacters(Preserve: Boolean)
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.Get(SEPACTCode);
        if not (BankExportImportSetup."Preserve Non-Latin Characters" = Preserve) then begin
            BankExportImportSetup.Validate("Preserve Non-Latin Characters", Preserve);
            BankExportImportSetup.Modify(true);
        end;
    end;

    local procedure VerifyDebitor(PaymentHeader: Record "Payment Header FR")
    var
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        VerifyCompanyNameAndPostalAddress(CompanyInformation, 'Dbtr');

        BankAccount.Get(PaymentHeader."Account No.");
        LibraryXMLRead.VerifyNodeValueInSubtree('Dbtr', 'AnyBIC', BankAccount."SWIFT Code");
        LibraryXMLRead.VerifyNodeValueInSubtree('DbtrAcct', 'IBAN', BankAccount.IBAN);
        LibraryXMLRead.VerifyNodeValueInSubtree('DbtrAgt', 'BICFI', BankAccount."SWIFT Code");
    end;

    local procedure VerifyCreditor(PaymentLine: Record "Payment Line FR")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(PaymentLine."Account No.");
        VerifyNameAndPostalAddress(
          'Cdtr', Vendor.Name, Vendor.Address, Vendor."Post Code", Vendor.City, Vendor."Country/Region Code");
        LibraryXMLRead.VerifyNodeValueInSubtree('CdtrAcct', 'IBAN', PaymentLine.IBAN);
        LibraryXMLRead.VerifyNodeValueInSubtree('CdtTrfTxInf', 'InstdAmt', PaymentLine.Amount);
        LibraryXMLRead.VerifyAttributeValueInSubtree('CdtTrfTxInf', 'InstdAmt', 'Ccy', 'EUR');
        asserterror LibraryXMLRead.VerifyNodeValue('Ustrd', '');
        Assert.ExpectedError(StrSubstNo(ElementIsMissingErr, 'Ustrd'));
    end;

    local procedure VerifyGroupHeader(PaymentLine: Record "Payment Line FR")
    begin
        // Mandatory/required elements
        VerifyNodeExistsAndNotEmpty('GrpHdr', 'MsgId');
        VerifyNodeExistsAndNotEmpty('GrpHdr', 'CreDtTm');
        LibraryXMLRead.VerifyNodeValueInSubtree('GrpHdr', 'NbOfTxs', '1');
        LibraryXMLRead.VerifyNodeValueInSubtree('GrpHdr', 'CtrlSum', PaymentLine.Amount);
    end;

    local procedure VerifyInitiatingParty()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        LibraryXMLRead.VerifyNodeValueInSubtree('InitgPty', 'Nm', CompanyInformation.Name);
        LibraryXMLRead.VerifyNodeValueInSubtree('InitgPty', 'Id', CompanyInformation."VAT Registration No.");
        // TFSID: 327225 Removal of 'PstlAdr' tag since the scheme has been changed
        LibraryXMLRead.VerifyNodeAbsenceInSubtree('InitgPty', 'PstlAdr');
    end;

    local procedure VerifyPaymentInformationHeader(PaymentLine: Record "Payment Line FR")
    begin
        // Mandatory elements
        VerifyNodeExistsAndNotEmpty('PmtInf', 'PmtInfId');
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'PmtMtd', 'TRF'); // Hardcoded to 'TRF' by the FR SEPA standard

        // Optional element
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'BtchBookg', 'false');

        // Mandatory element
        LibraryXMLRead.VerifyNodeValueInSubtree('ReqdExctnDt', 'Dt', PaymentLine."Posting Date");

        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'ChrgBr', 'SLEV'); // Hardcoded by FR SEPA standard    
    end;

    local procedure VerifyCompanyNameAndPostalAddress(CompanyInformation: Record "Company Information"; SubtreeRootNodeName: Text)
    begin
        VerifyNameAndPostalAddress(
          SubtreeRootNodeName, CompanyInformation.Name, CompanyInformation.Address,
          CompanyInformation."Post Code", CompanyInformation.City, CompanyInformation."Country/Region Code");
    end;

    local procedure VerifyNameAndPostalAddress(SubtreeRootNodeName: Text; Name: Text; Address: Text; PostCode: Text; City: Text; CountryRegionCode: Text)
    begin
        VerifyNodeValue(SubtreeRootNodeName, 'Nm', Name);
        VerifyNodeValue(SubtreeRootNodeName, 'StrtNm', Address);
        VerifyNodeValue(SubtreeRootNodeName, 'PstCd', PostCode);
        VerifyNodeValue(SubtreeRootNodeName, 'TwnNm', City);
        VerifyNodeValue(SubtreeRootNodeName, 'Ctry', CountryRegionCode);
    end;

    local procedure VerifyNodeExistsAndNotEmpty(SubtreeRootName: Text; NodeName: Text)
    begin
        Assert.AreNotEqual(
          '', LibraryXMLRead.GetNodeValueInSubtree(SubtreeRootName, NodeName), StrSubstNo(UnexpectedEmptyNodeErr, NodeName, SubtreeRootName));
    end;

    local procedure VerifyNodeValue(SubtreeRootNodeName: Text; NodeName: Text; ExpectedValue: Text)
    begin
        if not GetPreserveNonLatinCharacters() then
            ExpectedValue := StringConversionManagement.WindowsToASCII(ExpectedValue);
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, NodeName, ExpectedValue);
    end;

    local procedure VerifyXmlFileDeclarationAndVersion()
    begin
        LibraryXMLRead.VerifyXMLDeclaration('1.0', 'UTF-8', 'no');
        LibraryXMLRead.VerifyAttributeValue('Document', 'xmlns', 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.09');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}
