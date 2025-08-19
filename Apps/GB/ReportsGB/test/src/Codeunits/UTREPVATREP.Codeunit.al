namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

codeunit 144017 "UT REP VATREP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Report] [VAT]
    end;

    var
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";

    [Test]
    [HandlerFunctions('SalesInvoiceGBRequestPageHandler')]
    procedure OnAfterGetRecSalesInvLineSalesInvoiceGB()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        // Purpose of the test is to validate Sales Invoice Line - OnAfterGetRecord Trigger of Report 10583 - "Sales - Invoice".
        // Setup.
        Initialize();
        CreateSalesInvoice(SalesInvoiceLine);
        LibraryVariableStorage.Enqueue(SalesInvoiceLine."Document No.");  // Enqueue value required for SalesInvoiceGBRequestPageHandler.
        Commit();  // Commit required as it is called explicitly from OnRun function of Codeunit 315 Sales Inv.-Printed.

        // Exercise And Verify.
        RunReportAndVerifyXMLData(
          REPORT::"Sales - Invoice", 'No_SalesInvcHeader', SalesInvoiceLine."Document No.", SalesInvoiceLine."Reverse Charge GB");
    end;

    [Test]
    [HandlerFunctions('SalesCreditMemoGBRequestPageHandler')]
    procedure OnAfterGetRecSalesCrMemoLineSalesCrMemoGB()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        // Purpose of the test is to validate Sales Cr. Memo Line - OnAfterGetRecord Trigger of Report 10582 - "Sales - Credit Memo".
        // Setup.
        Initialize();
        CreateSalesCrMemo(SalesCrMemoLine);
        LibraryVariableStorage.Enqueue(SalesCrMemoLine."Document No.");  // Enqueue value required for SalesCreditMemoGBRequestPageHandler.
        Commit();  // Commit required as it is called explicitly from OnRun function of Codeunit 316 Sales Cr. Memo-Printed.

        // Exercise And Verify.
        RunReportAndVerifyXMLData(
          REPORT::"Sales - Credit Memo", 'No_SalesCrMemoHeader', SalesCrMemoLine."Document No.", SalesCrMemoLine."Reverse Charge GB");
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreateSalesCrMemo(var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader."No." := LibraryUTUtility.GetNewCode();
        SalesCrMemoHeader."Sell-to Customer No." := CreateCustomer();
        SalesCrMemoHeader."Bill-to Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
        SalesCrMemoHeader.Insert();
        SalesCrMemoLine."Document No." := SalesCrMemoHeader."No.";
        SalesCrMemoLine.Amount := LibraryRandom.RandDecInRange(0, 10, 2);
        SalesCrMemoLine."Amount Including VAT" := LibraryRandom.RandDecInRange(10, 50, 2);
        SalesCrMemoLine."Reverse Charge GB" := SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount;
        SalesCrMemoLine.Insert();
    end;

    local procedure CreateSalesInvoice(var SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader."No." := LibraryUTUtility.GetNewCode();
        SalesInvoiceHeader."Sell-to Customer No." := CreateCustomer();
        SalesInvoiceHeader."Bill-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        SalesInvoiceHeader.Insert();
        SalesInvoiceLine."Document No." := SalesInvoiceHeader."No.";
        SalesInvoiceLine.Amount := LibraryRandom.RandDecInRange(0, 10, 2);
        SalesInvoiceLine."Amount Including VAT" := LibraryRandom.RandDecInRange(10, 50, 2);
        SalesInvoiceLine."Reverse Charge GB" := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount;
        SalesInvoiceLine.Insert();
    end;

    local procedure RunReportAndVerifyXMLData(ReportID: Option; SalesDocumentCap: Text[30]; DocumentNo: Code[20]; ReverseCharge: Decimal)
    begin
        // Exercise.
        REPORT.Run(ReportID);  // Open SalesInvoiceGBReqPageHandler, SalesCreditMemoGBRequestPageHandler.

        // Verify: Verify No, Reverse Charge on Report.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(SalesDocumentCap, DocumentNo);
        LibraryReportDataset.AssertElementWithValueExists('TotalReverseCharge', ReverseCharge);
        // BUG 279809
        LibraryReportDataset.AssertElementWithValueExists('TotalReverseChargeVATCaption', 'Total Reverse Charge VAT');
    end;

    [RequestPageHandler]
    procedure SalesCreditMemoGBRequestPageHandler(var SalesCreditMemo: TestRequestPage "Sales - Credit Memo")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SalesCreditMemo."Sales Cr.Memo Header".SetFilter("No.", No);
        SalesCreditMemo.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure SalesInvoiceGBRequestPageHandler(var SalesInvoice: TestRequestPage "Sales - Invoice")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SalesInvoice."Sales Invoice Header".SetFilter("No.", No);
        SalesInvoice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}