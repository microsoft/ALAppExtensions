// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2BRouter;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.Threading;
using Microsoft.Foundation.UOM;
using System.Automation;
using Microsoft.eServices.EDocument.Integration;

codeunit 148199 "Integration Tests"
{
    Subtype = Test;
    Permissions =
        tabledata "b2brouter Setup" = rimd,
        tabledata "E-Document" = r;

    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitDocument()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent 
        Initialize();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();

        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running B2BRouter SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response.
        Assert.AreEqual(EDocument.Direction, EDocument.Direction::Outgoing, 'Direction should be outgoing.');
        Assert.AreEqual(MockServiceDocumentId(), EDocument."b2brouter File Id", 'B2BRouter integration failed to set Document Id on E-Document');
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has "Pending Response"
        Assert.AreEqual(EDocumentService.Code, format(EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code"), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), format(EDocumentPage."Outbound E-Doc. Factbox".SingleStatus), IncorrectValueErr);
        Assert.AreEqual('2', format(EDocumentPage."Outbound E-Doc. Factbox".Log), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        MockPositiveResponse();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running B2BRouter GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has Sent

        Assert.AreEqual(EDocumentService.Code, format(EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code"), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sent"), format(EDocumentPage."Outbound E-Doc. Factbox".SingleStatus), IncorrectValueErr);
        Assert.AreEqual('3', format(EDocumentPage."Outbound E-Doc. Factbox".Log), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sent");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitDocument_Pending_Sent()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Pending response -> Sent 
        Initialize();
        MockPositiveResponse();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"E-Document Get Response";
        if not JobQueueEntry.Insert() then;
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running B2BRouter SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockServiceDocumentId(), EDocument."b2brouter File Id", 'B2BRouter integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        EDocumentPage.Close();


        // [WHEN] Executing Get Response succesfully
        MockPendingResponse();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running B2BRouter GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        MockPositiveResponse();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running B2BRouter GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('4', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpSubmitHandler')]
    procedure SubmitDocument_Error_Sent()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Error -> Pending response -> Sent 
        Initialize();

        // [When] Posting invoice and EDocument is created

        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running B2BRouter SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockServiceDocumentId(), EDocument."b2brouter File Id", 'B2BRouter integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        MockErrorResponse();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running B2BRouter GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is in error state
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has sending error
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        EDocumentPage.ErrorMessagesPart.First();
        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('Document started processing', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocumentPage.ErrorMessagesPart.Next();
        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('Wrong data in send xml', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocumentPage.ErrorMessagesPart.Next();
        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('An error has been identified in the submitted document.', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocumentPage.Close();

        // Then user manually send 

        EDocument.FindLast();

        // [THEN] Open E-Document page and resend
        //MockPendingResponse();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Send_Promoted.Invoke();
        EDocumentPage.Close();

        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('4', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        MockPositiveResponse();

        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running B2BRouter GetResponse 

        EDocument.FindLast();

        // [Then] E-Document is pending response as B2BRouter is async
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('5', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitDocumentB2BRouterServiceDown()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        Initialize();

        MockImportServiceDown();
        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running B2BRouter SubmitDocument 
        EDocument.FindLast();

        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error state when service is down.');
        Assert.AreEqual(0, EDocument."b2brouter File Id", 'Document Id on E-Document should not be set.');

        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage."Outbound E-Doc. Factbox".SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('500: Internal Server Error', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitGetDocuments()
    var
        Unit: Record "Unit of Measure";
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        Initialize();

        if Unit.Get('Piece') then
            Unit.Delete();

        Unit.Code := 'Piece';
        Unit."International Standard Code" := 'EA';
        Unit.Insert();

        // Open and close E-Doc page creates auto import job due to setting
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);
        EDocServicePage."Resolve Unit Of Measure".SetValue(true);
        EDocServicePage."Lookup Item Reference".SetValue(false);
        EDocServicePage."Lookup Item GTIN".SetValue(false);
        EDocServicePage."Lookup Account Mapping".SetValue(false);
        EDocServicePage."Validate Line Discount".SetValue(false);
        EDocServicePage.Close();

        // Manually fire job queue job to import
        if EDocument.FindLast() then
            EDocument.SetFilter("Entry No", '>%1', EDocument."Entry No");

        LibraryEDocument.RunImportJob();

        // Assert that we have Purchase Invoice created
#pragma warning disable AA0210
        EDocument.SetRange("Document Type", EDocument."Document Type"::"Purchase Invoice");
        EDocument.SetRange("Bill-to/Pay-to No.", Vendor."No.");
#pragma warning restore AA0210
        EDocument.FindLast();
        PurchaseHeader.Get(EDocument."Document Record ID");
        Assert.AreEqual(Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Wrong Vendor');
    end;

    local procedure Initialize()
    var
        b2brouterSetup: Record "b2brouter Setup";
        CompanyInformation: Record "Company Information";
        EDocument: Record "E-Document";
        workflow: Record Workflow;
        ErrorMessage: Record "Error Message";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentLog: Record "E-Document Log";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        ApiKey: Text;
    begin
        MockImport201();
        if IsInitialized then
            exit;

        if b2brouterSetup.Get() then
            b2brouterSetup.DeleteAll();

        ApiKey := 'test';
        b2brouterSetup."Sandbox Mode" := true;
        b2brouterSetup."Sandbox Project" := 'test';
        b2brouterSetup.StoreApiKey(true, ApiKey);
        b2brouterSetup.Insert();

        ErrorMessage.DeleteAll();
        EDocument.DeleteAll();
        EDocumentService.DeleteAll();
        EDocumentLog.DeleteAll();
        EDocumentIntegrationLog.DeleteAll();
        workflow.DeleteAll();
        JobQueueEntry.DeleteAll();

        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::b2brouter);
        LibraryEDocument.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::b2brouter);
        EDocumentService.Validate("Auto Import", true);
        EDocumentService."Import Minutes between runs" := 10;
        EDocumentService."Import Start Time" := Time();
        EDocumentService.Modify();

        Customer."VAT Registration No." := 'DE123456789';
        Customer.Modify();

        Vendor."VAT Registration No." := 'DE987654321';
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        Vendor.Modify();

        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'DE123456789';
        CompanyInformation.Modify();

        IsInitialized := true;
    end;

    internal procedure MockServiceDocumentId(): Integer
    begin
        exit(45634);
    end;

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocServicesPage: TestPage "E-Document Services")
    begin
        EDocServicesPage.Filter.SetFilter(Code, EDocumentService.Code);
        EDocServicesPage.OK().Invoke();
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit System.Utilities.Regex;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/projects/.*/invoices/import\.json'):
                begin
                    LoadResourceIntoHttpResponse(ImportResourceUrl, Response);
                    Response.HttpStatusCode := ImportStatusCode;
                end;

            Regex.IsMatch(Request.Path, 'https?://.+/invoices/[0-9]+\.json$'):
                begin
                    LoadResourceIntoHttpResponse(ResponseResourceUrl, Response);
                    Response.HttpStatusCode := ResponseStatusCode;
                end;

            Regex.IsMatch(Request.Path, 'https?://.+/invoices/[0-9]+/as/'):
                begin
                    LoadResourceIntoHttpResponse('DownloadDocument.txt', Response);
                    Response.HttpStatusCode := 200;
                end;

            Regex.IsMatch(Request.Path, 'https?://.+/projects/.*/received\.json$'):
                begin
                    LoadResourceIntoHttpResponse('ReceivedInvoices.txt', Response);
                    Response.HttpStatusCode := 200;
                end;

            Regex.IsMatch(Request.Path, 'https?://.+/invoices/send_invoice/[0-9]+\.json$'):
                begin
                    LoadResourceIntoHttpResponse('ImportDocument.txt', Response);
                    Response.HttpStatusCode := 201;
                end;

            Regex.IsMatch(Request.Path, 'https?://.+/invoices/[0-9]+/ack\.json$'):
                begin
                    LoadResourceIntoHttpResponse('MarkFetched.txt', Response);
                    Response.HttpStatusCode := 200;
                end;
        end;
    end;

    internal procedure MockImport201()
    begin
        ImportResourceUrl := 'ImportDocument.txt';
        ImportStatusCode := 201;
    end;

    internal procedure MockImportServiceDown()
    begin
        ImportResourceUrl := 'internalErrorResponse.txt';
        ImportStatusCode := 500;
    end;

    internal procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
    end;

    internal procedure MockPositiveResponse(): Text
    begin
        ResponseResourceUrl := 'PositiveResponse.txt';
        ResponseStatusCode := 201;
    end;

    internal procedure MockPendingResponse(): Text
    begin
        ResponseResourceUrl := 'PendingResponse.txt';
        ResponseStatusCode := 201;
    end;

    internal procedure MockErrorResponse(): Text
    begin
        ResponseResourceUrl := 'errorResponse.txt';
        ResponseStatusCode := 201;
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        Assert: Codeunit "Library Assert";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        ResponseResourceUrl: Text;
        ResponseStatusCode: Integer;

        ImportResourceUrl: Text;
        ImportStatusCode: Integer;
}