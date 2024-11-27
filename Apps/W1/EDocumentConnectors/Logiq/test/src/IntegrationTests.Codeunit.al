// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;

codeunit 148201 "Integration Tests"
{

    Subtype = Test;
    Permissions = tabledata "Connection Setup" = rimd,
                    tabledata "E-Document" = rd;


    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure CreateLogiqUserSetup()
    var
        ConnectionUserSetup: Record "Connection User Setup";
    begin
        this.Initialize(false);

        //[When] Change password in Connection User Setup page
        this.EnterUserCredentials();

        //[Then] Check if access token is updated correctly
        ConnectionUserSetup.Get(UserId());
        this.Assert.AreNotEqual('', ConnectionUserSetup."Access Token", 'Access token is not updated');
        this.Assert.AreNotEqual('', ConnectionUserSetup."Refresh Token", 'Refresh token is not updated');
        this.Assert.AreNotEqual(0DT, ConnectionUserSetup."Access Token Expiration", 'Access token expiration date time is not updated');
        this.Assert.AreNotEqual(0DT, ConnectionUserSetup."Refresh Token Expiration", 'Refresh token expiration date time is not updated');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure ChangeLogiqCredentials()
    var
        ConnectionUserSetup: Record "Connection User Setup";
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

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteLogiqUserSetup()
    var
        ConnectionUserSetup: Record "Connection User Setup";
        OldAccessTokenGuid: Guid;
        OldRefreshTokenGuid: Guid;
    begin
        this.Initialize(true);

        //[Given] Delete
        ConnectionUserSetup.Get(UserId());
        OldAccessTokenGuid := ConnectionUserSetup."Access Token";
        OldRefreshTokenGuid := ConnectionUserSetup."Refresh Token";

        //[When] Delete Connection User Setup page
        ConnectionUserSetup.Delete(true);

        //[Then] Check if access tokens were deleted
        this.Assert.AreEqual(false, IsolatedStorage.Contains(OldAccessTokenGuid), 'Access token is not deleted');
        this.Assert.AreEqual(false, IsolatedStorage.Contains(OldRefreshTokenGuid), 'Refresh token is not deleted');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('EDocumentServiceSelectionHandler')]
    procedure SendDocumentToLogiq()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint to return 200 OK
        this.SetTransferResponseCode('200');

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();

        //[Then] E-Document is sent to Logiq
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Recreate.Invoke();
        EDocumentPage.Send.Invoke();

        //[Then] Re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Id", 'Document ID is not correct');

        //[Then] Check if e-document status is processed and e-document service status is sent
        this.Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        //[When] Get the document status
        this.SetReturnedStatus('distributed');
        EDocumentPage.UpdateStatus.Invoke();

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::Approved), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        // [Then] Check if E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('EDocumentServiceSelectionHandler')]
    procedure SendDocumentToLogiqInProgress()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint to return 200 OK
        this.SetTransferResponseCode('200');

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();

        //[Then] E-Document is sent to Logiq
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Recreate.Invoke();
        EDocumentPage.Send.Invoke();

        //[Then] Re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Id", 'Document ID is not correct');

        //[Then] Check if e-document status is in progress and e-document service status is sent
        this.Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        //[When] Get the failed document status
        this.SetReturnedStatus('received');
        EDocumentPage.UpdateStatus.Invoke();

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::"In Progress Logiq"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        // [Then] Check if E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('EDocumentServiceSelectionHandler')]
    procedure SendDocumentToLogiqFailed()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint to return 200 OK
        this.SetTransferResponseCode('200');

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();

        //[Then] E-Document is sent to Logiq
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Recreate.Invoke();
        EDocumentPage.Send.Invoke();

        //[Then] re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is updated correctly
        this.Assert.AreEqual(this.GetMockDocumentId(), EDocument."Logiq External Id", 'Document ID is not correct');

        //[Then] Check if e-document status is processed and e-document service status is sent
        this.Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        //[When] Get the failed document status
        this.SetReturnedStatus('failed');
        EDocumentPage.UpdateStatus.Invoke();

        //[Then] Check if status is updated correctly
        this.Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Failed Logiq"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        // [Then] Check if E-Document Errors and Warnings has correct status
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), this.IncorrectValueErr);
        EDocumentPage.Close();
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('EDocumentServiceSelectionHandler')]
    procedure SendDocumentToLogiqServerDown()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint to return 500 server error
        this.SetTransferResponseCode('500');

        //[When] Post an invoice and E-Document is created
        this.LibraryEDocument.PostInvoice(this.Customer);
        EDocument.FindLast();

        //[Then] E-Document is sent to Logiq
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Recreate.Invoke();
        EDocumentPage.Send.Invoke();

        //[Then] Re-query the record to get updated information
        EDocument.FindLast();
        EDocumentPage.GoToRecord(EDocument);

        //[Then] Check if external document ID is empty
        this.Assert.AreEqual('', EDocument."Logiq External Id", 'Document ID is not correct');

        //[Then] Check if e-document status is error and e-document service status is sending error
        this.Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), 'E-Document status is not correct');
        this.Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), 'E-Document service status is not correct');
        this.Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), this.IncorrectValueErr);
        this.Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.HttpLogs.Value(), this.IncorrectValueErr);

        //[Then] Check if correct error is shown in E-Document page
        this.Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), 'Error message type is not correct');
        this.Assert.AreEqual('Sending document failed with HTTP Status code 500. Error message: Internal Server Error', EDocumentPage.ErrorMessagesPart.Description.Value(), 'Error message is not correct');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DownloadOneDocument()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint
        this.SetDownloadDocumentsMode('one');

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

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DownloadMultipleDocuments()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        this.Initialize(true);

        //[Given] Set mock endpoint to download 2 documents
        this.SetDownloadDocumentsMode('multiple');

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

    local procedure GetMockBaseUrl(): Text[100]
    begin
        exit('http://localhost:8080/logiq/');
    end;

    local procedure GetMockAuthUrl(): Text[100]
    begin
        exit('http://localhost:8080/logiq/auth');
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
        ConnectionSetup: Record "Connection Setup";
        ConnectionUserSetup: Record "Connection User Setup";
        Auth: Codeunit Auth;
    begin
        //recreate setup for every test
        if ConnectionSetup.Get() then
            ConnectionSetup.Delete(true);

        ConnectionSetup.Init();
        ConnectionSetup.Insert(true);
        ConnectionSetup."Base URL" := this.GetMockBaseUrl();
        ConnectionSetup."Authentication URL" := this.GetMockAuthUrl();
        ConnectionSetup."Client ID" := 'ClientID';
        Auth.SetIsolatedStorageValue(ConnectionSetup."Client Secret", this.GetRandomSecret(30));
        ConnectionSetup.Modify(true);

        //recreate setup for every test
        if ConnectionUserSetup.Get(UserId()) then
            ConnectionUserSetup.Delete(true);

        ConnectionUserSetup.Init();
        ConnectionUserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(ConnectionUserSetup."User ID"));
        ConnectionUserSetup.Insert(true);

        ConnectionUserSetup.Validate("API Engine", ConnectionUserSetup."API Engine"::Engine1);
        ConnectionUserSetup.Modify(true);

        if CreateUserCredentials then begin
            ConnectionUserSetup.Username := 'user';
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Password", this.GetRandomSecret(20), DataScope::User);
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Access Token", this.GetRandomSecret(50), DataScope::User);
            ConnectionUserSetup."Access Token Expiration" := CurrentDateTime + 3000 * 1000;
            Auth.SetIsolatedStorageValue(ConnectionUserSetup."Refresh Token", this.GetRandomSecret(50), DataScope::User);
            ConnectionUserSetup."Refresh Token Expiration" := CurrentDateTime + 3000 * 1000;
            ConnectionUserSetup.Modify(true);
        end;
    end;

    local procedure ClearEDocuments()
    var
        EDocument: Record "E-Document";
    begin
        if EDocument.FindSet() then
            EDocument.DeleteAll(true);
    end;

    local procedure EnterUserCredentials()
    var
        ConnectionUserSetup: Record "Connection User Setup";
        ConnectionUserSetupPage: TestPage "Connection User Setup";
    begin
        ConnectionUserSetup.Get(UserId());

        ConnectionUserSetupPage.OpenView();

        ConnectionUserSetupPage.GoToRecord(ConnectionUserSetup);
        ConnectionUserSetupPage.Username.Value := 'user';
        ConnectionUserSetupPage.Password.Value := 'password';
        ConnectionUserSetupPage.Close();
    end;

    local procedure SetReturnedStatus(Status: Text)
    var
        ConnectionUserSetup: Record "Connection User Setup";
    begin
        if ConnectionUserSetup.Get(UserId()) then begin
            ConnectionUserSetup."Document Status Endpoint" += Status;
            ConnectionUserSetup.Modify(true);
        end;
    end;

    local procedure SetTransferResponseCode(Code: Text)
    var
        ConnectionUserSetup: Record "Connection User Setup";
    begin
        if ConnectionUserSetup.Get(UserId()) then begin
            ConnectionUserSetup."Document Transfer Endpoint" += '/' + Code;
            ConnectionUserSetup.Modify(true);
        end;
    end;

    local procedure SetDownloadDocumentsMode(Endpoint: Text)
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();
        ConnectionSetup."File List Endpoint" += '/' + Endpoint;
        ConnectionSetup.Modify(true);
    end;

    [ModalPageHandler]
    procedure EDocumentServiceSelectionHandler(var EDocumentServices: TestPage "E-Document Services")
    begin
        EDocumentServices.GoToRecord(this.EDocumentService);
        EDocumentServices.OK().Invoke();
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        Vendor: Record Vendor;
        Assert: Codeunit Assert;
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
}