// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using System.Threading;
using Microsoft.eServices.EDocument.Service;

codeunit 139780 "Integration Tests"
{

    Subtype = Test;
    TestType = Uncategorized;
    Permissions = tabledata "Logiq Connection Setup" = rimd,
                  tabledata "Logiq Connection User Setup" = rimd,
                  tabledata "E-Document" = rd;
    TestHttpRequestPolicy = AllowOutboundFromHandler;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure CreateLogiqUserSetup()
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
    begin
        this.Initialize(false);

        //[When] Change password in Connection User Setup page
        this.EnterUserCredentials();

        //[Then] Check if access token is updated correctly
        ConnectionUserSetup.Get(UserId());
        this.Assert.AreNotEqual('', ConnectionUserSetup."Access Token - Key", 'Access token is not updated');
        this.Assert.AreNotEqual('', ConnectionUserSetup."Refresh Token - Key", 'Refresh token is not updated');
        this.Assert.AreNotEqual(0DT, ConnectionUserSetup."Access Token Expiration", 'Access token expiration date time is not updated');
        this.Assert.AreNotEqual(0DT, ConnectionUserSetup."Refresh Token Expiration", 'Refresh token expiration date time is not updated');
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure ChangeLogiqCredentials()
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        OldAccessTokenExpires: DateTime;
        OldRefreshTokenExpires: DateTime;
    begin
        this.Initialize(true);
        //[Given] Get old tokens expiration date time
        ConnectionUserSetup.Get(UserId());
        OldAccessTokenExpires := ConnectionUserSetup."Access Token Expiration";
        OldRefreshTokenExpires := ConnectionUserSetup."Refresh Token Expiration";

        //[When] Change password in Connection User Setup page
        this.EnterUserCredentials();

        //[Then] Check if access token is updated correctly
        ConnectionUserSetup.Get(UserId());
        this.Assert.AreNotEqual(OldAccessTokenExpires, ConnectionUserSetup."Access Token Expiration", 'Access token expiration date time is not updated');
        this.Assert.AreNotEqual(OldRefreshTokenExpires, ConnectionUserSetup."Refresh Token Expiration", 'Refresh token expiration date time is not updated');
    end;

    [Test]
    procedure DeleteLogiqUserSetup()
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        OldAccessTokenGuid: Guid;
        OldRefreshTokenGuid: Guid;
    begin
        this.Initialize(true);

        //[Given] Delete
        ConnectionUserSetup.Get(UserId());
        OldAccessTokenGuid := ConnectionUserSetup."Access Token - Key";
        OldRefreshTokenGuid := ConnectionUserSetup."Refresh Token - Key";

        //[When] Delete Connection User Setup page
        ConnectionUserSetup.Delete(true);

        //[Then] Check if access tokens were deleted
        this.Assert.AreEqual(false, IsolatedStorage.Contains(OldAccessTokenGuid), 'Access token is not deleted');
        this.Assert.AreEqual(false, IsolatedStorage.Contains(OldRefreshTokenGuid), 'Refresh token is not deleted');
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SendDocumentToLogiq()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [Then] Re-query the record to get updated information
        EDocument.FindLast();
        // [Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Document Id", 'Document ID is not correct');

        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if e-document status is processed and e-document service status is "Pending Response"
        this.Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Pending Response", 2);
        this.Assert.AreEqual('1', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);

        EDocumentPage.Close();
        //[When] Get the document status
        this.SetReturnedStatus(DocumentStatus::Distributed);
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::Sent, 3);
        this.Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);

        // [Then] Check if E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SendDocumentToLogiqInProgress()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        //[Then] Re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Document Id", 'Document ID is not correct');

        //[Then] Check if e-document status is in progress and e-document service status is pending response
        this.Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Pending Response", 2);
        this.Assert.AreEqual('1', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        //[When] Get the failed document status
        this.SetReturnedStatus(DocumentStatus::Received);
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Pending Response", 3);
        this.Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);

        // Tear down
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocumentServiceStatus.Delete();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure SendDocumentToLogiqFailed()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        //[Then] re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Document Id", 'Document ID is not correct');

        //[Then] Check if e-document status is in progress and e-document service status is pending response
        this.Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Pending Response", 2);
        this.Assert.AreEqual('1', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();

        //[When] Get the failed document status
        this.SetReturnedStatus(DocumentStatus::Failed);
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        //[Then] re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Sending Error", 3);
        this.Assert.AreEqual('2', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);

        // [Then] Check if E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('Logiq rejected the sent file', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('ServerDownHandler')]
    procedure SendDocumentToLogiqServerDown()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        //[Then] re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is empty
        this.Assert.AreEqual('', EDocument."Logiq External Document Id", 'Document ID is not correct');

        //[Then] Check if e-document status is error and e-document service status is sending error
        this.Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Sending Error", 2);
        this.Assert.AreEqual('1', EDocumentPage."Outbound E-Doc. Factbox".HttpLog.Value(), this.IncorrectValueErr);

        //[Then] Check if correct error is shown in E-Document page
        this.Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), 'Error message type is not correct');
        this.Assert.AreEqual('Sending document failed with HTTP Status code 500. Error message: Internal Server Error', EDocumentPage.ErrorMessagesPart.Description.Value(), 'Error message is not correct');
    end;

    [Test]
    [HandlerFunctions('DownloadSingleDocumentHandler')]
    procedure DownloadOneDocument()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        this.Initialize(true);

        //[Then] Open E-Doc page and receive file
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(this.EDocumentService);
        EDocServicePage.Receive.Invoke();
        EDocServicePage.Close();

        //[Then] Assert that e-document is created
        this.Assert.TableIsNotEmpty(Database::"E-Document");

        //[Then] Assert that we have Purchase Invoice created
        EDocument.FindLast();
        PurchaseHeader.Get(EDocument."Document Record ID");
        this.Assert.AreEqual(this.Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Wrong Vendor');
    end;

    [Test]
    [HandlerFunctions('DownloadMultipleDocumentsHandler')]
    procedure DownloadMultipleDocuments()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        this.Initialize(true);

        //[Then] Open E-Doc page and receive 2 files
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(this.EDocumentService);
        EDocServicePage.Receive.Invoke();
        EDocServicePage.Close();

        //[Then] Assert that 2 e-documents are created
        EDocument.FindSet();
        this.Assert.AreEqual(2, EDocument.Count, 'Not all documents were downloaded');

        //[Then] Assert that we have Purchase Invoices created
        repeat
            PurchaseHeader.Get(EDocument."Document Record ID");
            this.Assert.AreEqual(this.Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Wrong Vendor');
        until EDocument.Next() = 0;
    end;

    local procedure VerifyOutboundFactboxValuesForSingleService(EDocument: Record "E-Document"; Status: Enum "E-Document Service Status"; Logs: Integer);
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        Factbox: TestPage "Outbound E-Doc. Factbox";
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindSet();
        // This function is for single service, so we expect only one record
        Assert.RecordCount(EDocumentServiceStatus, 1);

        Factbox.OpenView();
        Factbox.GoToRecord(EDocumentServiceStatus);

        Assert.AreEqual(EDocumentService.Code, Factbox."E-Document Service".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Status), Factbox.SingleStatus.Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Logs), Factbox.Log.Value(), IncorrectValueErr);
    end;

    //Setup mock values
    local procedure Initialize(CreateUserCredentials: Boolean)
    begin
        this.LibraryPermission.SetOutsideO365Scope();

        //reset setup with every test
        this.SetMockConnectionSetups(CreateUserCredentials);
        //clear E-Documents table for every run
        this.ClearEDocuments();

        if this.IsInitialized then
            exit;

        this.LibraryEDocument.SetupStandardVAT();
        this.LibraryEDocument.SetupStandardSalesScenario(this.Customer, this.EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Logiq);
        this.LibraryEDocument.SetupStandardPurchaseScenario(this.Vendor, this.EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Logiq);

        this.Vendor."VAT Registration No." := 'NO 777 777 777';
        this.Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        this.Vendor.Modify();

        this.CompanyInformation.Get();
        this.CompanyInformation."VAT Registration No." := 'NO 777 777 778';
        this.CompanyInformation.Modify();

        this.IsInitialized := true;
    end;

    local procedure GetMockDocumentId(): Text
    begin
        exit('12345678');
    end;

    local procedure GetRandomSecret(Length: Integer): SecretText
    var
        Random: Codeunit "Library - Random";
    begin
        exit(Random.RandText(Length));
    end;

    local procedure SetMockConnectionSetups(CreateUserCredentials: Boolean)
    var
        ConnectionSetup: Record "Logiq Connection Setup";
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        Auth: Codeunit "Logiq Auth";
        IsolatedStorageKey: Guid;
    begin
        //recreate setup for every test
        if ConnectionSetup.Get() then
            ConnectionSetup.Delete(true);

        ConnectionSetup.Init();
        ConnectionSetup.Insert(true);
        ConnectionSetup."Client ID" := 'ClientID';
        IsolatedStorageKey := Auth.GetConnectionSetupClientSecretKey();
        Auth.SetIsolatedStorageValue(IsolatedStorageKey, this.GetRandomSecret(30), DataScope::Company);
        ConnectionSetup.Modify(true);

        //recreate setup for every test
        if ConnectionUserSetup.Get(UserId()) then
            ConnectionUserSetup.Delete(true);

        ConnectionUserSetup.Init();
        ConnectionUserSetup.Validate("User ID", UserId());
        ConnectionUserSetup.Insert(true);

        ConnectionUserSetup.Validate("API Engine", ConnectionUserSetup."API Engine"::"Engine 1");
        ConnectionUserSetup.Modify(true);

        if CreateUserCredentials then begin
            ConnectionUserSetup.Username := 'user';
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Password - Key", this.GetRandomSecret(20), DataScope::User);
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Access Token - Key", this.GetRandomSecret(50), DataScope::User);
            ConnectionUserSetup."Access Token Expiration" := CurrentDateTime + 3000 * 1000;
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Refresh Token - Key", this.GetRandomSecret(50), DataScope::User);
            ConnectionUserSetup."Refresh Token Expiration" := CurrentDateTime + 3000 * 1000;
            ConnectionUserSetup.Modify(true);
        end;
    end;

    local procedure ClearEDocuments()
    var
        EDocument: Record "E-Document";
    begin
        if EDocument.FindSet() then
            EDocument.DeleteAll();
    end;

    local procedure EnterUserCredentials()
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        ConnectionUserSetupPage: TestPage "Logiq Connection User Setup";
    begin
        ConnectionUserSetup.Get(UserId());

        ConnectionUserSetupPage.OpenView();

        ConnectionUserSetupPage.GoToRecord(ConnectionUserSetup);
        ConnectionUserSetupPage.Username.Value := 'user';
        ConnectionUserSetupPage.Password.Value := 'password';
        ConnectionUserSetupPage.Close();
    end;

    local procedure SetReturnedStatus(NewDocumentStatus: Option Distributed,Received,Failed)
    begin
        this.DocumentStatus := NewDocumentStatus;
    end;

    [ModalPageHandler]
    procedure EDocumentServiceSelectionHandler(var EDocumentServices: TestPage "E-Document Services")
    begin
        EDocumentServices.GoToRecord(this.EDocumentService);
        EDocumentServices.OK().Invoke();
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        DocumentSentFileTok: Label 'DocumentSent.txt', Locked = true;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/auth/realms/connect-api/protocol/openid-connect/token'):
                LoadResourceIntoHttpResponse(AccessTokenFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/edi/connect/2.0/transfer-status/externalId/\d+'):
                this.GetTransferStatus(Response);

            Regex.IsMatch(Request.Path, 'https?://.+/edi/connect/2.0/transfer'):
                LoadResourceIntoHttpResponse(DocumentSentFileTok, Response);
        end;
    end;

    [HttpClientHandler]
    internal procedure ServerDownHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/auth/realms/connect-api/protocol/openid-connect/token'):
                LoadResourceIntoHttpResponse(AccessTokenFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/edi/connect/2.0/transfer'):
                begin
                    LoadResourceIntoHttpResponse('ServerError.txt', Response);
                    Response.HttpStatusCode := 500;
                end;
        end;
    end;

    [HttpClientHandler]
    internal procedure DownloadSingleDocumentHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/edi/connect/1.0/listfiles'):
                LoadResourceIntoHttpResponse('OneDocumentResponse.txt', Response);

            Regex.IsMatch(Request.Path, 'https?://.+/logiq/1.0/getfile/testfile1.xml'):
                LoadResourceIntoHttpResponse(TestFile1Tok, Response);
        end;
    end;

    [HttpClientHandler]
    internal procedure DownloadMultipleDocumentsHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
    begin
        case true of
            Regex.IsMatch(Request.Path, 'https?://.+/edi/connect/1.0/listfiles'):
                LoadResourceIntoHttpResponse(MultipleDocumentsResponseFileTok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/logiq/1.0/getfile/testfile1.xml'):
                LoadResourceIntoHttpResponse(TestFile1Tok, Response);

            Regex.IsMatch(Request.Path, 'https?://.+/logiq/1.0/getfile/testfile2.xml'):
                LoadResourceIntoHttpResponse(TestFile2Tok, Response);
        end;
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
    end;

    local procedure GetTransferStatus(var Response: TestHttpResponseMessage)
    begin
        case this.DocumentStatus of
            DocumentStatus::Distributed:
                LoadResourceIntoHttpResponse('DocumentStatusDistributed.txt', Response);

            DocumentStatus::Received:
                LoadResourceIntoHttpResponse('DocumentStatusReceived.txt', Response);

            DocumentStatus::Failed:
                LoadResourceIntoHttpResponse('DocumentStatusFailed.txt', Response);
        end;
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        Vendor: Record Vendor;
        Assert: Codeunit Assert;
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        AccessTokenFileTok: Label 'AccessToken.txt', Locked = true;
        MultipleDocumentsResponseFileTok: Label 'MultipleDocumentsResponse.txt', Locked = true;
        TestFile1Tok: Label 'testfile1.xml', Locked = true;
        TestFile2Tok: Label 'testfile2.xml', Locked = true;
        DocumentStatus: Option Distributed,Received,Failed;
}
