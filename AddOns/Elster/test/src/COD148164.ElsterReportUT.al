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
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;

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
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month);
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
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month);
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
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Quarter);
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
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month);
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
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Month);

        // Exercise: Update Create XML Option to Create in CreateXMLFileVATAdvNotifReportHandler and to Create and Transmit in TransmitXMLFileVATAdvNotifReportHandler.
        Commit(); // Commit required as the explicit Commit used in Sales VAT Advance Notification - OnPostDataItem in REPORT ID: 11016 - Create XML File VAT Adv. Notif.
        CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif);

        // Verify: Verify the Sales VAT Advance Notification Period, Statement Name and XSL File as blank.
        VerifySalesVATAdvanceNotification(SalesVATAdvanceNotif."No.", SalesVATAdvanceNotif.Period::Month, SalesVATAdvanceNotif."Statement Name");
    END;

    local procedure Initialize()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        LibraryVariableStorage.Clear();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; Period: Option)
    begin
        SalesVATAdvanceNotif."No." := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif."Contact for Tax Office" := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif.Period := Period;
        SalesVATAdvanceNotif."Statement Name" := FindVATStatementName();
        SalesVATAdvanceNotif."Use Authentication" := true;
        SalesVATAdvanceNotif.Insert();
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

    local procedure VerifySalesVATAdvanceNotification(SalesVATAdvanceNotifNo: Code[20]; Period: Option; StatementName: Code[10]);
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        SalesVATAdvanceNotif.Get(SalesVATAdvanceNotifNo);
        SalesVATAdvanceNotif.TestField("XML-File Creation Date", Today());
        SalesVATAdvanceNotif.TestField("XSL-Filename", '');
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
