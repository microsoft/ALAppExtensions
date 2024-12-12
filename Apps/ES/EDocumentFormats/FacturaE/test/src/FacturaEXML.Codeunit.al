// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.IO;
using System.Utilities;

codeunit 148001 "Factura-E XML"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        FacturaE: Codeunit "Factura-E";
        IsInitialized: Boolean;
        WrongValueForPathErr: Label 'Wrong value for path %1', Locked = true;

    [Test]
    procedure ExportInvoice_SellerNode()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export invoice with Seller data
        Initialize();

        // [GIVEN] Seller and buyer exist
        CompanyInformation.Get();
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Seller Data has been exported correctly
        VerifySeller(TempXMLBuffer, CompanyInformation);
    end;

    [Test]
    procedure ExportInvoice_BuyerNode()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export invoice with Buyer data
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Buyer Data has been exported correctly
        VerifyBuyer(TempXMLBuffer, Customer);
    end;

    [Test]
    procedure ExportInvoice_FileHeader()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export invoice with FileHeader data
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer with a line
        CreateSalesInvoiceWithExtraLines(SalesHeader, SalesLine, SalesInvoiceHeader, SalesInvoiceLine, Customer, 0);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] FileHeader Data has been exported correctly
        VerifyFileHeader(TempXMLBuffer, SalesInvoiceHeader);
    end;

    [Test]
    procedure ExportInvoice_InvoiceLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export invoice with Invoices lines data
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer with a line
        CreateSalesInvoiceWithExtraLines(SalesHeader, SalesLine, SalesInvoiceHeader, SalesInvoiceLine, Customer, 0);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Invoice Lines Node has been exported correctly
        VerifyInvoiceLine(TempXMLBuffer, SalesInvoiceLine);
    end;

    [Test]
    procedure ExportInvoice_InvoiceHeader()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export invoice with Invoice header data
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer with a line
        CreateSalesInvoiceWithExtraLines(SalesHeader, SalesLine, SalesInvoiceHeader, SalesInvoiceLine, Customer, 0);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Invoice Header Node has been exported correctly
        VerifyInvoiceHeader(TempXMLBuffer, SalesInvoiceHeader);
    end;

    [Test]
    procedure ExportInvoice_MultipleInvoiceLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        NumberOfLines: Integer;
    begin
        // [SCENARIO] Export invoice with alot of Invoice lines
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create invoice for customer with a lot of lines
        NumberOfLines := LibraryRandom.RandIntInRange(10, 20);
        CreateSalesInvoiceWithExtraLines(SalesHeader, SalesLine, SalesInvoiceHeader, SalesInvoiceLine, Customer, NumberOfLines);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Verify number of lines in the file
        VerifyNumberOfLines(TempXMLBuffer, NumberOfLines + 1);
    end;

    [Test]
    procedure ExportCreditMemo_Error()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
    begin
        // [SCENARIO] Export credit memo fails because reason code is not set
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create Credit memo for customer with a line
        CreateSalesCreditMemoWithExtraLines(SalesHeader, SalesLine, SalesCrMemoHeader, SalesCrMemoLine, Customer, 0);

        // [WHEN] Check invoice before export
        asserterror CheckCreditMemo(SalesCrMemoHeader);

        // [THEN] Check failed because reason code is not set
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure ExportCreditMemo_NoError()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
    begin
        // [SCENARIO] Export credit memo is successful when reason code is set
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create Credit memo for customer with a line
        LibrarySales.CreateSalesCreditMemoForCustomerNo(SalesHeader, Customer."No.");

        // [GIVEN] Set reason code in Credit Memo
        SalesHeader."Factura-E Reason Code" := SalesCrMemoHeader."Factura-E Reason Code"::"01";
        SalesHeader.Modify(true);

        // [GIVEN] Post Credit memo
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoLine."No.");

        // [WHEN] Check credit memo before export
        CheckCreditMemo(SalesCrMemoHeader);

        // [THEN] Check is successful
    end;

    [Test]
    procedure ExportCreditMemo_CorrectiveNode()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export credit memo and check Corrective node
        Initialize();

        // [GIVEN] Buyer with contact data exists
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);

        // [GIVEN] Create Credit memo for customer with a line
        LibrarySales.CreateSalesCreditMemoForCustomerNo(SalesHeader, Customer."No.");

        // [GIVEN] Set reason code in Credit Memo
        SalesHeader."Factura-E Reason Code" := SalesCrMemoHeader."Factura-E Reason Code"::"01";
        SalesHeader.Modify(true);

        // [GIVEN] Post Credit memo
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoLine."No.");

        // [WHEN] Export credit memo
        ExportCreditMemo(SalesCrMemoHeader, SalesCrMemoLine, TempXMLBuffer);

        // [THEN] Check Corrective node
        VerifyCorrectiveNode(TempXMLBuffer, SalesCrMemoHeader);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Factura-E XML");
        if not IsInitialized then begin
            LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Factura-E XML");
            IsInitialized := true;

            LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Factura-E XML");
        end;
    end;

    local procedure CreateSalesInvoiceWithExtraLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; Customer: Record "Customer"; ExtraLines: Integer)
    var
        i: Integer;
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        for i := 1 to ExtraLines do
            AddLineToSalesHeader(SalesHeader, SalesLine);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
    end;

    local procedure CreateSalesCreditMemoWithExtraLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; Customer: Record "Customer"; ExtraLines: Integer)
    var
        i: Integer;
    begin
        LibrarySales.CreateSalesCreditMemoForCustomerNo(SalesHeader, Customer."No.");
        for i := 1 to ExtraLines do
            AddLineToSalesHeader(SalesHeader, SalesLine);
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoLine."No.");
    end;

    local procedure AddLineToSalesHeader(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        GLAccountNo: Code[20];
    begin
        GLAccountNo := LibraryERM.CreateGLAccountWithSalesSetup();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccountNo, LibraryRandom.RandInt(10));
        SalesLine.Validate("Unit Price", -LibraryRandom.RandDec(100, 2));
        SalesLine.Modify();
    end;

    local procedure VerifySeller(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information")
    var
        SellerPrefixTok: Label '/namespace:Facturae/Parties/SellerParty', Locked = true;
        Path: Text;
    begin
        // VAT Reg No
        Path := SellerPrefixTok + '/TaxIdentification/TaxIdentificationNumber';
        Assert.AreEqual(CompanyInformation."VAT Registration No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Seller Name
        Path := SellerPrefixTok + '/LegalEntity/CorporateName';
        Assert.AreEqual(CompanyInformation.Name, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Contact info
        Path := SellerPrefixTok + '/LegalEntity/ContactDetails/Telephone';
        Assert.AreEqual(CopyStr(CompanyInformation."Phone No.", 1, 15), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyBuyer(var TempXMLBuffer: Record "XML Buffer" temporary; Customer: Record "Customer")
    var
        BuyerPrefixTok: Label '/namespace:Facturae/Parties/BuyerParty', Locked = true;
        Path: Text;
    begin
        // VAT Reg No
        Path := BuyerPrefixTok + '/TaxIdentification/TaxIdentificationNumber';
        Assert.AreEqual(Customer."VAT Registration No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Seller Name
        Path := BuyerPrefixTok + '/LegalEntity/CorporateName';
        Assert.AreEqual(Customer.Name, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Contact info
        Path := BuyerPrefixTok + '/LegalEntity/ContactDetails/Telephone';
        Assert.AreEqual(CopyStr(Customer."Phone No.", 1, 15), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyFileHeader(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        FileHeaderTok: Label '/namespace:Facturae/FileHeader', Locked = true;
        Amount: Decimal;
        Path: Text;
    begin
        // Modality
        Path := FileHeaderTok + '/Modality';
        Assert.AreEqual('I', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Schema version
        Path := FileHeaderTok + '/SchemaVersion';
        Assert.AreEqual('3.2.2', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Invoice total
        Path := FileHeaderTok + '/Batch/TotalInvoicesAmount/TotalAmount';
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount Including VAT", Amount, StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyInvoiceLine(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceLine: Record "Sales Invoice Line")
    var
        LineTok: Label '/namespace:Facturae/Invoices/Invoice/Items/InvoiceLine', Locked = true;
        Amount: Decimal;
        Path: Text;
    begin
        // Description
        Path := LineTok + '/ItemDescription';
        Assert.AreEqual(SalesInvoiceLine.Description, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Quantity
        Path := LineTok + '/Quantity';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine.Quantity, Amount, StrSubstNo(WrongValueForPathErr, Path));
        // Unit Price
        Path := LineTok + '/UnitPriceWithoutTax';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine."Unit Price", Amount, StrSubstNo(WrongValueForPathErr, Path));
        // Tax
        Path := LineTok + '/TaxesOutputs/Tax/TaxAmount/TotalAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount, Amount, StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyInvoiceHeader(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        InvoiceHeaderTok: Label '/namespace:Facturae/Invoices/Invoice', Locked = true;
        Amount: Decimal;
        Path: Text;
    begin
        // Invoice number
        Path := InvoiceHeaderTok + '/InvoiceHeader/InvoiceNumber';
        Assert.AreEqual(SalesInvoiceHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Invoice date
        Path := InvoiceHeaderTok + '/InvoiceIssueData/IssueDate';
        Assert.AreEqual(Format(SalesInvoiceHeader."Posting Date", 0, 9), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
        // Tax
        Path := InvoiceHeaderTok + '/TaxesOutputs/Tax/TaxAmount/TotalAmount';
        SalesInvoiceHeader.CalcFields("Amount Including VAT", Amount);
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader."Amount", Amount, StrSubstNo(WrongValueForPathErr, Path));
        // Executable amount
        Path := InvoiceHeaderTok + '/InvoiceTotals/TotalExecutableAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount Including VAT", Amount, StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyNumberOfLines(var TempXMLBuffer: Record "XML Buffer" temporary; NumberOfLines: Integer)
    var
        InvoiceLineTok: Label '/namespace:Facturae/Invoices/Invoice/Items/InvoiceLine', Locked = true;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, InvoiceLineTok);
        Assert.AreEqual(NumberOfLines, TempXMLBuffer.Count, 'Wrong number of invoice lines');
    end;

    local procedure VerifyCorrectiveNode(var TempXMLBuffer: Record "XML Buffer" temporary; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CorrectiveTok: Label '/namespace:Facturae/Invoices/Invoice/InvoiceHeader/Corrective', Locked = true;
        Path, Reason : Text;
    begin
        // Reason code
        Path := CorrectiveTok + '/ReasonCode';
        Reason := GetNodeByPathWithError(TempXMLBuffer, Path);
        Path := CorrectiveTok + '/ReasonDescription';
        Reason += ' ' + GetNodeByPathWithError(TempXMLBuffer, Path);
        Assert.AreEqual(Format(SalesCrMemoHeader."Factura-E Reason Code"::"01"), Reason, StrSubstNo(WrongValueForPathErr, Path));
        // Correction Method
        Path := CorrectiveTok + '/CorrectionMethod';
        Assert.AreEqual('02', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure ExportInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesInvoiceHeader);
        SourceDocumentLines.GetTable(SalesInvoiceLine);
        FacturaE.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlobToXMLBuffer(TempBlob, TempXMLBuffer);
    end;

    local procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesCrMemoHeader);
        SourceDocumentLines.GetTable(SalesCrMemoLine);
        FacturaE.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlobToXMLBuffer(TempBlob, TempXMLBuffer);
    end;

    local procedure CheckCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        EDocumentService: Record "E-Document Service";
        SourceDocumentHeader: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesCrMemoHeader);
        FacturaE.Check(SourceDocumentHeader, EDocumentService, Enum::"E-Document Processing Phase"::Create);
    end;

    local procedure TempBlobToXMLBuffer(var TempBlob: Codeunit "Temp Blob"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);
    end;

    local procedure GetNodeByPathWithError(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);

        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
        Error('Node not found: %1', XPath);
    end;
}