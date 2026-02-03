// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 148022 "IRS 1099 IRIS Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryIRS1099IRIS: Codeunit "Library - IRS 1099 IRIS";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
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

    local procedure Initialize()
    var
        MockKeyVaultClientIRIS: Codeunit "Mock Key Vault Client IRIS";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 IRIS Tests");

        LibrarySetupStorage.Restore();
        LibraryIRS1099IRIS.DeleteAllTransmissions();
        LibraryIRS1099Document.DeleteFormDocuments();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 IRIS Tests");

        LibraryIRS1099IRIS.InitializeCompanyInformation();
        LibraryIRS1099IRIS.InitializeIRSFormsSetup();
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
}
