// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 148022 "IRS 1099 IRIS Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryIRS1099IRIS: Codeunit "Library - IRS 1099 IRIS";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;

    [Test]
    procedure ContactPersonInfoGrpNotAddedWhenContactPersonIsEmpty()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary;
        TempBlob: Codeunit "Temp Blob";
        UniqueTransmissionId: Text[100];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 619239] ContactPersonInformationGrp is not added to XML when Contact Person is empty but Phone No. and E-Mail are filled
        Initialize();

        // [GIVEN] Company Information with empty Contact Person but filled Phone No. and E-Mail
        UpdateCompanyContactInfo('', '1234567890', 'test@example.com');

        // [GIVEN] A vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [WHEN] Create transmission XML
        LibraryIRS1099IRIS.CreateTransmissionXmlContent(Transmission, Enum::"Transmission Type IRIS"::"O", false, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);

        // [THEN] ContactPersonInformationGrp is not present in the XML
        InitXMLReader(TempBlob);
        LibraryXPathXMLReader.VerifyXmlNodeAbsence('//n1:ContactPersonInformationGrp');
    end;

    [Test]
    procedure ContactPersonInfoGrpAddedWhenContactPersonIsFilled()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary;
        TempBlob: Codeunit "Temp Blob";
        UniqueTransmissionId: Text[100];
        ContactName: Text[50];
        PhoneNo: Text[30];
        Email: Text[80];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 619239] ContactPersonInformationGrp is added to XML when Contact Person is filled
        Initialize();

        // [GIVEN] Company Information with filled Contact Person, Phone No. and E-Mail
        ContactName := LibraryUtility.GenerateGUID();
        PhoneNo := LibraryUtility.GenerateRandomPhoneNo();
        Email := LibraryUtility.GenerateRandomEmail();
        UpdateCompanyContactInfo(ContactName, PhoneNo, Email);

        // [GIVEN] A vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [WHEN] Create transmission XML
        LibraryIRS1099IRIS.CreateTransmissionXmlContent(Transmission, Enum::"Transmission Type IRIS"::"O", false, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);

        // [THEN] ContactPersonInformationGrp is present in the XML with ContactPersonNm
        InitXMLReader(TempBlob);
        LibraryXPathXMLReader.VerifyXmlNodeValue('//n1:ContactPersonInformationGrp/n1:ContactPersonNm', ContactName);
        LibraryXPathXMLReader.VerifyXmlNodeValue('//n1:ContactPersonInformationGrp/n1:ContactPhoneNum', DelChr(PhoneNo, '=', ' -+()'));
        LibraryXPathXMLReader.VerifyXmlNodeValue('//n1:ContactPersonInformationGrp/n1:ContactEmailAddressTxt', Email);
    end;

    [Test]
    procedure StateCodeWithLeadingAndTrailingSpacesIsTrimmed()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary;
        TempBlob: Codeunit "Temp Blob";
        UniqueTransmissionId: Text[100];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 619973] State code with leading and trailing spaces is trimmed in the XML
        Initialize();

        // [GIVEN] A vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Vendor's County (State) = " CA " (with leading and trailing spaces)
        UpdateVendorProvinceOrState(IRS1099FormDocHeader."Vendor No.", ' CA ');

        // [WHEN] Create transmission XML
        LibraryIRS1099IRIS.CreateTransmissionXmlContent(Transmission, Enum::"Transmission Type IRIS"::"O", false, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);

        // [THEN] StateAbbreviationCd is "CA" without spaces
        InitXMLReader(TempBlob);
        LibraryXPathXMLReader.VerifyXmlNodeValue('//n1:RecipientDetail/n1:MailingAddressGrp/n1:USAddress/n1:StateAbbreviationCd', 'CA');
    end;

    [Test]
    [HandlerFunctions('ErrorMessagesPageHandler')]
    procedure NonExistingStateCodeCausesValidationError()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 619973] Non-existing state code causes validation error when checking data to report
        Initialize();

        // [GIVEN] A vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Vendor's County (State) = "A1" (invalid state code)
        UpdateVendorProvinceOrState(IRS1099FormDocHeader."Vendor No.", 'A1');

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error is thrown for invalid state code
        Assert.ExpectedMessage('State must be a valid 2-letter US state code', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MultipleErrorMessagesPageHandler')]
    procedure TwoDuplicateTINGroupsInSameSubmission()
    var
        Vendor: array[5] of Record Vendor;
        IRS1099FormDocHeader: array[5] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        TINGroup1: Text[30];
        TINGroup2: Text[30];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Two groups of vendors with duplicate TINs in same submission cause two error messages
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));

        // [GIVEN] 3 vendors "V1", "V2", "V3" share TIN "A" without bank accounts
        TINGroup1 := LibraryIRS1099IRIS.GetUniqueTIN();
        for i := 1 to 3 do begin
            LibraryIRS1099IRIS.CreateUSVendor(Vendor[i]);
            UpdateVendorFederalId(Vendor[i]."No.", TINGroup1);
        end;

        // [GIVEN] 2 vendors "V4", "V5" share TIN "B" without bank accounts
        TINGroup2 := LibraryIRS1099IRIS.GetUniqueTIN();
        for i := 4 to 5 do begin
            LibraryIRS1099IRIS.CreateUSVendor(Vendor[i]);
            UpdateVendorFederalId(Vendor[i]."No.", TINGroup2);
        end;

        // [GIVEN] Form documents for all vendors with form NEC
        for i := 1 to 5 do
            CreateReleasedFormDocForVendor(IRS1099FormDocHeader[i], Vendor[i]."No.", 'NEC', 'NEC-01');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Two error messages are shown for duplicate TINs (one for each group)
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('vendors have the same TIN', LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage('vendors have the same TIN', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MultipleErrorMessagesPageHandler')]
    procedure DuplicateTINsWithSameBankAccountNo()
    var
        Vendor: array[2] of Record Vendor;
        IRS1099FormDocHeader: array[2] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        SharedTIN: Text[30];
        SharedBankAccountNo: Code[30];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Two vendors with the same TIN and same Bank Account No. cause validation error
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));
        SharedTIN := LibraryIRS1099IRIS.GetUniqueTIN();
        SharedBankAccountNo := 'SHARED-BANK-123';

        // [GIVEN] 2 vendors "V1", "V2" share the same TIN with same bank account number
        LibraryIRS1099IRIS.CreateUSVendorWithBankAccount(Vendor[1], SharedBankAccountNo);
        UpdateVendorFederalId(Vendor[1]."No.", SharedTIN);
        LibraryIRS1099IRIS.CreateUSVendorWithBankAccount(Vendor[2], SharedBankAccountNo);
        UpdateVendorFederalId(Vendor[2]."No.", SharedTIN);

        // [GIVEN] Form documents for both vendors
        for i := 1 to 2 do
            CreateReleasedFormDocForVendor(IRS1099FormDocHeader[i], Vendor[i]."No.", 'NEC', 'NEC-01');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error message is shown for duplicate TINs with same bank account
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('2 vendors have the same TIN', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MultipleErrorMessagesPageHandler')]
    procedure DuplicateTINsOneVendorHasBankAccountOneDoesNot()
    var
        Vendor: array[2] of Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        IRS1099FormDocHeader: array[2] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        SharedTIN: Text[30];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Two vendors with the same TIN where only one has a bank account cause validation error
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));
        SharedTIN := LibraryIRS1099IRIS.GetUniqueTIN();

        // [GIVEN] 2 vendors "V1", "V2" share the same TIN
        for i := 1 to 2 do begin
            LibraryIRS1099IRIS.CreateUSVendor(Vendor[i]);
            UpdateVendorFederalId(Vendor[i]."No.", SharedTIN);
        end;

        // [GIVEN] Only vendor "V1" has a bank account
        LibraryIRS1099IRIS.CreateVendorBankAccount(VendorBankAccount, Vendor[1]."No.", 'BANK-ACCOUNT-1');

        // [GIVEN] Form documents for both vendors
        for i := 1 to 2 do
            CreateReleasedFormDocForVendor(IRS1099FormDocHeader[i], Vendor[i]."No.", 'NEC', 'NEC-01');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error message is shown because "V2" has empty bank account
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('2 vendors have the same TIN', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure DuplicateTINsWithUniqueBankAccountNos()
    var
        Vendor: array[2] of Record Vendor;
        IRS1099FormDocHeader: array[2] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        SharedTIN: Text[30];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Two vendors with the same TIN but unique bank account numbers do not cause error
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));
        SharedTIN := LibraryIRS1099IRIS.GetUniqueTIN();

        // [GIVEN] 2 vendors "V1", "V2" share the same TIN with unique bank account numbers
        LibraryIRS1099IRIS.CreateUSVendorWithBankAccount(Vendor[1], 'UNIQUE-BANK-001');
        UpdateVendorFederalId(Vendor[1]."No.", SharedTIN);
        LibraryIRS1099IRIS.CreateUSVendorWithBankAccount(Vendor[2], 'UNIQUE-BANK-002');
        UpdateVendorFederalId(Vendor[2]."No.", SharedTIN);

        // [GIVEN] Form documents for both vendors
        for i := 1 to 2 do
            CreateReleasedFormDocForVendor(IRS1099FormDocHeader[i], Vendor[i]."No.", 'NEC', 'NEC-01');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised because bank account numbers are unique
    end;

    [Test]
    procedure DuplicateTINsAcrossDifferentSubmissions()
    var
        Vendor: array[2] of Record Vendor;
        IRS1099FormDocHeader: array[2] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        SharedTIN: Text[30];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Vendors with the same TIN but different form types do not cause error
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));
        SharedTIN := LibraryIRS1099IRIS.GetUniqueTIN();

        // [GIVEN] 2 vendors "V1", "V2" share the same TIN without bank accounts
        for i := 1 to 2 do begin
            LibraryIRS1099IRIS.CreateUSVendor(Vendor[i]);
            UpdateVendorFederalId(Vendor[i]."No.", SharedTIN);
        end;

        // [GIVEN] Vendor "V1" has form doc for NEC, vendor "V2" has form doc for MISC (different submissions)
        CreateReleasedFormDocForVendor(IRS1099FormDocHeader[1], Vendor[1]."No.", 'NEC', 'NEC-01');
        CreateReleasedFormDocForVendor(IRS1099FormDocHeader[2], Vendor[2]."No.", 'MISC', 'MISC-03');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised because vendors are in different submissions (form types)
    end;

    [Test]
    procedure NoDuplicateTINsNoError()
    var
        Vendor: array[3] of Record Vendor;
        IRS1099FormDocHeader: array[3] of Record "IRS 1099 Form Doc. Header";
        Transmission: Record "Transmission IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        PeriodNo: Code[20];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621343] Multiple vendors with unique TINs do not cause error
        Initialize();
        PeriodNo := Format(Date2DMY(WorkDate(), 3));

        // [GIVEN] 3 vendors "V1", "V2", "V3" with unique TINs
        LibraryIRS1099IRIS.CreateUSVendor(Vendor[1]);
        UpdateVendorFederalId(Vendor[1]."No.", LibraryIRS1099IRIS.GetUniqueTIN());
        LibraryIRS1099IRIS.CreateUSVendor(Vendor[2]);
        UpdateVendorFederalId(Vendor[2]."No.", LibraryIRS1099IRIS.GetUniqueTIN());
        LibraryIRS1099IRIS.CreateUSVendor(Vendor[3]);
        UpdateVendorFederalId(Vendor[3]."No.", LibraryIRS1099IRIS.GetUniqueTIN());

        // [GIVEN] Form documents for all vendors
        for i := 1 to 3 do
            CreateReleasedFormDocForVendor(IRS1099FormDocHeader[i], Vendor[i]."No.", 'NEC', 'NEC-01');

        // [GIVEN] Transmission created that picks up released form documents
        LibraryIRS1099IRIS.CreateTransmission(Transmission, PeriodNo);

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised because all TINs are unique
    end;

    [Test]
    [HandlerFunctions('ErrorMessagesPageHandler')]
    procedure EmptyContactPersonCausesValidationError()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Empty Contact Person in Company Information causes validation error
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with empty Contact Person
        UpdateCompanyContactInfo('', '1234567890', 'test@example.com');

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error is thrown for empty Contact Person
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('Contact Person must be between 1 and 35 characters', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure ContactPersonWithMaxLengthPasses()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        ContactPerson35Chars: Text[50];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Contact Person with exactly 35 characters passes validation
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with Contact Person of exactly 35 characters
        ContactPerson35Chars := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(35, 0), 1, 50);
        UpdateCompanyContactInfo(ContactPerson35Chars, '1234567890', 'test@example.com');

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised for Contact Person
    end;

    [Test]
    [HandlerFunctions('ErrorMessagesPageHandler')]
    procedure ContactPersonExceedingMaxLengthCausesError()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        ContactPersonTooLong: Text[50];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Contact Person exceeding 35 characters after formatting causes validation error
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with Contact Person exceeding 35 characters
        ContactPersonTooLong := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(36, 0), 1, 50);
        UpdateCompanyContactInfo(ContactPersonTooLong, '1234567890', 'test@example.com');

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error is thrown for Contact Person exceeding max length
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('Contact Person must be between 1 and 35 characters', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ErrorMessagesPageHandler')]
    procedure EmptyPhoneNoCausesValidationError()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Empty Phone No. in Company Information causes validation error
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with empty Phone No.
        UpdateCompanyContactInfo('John Doe', '', 'test@example.com');

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error is thrown for empty Phone No.
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('Phone No. must be between 10 and 30 digits', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure PhoneNoWithMinLengthPasses()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Phone No. with exactly 10 digits passes validation
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with Phone No. of exactly 10 digits
        UpdateCompanyContactInfo('John Doe', '1234567890', 'test@example.com');

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised for Phone No.
    end;

    [Test]
    [HandlerFunctions('ErrorMessagesPageHandler')]
    procedure PhoneNoTooShortCausesError()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Phone No. with less than 10 digits causes validation error
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with Phone No. of only 9 digits
        UpdateCompanyContactInfo('John Doe', '123456789', 'test@example.com');

        // [WHEN] Check data to report
        asserterror IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] Error is thrown for Phone No. too short
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedMessage('Phone No. must be between 10 and 30 digits', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure PhoneNoWithMaxLengthPasses()
    var
        Transmission: Record "Transmission IRIS";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 621425] Phone No. with exactly 30 digits passes validation
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form document ready for transmission
        CreateTransmissionWithSingleFormDoc(Transmission, IRS1099FormDocHeader);

        // [GIVEN] Company Information with Phone No. of exactly 30 digits (max allowed)
        UpdateCompanyContactInfo('John Doe', '123456789012345678901234567890', 'test@example.com');

        // [WHEN] Check data to report
        IRSFormsFacade.CheckDataToReport(Transmission);

        // [THEN] No error is raised for Phone No. at max length
    end;

    local procedure Initialize()
    var
        MockKeyVaultClientIRIS: Codeunit "Mock Key Vault Client IRIS";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 IRIS Tests");

        LibrarySetupStorage.Restore();
        LibraryIRS1099IRIS.RestoreIRISUserID();
        LibraryIRS1099IRIS.DeleteAllTransmissions();
        LibraryIRS1099Document.DeleteFormDocuments();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 IRIS Tests");

        LibraryIRS1099IRIS.InitializeCompanyInformation();
        LibraryIRS1099IRIS.InitializeIRSFormsSetup();
        LibraryIRS1099IRIS.SaveIRISUserID();
        LibraryIRS1099IRIS.InitializeIRISUserID();
        MockKeyVaultClientIRIS.SetDefaultValues();
        InitializeReportingPeriodAndForms(Date2DMY(WorkDate(), 3));

        LibrarySetupStorage.SaveCompanyInformation();
        LibrarySetupStorage.Save(Database::"IRS Forms Setup");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 IRIS Tests");
    end;

    local procedure InitializeReportingPeriodAndForms(Year: Integer)
    var
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := DMY2Date(1, 1, Year);
        EndingDate := CalcDate('<CY>', StartingDate);
        LibraryIRSReportingPeriod.CreateSpecificReportingPeriod(Format(Year), StartingDate, EndingDate);

        LibraryIRS1099FormBox.CreateSpecificFormInReportingPeriod(StartingDate, EndingDate, 'DIV');
        LibraryIRS1099FormBox.CreateSpecificFormBoxInReportingPeriod(StartingDate, EndingDate, 'DIV', 'DIV-01-A');

        LibraryIRS1099FormBox.CreateSpecificFormInReportingPeriod(StartingDate, EndingDate, 'INT');
        LibraryIRS1099FormBox.CreateSpecificFormBoxInReportingPeriod(StartingDate, EndingDate, 'INT', 'INT-01');

        LibraryIRS1099FormBox.CreateSpecificFormInReportingPeriod(StartingDate, EndingDate, 'MISC');
        LibraryIRS1099FormBox.CreateSpecificFormBoxInReportingPeriod(StartingDate, EndingDate, 'MISC', 'MISC-03');

        LibraryIRS1099FormBox.CreateSpecificFormInReportingPeriod(StartingDate, EndingDate, 'NEC');
        LibraryIRS1099FormBox.CreateSpecificFormBoxInReportingPeriod(StartingDate, EndingDate, 'NEC', 'NEC-01');
    end;

    local procedure InitXMLReader(var TempBlob: Codeunit "Temp Blob")
    begin
        LibraryXPathXMLReader.InitializeXml(TempBlob, 'n1', 'urn:us:gov:treasury:irs:ir');
    end;

    local procedure CreateTransmissionWithSingleFormDoc(var Transmission: Record "Transmission IRIS"; var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        CreateReleasedFormDocument(IRS1099FormDocHeader, Date2DMY(WorkDate(), 3));
        LibraryIRS1099IRIS.CreateTransmission(Transmission, IRS1099FormDocHeader."Period No.");
        IRS1099FormDocHeader.Get(IRS1099FormDocHeader.ID);
    end;

    local procedure CreateReleasedFormDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; Year: Integer)
    var
        Vendor: Record Vendor;
        StartingDate: Date;
        EndingDate: Date;
        PeriodNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2] of Code[20];
        ExcludeFormBoxNoList: List of [Code[20]];
    begin
        StartingDate := DMY2Date(1, 1, Year);
        EndingDate := CalcDate('<CY>', StartingDate);
        PeriodNo := Format(Year);

        LibraryIRS1099IRIS.CreateUSVendor(Vendor);

        GetRandomFormAndFormBox(FormNo[1], FormBoxNo[1], Year, ExcludeFormBoxNoList);
        GetRandomFormAndFormBox(FormNo[2], FormBoxNo[2], Year, ExcludeFormBoxNoList);

        LibraryIRS1099Document.CreateAndPostPurchaseDocument("Purchase Document Type"::Invoice, Vendor."No.", Year, FormNo[1], FormBoxNo[1]);
        LibraryIRS1099Document.CreateAndPostPurchaseDocument("Purchase Document Type"::Invoice, Vendor."No.", Year, FormNo[2], FormBoxNo[2]);

        LibraryIRS1099Document.CreateFormDocuments(StartingDate, EndingDate, Vendor."No.");
        IRS1099FormDocHeader.SetRange("Period No.", PeriodNo);
        IRS1099FormDocHeader.SetRange("Vendor No.", Vendor."No.");
        IRS1099FormDocHeader.FindFirst();
        IRS1099FormDocHeader.Validate(Status, IRS1099FormDocHeader.Status::Released);
        IRS1099FormDocHeader.Modify(true);
    end;

    local procedure CreateReleasedFormDocForVendor(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20])
    var
        Year: Integer;
        StartingDate: Date;
        EndingDate: Date;
        PeriodNo: Code[20];
    begin
        Year := Date2DMY(WorkDate(), 3);
        StartingDate := DMY2Date(1, 1, Year);
        EndingDate := CalcDate('<CY>', StartingDate);
        PeriodNo := Format(Year);

        LibraryIRS1099Document.CreateAndPostPurchaseDocument("Purchase Document Type"::Invoice, VendorNo, Year, FormNo, FormBoxNo);
        LibraryIRS1099Document.CreateFormDocuments(StartingDate, EndingDate, VendorNo);

        IRS1099FormDocHeader.SetRange("Period No.", PeriodNo);
        IRS1099FormDocHeader.SetRange("Vendor No.", VendorNo);
        IRS1099FormDocHeader.SetRange("Form No.", FormNo);
        IRS1099FormDocHeader.FindFirst();
        IRS1099FormDocHeader.Validate(Status, IRS1099FormDocHeader.Status::Released);
        IRS1099FormDocHeader.Modify(true);
    end;

    local procedure GetRandomFormAndFormBox(var FormNo: Code[20]; var FormBoxNo: Code[20]; Year: Integer; var ExcludeFormBoxNoList: List of [Code[20]])
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
        FormBoxNoList: List of [Code[20]];
        RandomIndex: Integer;
    begin
        IRS1099FormBox.SetRange("Period No.", Format(Year));
        IRS1099FormBox.FindSet();
        repeat
            if not ExcludeFormBoxNoList.Contains(IRS1099FormBox."No.") then
                FormBoxNoList.Add(IRS1099FormBox."No.");
        until IRS1099FormBox.Next() = 0;

        RandomIndex := LibraryRandom.RandInt(FormBoxNoList.Count());
        FormBoxNo := FormBoxNoList.Get(RandomIndex);
        IRS1099FormBox.SetRange("No.", FormBoxNo);
        IRS1099FormBox.FindFirst();
        FormNo := IRS1099FormBox."Form No.";
        ExcludeFormBoxNoList.Add(FormBoxNo);
    end;

    local procedure UpdateCompanyContactInfo(ContactPerson: Text[50]; PhoneNo: Text[30]; Email: Text[80])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Contact Person" := ContactPerson;
        CompanyInformation."Phone No." := PhoneNo;
        CompanyInformation."E-Mail" := Email;
        CompanyInformation.Modify();
    end;

    local procedure UpdateVendorProvinceOrState(VendorNo: Code[20]; ProvinceOrStateCode: Text[30])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor.County := ProvinceOrStateCode;
        Vendor.Modify();
    end;

    local procedure UpdateVendorFederalId(VendorNo: Code[20]; FederalId: Text[30])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor."Federal ID No." := FederalId;
        Vendor.Modify();
    end;

    [PageHandler]
    procedure ErrorMessagesPageHandler(var ErrorMessagesPage: TestPage "Error Messages")
    begin
        LibraryVariableStorage.Enqueue(ErrorMessagesPage.Description.Value);
        ErrorMessagesPage.Close();
    end;

    [PageHandler]
    procedure MultipleErrorMessagesPageHandler(var ErrorMessagesPage: TestPage "Error Messages")
    begin
        ErrorMessagesPage.First();
        repeat
            LibraryVariableStorage.Enqueue(ErrorMessagesPage.Description.Value);
        until not ErrorMessagesPage.Next();
        ErrorMessagesPage.Close();
    end;
}
