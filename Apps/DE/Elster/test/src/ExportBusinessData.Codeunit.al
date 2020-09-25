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
        ConvertedGermanicUmlauErr: Label 'ENU=Converted Germanic umlaut text expected.';

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestExportElsterXMLWithGermanicSymbols()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        TempBlob: Codeunit "Temp Blob";
        GermanicUmlautTxt: Text[7];
        ConvertedGermanicUmlautTxt: Text[14];
    begin
        // [SCENARIO 382098] Generate Sales VAT Advance Notification XML file with proper Germanic umlaut symbols

        GermanicUmlautTxt := 'ÄÖÜüöäß';
        ConvertedGermanicUmlautTxt := 'AeOeUeueoeaess';
        LibrarySetupStorage.Save(Database::"Company Information");
        UpdateCompanyInformation();

        // [GIVEN] Sales VAT Advance Notification "SN"
        MockSalesVATAdvanceNotif(SalesVATAdvanceNotif, GermanicUmlautTxt);

        // [WHEN] Creating an XML file for "SN"
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] Verifying that Germanic umlaut symbols are converted correctly
        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        TempBlob.FromRecord(SalesVATAdvanceNotif, SalesVATAdvanceNotif.FieldNo("XML Submission Document"));
        LibraryXPathXMLReader.InitializeXml(TempBlob, 'elster', 'http://www.elster.de/elsterxml/schema/v11');
        Assert.AreEqual(ConvertedGermanicUmlautTxt, LibraryXPathXMLReader.GetXmlElementValue('//elster:Name'), ConvertedGermanicUmlauErr);
        LibrarySetupStorage.Restore();
    END;

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

    local procedure MockSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; GermanicUmlautTxt: Text[7])
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        SalesVATAdvanceNotif.Init();
        SalesVATAdvanceNotif."No." :=
          LibraryUtility.GenerateRandomCode(SalesVATAdvanceNotif.FieldNo("No."), DATABASE::"Sales VAT Advance Notif.");
        SalesVATAdvanceNotif."Starting Date" := CalcDate('<-CY>', WorkDate());
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

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
        // Dummy message handler.
    end;
}