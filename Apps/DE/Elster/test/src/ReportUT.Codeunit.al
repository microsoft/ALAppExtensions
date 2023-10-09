// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148164 "Elster Report UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Elster] [UT] [Report]
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler,MessageHandler')]
    procedure OnPostDataItemCreateXMLFileVATAdvNotif()
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnPostDataItem of Report Create XML File VAT Adv. Notif. for XML Create option of Create.
        Initialize();
        OnPostDataItemXMLOptionCreateXMLFileVATAdvNotif();
    end;

    [Test]
    [HandlerFunctions('TransmitXMLFileVATAdvNotifReportHandler')]
    procedure OnPostDataItemTransmitXMLFileVATAdvNotif()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnPostDataItem of Report Create XML File VAT Adv. Notif. for XML Create option of Create and Transmit.
        Initialize();
        if not CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.EnableEncryption(true);
        OnPostDataItemXMLOptionCreateXMLFileVATAdvNotif();
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler')]
    procedure OnAfterGetRecordTaxOfficeCreateXMLFileVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnAfterGetRecord of Report Create XML File VAT Adv. Notif. for Contact for Tax Office.
        // Setup.
        Initialize();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, FindVATStatementName());
        SalesVATAdvanceNotif."Contact for Tax Office" := '';
        SalesVATAdvanceNotif.Modify();
        Commit();

        // Exercise.
        asserterror CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Error Code, Error - Contact for Tax Office must have a value after running Create XML File VAT Adv. Notif. Report.
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler,MessageHandler')]
    procedure OnAfterGetRecordXMLExistCreateXMLFileVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnAfterGetRecord of Report Create XML File VAT Adv. Notif. for XML already exist Error.
        // Setup.
        Initialize();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, FindVATStatementName());
        Commit();  // Commit required as the explicit Commit used in Sales VAT Advance Notification - OnPostDataItem in REPORT ID: 11016 - Create XML File VAT Adv. Notif.
        CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Exercise: Run Create XML File VAT Adv. Notif. Report again.
        asserterror CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Error Code, Error - The XML-File for the Sales VAT Advance Notification already exists after running Create XML File VAT Adv. Notif. Report.
        Assert.ExpectedErrorCode('Dialog')
    END;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler')]
    procedure OnAfterGetRecordStartDateCreateXMLFileVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnAfterGetRecord of Report Create XML File VAT Adv. Notif. to check Starting Date of Quarter.
        // Setup.
        Initialize();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Quarter, FindVATStatementName());
        UpdateStartingDateOnSalesVATAdvanceNotification(SalesVATAdvanceNotif, 1);  // Period Length 1.
        Commit();

        // Exercise.
        asserterror CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Error Code, Error - The starting date is not the first date of a quarter in Create XML File VAT Adv. Notif. Report.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [HandlerFunctions('ShowXMLFileVATAdvNotifReportHandler')]
    procedure OnAfterGetRecordVATRepCreateXMLFileVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT Advance Notification - OnAfterGetRecord of Report Create XML File VAT Adv. Notif. to check VAT Representative.
        // Setup.
        Initialize();
        UpdateCompanyInformation();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, FindVATStatementName());
        Commit();

        // Exercise.
        asserterror CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Error Code, Error - VAT Representative must have a value in Report Create XML File VAT Adv. Notif. Report.
        Assert.ExpectedErrorCode('TestField');
    end;

    local procedure OnPostDataItemXMLOptionCreateXMLFileVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // Create Sales VAT Advance Notification.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, FindVATStatementName());

        // Exercise: Update Create XML Option to Create in CreateXMLFileVATAdvNotifReportHandler and to Create and Transmit in TransmitXMLFileVATAdvNotifReportHandler.
        Commit(); // Commit required as the explicit Commit used in Sales VAT Advance Notification - OnPostDataItem in REPORT ID: 11016 - Create XML File VAT Adv. Notif.
        CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Sales VAT Advance Notification Period, Statement Name and XSL File as blank.
        VerifySalesVATAdvanceNotification(SalesVATAdvanceNotif."No.", SalesVATAdvanceNotif.Period::Month, SalesVATAdvanceNotif."Statement Name");
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateXMLFile_KZ37_Kz50()
    var
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATProdPostingGroup: Code[20];
    begin
        // [SCENARIO 386738] Report 11016 "Create XML-File VAT Adv.Notif." exports "Kz37" (VAT Amount) and "Kz50" (VAT Base)
        Initialize();

        // [GIVEN] VAT Statement setup for "Kz37" (VAT Amount), "Kz50" (VAT Base)
        VATProdPostingGroup := LibraryUtility.GenerateGUID();
        CreateVATStatementName(VATStatementName);
        CreateVATStatementLine(VATStatementName, '37', VATStatementLine."Amount Type"::Amount, VATProdPostingGroup);
        CreateVATStatementLine(VATStatementName, '50', VATStatementLine."Amount Type"::Base, VATProdPostingGroup);
        // [GIVEN] Posted VAT Entry with Amount "A", Base "B"
        MockVATEntry(VATEntry, VATProdPostingGroup);
        // [GIVEN] Sales VAT Advance notification entry
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, VATStatementName.Name);

        // [WHEN] Run "Create XML File" action from sales VAT advance notification
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] XML file has been generated with the following nodes:
        // [THEN] "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz37" = "B"
        // [THEN] "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz50" = "A"
        LoadXMLFromSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        Assert.AreEqual(
            Format(VATEntry.Amount, 0, '<precision,2:2><Sign><Integer><Decimals><comma,.>'),
            LibraryXPathXMLReader.GetXmlElementValue('//ns:Steuerfall/ns:Umsatzsteuervoranmeldung/ns:Kz37'),
            'Kz37');
        Assert.AreEqual(
            Format(VATEntry.Base, 0, '<Sign><Integer>'),
            LibraryXPathXMLReader.GetXmlElementValue('//ns:Steuerfall/ns:Umsatzsteuervoranmeldung/ns:Kz50'),
            'Kz50');

        // Tear down
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateXMLFile_KZ21Order()
    var
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempResultedXMLBuffer: Record "XML Buffer" temporary;
        DocInStream: InStream;
        VATProdPostingGroup: Code[20];
    begin
        // [SCENARIO 394388] Report 11016 "Create XML-File VAT Adv.Notif." exports "Kz21" after "Kz10" and before "Kz22"
        Initialize();

        // [GIVEN] VAT Statement setup for "Kz21"
        VATProdPostingGroup := LibraryUtility.GenerateGUID();
        CreateVATStatementName(VATStatementName);
        CreateVATStatementLine(VATStatementName, '21', VATStatementLine."Amount Type"::Base, VATProdPostingGroup);
        // [GIVEN] Posted VAT Entry for "Kz21"
        MockVATEntry(VATEntry, VATProdPostingGroup);
        // [GIVEN] Sales VAT Advance notification setup for "Kz10", "Kz21" and "Kz22"
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, VATStatementName.Name);
        SalesVATAdvanceNotif.Validate("Corrected Notification", true); // for "Kz10"
        SalesVATAdvanceNotif.Validate("Documents Submitted Separately", true); // for "Kz22"
        SalesVATAdvanceNotif.Modify(true);

        // [WHEN] Run "Create XML File" action from sales VAT advance notification
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] XML file has been generated with the following nodes in order:
        // [THEN] "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz10"
        // [THEN] "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz21"
        // [THEN] "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz22"
        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        SalesVATAdvanceNotif."XML Submission Document".CreateInStream(DocInStream);
        TempXMLBuffer.LoadFromStream(DocInStream);
        Assert.IsTrue(TempXMLBuffer.FindNodesByXPath(TempResultedXMLBuffer, 'Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz10'), '');
        TempResultedXMLBuffer.Reset();
        TempResultedXMLBuffer.Next();
        TempResultedXMLBuffer.TestField(Name, 'Kz21');
        TempResultedXMLBuffer.Next();
        TempResultedXMLBuffer.TestField(Name, 'Kz22');

        // Tear down
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ShowAmountsFromTheCreatedXMLFile()
    var
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
        ElecVATDeclOverview: TestPage "Elec. VAT Decl. Overview";
        VATProdPostingGroup: Code[20];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 422698] Stan can see the amounts from the created XML file in UI

        Initialize();

        // [GIVEN] VAT Statement setup for "Kz37" (VAT Amount), "Kz50" (VAT Base)
        VATProdPostingGroup := LibraryUtility.GenerateGUID();
        CreateVATStatementName(VATStatementName);
        CreateVATStatementLine(VATStatementName, '37', VATStatementLine."Amount Type"::Amount, VATProdPostingGroup);
        CreateVATStatementLine(VATStatementName, '50', VATStatementLine."Amount Type"::Base, VATProdPostingGroup);
        // [GIVEN] Posted VAT Entry with Amount "A", Base "B"
        MockVATEntry(VATEntry, VATProdPostingGroup);
        // [GIVEN] Sales VAT Advance notification entry
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, VATStatementName.Name);
        ElecVATDeclOverview.Trap();

        // [GIVEN] XML file has been generated
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [GIVEN] "Sales VAT Adv. Notif. Card" page is opened
        SalesVATAdvNotifCard.OpenEdit();
        SalesVATAdvNotifCard.Filter.SetFilter("No.", SalesVATAdvanceNotif."No.");

        // [WHEN] Stan press "Preview Amounts" from the "Sales VAT Adv. Notif. Card" page
        SalesVATAdvNotifCard.PreviewAmounts.Invoke();

        // [THEN] "Elec. VAT Decl. Overview" page opens with the code values
        // #37 with amount "A"
        // #50 with amount "B"
        // #83 with zero amount
        ElecVATDeclOverview.First();
        ElecVATDeclOverview.Code.AssertEquals('#37');
        ElecVATDeclOverview.Amount.AssertEquals(Format(VATEntry.Amount, 0, '<precision,2:2><Sign><Integer><Decimals><comma,.>'));
        Assert.IsTrue(ElecVATDeclOverview.Next(), '');
        ElecVATDeclOverview.Code.AssertEquals('#50');
        ElecVATDeclOverview.Amount.AssertEquals(Format(Round(VATEntry.Base, 1, '<'), 0, '<precision,2:2><Sign><Integer><Decimals><comma,.>'));
        ElecVATDeclOverview.Next();
        ElecVATDeclOverview.Code.AssertEquals('#83');
        ElecVATDeclOverview.Amount.AssertEquals('0.00');
        Assert.IsFalse(ElecVATDeclOverview.Next(), '');

        // Tear down
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateXMLFile_Kz87()
    var
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATProdPostingGroup: Code[20];
    begin
        // [SCENARIO 468885] Report 11016 "Create XML-File VAT Adv.Notif." exports "Kz87" (VAT Base type)
        Initialize();

        // [GIVEN] VAT Statement setup for "Kz87" (VAT Base type)
        VATProdPostingGroup := LibraryUtility.GenerateGUID();
        CreateVATStatementName(VATStatementName);
        CreateVATStatementLine(VATStatementName, '87', VATStatementLine."Amount Type"::Base, VATProdPostingGroup);

        // [GIVEN] Posted VAT Entry with Base "A"
        MockVATEntry(VATEntry, VATProdPostingGroup);

        // [GIVEN] Sales VAT Advance notification entry
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, VATStatementName.Name);

        // [WHEN] Run "Create XML File" action from sales VAT advance notification
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] XML file has been generated with the following node: "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz87" = "A"
        LoadXMLFromSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        Assert.AreEqual(
            Format(VATEntry.Base, 0, '<Sign><Integer>'),
            LibraryXPathXMLReader.GetXmlElementValue('//ns:Steuerfall/ns:Umsatzsteuervoranmeldung/ns:Kz87'),
            'Kz87');

        // Tear down
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateXMLFile_Kz90()
    var
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATProdPostingGroup: Code[20];
    begin
        // [SCENARIO 468885] Report 11016 "Create XML-File VAT Adv.Notif." exports "Kz90" (VAT Base type)
        Initialize();

        // [GIVEN] VAT Statement setup for "Kz90" (VAT Base type)
        VATProdPostingGroup := LibraryUtility.GenerateGUID();
        CreateVATStatementName(VATStatementName);
        CreateVATStatementLine(VATStatementName, '90', VATStatementLine."Amount Type"::Base, VATProdPostingGroup);

        // [GIVEN] Posted VAT Entry with Base "A"
        MockVATEntry(VATEntry, VATProdPostingGroup);

        // [GIVEN] Sales VAT Advance notification entry
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month, VATStatementName.Name);

        // [WHEN] Run "Create XML File" action from sales VAT advance notification
        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        // [THEN] XML file has been generated with the following node: "Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz90" = "A"
        LoadXMLFromSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        Assert.AreEqual(
            Format(VATEntry.Base, 0, '<Sign><Integer>'),
            LibraryXPathXMLReader.GetXmlElementValue('//ns:Steuerfall/ns:Umsatzsteuervoranmeldung/ns:Kz90'),
            'Kz90');

        // Tear down
        VATStatementName.Delete(true);
    end;

    local procedure Initialize()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        LibraryVariableStorage.Clear();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibrarySetupStorage.SaveCompanyInformation();
    end;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; Period: Option; StatementName: Code[10])
    begin
        SalesVATAdvanceNotif."No." := LibraryUtility.GenerateGUID();
        SalesVATAdvanceNotif."Contact for Tax Office" := LibraryUtility.GenerateGUID();
        SalesVATAdvanceNotif.Period := Period;
        SalesVATAdvanceNotif."Statement Name" := StatementName;
        SalesVATAdvanceNotif."Use Authentication" := true;
        SalesVATAdvanceNotif.Insert();
        SalesVATAdvanceNotif.SetRecFilter();
        UpdateStartingDateOnSalesVATAdvanceNotification(SalesVATAdvanceNotif, 0);  // Period Length Zero for current Month.
    end;

    local procedure FindVATStatementName(): Code[10];
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        VATStatementName.SetRange("Sales VAT Adv. Notif.", true);
        VATStatementName.FindFirst();
        exit(VATStatementName.Name);
    end;

    local procedure UpdateStartingDateOnSalesVATAdvanceNotification(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; PeriodLength: Integer);
    var
        Month: Integer;
        Year: Integer;
    begin
        Month := Date2DMY(WorkDate(), 2);  // Required for Month.
        Year := Date2DMY(WorkDate(), 3);  // Required for Year.
        SalesVATAdvanceNotif."Starting Date" := DMY2Date(1, Month + PeriodLength, Year);
        SalesVATAdvanceNotif.Modify();
    end;

    local procedure CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    var
        CreateXMLFileVATAdvNotif: Report "Create XML-File VAT Adv.Notif.";
    begin
        SalesVATAdvanceNotif.SetRange("No.", SalesVATAdvanceNotif."No.");
        CreateXMLFileVATAdvNotif.SetTableView(SalesVATAdvanceNotif);
        CreateXMLFileVATAdvNotif.Run();  // Invokes CreateXMLFileVATAdvNotifReportHandler, ShowXMLFileVATAdvNotifReportHandler, TransmitXMLFileVATAdvNotifReportHandler.
    end;

    local procedure CreateVATStatementName(var VATStatementName: Record "VAT Statement Name")
    begin
        LibraryERM.CreateVATStatementNameWithTemplate(VATStatementName);
        VATStatementName."Sales VAT Adv. Notif." := true;
        VATStatementName.Modify();
    end;

    local procedure CreateVATStatementLine(VATStatementName: Record "VAT Statement Name"; RowNo: Code[10]; AmountType: Enum "VAT Statement Line Amount Type"; VATProdPostingGroup: Code[20]);
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.Init();
        VATStatementLine."Statement Template Name" := VATStatementName."Statement Template Name";
        VATStatementLine."Statement Name" := VATStatementName.Name;
        VATStatementLine."Line No." := LibraryUtility.GetNewRecNo(VATStatementLine, VATStatementLine.FieldNo("Line No."));
        VATStatementLine."Row No." := RowNo;
        VATStatementLine."Print with" := VATStatementLine."Print with"::Sign;
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Amount Type" := AmountType;
        VATStatementLine."VAT Prod. Posting Group" := VATProdPostingGroup;
        VATStatementLine.Insert();
    end;

    local procedure MockVATEntry(var VATEntry: Record "VAT Entry"; VATProdPostingGroup: Code[20]);
    begin
        VATEntry.Init();
        VATEntry."Entry No." := LibraryUtility.GetNewRecNo(VATEntry, VATEntry.FieldNo("Entry No."));
        VATEntry."Posting Date" := WorkDate();
        VATEntry."VAT Prod. Posting Group" := VATProdPostingGroup;
        VATEntry.Amount := LibraryRandom.RandDec(1000, 2);
        VATEntry.Base := LibraryRandom.RandDec(1000, 2);
        VATEntry."Unrealized Amount" := LibraryRandom.RandDec(1000, 2);
        VATEntry."Unrealized Base" := LibraryRandom.RandDec(1000, 2);
        VATEntry.Insert();
    end;

    local procedure VerifySalesVATAdvanceNotification(SalesVATAdvanceNotifNo: Code[20]; Period: Option; StatementName: Code[10]);
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        SalesVATAdvanceNotif.Get(SalesVATAdvanceNotifNo);
        SalesVATAdvanceNotif.TestField(Period, Period);
        SalesVATAdvanceNotif.TestField("Statement Name", StatementName);
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."VAT Representative" := '';
        CompanyInformation.Modify();
    end;

    local procedure UpdateXMLFileVATAdvNotifReportRequestpage(CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif."; CreateXMLOption: Option);
    begin
        CreateXMLFileVATAdvNotif.XMLFile.SetValue(CreateXMLOption);
        CreateXMLFileVATAdvNotif.OK().Invoke();
    end;

    local procedure LoadXMLFromSalesVATAdvanceNotif(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.")
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        TempBlob.FromRecord(SalesVATAdvanceNotif, SalesVATAdvanceNotif.FieldNo("XML Submission Document"));
        LibraryXPathXMLReader.InitializeXml(TempBlob, 'ns', 'http://finkonsens.de/elster/elsteranmeldung/ustva/v2023');
    end;

    [RequestPageHandler]
    procedure ShowXMLFileVATAdvNotifReportHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.");
    var
        CreateXMLOption: Option Create,"Create and export";
    begin
        UpdateXMLFileVATAdvNotifReportRequestpage(CreateXMLFileVATAdvNotif, CreateXMLOption::"Create and export");
    end;

    [RequestPageHandler]
    procedure CreateXMLFileVATAdvNotifReportHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.");
    var
        CreateXMLOption: Option Create,"Create and export";
    begin
        UpdateXMLFileVATAdvNotifReportRequestpage(CreateXMLFileVATAdvNotif, CreateXMLOption::Create);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
    end;

    [RequestPageHandler]
    procedure TransmitXMLFileVATAdvNotifReportHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.");
    var
        CreateXMLOption: Option "Only create","Create and export";
    begin
        UpdateXMLFileVATAdvNotifReportRequestpage(CreateXMLFileVATAdvNotif, CreateXMLOption::"Create and export");
    end;
}
