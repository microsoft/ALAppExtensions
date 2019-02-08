// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148169 "Elster VAT Adv. Notification"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster] [VAT Advance Notification]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        RollBackChangesErr: Label 'Roll-back the changes done by this test case.';

    [Test]
    procedure CheckFieldValuesOnSalesVATAdvanceNotification()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        SalesVATAdvanceNotif2: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Verify Default field Values on New Sales VAT Advance Notification Record after creating First record.

        // Setup: Create and Update Sales VAT Advance Notification Record for the first time.
        Initialize();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        UpdateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // Exercise: Create new Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif2);

        // Verify: Verify that New record will take values from previous record.
        SalesVATAdvanceNotif2.TestField(Period, SalesVATAdvanceNotif.Period);
        SalesVATAdvanceNotif2.TestField("XSL-Filename", SalesVATAdvanceNotif."XSL-Filename");
        SalesVATAdvanceNotif2.TestField("Contact for Tax Office", SalesVATAdvanceNotif."Contact for Tax Office");

        // Tear-Down
        asserterror Error(RollBackChangesErr);
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler,MessageHandler,ConfirmHandlerThatDeletesFile')]
    procedure ExportWhenFileExistsConfirmYes();
    var
        SalesVATAdvanceNotification: Record "Sales VAT Advance Notif.";
        ElectronicVATDeclSetup: Record "Elec. VAT Decl. Setup";
        FileManagement: Codeunit "File Management";
        FullXMLFilename: Text;
    begin
        // [SCENARIO 296232] Export warns user about existing file and if "Yes" is selected overwrites the file.
        Initialize();

        // [GIVEN] Electronic VAT Declaration Setup exists
        CreateElectronicVATDeclSetup(ElectronicVATDeclSetup, LibraryUtility.GenerateGUID(), TemporaryPath());

        // [GIVEN] Sales VAT Advance Notification ready to run the Create XML function
        CreateSalesVATAdvanceNotification(SalesVATAdvanceNotification);
        SalesVATAdvanceNotification.Description := LibraryUtility.GenerateGUID();

        Commit();

        // [GIVEN] XML Body was created for Sales VAT Advance Notification via Create XML Report
        CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotification);
        SalesVATAdvanceNotification."XML-File Creation Date" := WorkDate();

        // [GIVEN] There was no XML file with this name before
        FullXMLFilename := TemporaryPath() +
          STRSUBSTNO('%1_%2.xml', ElectronicVATDeclSetup."XML File Default Name", SalesVATAdvanceNotification.Description);
        FileManagement.DeleteClientFile(FullXMLFilename);

        // [GIVEN] Export was ran to create the file
        SalesVATAdvanceNotification.Export();

        // [WHEN] Export is ran one more time and User chooses "Yes"
        LibraryVariableStorage.Enqueue(FullXMLFilename);
        LibraryVariableStorage.Enqueue(True);
        SalesVATAdvanceNotification.Export();
        // UI Handled by ConfirmHandlerThatDeletesFile

        // [THEN] XML File is created
        Assert.IsTrue(FileManagement.ClientFileExists(FullXMLFilename), 'File does not exist');
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifReportHandler,MessageHandler,ConfirmHandlerThatDeletesFile')]
    procedure ExportWhenFileExistsConfirmNo();
    var
        SalesVATAdvanceNotification: Record "Sales VAT Advance Notif.";
        ElectronicVATDeclSetup: Record "Elec. VAT Decl. Setup";
        FileManagement: Codeunit "File Management";
        FullXMLFilename: Text;
    begin
        // [SCENARIO 296232] Export warns user about existing file and if "Yes" is selected overwrites the file.
        Initialize();

        // [GIVEN] Electronic VAT Declaration Setup exists
        CreateElectronicVATDeclSetup(ElectronicVATDeclSetup, LibraryUtility.GenerateGUID(), TemporaryPath());

        // [GIVEN] Sales VAT Advance Notification ready to run the Create XML function
        CreateSalesVATAdvanceNotification(SalesVATAdvanceNotification);
        SalesVATAdvanceNotification.Description := LibraryUtility.GenerateGUID();

        Commit();

        // [GIVEN] XML Body was created for Sales VAT Advance Notification via Create XML Report
        CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotification);
        SalesVATAdvanceNotification."XML-File Creation Date" := WorkDate();

        // [GIVEN] There was no XML file with this name before
        FullXMLFilename := TemporaryPath() +
          STRSUBSTNO('%1_%2.xml', ElectronicVATDeclSetup."XML File Default Name", SalesVATAdvanceNotification.Description);
        FileManagement.DeleteClientFile(FullXMLFilename);

        // [GIVEN] Export was ran to create the file
        SalesVATAdvanceNotification.Export();

        // [WHEN] Export is ran one more time and User chooses "No"
        LibraryVariableStorage.Enqueue(FullXMLFilename);
        LibraryVariableStorage.Enqueue(False);
        SalesVATAdvanceNotification.Export();
        // UI Handled by ConfirmHandlerThatDeletesFile

        // [THEN] XML File is not created
        Assert.IsFalse(FileManagement.ClientFileExists(FullXMLFilename), 'File exists');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Elster VAT Adv. Notification");
        // Lazy Setup.
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");

        LibraryERMCountryData.CreateVATData();
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");
    end;

    local procedure UpdateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif.Validate("XSL-Filename", TemporaryPath() + SalesVATAdvanceNotif.Description + SalesVATAdvanceNotif."No." + '.xsl');
        SalesVATAdvanceNotif.Validate(Period, SalesVATAdvanceNotif.Period::Quarter);
        SalesVATAdvanceNotif.Validate("Contact for Tax Office", LibraryUtility.GenerateGUID());
        SalesVATAdvanceNotif.Modify(true);
    END;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif.Init();
        SalesVATAdvanceNotif.Validate("No.",
          CopyStr(LibraryUtility.GenerateRandomCode(SalesVATAdvanceNotif.FieldNo("No."), Database::"Sales VAT Advance Notif."),
            1, LibraryUtility.GetFieldLength(Database::"Sales VAT Advance Notif.", SalesVATAdvanceNotif.FieldNo("No."))));
        SalesVATAdvanceNotif.Insert(true);
    end;

    local procedure CreateSalesVATAdvanceNotification(var SalesVATAdvanceNotification: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotification.Init();
        SalesVATAdvanceNotification."No." := LibraryUtility.GenerateGUID();
        SalesVATAdvanceNotification."Contact for Tax Office" := LibraryUtility.GenerateGUID();
        SalesVATAdvanceNotification.Period := SalesVATAdvanceNotification.Period::Month;
        SalesVATAdvanceNotification."Starting Date" := DMY2Date(1, Date2DMY(WorkDate(), 2), Date2DMY(WorkDate(), 3));
        SalesVATAdvanceNotification.Insert();
    end;


    local procedure CreateElectronicVATDeclSetup(var ElectronicVATDeclSetup: Record "Elec. VAT Decl. Setup"; DefaultFileName: Code[20]; DefaultXMLPath: Text);
    begin
        if not ElectronicVATDeclSetup.Get() then
            ElectronicVATDeclSetup.Init();
        ElectronicVATDeclSetup."XML File Default Name" := DefaultFileName;
        ElectronicVATDeclSetup."Sales VAT Adv. Notif. Path" := COPYSTR(DefaultXMLPath, 1, 250);
        ElectronicVATDeclSetup.Modify();
    end;

    local procedure CreateXMLFileVATAdvNotificationReport(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    var
        CreateXMLFileVATAdvNotif: Report "Create XML-File VAT Adv.Notif.";
    begin
        SalesVATAdvanceNotif.SetRange("No.", SalesVATAdvanceNotif."No.");
        CreateXMLFileVATAdvNotif.SetTableView(SalesVATAdvanceNotif);
        CreateXMLFileVATAdvNotif.Run();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerThatDeletesFile(Question: Text[1024]; var Reply: Boolean);
    var
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.DeleteClientFile(LibraryVariableStorage.DequeueText());
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [RequestPageHandler]
    procedure CreateXMLFileVATAdvNotifReportHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.");
    var
        CreateXMLOption: Option Create,"Create and export";
    begin
        CreateXMLFileVATAdvNotif.XMLFile.SetValue(CreateXMLOption::Create);
        CreateXMLFileVATAdvNotif.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
    end;
}