// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;
using System.IO;
using Microsoft.Foundation.UOM;
using Microsoft.Foundation.Address;
using Microsoft.eServices.EDocument;
using Microsoft.Sales.Document;
using Microsoft.Finance.Currency;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.PaymentTerms;
codeunit 13918 "XRechnung XML Document Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [XRechnung E-document]
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EDocumentService: Record "E-Document Service";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryEdocument: Codeunit "Library - E-Document";
        Assert: Codeunit Assert;
        ExportXRechnungFormat: Codeunit "XRechnung Format";
        IncorrectValueErr: Label 'Incorrect value for %1', Locked = true;
        IsInitialized: Boolean;

    #region SalesInvoice
    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyHeaderData();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with header data from the document
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created
        VerifyHeaderData(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post Sales Invoice with Customer X, E-invoice routing no. = XY
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XY
        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/ubl:Invoice');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyBuyerReferenceAsYourReference();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post Sales Invoice with your reference = XX
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XX
        VerifyBuyerReference(SalesInvoiceHeader."Your Reference", TempXMLBuffer, '/ubl:Invoice');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyAccountingSupplierParty();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with company data as accounting supplier party
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ubl:Invoice/cac:AccountingSupplierParty/cac:Party');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyAccountingCustomerParty();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with customer data as accounting customer party
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with customer data as accounting customer party
        VerifyAccountingCustomerParty(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyPaymentMeans();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with bank informarion as payment means
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with bank informarion as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/ubl:Invoice/cac:PaymentMeans');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyPaymentTerms();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with payment terms
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with payment terms
        VerifyPaymentTerms(SalesInvoiceHeader."Payment Terms Code", TempXMLBuffer, '/ubl:Invoice/cac:PaymentTerms');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyTaxTotal();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with different tax totals
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with different tax totals
        VerifyTaxTotals(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyLegalMonetaryTotal();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with document totals
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyInvoiceLine();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales invoice creates electronic document in XRechnung format with 2 invoice lines
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 invoice lines
        VerifyInvoiceLine(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyInvoiceLineWithLineDiscount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in XRechnung format with 2 invoice lines, one line has line discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with line discount
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 invoice lines and one line has line discount
        VerifyInvoiceLineWithDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyInvoiceWithInvoiceDiscounts();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in XRechnung format with 2 invoice lines and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 invoice lines and invoice discount
        VerifyInvoiceWithInvDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyInvoiceWithInvoiceDiscountsAndLineDiscount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in XRechnung format with 2 invoice lines with discount and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount and line discount on one line
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 invoice lines with line discount and invoice discount
        VerifyInvoiceWithInvDiscount(SalesInvoiceHeader, TempXMLBuffer);
        VerifyInvoiceLineWithDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;
    #endregion

    #region SalesCreditMemo
    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyHeaderData();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with header data from the document
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created
        VerifyHeaderData(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post sales cr. memo with Customer X, E-invoice routing no. = XY
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XY
        Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/ns0:CreditNote');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyBuyerReferenceAsYourReference();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post sales cr. memo with your reference = XX
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XX
        VerifyBuyerReference(SalesCrMemoHeader."Your Reference", TempXMLBuffer, '/ns0:CreditNote');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyAccountingSupplierParty();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with company data as accounting supplier party
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ns0:CreditNote/cac:AccountingSupplierParty/cac:Party');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyAccountingCustomerParty();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with customer data as accounting customer party
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with customer data as accounting customer party
        VerifyAccountingCustomerParty(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyPaymentMeans();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with bank informarion as payment means
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with bank informarion as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/ns0:CreditNote/cac:PaymentMeans');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyPaymentTerms();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with payment terms
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with payment terms
        VerifyPaymentTerms(SalesCrMemoHeader."Payment Terms Code", TempXMLBuffer, '/ns0:CreditNote/cac:PaymentTerms');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyTaxTotal();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with different tax totals
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with different tax totals
        VerifyTaxTotals(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyLegalMonetaryTotal();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with document totals
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyCrMemoLine();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 496414] Export posted sales cr. memo creates electronic document in XRechnung format with 2 cr.memo lines
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 cr.memo lines
        VerifyCrMemoLine(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyCrMemoWithInvoiceDiscounts();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales cr. memo creates electronic document in XRechnung format with 2 lines and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 lines and invoice discount
        VerifyCrMemoWithInvDiscount(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyCrMemoWithInvoiceDiscountsAndLineDiscount();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales cr.memo creates electronic document in XRechnung format with 2 cr.memo lines with discount and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Cr. Memo with invoice discount and line discount on one line
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 lines with line discount and invoice discount
        VerifyCrMemoWithInvDiscount(SalesCrMemoHeader, TempXMLBuffer);
        VerifyCrMemoLineWithDiscounts(SalesCrMemoHeader, TempXMLBuffer);
    end;
    #endregion
    local procedure CreateAndPostSalesDocument(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType, LineType, InvoiceDiscount));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesDocumentWithTwoLines(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithTwoLine(DocumentType, LineType, InvoiceDiscount));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesDocumentWithTwoLinesLineDiscount(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithTwoLineLineDiscount(DocumentType, LineType, InvoiceDiscount));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateSalesDocumentWithLine(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader, LineType);

        if InvoiceDiscount then
            ApplyInvoiceDiscount(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesDocumentWithTwoLine(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader, LineType);
        CreateSalesLine(SalesHeader, LineType);

        if InvoiceDiscount then
            ApplyInvoiceDiscount(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesDocumentWithTwoLineLineDiscount(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader, LineType);
        CreateSalesLineLineDiscount(SalesHeader, LineType);

        if InvoiceDiscount then
            ApplyInvoiceDiscount(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure ApplyInvoiceDiscount(SalesHeader: Record "Sales Header");
    var
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        LibrarySales.SetCalcInvDiscount(true);
        SalesHeader.CalcFields(Amount);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount / 2, SalesHeader);
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type");
    var
        PostCode: Record "Post Code";
        PaymentTermsCode: Code[10];
    begin
        LibraryERM.FindPostCode(PostCode);
        PaymentTermsCode := LibraryERM.FindPaymentTermsCode();
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CreateCustomer());
        SalesHeader.Validate("Sell-to Contact", SalesHeader."No.");
        SalesHeader.Validate("Bill-to Address", LibraryUtility.GenerateGUID());
        SalesHeader.Validate("Bill-to City", PostCode.City);
        SalesHeader.Validate("Ship-to Address", LibraryUtility.GenerateGUID());
        SalesHeader.Validate("Ship-to City", PostCode.City);
        SalesHeader.Validate("Sell-to Address", LibraryUtility.GenerateGUID());
        SalesHeader.Validate("Sell-to City", PostCode.City);
        SalesHeader.Validate("Your Reference", LibraryUtility.GenerateRandomText(20));
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Modify(true);
    end;

    local procedure CreateCustomer(): Code[20];
    var
        Customer: Record Customer;
    begin
        Customer.DeleteAll();
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.Validate("VAT Registration No.", CompanyInformation."VAT Registration No.");
        Customer.Validate("E-Invoice Routing No.", LibraryUtility.GenerateRandomText(20));
        Customer.Modify(true);
        exit(Customer."No.")
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; LineType: Enum "Sales Line Type");
    var
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        UnitOfMeasure."International Standard Code" := LibraryUtility.GenerateGUID();
        UnitOfMeasure.Modify(true);
        LibrarySales.CreateSalesLine(
        SalesLine, SalesHeader, LineType, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        SalesLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.Validate("Tax Category", 'S');
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLineLineDiscount(SalesHeader: Record "Sales Header"; LineType: Enum "Sales Line Type");
    var
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        UnitOfMeasure."International Standard Code" := LibraryUtility.GenerateGUID();
        UnitOfMeasure.Modify(true);
        LibrarySales.CreateSalesLine(
        SalesLine, SalesHeader, LineType, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        SalesLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.Validate("Tax Category", 'S');
        SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
        SalesLine.Modify(true);
    end;

    local procedure ExportInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FileInStream: InStream;
    begin
        SourceDocumentHeader.GetTable(SalesInvoiceHeader);
        SourceDocumentLines.GetTable(SalesInvoiceLine);
        ExportXRechnungFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlob.CreateInStream(FileInStream);
        TempXMLBuffer.LoadFromStream(FileInStream);
    end;

    local procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FileInStream: InStream;
    begin
        SourceDocumentHeader.GetTable(SalesCrMemoHeader);
        SourceDocumentLines.GetTable(SalesCrMemoLine);
        ExportXRechnungFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlob.CreateInStream(FileInStream);
        TempXMLBuffer.LoadFromStream(FileInStream);
    end;

    local procedure VerifyHeaderData(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/ubl:Invoice', Locked = true;
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:InvoiceTypeCode';
        Assert.AreEqual('380', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(SalesInvoiceHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:IssueDate';
        Assert.AreEqual(FormatDate(SalesInvoiceHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:DocumentCurrencyCode';
        Assert.AreEqual(GetCurrencyCode(SalesInvoiceHeader."Currency Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyHeaderData(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentCreditNoteTok: Label '/ns0:CreditNote', Locked = true;
        Path: Text;
    begin
        Path := DocumentCreditNoteTok + '/cbc:CreditNoteTypeCode';
        Assert.AreEqual('381', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentCreditNoteTok + '/cbc:ID';
        Assert.AreEqual(SalesCrMemoHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentCreditNoteTok + '/cbc:IssueDate';
        Assert.AreEqual(FormatDate(SalesCrMemoHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentCreditNoteTok + '/cbc:DocumentCurrencyCode';
        Assert.AreEqual(GetCurrencyCode(SalesCrMemoHeader."Currency Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyBuyerReference(BuyerReference: Text[50]; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:BuyerReference';
        Assert.AreEqual(BuyerReference, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingSupplierParty(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(CompanyInformation.Address, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(CompanyInformation.City, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:PostalAddress/cbc:PostalZone';
        Assert.AreEqual(CompanyInformation."Post Code", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));

        Path := DocumentTok + '/cac:PartyTaxScheme/cbc:CompanyID';
        Assert.AreEqual(GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingCustomerParty(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentPartyTok: Label '/ubl:Invoice/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
    begin
        Path := DocumentPartyTok + '/cbc:EndpointID';
        Assert.AreEqual(SalesInvoiceHeader."Sell-to E-Mail", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentPartyTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(SalesInvoiceHeader."Bill-to Address", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentPartyTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(SalesInvoiceHeader."Bill-to City", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingCustomerParty(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentAccountingCustomerPartyTok: Label '/ns0:CreditNote/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
    begin
        Path := DocumentAccountingCustomerPartyTok + '/cbc:EndpointID';
        Assert.AreEqual(SalesCrMemoHeader."Sell-to E-Mail", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentAccountingCustomerPartyTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(SalesCrMemoHeader."Bill-to Address", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentAccountingCustomerPartyTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(SalesCrMemoHeader."Bill-to City", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyPaymentMeans(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:PaymentMeansCode';
        Assert.AreEqual('68', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyPaymentTerms(PaymentTermsCode: Code[10]; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        PaymentTerms: Record "Payment Terms";
        Path: Text;
    begin
        PaymentTerms.Get(PaymentTermsCode);
        Path := DocumentTok + '/cbc:Note';
        Assert.AreEqual(PaymentTerms.Description, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTaxTotalTok: Label '/ubl:Invoice/cac:TaxTotal', Locked = true;
        Path: Text;
    begin
        Path := DocumentTaxTotalTok + '/cbc:TaxAmount';
        Assert.AreEqual(FormatDecimal(GetTotalTaxAmount(SalesInvoiceHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTaxTotalsTok: Label '/ns0:CreditNote/cac:TaxTotal', Locked = true;
        Path: Text;
    begin
        Path := DocumentTaxTotalsTok + '/cbc:TaxAmount';
        Assert.AreEqual(FormatDecimal(GetTotalTaxAmount(SalesCrMemoHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalTok: Label '/ubl:Invoice/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesInvoiceHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:PayableAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalsTok: Label '/ns0:CreditNote/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesCrMemoHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:PayableAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceLine(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/ubl:Invoice/cac:InvoiceLine', Locked = true;
        Path: Text;
        SecondLine: Boolean;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
        repeat
            Path := DocumentTok + '/cbc:ID';
            if SecondLine then
                Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:InvoicedQuantity';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:LineExtensionAmount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cbc:Name';
            if SecondLine then
                Assert.AreEqual(SalesInvoiceLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(SalesInvoiceLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
            if SecondLine then
                Assert.AreEqual(SalesInvoiceLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(SalesInvoiceLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
            if SecondLine then
                Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
            Assert.AreEqual(SalesInvoiceLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            SecondLine := true;
        until SalesInvoiceLine.Next() = 0;
    end;

    local procedure VerifyInvoiceLineWithDiscount(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/ubl:Invoice/cac:InvoiceLine/cac:AllowanceCharge', Locked = true;
        Path: Text;
        SecondLine: Boolean;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
        repeat
            Path := DocumentTok + '/cbc:AllowanceChargeReason';
            if SecondLine then
                Assert.AreEqual('LineDiscount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Line Discount %"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:Amount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:BaseAmount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Unit Price" * SalesInvoiceLine.Quantity), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            SecondLine := true;
        until SalesInvoiceLine.Next() = 0;
    end;

    local procedure VerifyInvoiceWithInvDiscount(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/ubl:Invoice/cac:AllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesInvoiceHeader.CalcFields(Amount, "Invoice Discount Amount");
        Path := DocumentTok + '/cbc:AllowanceChargeReason';
        Assert.AreEqual('Document discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
        Assert.AreEqual(FormatDecimal(100 * SalesInvoiceHeader."Invoice Discount Amount" / (SalesInvoiceHeader."Invoice Discount Amount" + SalesInvoiceHeader.Amount)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceHeader."Invoice Discount Amount" + SalesInvoiceHeader.Amount), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoLine(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/ns0:CreditNote/cac:CreditNoteLine', Locked = true;
        Path: Text;
        SecondLine: Boolean;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        repeat
            Path := DocumentTok + '/cbc:ID';
            if SecondLine then
                Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:CreditedQuantity ';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:LineExtensionAmount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cbc:Name';
            if SecondLine then
                Assert.AreEqual(SalesCrMemoLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(SalesCrMemoLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
            if SecondLine then
                Assert.AreEqual(SalesCrMemoLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(SalesCrMemoLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
            if SecondLine then
                Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path))
            else
                Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
            Assert.AreEqual(SalesCrMemoLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            SecondLine := true;
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure VerifyCrMemoLineWithDiscounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/ns0:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge', Locked = true;
        Path: Text;
        SecondLine: Boolean;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        repeat
            Path := DocumentTok + '/cbc:AllowanceChargeReason';
            if SecondLine then
                Assert.AreEqual('LineDiscount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Line Discount %"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:Amount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            Path := DocumentTok + '/cbc:BaseAmount';
            if SecondLine then
                Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Unit Price" * SalesCrMemoLine.Quantity), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
            SecondLine := true;
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure VerifyCrMemoWithInvDiscount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/ns0:CreditNote/cac:AllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesCrMemoHeader.CalcFields(Amount, "Invoice Discount Amount");
        Path := DocumentTok + '/cbc:AllowanceChargeReason';
        Assert.AreEqual('Document discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
        Assert.AreEqual(FormatDecimal(100 * SalesCrMemoHeader."Invoice Discount Amount" / (SalesCrMemoHeader."Invoice Discount Amount" + SalesCrMemoHeader.Amount)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoHeader."Invoice Discount Amount" + SalesCrMemoHeader.Amount), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10];
    begin
        if CurrencyCode <> '' then
            exit(CurrencyCode);

        exit(GeneralLedgerSetup."LCY Code");
    end;

    local procedure SetEdocumentServiceBuyerReference(EInvoiceBuyerReference: Enum "E-Document Buyer Reference");
    begin
        EDocumentService."Buyer Reference" := EInvoiceBuyerReference;
        EDocumentService.Modify();
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

    local procedure GetLastNodeByPathWithError(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);
        if TempXMLBuffer.FindLast() then
            exit(TempXMLBuffer.Value);
        Error('Node not found: %1', XPath);
    end;

    local procedure GetVATRegistrationNo(VATRegistrationNo: Text[20]; CountryRegionCode: Code[10]): Text[30];
    begin
        if CopyStr(VATRegistrationNo, 1, 2) <> CountryRegionCode then
            exit(CountryRegionCode + VATRegistrationNo);
        exit(VATRegistrationNo);
    end;

    local procedure CalculateLineAmounts(SalesInvoiceHeader: Record "Sales Invoice Header"; var LineAmounts: Dictionary of [Text, Decimal])
    var
        SalesInvLine: Record "Sales Invoice Line";
        Currency: Record Currency;
    begin
        GetCurrencyCode(SalesInvoiceHeader."Currency Code", Currency);
        SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvLine.FindSet();
        if SalesInvoiceHeader."Prices Including VAT" then
            repeat
                SalesInvLine."Line Discount Amount" := Round(SalesInvLine."Line Discount Amount" / (1 + SalesInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesInvLine."Inv. Discount Amount" := Round(SalesInvLine."Inv. Discount Amount" / (1 + SalesInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesInvLine."Unit Price" := Round(SalesInvLine."Unit Price" / (1 + SalesInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesInvLine.Modify(true);
            until SalesInvLine.Next() = 0;

        SalesInvLine.CalcSums(Amount, "Amount Including VAT", "Inv. Discount Amount");

        if not LineAmounts.ContainsKey(SalesInvLine.FieldName(Amount)) then
            LineAmounts.Add(SalesInvLine.FieldName(Amount), SalesInvLine.Amount);
        if not LineAmounts.ContainsKey(SalesInvLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(SalesInvLine.FieldName("Amount Including VAT"), SalesInvLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(SalesInvLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(SalesInvLine.FieldName("Inv. Discount Amount"), SalesInvLine."Inv. Discount Amount");
    end;

    local procedure CalculateLineAmounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var LineAmounts: Dictionary of [Text, Decimal])
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Currency: Record Currency;
    begin
        GetCurrencyCode(SalesCrMemoHeader."Currency Code", Currency);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        if SalesCrMemoHeader."Prices Including VAT" then
            repeat
                SalesCrMemoLine."Line Discount Amount" := Round(SalesCrMemoLine."Line Discount Amount" / (1 + SalesCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesCrMemoLine."Inv. Discount Amount" := Round(SalesCrMemoLine."Inv. Discount Amount" / (1 + SalesCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesCrMemoLine."Unit Price" := Round(SalesCrMemoLine."Unit Price" / (1 + SalesCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                SalesCrMemoLine.Modify(true);
            until SalesCrMemoLine.Next() = 0;

        SalesCrMemoLine.CalcSums(Amount, "Amount Including VAT", "Inv. Discount Amount");

        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName(Amount)) then
            LineAmounts.Add(SalesCrMemoLine.FieldName(Amount), SalesCrMemoLine.Amount);
        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(SalesCrMemoLine.FieldName("Amount Including VAT"), SalesCrMemoLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(SalesCrMemoLine.FieldName("Inv. Discount Amount"), SalesCrMemoLine."Inv. Discount Amount");
    end;

    local procedure GetTotalTaxAmount(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvLine.SetFilter(
          "VAT Calculation Type", '%1|%2|%3',
          SalesInvLine."VAT Calculation Type"::"Normal VAT",
          SalesInvLine."VAT Calculation Type"::"Full VAT",
          SalesInvLine."VAT Calculation Type"::"Reverse Charge VAT");
        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
        SalesInvLine.SetRange("VAT Calculation Type");
        exit(SalesInvLine."Amount Including VAT" - SalesInvLine.Amount);
    end;

    local procedure GetTotalTaxAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(
          "VAT Calculation Type", '%1|%2|%3',
          SalesCrMemoLine."VAT Calculation Type"::"Normal VAT",
          SalesCrMemoLine."VAT Calculation Type"::"Full VAT",
          SalesCrMemoLine."VAT Calculation Type"::"Reverse Charge VAT");
        SalesCrMemoLine.CalcSums(Amount, "Amount Including VAT");
        SalesCrMemoLine.SetRange("VAT Calculation Type");
        exit(SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount);
    end;

    local procedure GetCurrencyCode(DocumentCurrencyCode: Code[10]; var Currency: Record Currency): Code[10]
    begin
        if DocumentCurrencyCode = '' then begin
            Currency.InitRoundingPrecision();
            exit(GeneralLedgerSetup."LCY Code");
        end else begin
            Currency.Get(DocumentCurrencyCode);
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
            exit(DocumentCurrencyCode);
        end;
    end;

    local procedure FormatDate(VarDate: Date): Text[20];
    begin
        if VarDate = 0D then
            exit('1753-01-01');
        exit(Format(VarDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    local procedure FormatDecimal(VarDecimal: Decimal): Text[30];
    begin
        exit(Format(Round(VarDecimal, 0.01), 0, 9));
    end;

    procedure FormatFourDecimal(VarDecimal: Decimal): Text[30];
    begin
        exit(Format(Round(VarDecimal, 0.0001), 0, 9));
    end;

    local procedure Initialize();
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"XRechnung XML Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"XRechnung XML Document Tests");
        IsInitialized := true;
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        EDocumentService.DeleteAll();
        EDocumentService.Get(LibraryEdocument.CreateService("E-Document Format"::XRechnung, "Service Integration"::"No Integration"));
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"XRechnung XML Document Tests");
    end;
}

