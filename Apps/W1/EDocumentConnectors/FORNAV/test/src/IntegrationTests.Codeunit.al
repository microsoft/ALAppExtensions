// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Document;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.Threading;
using Microsoft.Sales.History;
using Microsoft.eServices.EDocument.Integration;

codeunit 6246280 "Integration Tests"
{
    Subtype = Test;
    Permissions = tabledata "E-Document" = r;

    [Test]
    procedure SubmitDocument()
    var
        EDocument: Record "E-Document";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
        Header: Record "Sales Invoice Header";
    begin
        // Steps:
        // Pending response -> Sent 
        Initialize();

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        Header := LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ForNAV SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response.
        Assert.AreEqual(Test.MockServiceDocumentId(), EDocument."ForNAV ID", 'ForNAV integration failed to set Document Id on E-Document');
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has "Pending Response"
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        Test.CreateEvidence(EDocument, true);
        Codeunit.Run(Codeunit::"E-Document Get Response");
        // JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        // LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ForNAV GetResponse 
        SelectLatestVersion();
        EDocument.FindLast();

        // [Then] E-Document is considered processed
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has Sent
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sent");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
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
        Test.SetStatusCode(200);

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ForNAV SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(Test.MockServiceDocumentId(), EDocument."ForNAV ID", 'ForNAV integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);
        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();


        // [WHEN] Executing Get Response succesfully
        Codeunit.Run(Codeunit::"E-Document Get Response");
        // JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        // LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ForNAV GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        Test.CreateEvidence(EDocument, true);
        Codeunit.Run(Codeunit::"E-Document Get Response");
        // JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        // LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ForNAV GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('4', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
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
        Test.SetStatusCode(200);

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ForNAV SubmitDocument 
        EDocument.FindLast();

        // [Then] Document Id has been correctly set on E-Document, parsed from Integration response
        Assert.AreEqual(Test.MockServiceDocumentId(), EDocument."ForNAV ID", 'ForNAV integration failed to set Document Id on E-Document');

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Executing Get Response succesfully
        test.CreateEvidence(EDocument, false);
        Codeunit.Run(Codeunit::"E-Document Get Response");
        // JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        // LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ForNAV GetResponse 
        EDocument.FindLast();

        // [Then] E-Document is in error state
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has sending error
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        EDocumentPage.ErrorMessagesPart.First();
        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('Rejected', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocumentPage.Close();

        // Then user manually send 
        Test.CreateEvidence(EDocument, true);
        EDocument.FindLast();

        // [THEN] Open E-Document page and resend
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.Send_Promoted.Invoke();
        EDocumentPage.Close();

        EDocument.FindLast();
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::"In Progress", EDocument.Status, 'E-Document should be set to in progress');

        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Response"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('4', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();

        Codeunit.Run(Codeunit::"E-Document Get Response");
        // JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        // LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [When] EDocument is fetched after running ForNAV GetResponse 

        EDocument.FindLast();

        // [Then] E-Document is pending response as ForNAV is async
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocument.Status, 'E-Document should be set to processed');

        // [THEN] Open E-Document page
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has pending response
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('5', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Pending Response");
        EDocLogList.Add(Enum::"E-Document Service Status"::Sent);
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
        EDocumentPage.Close();
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure SubmitDocumentForNAVServiceDown()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        EDocLogList: List of [Enum "E-Document Service Status"];
    begin
        Initialize();
        Test.SetStatusCode(500);

        // [Given] Team member 
        LibraryPermission.SetTeamMember();

        // [When] Posting invoice and EDocument is created
        LibraryEDocument.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryEDocument.RunEDocumentJobQueue(EDocument);

        // [When] EDocument is fetched after running ForNAV SubmitDocument 
        EDocument.FindLast();

        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocument.Status, 'E-Document should be set to error state when service is down.');
        Assert.AreEqual('', EDocument."ForNAV ID", 'Document Id on E-Document should not be set.');

        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        Clear(EDocLogList);
        EDocLogList.Add(Enum::"E-Document Service Status"::"Exported");
        EDocLogList.Add(Enum::"E-Document Service Status"::"Sending Error");
        LibraryEDocument.AssertEDocumentLogs(EDocument, EDocumentService, EDocLogList);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        //        Assert.AreEqual('Error Code: 500, Error Message: The HTTP request is not successful. An internal server error occurred.', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure SubmitGetDocuments()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocServicePage: TestPage "E-Document Service";
    begin
        Initialize();
        Test.SetStatusCode(200);
        Test.SetVendorNo(Vendor."No.");

        // Open and close E-Doc page creates auto import job due to setting
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);
        EDocServicePage."Resolve Unit Of Measure".SetValue(false);
        EDocServicePage."Lookup Item Reference".SetValue(true);
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
        //        EDocument.SetRange("Bill-to/Pay-to No.", Vendor."No.");
#pragma warning restore AA0210
        EDocument.FindLast();
        PurchaseHeader.Get(EDocument."Document Record ID");
        Assert.AreEqual(Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Wrong Vendor');
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
        KeyGuid: Guid;
    begin
        Test.CreateMockServiceDocumentId();
        LibraryPermission.SetOutsideO365Scope();

        if IsInitialized then
            exit;
        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", "Service Integration"::ForNAV);
        EDocumentService.Get('FORNAV');
        Customer."Document Sending Profile" := 'FORNAV';

        LibraryEDocument.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", "Service Integration"::ForNAV);
        EDocumentService."Auto Import" := true;
        EDocumentService."Import Minutes between runs" := 10;
        EDocumentService."Import Start Time" := Time();
        EDocumentService.Modify();

        Vendor."VAT Registration No." := 'GB' + Vendor."No.";
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        Vendor."Document Sending Profile" := 'FORNAV';
        Vendor.Modify();

        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := 'GB777777771';
        CompanyInformation.Modify();

        Test.Init();
        Test.SetStatusCode(200);

        IsInitialized := true;
    end;

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocServicesPage: TestPage "E-Document Services")
    begin
        EDocServicesPage.Filter.SetFilter(Code, EDocumentService.Code);
        EDocServicesPage.OK().Invoke();
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        Test: Codeunit "ForNAV Peppol Test";
}
