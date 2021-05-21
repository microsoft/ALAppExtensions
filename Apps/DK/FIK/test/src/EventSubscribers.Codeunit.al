// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148025 "FIK Event Subscribers"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Assert: codeunit Assert;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceRequestPageHandler')]
    procedure SetDocumentReferenceTxtOnPrintSalesInvoice();
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FIKManagement: Codeunit FIKManagement;
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesInvoiceHeader.GET(LibrarySales.PostSalesDocument(SalesHeader, TRUE, TRUE));
        REPORT.RUN(REPORT::"Sales - Invoice", TRUE, FALSE, SalesInvoiceHeader);

        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.AssertElementWithValueExists('DocumentReference', FIKManagement.GetFIK71String(SalesInvoiceHeader."No."));
    end;

    [Test]    
    procedure VerifyFIKImportFormat()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // [WHEN] Running company initialize
        // [THEN] FIK Import Format should be set correctly
        GeneralLedgerSetup.Get();
        Assert.AreEqual('FIK71', GeneralLedgerSetup."FIK Import Format",
            'The FIK Import Format should be set correctly during company initialize.');
    end;



    [RequestPageHandler]
    procedure SalesInvoiceRequestPageHandler(VAR SalesInvoice: TestRequestPage "Sales - Invoice");
    begin
        SalesInvoice.SAVEASXML(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}