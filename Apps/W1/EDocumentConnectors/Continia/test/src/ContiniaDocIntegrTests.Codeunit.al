namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;
using System.TestLibraries.Environment;
using Microsoft.Purchases.Document;
using System.Threading;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.Currency;
codeunit 148203 "Continia Doc. Integr. Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestHttpRequestPolicy = AllowOutboundFromHandler;
    Access = Internal;

    /// <summary>
    /// SubmitDocument - Tests successful document submission.
    /// This test verifies that a document is created, assigned a valid Document ID, and transitions through
    /// the expected statuses ("In Progress" -> "Processed") as the Continia API processes it. Additionally,
    /// it validates that the e-Document logs contain the correct status entries.
    /// </summary>

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure SubmitDocument()
    var
        EDocument: Record "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent 
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();

        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocumentCdnServiceDown - Tests error handling when the Continia service is down.
    /// This test ensures that when the Continia API returns a 500 error, the document moves to an "Error" 
    /// status. It verifies that the Document ID is not set and that the error is logged correctly.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure SubmitDocumentCdnServiceDown()
    var
        EDocument: Record "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        Initialize();

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            500,
            GetMockResponseContent('Common500.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] E-Document is in Error
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error state when service is down.');
        // [Then] Document Id has not been set
        Assert.IsTrue(IsNullGuid(EDocument."Continia Document Id"), 'Document Id on E-Document should not be set.');

        // [Then] eDocument Service Status has "Sending Error" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Error, Enum::"E-Document Service Status"::"Sending Error", EDocLogList, 'Error', 'The Continia Delivery Network API returned the following system error: Error Code Internal Server - Unhandled system error');
    end;

    /// <summary>
    /// SubmitDocument_ResponseServerDown_Sent - Tests response retrieval during server down scenario.
    /// This test simulates a scenario where the Continia API is temporarily down while retrieving responses.
    /// It verifies that the document status remains "In Progress" and is successfully updated to "Sent" once
    /// the service is back online.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure SubmitDocument_ResponseServerDown_Sent()
    var
        EDocument: Record "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Pending response -> Pending Response (ResponseServerDown) -> Sent 
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');

        // [Then]  E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Service is down
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            500,
            GetMockResponseContent('Common500.txt'));
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then]  E-Document is "In Progress"
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Service is up again
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then]  E-Document is Processed
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_Pending_Sent - Tests handling of pending responses before successful document sending.
    /// This test checks that the document moves to "In Progress" and remains in this status until the API 
    /// confirms it is processed, transitioning it to "Sent."
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure SubmitDocument_Pending_Sent()
    var
        EDocument: Record "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Pending response -> Sent 
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');

        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Executing Get Response successfully (pending)
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Pending.txt'));
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is "In Progress"
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Executing Get Response successfully (Success)
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is Processed
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_Error_Sent - Tests handling of submission errors, like unregistered recipients.
    /// This test ensures that when the API response indicates an error (e.g., recipient not registered), the 
    /// document moves to "Error" status, and the error is properly logged. It also verifies successful resubmission 
    /// after the issue is resolved.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_Error_Sent()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Error -> Pending response -> Sent 
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');

        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Executing Get Response successfully (error)
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Error.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is Error
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has "Sending Error" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Error, Enum::"E-Document Service Status"::"Sending Error", EDocLogList, 'Error', 'ReceiverNotRegistered - The recipient of the document is not registered to receive this type of document.');

        // Then user manually send 
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        EDocument.FindLast();

        // [THEN] Open E-Document page and resend
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Send_Promoted.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [When] Executing Get Response successfully (Success)
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is Processed
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, 'Continia integration failed to set Document Status on E-Document');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_NoApproval - Tests handling when no approval is returned for document processing.
    /// This test ensures that if no approval is returned, the document remains in the "Sent" state 
    /// without transitioning to "Approved" or other statuses. It validates that the document stays 
    /// in "Sent" when approval is not received.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_NoApproval()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent -> Sent (No Approval)
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');


        // [Then] Open E-Document page and Get Approval
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.BusinessResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('BusinessResponse200-noresponse.txt'));
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_StatusInfo - Tests handling of responses without approval.
    /// This test ensures that if responses are received without any approval indication, 
    /// the document is treated as though no approval has been received and remains in the "Sent" state. 
    /// It validates that the system does not move the document to an "Approved" status 
    /// without an explicit approval response.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_StatusInfo()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent -> Sent (StatusInfo)
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');


        // [Then] Open E-Document page and Get Approval
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.BusinessResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('BusinessResponse200-multiple-statusinfo.txt'));
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_Approved - Tests document status update upon approval.
    /// This test ensures that when an approved response is received, the document status is updated 
    /// from "Sent" to "Approved," validating proper handling and logging of approvals.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_Approved()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent -> Approved
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');

        // [Then] Open E-Document page and Get Approval
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.BusinessResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('BusinessResponse200-multiple-accepted.txt'));
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Approved and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        EDocLogList.Add(Enum::"E-Document Service Status"::Approved);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Approved, EDocLogList, '', '');
    end;

    /// <summary>
    /// SubmitDocument_Rejected - Tests error handling for rejected documents with rejection reasons.
    /// This test validates that when the document is rejected by the API, it moves to an "Error" status 
    /// with the rejection reason logged, ensuring accurate status updates for failed submissions.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_Rejected()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent -> Error (Rejected)
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');


        // [Then] Open E-Document page and Get Approval
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.BusinessResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('BusinessResponse200-multiple-rejected.txt'));
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status is Processed and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        EDocLogList.Add(Enum::"E-Document Service Status"::Rejected);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Rejected, EDocLogList, 'Warning', 'Reason: PRI - Prices incorrect');
    end;

    /// <summary>
    /// SubmitDocument_GetApprovalServiceDown - Tests handling of approval retrieval when the service is down.
    /// This test simulates a scenario where the approval API is temporarily down, verifying that the document 
    /// can be processed as "Sent" and retries approval retrieval once the service is available.
    /// </summary>
    [Test]
    [HandlerFunctions('EDocServicesPageHandler,HttpClientHandler')]
    procedure SubmitDocument_GetApprovalServiceDown()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        // Steps:
        // Pending response -> Sent -> Sent (Service Down)
        Initialize();

        // [Given] Team Member
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            StrSubstNo(DocumentUriPatternTok, ContiniaApiUrlMgt.CdnBaseUrl()),
            200,
            GetMockResponseContent('SubmitDocument200.txt'));
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running Continia SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(MockDocumentId(), EDocument."Continia Document Id", 'Continia integration failed to set Document Id on E-Document');
        // [Then] E-Document is "In Progress"
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [Then] eDocument Service Status has "Pending Response" and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::"In Progress", Enum::"E-Document Service Status"::"Pending Response", EDocLogList, '', '');

        // [WHEN] Executing Get Response successfully
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.TechnicalResponseUrl(MockDocumentId()),
            200,
            GetMockResponseContent('TechnicalResponse200-Success.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl(MockDocumentId()),
            200);
        RunGetResponseJob();

        // [When] EDocument is fetched after running Continia GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');


        // [Then] Open E-Document page and Get Approval
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.BusinessResponseUrl(MockDocumentId()),
            500,
            GetMockResponseContent('Common500.txt'));
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();
        // EDocServicesPageHandler
        EDocumentPage.Close();

        // [When] EDocument is fetched after running Continia Send Document 
        EDocument.FindLast();

        // [Then] E-Document is considered Processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [Then] eDocument Service Status has Sent and has correct logs
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::Exported);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        TestEDocumentPage(EDocument, Enum::"E-Document Status"::Processed, Enum::"E-Document Service Status"::Sent, EDocLogList, '', '');
    end;

    /// <summary>
    /// ReceiveDocuments_SingleDocument - Tests receiving a single document and creating a Purchase Invoice.
    /// This test verifies that a single document is correctly received from the API and that a Purchase 
    /// Invoice is created, linking the document to the correct vendor.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure ReceiveDocuments_SingleDocument()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
        ReceiveDocumentsUri: Text;
    begin
        Initialize();
        // [Given] Empty E-Document table
        EDocument.DeleteAll();

        // [Given] Auto import job. Open and close E-Doc page creates auto import job due to setting
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);
        EDocServicePage."Resolve Unit Of Measure".SetValue(true);
        EDocServicePage."Lookup Item Reference".SetValue(true);
        EDocServicePage."Lookup Item GTIN".SetValue(false);
        EDocServicePage."Lookup Account Mapping".SetValue(false);
        EDocServicePage."Validate Line Discount".SetValue(false);
        EDocServicePage.Close();

        // [When] Manually fire job queue job to import Documents
        ContiniaMockHttpHandler.ClearHandler();
        ReceiveDocumentsUri :=
            StrSubstNo(
                ParticipationProfileDocumentsUriPatternTok,
                ContiniaApiUrlMgt.CdnBaseUrl(),
                Enum::"Continia E-Delivery Network"::Peppol,
                ConnectorLibrary.ParticipationId(),
                ConnectorLibrary.ActiveNetworkProfileId());
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ReceiveDocumentsUri,
            200,
            GetMockResponseContent('ReceiveDocuments.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            StrSubstNo(DownloadUriPatternTok, ReceiveDocumentsUri),
            200,
            GetMockResponseContent('ReceivePeppolInvoiceDocument200.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl('65DD7456-7A49-4382-9F76-1211FA8AD0BF'),
            200);

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

    /// <summary>
    /// ReceiveDocuments_Peppol_MultipleEdocServices - Tests handling documents from multiple network profiles.
    /// This test ensures that only documents associated with the specified network profiles are imported.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure ReceiveDocuments_Peppol_MultipleEdocServices()
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocument: Record "E-Document";
        Participation: Record "Continia Participation";
        EDocServicePage: TestPage "E-Document Service";
        ReceiveDocumentsUri, ActivatedNetProfIdText : Text;
    begin
        // Receive documents from multiple network profiles
        Initialize();
        ConnectorLibrary.CleanParticipations();
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ConnectorLibrary.AddActivatedNetworkProfile(Participation, ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(), CreateGuid(), ActivatedNetProf, EDocumentService.Code);
        // [Given] Empty E-Document table
        EDocument.DeleteAll();

        // [Given] Auto import job. Open and close E-Doc page creates auto import job due to setting
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);
        EDocServicePage."Resolve Unit Of Measure".SetValue(true);
        EDocServicePage."Lookup Item Reference".SetValue(true);
        EDocServicePage."Lookup Item GTIN".SetValue(false);
        EDocServicePage."Lookup Account Mapping".SetValue(false);
        EDocServicePage."Validate Line Discount".SetValue(false);
        EDocServicePage.Close();

        // [When] Manually fire job queue job to import Documents
        ContiniaMockHttpHandler.ClearHandler();
        ReceiveDocumentsUri :=
            StrSubstNo(
                ParticipationProfileDocumentsUriPatternTok,
                ContiniaApiUrlMgt.CdnBaseUrl(),
                Enum::"Continia E-Delivery Network"::Peppol,
                ConnectorLibrary.ParticipationId(),
                ConnectorLibrary.ActiveNetworkProfileId());
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ReceiveDocumentsUri,
            200,
            GetMockResponseContent('ReceiveDocuments.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            StrSubstNo(DownloadUriPatternTok, ReceiveDocumentsUri),
            200,
            GetMockResponseContent('ReceivePeppolInvoiceDocument200.txt'));
        ActivatedNetProfIdText := ActivatedNetProf.Id;
        ActivatedNetProfIdText := ActivatedNetProfIdText.TrimStart('{');
        ActivatedNetProfIdText := ActivatedNetProfIdText.TrimEnd('}');
        ReceiveDocumentsUri :=
            StrSubstNo(
                ParticipationProfileDocumentsUriPatternTok,
                ContiniaApiUrlMgt.CdnBaseUrl(),
                Enum::"Continia E-Delivery Network"::Peppol,
                ConnectorLibrary.ParticipationId(),
                ActivatedNetProfIdText);
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ReceiveDocumentsUri,
            200,
            GetMockResponseContent('ReceiveDocuments.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            StrSubstNo(DownloadUriPatternTok, ReceiveDocumentsUri),
            200,
            GetMockResponseContent('ReceivePeppolInvoiceDocument200.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.DocumentActionUrl('65DD7456-7A49-4382-9F76-1211FA8AD0BF'),
            200);
        LibraryEDocument.RunImportJob();

        // Assert that we have only 2 documents imported
        EDocument.FindLast();
        Assert.AreEqual(2, EDocument.Count, 'Wrong number of documents imported');
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
        ContiniaConnectionSetup: Record "Continia Connection Setup";
        PurchaseHeader: Record "Purchase Header";
        Currency: Record Currency;
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        LibraryPermission.SetOutsideO365Scope();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        ContiniaConnectionSetup.DeleteAll();
        ContiniaConnectionSetup.Init();
        ContiniaConnectionSetup.Insert(true);

        PurchaseHeader.DeleteAll();

        if IsInitialized then
            exit;
        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Continia);

        LibraryEDocument.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Continia);
        CreateTestItem();

        EDocumentService.Validate("Auto Import", true);
        EDocumentService."Import Minutes between runs" := 10;
        EDocumentService."Import Start Time" := Time();
        EDocumentService.Modify();

        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'GB777777771';
        CompanyInformation.Modify();

        Vendor."VAT Registration No." := 'GB777777772';
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        Vendor.Modify();

        // Use date and currency exchange rate in document that is loaded
        Currency.Init();
        Currency.Validate(Code, 'XYZ');
        if Currency.Insert(true) then
            LibraryERM.CreateExchangeRate('XYZ', DMY2Date(8, 4, 2024), 1, 1);

        ConnectorLibrary.PrepareParticipation(EDocumentService);

        IsInitialized := true;
    end;

    local procedure CreateTestItem()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        UnitofMeasure: Record "Unit of Measure";
        VATPostingSetup: Record "VAT Posting Setup";
        ItemNoTok: Label 'Item1', Locked = true;
    begin
        // Create a test item
        if Item.Get(ItemNoTok) then
            Item.Delete();
        LibraryEDocument.CreateGenericItem(Item);
        Item.Rename(ItemNoTok);
        Item.Description := 'LONDON Swivel Chair, blue';
#pragma warning disable AA0210
        UnitofMeasure.SetRange("International Standard Code", TestItemIsoUomTok);
#pragma warning restore AA0210
        UnitofMeasure.FindFirst();
        Item.Validate("Base Unit of Measure", UnitofMeasure.Code);
        Item.Modify(true);
        LibraryItemReference.CreateItemReferenceWithNo(ItemReference, ItemNoTok, Item."No.", Enum::"Item Reference Type"::Vendor, Vendor."No.");
        if not VATPostingSetup.GET(Vendor."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then begin
            VATPostingSetup.Init();
            VATPostingSetup."VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
            VATPostingSetup."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
            VATPostingSetup."VAT %" := 20;
            VATPostingSetup."Tax Category" := 'S';
            VATPostingSetup.Insert();
        end;
    end;

    local procedure TestEDocumentPage(EDocument: Record "E-Document"; EDocumentStatus: Enum "E-Document Status"; EDocServiceStatus: Enum "E-Document Service Status"; EDocLogList: List of [Enum "E-Document Service Status"]; ErrorMessageType: Text; ErrorMessage: Text)
    var
        EDocumentPage: TestPage "E-Document";
    begin
        // [Then] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocumentStatus), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [Then] E-Document Service Status is correct
        Assert.AreEqual(EDocumentService.Code, EDocumentPage."Outbound E-Doc. Factbox"."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocServiceStatus), EDocumentPage."Outbound E-Doc. Factbox".Status.Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocLogList.Count), EDocumentPage."Outbound E-Doc. Factbox".Log.Value(), IncorrectValueErr);

        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        if (ErrorMessageType = '') and (ErrorMessage = '') then
            // [Then] E-Document Has no Errors or Warnings
            Assert.AreEqual(0, GetEDocumentErrorOrWarningsCount(EDocument), IncorrectValueErr)
        else begin
            // [Then] E-Document Errors and Warnings has correct status
            Assert.AreEqual(ErrorMessageType, EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
            Assert.AreEqual(ErrorMessage, EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        end;
        EDocumentPage.Close();
    end;

    local procedure GetEDocumentErrorOrWarningsCount(EDocument: Record "E-Document"): Integer
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
    begin
        exit(EDocumentErrorHelper.ErrorMessageCount(EDocument) + EDocumentErrorHelper.WarningMessageCount(EDocument))
    end;

    local procedure RunGetResponseJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        Codeunit.Run(Codeunit::"Job Queue Dispatcher", JobQueueEntry);
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);
    end;

    local procedure MockDocumentId() DocumentId: Guid
    begin
        Evaluate(DocumentId, '{3fa85f64-5717-4562-b3fc-2c963f66afa6}');
    end;

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocServicesPage: TestPage "E-Document Services")
    begin
        EDocServicesPage.Filter.SetFilter(Code, EDocumentService.Code);
        EDocServicesPage.OK().Invoke();
    end;

    local procedure GetMockResponseContent(ResourceFileName: Text): Text
    begin
        exit(NavApp.GetResourceAsText(ResourceFileName, TextEncoding::UTF8));
    end;

    [HttpClientHandler]
    internal procedure HttpClientHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        if ContiniaMockHttpHandler.HandleAuthorization(Request, Response) then
            exit;

        Response := ContiniaMockHttpHandler.GetResponse(Request);
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryItemReference: Codeunit "Library - Item Reference";
        ConnectorLibrary: Codeunit "Continia Connector Library";
        ContiniaMockHttpHandler: Codeunit "Continia Mock Http Handler";
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        TestItemIsoUomTok: Label 'EA', Locked = true;
        DocumentUriPatternTok: Label '%1/documents.xml', Comment = '%1 - Base URL', Locked = true;
        ParticipationProfileDocumentsUriPatternTok: Label '%1/networks/%2/participations/%3/profiles/%4/documents.xml', Comment = '%1 - Base URL, %2- Participation Id, %3 - Profile Id', Locked = true;
        DownloadUriPatternTok: Label '%1/download/peppol', Comment = '%1 - Receive documents URI', Locked = true;
}
