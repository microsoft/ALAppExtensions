// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148166 "Elster Pages UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster] [UT] [UI]
    end;

    var
        LibraryUTUtility: Codeunit "Library UT Utility";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryApplicationArea: Codeunit "Library - Application Area";

    [Test]
    [HandlerFunctions('VATStatementGermanyRequestPageHandler')]
    procedure PrintSalesVATAdvNotifListSalesVATAdvNotifList()
    var
        SalesVATAdvNotifList: TestPage "Sales VAT Adv. Notif. List";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Print Action of Page ID 11017 - Sales VAT Adv. Notif. List.
        // Setup.
        OpenSalesVATAdvNotifList(SalesVATAdvNotifList, WorkDate());  // XML-File Creation Date as WORKDATE.
        Commit();

        // Exercise & verify: Action Print opens VAT Statement Germany Request Page handled in VATStatementGermanyRequestPageHandler.
        SalesVATAdvNotifList.Print.Invoke();
        SalesVATAdvNotifList.Close();
    end;

    [Test]
    [HandlerFunctions('GLVATReconciliationRequestPageHandler')]
    procedure GLVATReconciliationSalesVATAdvNotifList()
    var
        SalesVATAdvNotifList: TestPage "Sales VAT Adv. Notif. List";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Sales VAT & Adv. Not Acc. Proof Action of Page ID 11017 - Sales VAT Adv. Notif. List.
        // Setup.
        OpenSalesVATAdvNotifList(SalesVATAdvNotifList, WorkDate());  // XML-File Creation Date as WORKDATE.
        Commit();

        // Exercise & verify: Action SalesVATAdvNotAccProof opens VAT Statement Germany Request Page handled in VATStatementGermanyRequestPageHandler.
        SalesVATAdvNotifList.GLVATReconciliation.Invoke();
        SalesVATAdvNotifList.Close();
    end;

    [Test]
    procedure ShowSalesVATAdvNotifList()
    var
        SalesVATAdvNotifList: TestPage "Sales VAT Adv. Notif. List";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Show Action of Page 11017 ID - Sales VAT Adv. Notif. List.
        // Setup.
        OpenSalesVATAdvNotifList(SalesVATAdvNotifList, 0D); // XML-File Creation Date as 0D.

        // Exercise.
        asserterror SalesVATAdvNotifList.Export.Invoke();

        // Verify: Verify Error Code, Actual Error Message: You must create the XML-File before it can be shown.
        Assert.ExpectedErrorCode('Dialog');
        SalesVATAdvNotifList.Close();
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifRequestPageHandler,MessageHandler')]
    procedure CreateXMLFileSalesVATAdvNotifCard()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CreateXMLFile Action of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);  // XML-File Creation Date as 0D.
        Commit();  // Commit required as it is called explicitly from Report - Create XML-File VAT Adv.Notif. OnPostDataItem of Sales VAT Advance Notification.

        // Exercise: Invoke CreateXMLFile Action of Page - Sales VAT Adv. Notif. Card.
        SalesVATAdvNotifCard.CreateXMLFile.Invoke();

        // Verify: Verify XML-File Creation Date updated from UpdateSalesVATAdvNotif function of Report - Create XML File VAT Adv. Notif. as TODAY on Sales VAT Adv. Notif. Card.
        SalesVATAdvNotifCard."XML-File Creation Date".AssertEquals(Today());
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure DeleteXMLFileSalesVATAdvNotifCard()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate DeleteXMLFile Action of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);  // XML-File Creation Date as 0D.

        // Exercise: Invoke Action DeleteXMLFile of Page - Sales VAT Adv. Notif. Card. Opens handler ConfirmHandler.
        SalesVATAdvNotifCard.DeleteXMLFile.Invoke();

        // Verify: Verify Statement Name after Action DeleteXMLFile invoked on Page - Sales VAT Adv. Notif. Card.
        SalesVATAdvNotifCard."Statement Name".AssertEquals('');  // Blank value for Statement Name.
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    [HandlerFunctions('NoSeriesPageHandler')]
    procedure NoAssistEditSalesVATAdvNotifCard()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate No AssistEdit of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        SalesVATAdvanceNotif.DeleteAll();
        SalesVATAdvNotifCard.OpenEdit();

        // Exercise: AssistEdit No. field of Sales - VAT Adv. Notif. Card. Opens handler NoSeriesPageHandler.
        SalesVATAdvNotifCard."No.".AssistEdit();

        // Verify: Verify Number of Records in Sales VAT Advance Notification is equal to 1.
        Assert.AreEqual(1, SalesVATAdvanceNotif.Count(), 'Value must be equal.');
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    [HandlerFunctions('VATStatementGermanyRequestPageHandler')]
    procedure PrintSalesVATAdvNotifCard()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Print Action of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);  // XML-File Creation Date as 0D.
        Commit();

        // Exercise & verify: Invoke Action Print of Page - Sales VAT Adv. Notif. Card. Opens Report - VAT Statement Germany handled in VATStatementGermanyRequestPageHandler.
        SalesVATAdvNotifCard.Print.Invoke();
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    [HandlerFunctions('GLVATReconciliationRequestPageHandler')]
    procedure GLVATReconciliationVATAdvNotifCard()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate SalesVATAdvNotAccProof Action of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);  // XML-File Creation Date as 0D.
        Commit();

        // Exercise & verify: Invoke Action SalesVATAdvNotAccProof of Page - Sales VAT Adv. Notif. Card. Opens Report - Sales VAT Adv. Not. Acc. Proof handled in SalesVATAdvNotAccProofRequestPageHandler.
        SalesVATAdvNotifCard.GLVATReconciliation.Invoke();
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    procedure ShowVATAdvNotifCard()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Show Action of Page 11016 - Sales VAT Adv. Notif. Card.
        // Setup.
        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);  // XML-File Creation Date as 0D.

        // Exercise: Invoke Action Show of Page - Sales VAT Adv. Notif. Card.
        asserterror SalesVATAdvNotifCard.Export.Invoke();

        // Verify: Verify Error Code for Error message - You must create the XML-File before it can be shown.
        Assert.ExpectedErrorCode('Dialog');
        SalesVATAdvNotifCard.Close();
    end;

    [Test]
    procedure Testversion_SalesVATAdvNotificationCardAppAreaBasic()
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        // [FEATURE] [Sales VAT Advance Notification]
        // [SCENARIO 271929] "Testversion" field is available under Basic setup on Sales VAT Advance Notification card page
        LibraryApplicationArea.EnableBasicSetup();

        OpenSalesVATAdvNotifCard(SalesVATAdvNotifCard, 0D);

        Assert.IsTrue(SalesVATAdvNotifCard.Testversion.Visible(), 'Testversion is not visible in Basic setup');

        LibraryApplicationArea.DisableApplicationAreaSetup();
    end;

    local procedure OpenSalesVATAdvNotifList(var SalesVATAdvNotifList: TestPage "Sales VAT Adv. Notif. List"; XMLFileCreationDate: Date);
    begin
        SalesVATAdvNotifList.OpenEdit();
        SalesVATAdvNotifList.Filter.SetFilter("No.", CreateSalesVATAdvanceNotif(XMLFileCreationDate));
    end;

    local procedure CreateSalesVATAdvanceNotif(XMLFileCreationDate: Date): Code[20];
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATStatementName: Record "VAT Statement Name";
    begin
        VATStatementName.FindFirst();
        SalesVATAdvanceNotif."No." := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif."Contact for Tax Office" := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif."Starting Date" := DMY2Date(1, Date2DMY(WorkDate(), 2), Date2DMY(WorkDate(), 3));  // Date where calendar day = 1.
        SalesVATAdvanceNotif."Statement Name" := VATStatementName.Name;
        SalesVATAdvanceNotif."Statement Template Name" := VATStatementName."Statement Template Name";
        SalesVATAdvanceNotif."XML-File Creation Date" := XMLFileCreationDate;
        SalesVATAdvanceNotif.Insert();
        exit(SalesVATAdvanceNotif."No.");
    end;

    local procedure OpenSalesVATAdvNotifCard(var SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card"; XMLFileCreationDate: Date);
    begin
        SalesVATAdvNotifCard.OpenEdit();
        SalesVATAdvNotifCard.Filter.SetFilter("No.", CreateSalesVATAdvanceNotif(XMLFileCreationDate));
    end;

    [RequestPageHandler]
    procedure CreateXMLFileVATAdvNotifRequestPageHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.")
    var
        XMLFile: Option "Only create","Create and export";
    begin
        CreateXMLFileVATAdvNotif.XMLFile.SetValue(XMLFile::"Only create");
        CreateXMLFileVATAdvNotif.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [RequestPageHandler]
    procedure VATStatementGermanyRequestPageHandler(var VATStatementGermany: TestRequestPage "VAT Statement Germany")
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure GLVATReconciliationRequestPageHandler(var GLVATReconciliation: TestRequestPage "G/L - VAT Reconciliation")
    begin
    end;

    [ModalPageHandler]
    procedure NoSeriesPageHandler(var NoSeriesPage: TestPage "No. Series");
    begin
        NoSeriesPage.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure TransmitConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := false;
    end;
}