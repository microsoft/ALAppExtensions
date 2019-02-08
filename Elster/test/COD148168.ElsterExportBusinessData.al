codeunit 148168 "Elster Export Business Data"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster]
    end;

    var
        FileManagement: Codeunit "File Management";
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
        LibraryXMLRead: Codeunit "Library - XML Read";
        GermanicUmlautTxt: Text[7];
        ConvertedGermanicUmlautTxt: Text[14];
        FilePath: Text;
    begin
        // [SCENARIO 382098] Generate Sales VAT Advance Notification XML file with proper Germanic umlaut symbols

        GermanicUmlautTxt := 'ÄÖÜüöäß';
        ConvertedGermanicUmlautTxt := 'AeOeUeueoeaess';
        FilePath := FileManagement.ServerTempFileName('XML');
        LibrarySetupStorage.Save(Database::"Company Information");
        UpdateCompanyInformation();

        // [GIVEN] Sales VAT Advance Notification "SN"
        MockSalesVATAdvanceNotif(SalesVATAdvanceNotif, GermanicUmlautTxt);

        // [WHEN] Creating an XML file for "SN"
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] Verifying that Germanic umlaut symbols are converted correctly
        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        SalesVATAdvanceNotif."XML Submission Document".Export(FilePath);
        LibraryXMLRead.Initialize(FilePath);

        Assert.AreEqual(ConvertedGermanicUmlautTxt, LibraryXMLRead.GetElementValue('Name'), ConvertedGermanicUmlauErr);
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