// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Utilities;
using System.Threading;
using System.Environment.Configuration;
using System.Apps;
using Microsoft.eServices.EDocument;
using Microsoft.Inventory.Item;
using Microsoft.EServices.EDocument.Service.Participant;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument.Integration;

codeunit 148193 IntegrationTests
{
    Subtype = Test;

    Permissions = tabledata "SignUp Connection Setup" = rimd,
                  tabledata "E-Document" = r;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        IntegrationHelpers: Codeunit IntegrationHelpers;
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value', Locked = true;
        GetAccessTokenFileTok: Label 'GetAccessToken.txt', Locked = true;
        DocumentStatus: Option Processing,Error;

    #region tests
    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitDocument()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Pending response -> Sent 
        this.Initialize();

        // [Given] Team member 
        this.LibraryLowerPermissions.SetTeamMember();
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');

        // [When] Posting invoice and EDocument is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        this.LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ExFlow SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response.
        this.Assert.AreEqual(this.IntegrationHelpers.MockServiceDocumentId(), EDocument."Signup Document Id", 'ExFlow integration failed to set Document Id on E-Document');
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has "Pending Response"
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(2, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        this.LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ExFlow GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has Sent
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(3, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SubmitDocument_Pending_Sent()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Pending response -> Sent 
        this.Initialize();

        // [Given] Team member
        this.LibraryLowerPermissions.SetTeamMember();
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');

        // [When] Posting invoice and EDocument is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        this.LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ExFlow SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        this.Assert.AreEqual(this.IntegrationHelpers.MockServiceDocumentId(), EDocument."Signup Document Id", 'ExFlow integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(2, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Edit');
        this.SetDocumentStatus(DocumentStatus::Processing);
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        this.LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ExFlow GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(3, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Edit');
        this.SetDocumentStatus(DocumentStatus::Processing);
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        this.LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ExFlow GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(4, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpSubmitHandler')]
    procedure SubmitDocument_Error_Sent()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Error -> Pending response -> Sent 
        this.Initialize();

        // [Given] Team member 
        this.LibraryLowerPermissions.SetTeamMember();
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');

        // [When] Posting invoice and EDocument is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        this.LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ExFlow SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        this.Assert.AreEqual(this.IntegrationHelpers.MockServiceDocumentId(), EDocument."Signup Document Id", 'ExFlow integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(2, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Edit');
        this.SetDocumentStatus(DocumentStatus::Error);
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        this.LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ExFlow GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is in error state
        this.Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has sending error
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Sending Error", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(3, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        EDocumentPage.ErrorMessagesPart.First();
        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('Reason: Http error 404 document identifier not found', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);

        EDocumentPage.Close();

        // Then user manually send 
        EDocument.FindLast();

        // [THEN] Open E-Document page and resend
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.SetDocumentStatus(DocumentStatus::Processing);
        EDocumentPage.Send_Promoted.Invoke();
        EDocumentPage.Close();

        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(4, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Edit');
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');

        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        this.LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ExFlow GetResponse
        EDocument.FindLast();

        // [Then] E-Document is pending response as ExFlow is async
        this.Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(5, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('ServiceDownHandler')]
    procedure SubmitDocumentServiceDown()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        this.Initialize();

        // [Given] Team member 
        this.LibraryLowerPermissions.SetTeamMember();
        this.LibraryLowerPermissions.AddPermissionSet('SignUp E-Doc Read');

        // [When] Posting invoice and EDocument is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        this.LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Avalara SubmitDocument 
        EDocument.FindLast();

        this.Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error state when service is down.');
        this.Assert.AreEqual('', EDocument."Signup Document Id", 'Document Id on E-Document should not be set.');

        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [THEN] E-Document has correct error status
        this.Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), this.IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        EDocumentServiceStatus := this.GetEDocumentServiceStatus(EDocument."Entry No");
        this.Assert.AreEqual(this.EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", this.IncorrectValueErr);
        this.Assert.AreEqual(Enum::"E-Document Service Status"::"Sending Error", EDocumentServiceStatus.Status, this.IncorrectValueErr);
        this.Assert.AreEqual(2, this.LogsCount(EDocumentServiceStatus), this.IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        this.LibraryEDocument.AssertEDocumentLogs(EDocument, this.EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('There was an error sending the request. Response code: 500 and error message: Internal Server Error', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('ReceiveDocumentHandler')]
    procedure SubmitGetDocuments()
    var
        EDocument: Record "E-Document";
        EDocumentServicesPage: TestPage "E-Document Service";
        TmpDocCount: Integer;
    begin
        this.Initialize();

        // Open and close E-Doc page creates auto import job due to setting
        EDocumentServicesPage.OpenView();
        EDocumentServicesPage.GoToRecord(this.EDocumentService);
        EDocumentServicesPage."Resolve Unit Of Measure".SetValue(false);
        EDocumentServicesPage."Lookup Item Reference".SetValue(true);
        EDocumentServicesPage."Lookup Item GTIN".SetValue(false);
        EDocumentServicesPage."Lookup Account Mapping".SetValue(false);
        EDocumentServicesPage."Validate Line Discount".SetValue(false);
        EDocumentServicesPage."Auto Import".SetValue(true);
        EDocumentServicesPage.Close();

        TmpDocCount := EDocument.Count();
        // Manually fire job queue job to import
        this.LibraryEDocument.RunImportJob();

        // Assert that we have Purchase Invoice created
        this.Assert.AreEqual(TmpDocCount + 1, EDocument.Count(), 'The document was not imported!');
    end;

    [Test]
    [HandlerFunctions('GetMetadataProfileHandler')]
    procedure GetMetadataProfiles()
    var
        SignUpMetadataProfile: Record "SignUp Metadata Profile";
        EDocServiceSupportedTypes: TestPage "E-Doc Service Supported Types";
    begin
        this.Initialize();

        SignUpMetadataProfile.Reset();
        SignUpMetadataProfile.DeleteAll();

        // Populate metadata profiles
        EDocServiceSupportedTypes.OpenView();
        EDocServiceSupportedTypes.PopulateMetaData.Invoke();
        EDocServiceSupportedTypes.Close();

        this.Assert.TableIsNotEmpty(Database::"SignUp Metadata Profile");
    end;

    #endregion

    #region handlers

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocumentServicesPage: TestPage "E-Document Services")
    begin
        EDocumentServicesPage.Filter.SetFilter(Code, this.EDocumentService.Code);
        EDocumentServicesPage.OK().Invoke();
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        GetSentDocumentStatusFileTok: Label 'GetSentDocumentStatus.txt', Locked = true;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/.+/oauth2/token'):
                LoadResourceIntoHttpResponse(GetAccessTokenFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/api/v2/Peppol/outbox/transactions/[0-9a-zA-Z-]+/status'):
                GetStatusResponse(Response);

            Regex.IsMatch(Request.Path, 'https?://.+/api/v2/Peppol/outbox/transactions'):
                LoadResourceIntoHttpResponse(GetSentDocumentStatusFileTok, Response);
        end;
    end;

    [HttpClientHandler]
    internal procedure ReceiveDocumentHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        GetTargetDocumentRequestFileTok: Label 'GetTargetDocumentRequest.txt', Locked = true;
        GetRecievedDocumentsRequestFileTok: Label 'GetReceivedDocumentsRequest.txt', Locked = true;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/.+/oauth2/token'):
                LoadResourceIntoHttpResponse(GetAccessTokenFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/api/v2/Peppol/inbox/transactions/[0-9a-zA-Z-]+'):
                LoadResourceIntoHttpResponse(GetTargetDocumentRequestFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/api/v2/Peppol/inbox/transactions'):
                LoadResourceIntoHttpResponse(GetRecievedDocumentsRequestFileTok, Response);
        end;
    end;

    [HttpClientHandler]
    internal procedure ServiceDownHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
    begin
        if Regex.IsMatch(Request.Path, 'https?://.+/.+/oauth2/token') then
            LoadResourceIntoHttpResponse(GetAccessTokenFileTok, Response)
        else
            Response.HttpStatusCode := 500;
    end;

    [HttpClientHandler]
    internal procedure GetMetadataProfileHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        GetMetadataProfileFileTok: Label 'GetMetadataProfile.txt', Locked = true;
    begin
        if Regex.IsMatch(Request.Path, 'https?://.+/.+/oauth2/token') then
            LoadResourceIntoHttpResponse(GetAccessTokenFileTok, Response)
        else
            LoadResourceIntoHttpResponse(GetMetadataProfileFileTok, Response);
    end;
    #endregion

    #region local methods

    local procedure Initialize()
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
        CompanyInformation: Record "Company Information";
        ServiceParticipant: Record "Service Participant";
        SignUpAuthentication: Codeunit "SignUp Authentication";
    begin
        this.AllowEDocConnectorHttpRequests();
        this.LibraryLowerPermissions.SetOutsideO365Scope();

        SignUpConnectionSetup.DeleteAll();
        SignUpAuthentication.InitConnectionSetup();

        if this.IsInitialized then
            exit;

        this.CreateDefaultMetadataProfile();
        this.LibraryEDocument.SetupStandardVAT();
        this.LibraryEDocument.SetupStandardSalesScenario(this.Customer, this.EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::"ExFlow E-Invoicing");
        this.LibraryEDocument.SetupStandardPurchaseScenario(this.Vendor, this.EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::"ExFlow E-Invoicing");
        this.EDocumentService."Auto Import" := true;
        this.EDocumentService."Import Minutes between runs" := 5;
        this.EDocumentService."Import Start Time" := Time();
        this.EDocumentService.Modify();

        this.LibraryInventory.CreateItem(this.Item);

        this.Vendor.Name := 'CRONUS GB SELLER';
        this.Vendor."VAT Registration No." := '777777777'; // GB777777771
        this.Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        this.Vendor.Modify();

        // Vendor to get invoices from
        Clear(ServiceParticipant);
        ServiceParticipant.Service := this.EDocumentService.Code;
        ServiceParticipant."Participant Type" := ServiceParticipant."Participant Type"::Vendor;
        ServiceParticipant.Participant := this.Vendor."No.";
        ServiceParticipant."Participant Identifier" := this.IntegrationHelpers.MockCompanyId();
        ServiceParticipant.Insert();

        // Customer to send invoice to
        Clear(ServiceParticipant);
        ServiceParticipant.Service := this.EDocumentService.Code;
        ServiceParticipant."Participant Type" := ServiceParticipant."Participant Type"::Customer;
        ServiceParticipant.Participant := this.Customer."No.";
        ServiceParticipant."Participant Identifier" := this.IntegrationHelpers.MockCompanyId();
        ServiceParticipant.Insert();

        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := '777777777'; // GB777777771
        CompanyInformation."SignUp Service Participant Id" := this.IntegrationHelpers.MockCompanyId();
        CompanyInformation.Modify();

        this.ApplyMetadataProfile(this.GetMetadataProfileId());

        this.IsInitialized := true;
    end;

    local procedure CreateDefaultMetadataProfile()
    var
        SignUpMetadataProfile: Record "SignUp Metadata Profile";
    begin
        if not SignUpMetadataProfile.IsEmpty() then
            SignUpMetadataProfile.DeleteAll(true);

        SignUpMetadataProfile.Init();
        SignUpMetadataProfile.Validate("Profile ID", this.GetMetadataProfileId());
        SignUpMetadataProfile.Validate("Profile Name", 'PEPPOL BIS Billing v 3 Invoice UBL');
        SignUpMetadataProfile.Validate("Process Identifier Scheme", 'cenbii-procid-ubl');
        SignUpMetadataProfile.Validate("Process Identifier Value", 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0');
        SignUpMetadataProfile.Validate("Document Identifier Scheme", 'busdox-docid-qns');
        SignUpMetadataProfile.Validate("Document Identifier Value", 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2::Invoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::2.1');
        SignUpMetadataProfile.Insert(true);
    end;

    local procedure ApplyMetadataProfile(ProfileID: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if EDocServiceSupportedType.FindSet(true) then
            repeat
                EDocServiceSupportedType.Validate("Profile Id", ProfileID);
                EDocServiceSupportedType.Modify(true);
            until EDocServiceSupportedType.Next() = 0;
    end;

    local procedure GetMetadataProfileId(): Integer
    begin
        exit(158);
    end;

    local procedure AllowEDocConnectorHttpRequests()
    var
        ModuleInfo: ModuleInfo;
    begin
        if not NavApp.GetModuleInfo('b56171bd-9a8e-47ad-a527-99f476d5af83', ModuleInfo) then
            exit;

        this.AllowOutboundHttpRequests(ModuleInfo);
    end;

    local procedure AllowOutboundHttpRequests(ModuleInfo: ModuleInfo)
    var
        NavAppSetting: Record "NAV App Setting";
        ExtensionManagement: Codeunit "Extension Management";
    begin
        if not NavAppSetting.Get(ModuleInfo.Id) then begin
            NavAppSetting.Init();
            NavAppSetting.Validate("App ID", ModuleInfo.Id);
            NavAppSetting.Insert(true);
        end;

        if NavAppSetting."Allow HttpClient Requests" then
            exit;

        ExtensionManagement.ConfigureExtensionHttpClientRequestsAllowance(ModuleInfo.PackageId, true);
    end;

    local procedure GetEDocumentServiceStatus(EntryNo: Integer) EDocumentServiceStatus: Record "E-Document Service Status"
    begin
        EDocumentServiceStatus.SetLoadFields("E-Document Service Code", Status);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EntryNo);
        if EDocumentServiceStatus.FindFirst() then;
    end;

    local procedure LogsCount(EDocumentServiceStatus: Record "E-Document Service Status"): Integer
    var
        EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.SetRange("Service Code", EDocumentServiceStatus."E-Document Service Code");
        EDocumentLog.SetRange("E-Doc. Entry No", EDocumentServiceStatus."E-Document Entry No");
        exit(EDocumentLog.Count());
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
    end;

    local procedure SetDocumentStatus(NewDocumentStatus: Option Processing,Error)
    begin
        this.DocumentStatus := NewDocumentStatus;
    end;

    local procedure GetStatusResponse(var Response: TestHttpResponseMessage)
    var
        GetSentDocumentStatusInProgressFileTok: Label 'GetSentDocumentStatusInProgress.txt', Locked = true;
        GetSentDocumentStatusErrorFileTok: Label 'GetSentDocumentStatusError.txt', Locked = true;
    begin
        case this.DocumentStatus of
            this.DocumentStatus::Processing:
                LoadResourceIntoHttpResponse(GetSentDocumentStatusInProgressFileTok, Response);
            this.DocumentStatus::Error:
                LoadResourceIntoHttpResponse(GetSentDocumentStatusErrorFileTok, Response);
        end;
    end;
    #endregion
}