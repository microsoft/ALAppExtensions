// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Pagero;

using Microsoft.eServices.EDocument;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.Threading;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Service;
using System.Security.Authentication;
using Microsoft.EServices.EDocumentConnector;

codeunit 148192 "Integration Tests"
{
    TestHttpRequestPolicy = AllowOutboundFromHandler;
    Subtype = Test;
    TestType = Uncategorized;
    Permissions = tabledata "E-Doc. Ext. Connection Setup" = rimd,
                    tabledata "E-Document" = r;



    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('HTTPSubmitHandler')]
    internal procedure SubmitDocument()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent 
        Initialize();

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Avalara SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response.
        Assert.AreEqual(MockFileId(), EDocument."File Id", 'Pagero integration failed to set File Id on E-Document');
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has "Pending Response"
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::"Pending Response", 2);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running Avalara GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');
        Assert.AreEqual(MockDocumentId(), EDocument."Document Id", 'Pagero integration failed to set Document Id on E-Document');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has Sent
        VerifyOutboundFactboxValuesForSingleService(EDocument, Enum::"E-Document Service Status"::Sent, 3);

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
    [HandlerFunctions('ConfirmQst')]
    procedure ResetSetupRecord()
    var
        EDocExtConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        EDOCExt: TestPage "EDoc Ext Connection Setup Card";
        ValueBefore: Text;
    begin
        PageroAuth.InitConnectionSetup();
        EDocExtConnectionSetup.Get();
        ValueBefore := EDocExtConnectionSetup."Authentication URL";

        // Mimic wrong url
        EDocExtConnectionSetup."Authentication URL" := 'Random URL';
        EDocExtConnectionSetup.Modify();

        EDOCExt.OpenView();
        EDOCExt.ResetSetup.Invoke();

        EDocExtConnectionSetup.Get();
        Assert.AreEqual(ValueBefore, EDocExtConnectionSetup."Authentication URL", 'Reset Setup did not restore the Authentication URL');
    end;

    [ConfirmHandler]
    procedure ConfirmQst(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true; // Automatically confirm all questions in tests
    end;

    [HttpClientHandler]
    internal procedure HTTPSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        ResponseJson: Text;
    begin
        case Request.Path of
            'https://api.pageroonline.com/file/v1/files':
                begin
                    ResponseJson := NavApp.GetResourceAsText('files200.json', TextEncoding::UTF8);
                    Response.Content.WriteFrom(ResponseJson);
                    Response.HttpStatusCode := 200;
                end;
            'https://api.pageroonline.com/file/v1/files/' + MockFileId() + '/fileparts':
                begin
                    ResponseJson := NavApp.GetResourceAsText('fileparts200.json', TextEncoding::UTF8);
                    Response.Content.WriteFrom(ResponseJson);
                    Response.HttpStatusCode := 200;
                end;
            'https://api.pageroonline.com/document/v1/documents':
                begin
                    ResponseJson := NavApp.GetResourceAsText('documents200.json', TextEncoding::UTF8);
                    Response.Content.WriteFrom(ResponseJson);
                    Response.HttpStatusCode := 200;
                end;
            else
                Response.HttpStatusCode := 500;
        end;
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

    local procedure Initialize()
    var
        ConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        CompanyInformation: Record "Company Information";
        OAuth2Setup: Record "OAuth 2.0 Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        KeyGuid: Guid;
    begin
        LibraryPermission.SetOutsideO365Scope();
        // Clean up token between runs
        if ConnectionSetup.Get() then
            ConnectionSetup.DeleteAll();
        PageroAuth.InitConnectionSetup();
        ConnectionSetup.Get();
        ConnectionSetup."Send Mode" := "E-Doc. Ext. Send Mode"::Test;
        ConnectionSetup."Company Id" := Format(CreateGuid());
        ConnectionSetup.Modify();

        if not OAuth2Setup.Get('EDocPagero') then begin
            OAuth2Setup.Init();
            OAuth2Setup.Code := 'EDocPagero';
            OAuth2Setup."Client Id" := KeyGuid;
            OAuth2Setup."Client Secret" := KeyGuid;
            OAuth2Setup."Access Token" := KeyGuid;
            OAuth2Setup.Insert(true);
        end;

        OAuth2Setup."Access Token Due DateTime" := CurrentDateTime() + 600 * 1000;
        OAuth2Setup.Modify();

        if IsInitialized then
            exit;

        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Pagero);

        LibraryEDocument.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Pagero);
        EDocumentService.Validate("Auto Import", true);
        EDocumentService."Import Minutes between runs" := 10;
        EDocumentService."Import Start Time" := Time();
        EDocumentService.Modify();

        Vendor."VAT Registration No." := 'GB777777771';
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        Vendor.Modify();

        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'GB777777771';
        CompanyInformation.Modify();

        IsInitialized := true;
    end;

    local procedure MockFileId(): Text
    begin
        exit('1234567890');
    end;

    local procedure MockDocumentId(): Text
    begin
        exit('01f00578-8650-17dc-8631-390b96a662c9');
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        //LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';

}
