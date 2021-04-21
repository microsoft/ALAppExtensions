// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148168 "Elster Export Business Data"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster]
    end;

    var
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        ConvertedGermanicUmlauErr: Label 'ENU=Converted Germanic umlaut text expected.';

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestExportElsterXMLWithGermanicSymbolsYear2020()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 381046] Generate Sales VAT Advance Notification XML file with proper Germanic umlaut symbols for Elster format year 2020

        Initialize();
        UpdateCompanyInformation();

        // [GIVEN] Sales VAT Advance Notification "SN" with "Starting Date" = 01.01.2020
        MockSalesVATAdvanceNotif(SalesVATAdvanceNotif, GetGermanicUmlautString(), 20200101D);

        // [WHEN] Creating an XML file for "SN"
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] Verifying that Germanic umlaut symbols are converted correctly
        VerifyGermanicSymbols(SalesVATAdvanceNotif, 'http://www.elster.de/elsterxml/schema/v11');
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestExportElsterXMLWithGermanicSymbolsYear2021()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 381046] Generate Sales VAT Advance Notification XML file with proper Germanic umlaut symbols for Elster format year 2021

        Initialize();
        UpdateCompanyInformation();

        // [GIVEN] Sales VAT Advance Notification "SN" with "Starting Date" = 01.01.2021
        MockSalesVATAdvanceNotif(SalesVATAdvanceNotif, GetGermanicUmlautString(), 20210101D);

        // [WHEN] Creating an XML file for "SN"
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] Verifying that Germanic umlaut symbols are converted correctly
        VerifyGermanicSymbols(SalesVATAdvanceNotif, 'http://finkonsens.de/elster/elsteranmeldung/ustva/v2021');
    END;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;

        LibrarySetupStorage.Save(Database::"Company Information");
        IsInitialized := true;
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Tax Office Area" := CompanyInformation."Tax Office Area"::Hamburg;
        CompanyInformation."Registration No." :=
          CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CompanyInformation."Registration No."));
        CompanyInformation."VAT Representative" :=
          CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CompanyInformation."VAT Representative"));
        CompanyInformation."Tax Office Number" := Format(LibraryRandom.RandIntInRange(1000, 2000));
        CompanyInformation.Modify();
    end;

    local procedure GetGermanicUmlautString(): Text[7]
    begin
        exit('ÄÖÜüöäß');
    end;

    local procedure GetConvertedGermanicUmlautString(): Text[14]
    begin
        exit('AeOeUeueoeaess');
    end;

    local procedure MockSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; GermanicUmlautTxt: Text[7]; StartingDate: Date)
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        SalesVATAdvanceNotif.Init();
        SalesVATAdvanceNotif."No." :=
          LibraryUtility.GenerateRandomCode(SalesVATAdvanceNotif.FieldNo("No."), DATABASE::"Sales VAT Advance Notif.");
        SalesVATAdvanceNotif."Starting Date" := StartingDate;
        SalesVATAdvanceNotif."XML-File Creation Date" := 0D;
        SalesVATAdvanceNotif."Contact for Tax Office" := GermanicUmlautTxt;
        SalesVATAdvanceNotif.Insert();
        SalesVATAdvanceNotif.SetRecFilter();

        VATStatementName.Init();
        VATStatementName."Statement Template Name" :=
          CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(VATStatementName."Statement Template Name"));
        VATStatementName.Name :=
          CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(VATStatementName.Name));
        VATStatementName."Sales VAT Adv. Notif." := true;
        VATStatementName.Insert();
    END;

    local procedure VerifyGermanicSymbols(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; NameSpace: Text)
    var
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        TempBlob: Codeunit "Temp Blob";
    begin
        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        TempBlob.FromRecord(SalesVATAdvanceNotif, SalesVATAdvanceNotif.FieldNo("XML Submission Document"));
        LibraryXPathXMLReader.InitializeXml(TempBlob, 'elster', NameSpace);
        Assert.AreEqual(
            GetConvertedGermanicUmlautString(), LibraryXPathXMLReader.GetXmlElementValue('//elster:Name'), ConvertedGermanicUmlauErr);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
        // Dummy message handler.
    end;
}