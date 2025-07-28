// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;
using Microsoft.Bank.BankAccount;
using System.Reflection;
using System.IO;
using Microsoft.Foundation.UOM;
using Microsoft.Foundation.Address;
using Microsoft.eServices.EDocument;
using Microsoft.Sales.Document;
using Microsoft.Finance.Currency;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.PaymentTerms;
codeunit 13922 "ZUGFeRD XML Document Tests"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun();
    begin
        // [FEATURE] [ZUGFeRD E-document]
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
        ZUGFeRDFormat: Codeunit "ZUGFeRD Format";
        IncorrectValueErr: Label 'Incorrect value for %1', Locked = true;
        IsInitialized: Boolean;

    #region SalesInvoice
    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyHeaderData();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with header data from the document
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created
        VerifyHeaderData(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post Sales Invoice with Customer X, E-invoice routing no. = XY
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with buyer reference XY
        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/rsm:CrossIndustryInvoice');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyBuyerReferenceAsYourReference();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post Sales Invoice with your reference = XX
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with buyer reference XX
        VerifyBuyerReference(SalesInvoiceHeader."Your Reference", TempXMLBuffer, '/rsm:CrossIndustryInvoice');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifySellerDataApplicableHeaderTradeAgreement();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with company data as seller in applicable header trade agreement
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with company data as seller in applicable header trade agreement
        VerifySellerData(TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyBuyerDataApplicableHeaderTradeAgreement();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with customer data
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with customer data
        VerifyBuyerData(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyPaymentMeans();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with bank informarion as payment means
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with bank informarion as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement', SalesInvoiceHeader."Currency Code");
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyPaymentTerms();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with payment terms
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with payment terms
        VerifyPaymentTerms(SalesInvoiceHeader."Payment Terms Code", SalesInvoiceHeader."Due Date", TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms');
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyTaxTotal();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with different tax totals
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with different tax totals
        VerifyTaxTotals(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyLegalMonetaryTotal();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with document totals
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyInvoiceLine();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales invoice creates electronic document in ZUGFeRD format with 2 invoice lines
        Initialize();

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 invoice lines
        VerifyInvoiceLine(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyInvoiceLineWithLineDiscount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in ZUGFeRD format with 2 invoice lines, one line has line discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with line discount
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 invoice lines and one line has line discount
        VerifyInvoiceLineWithDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyInvoiceWithInvoiceDiscounts();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in ZUGFeRD format with 2 invoice lines and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 invoice lines and invoice discount
        VerifyInvoiceWithInvDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInZUGFeRDFormatVerifyInvoiceWithInvoiceDiscountsAndLineDiscount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales invoice creates electronic document in ZUGFeRD format with 2 invoice lines with discount and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount and line discount on one line
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 invoice lines with line discount and invoice discount
        VerifyInvoiceWithInvDiscount(SalesInvoiceHeader, TempXMLBuffer);
        VerifyInvoiceLineWithDiscount(SalesInvoiceHeader, TempXMLBuffer);
    end;
    #endregion

    #region SalesCreditMemo
    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyHeaderData();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with header data from the document
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created
        VerifyHeaderData(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post sales cr. memo with Customer X, E-invoice routing no. = XY
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with buyer reference XY
        Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/rsm:CrossIndustryInvoice');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyBuyerReferenceAsYourReference();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post sales cr. memo with your reference = XX
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with buyer reference XX
        VerifyBuyerReference(SalesCrMemoHeader."Your Reference", TempXMLBuffer, '/rsm:CrossIndustryInvoice');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifySellerDataApplicableHeaderTradeAgreement();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with company data as seller in applicable header trade agreement
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with company data as seller in applicable header trade agreement
        VerifySellerData(TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyBuyerDataApplicableHeaderTradeAgreement();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with customer data
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with customer data
        VerifyBuyerData(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyPaymentMeans();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with bank informarion as payment means
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with bank informarion as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement', SalesCrMemoHeader."Currency Code");
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyPaymentTerms();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with payment terms
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with payment terms
        VerifyPaymentTerms(SalesCrMemoHeader."Payment Terms Code", SalesCrMemoHeader."Due Date", TempXMLBuffer, '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms');
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyTaxTotal();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with different tax totals
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with different tax totals
        VerifyTaxTotals(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyLegalMonetaryTotal();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with document totals
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyCrMemoLine();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 556034] Export posted sales cr. memo creates electronic document in ZUGFeRD format with 2 cr.memo lines
        Initialize();

        // [GIVEN] Create and Post sales cr. memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 cr.memo lines
        VerifyCrMemoLine(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyCrMemoWithInvoiceDiscounts();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales cr. memo creates electronic document in ZUGFeRD format with 2 lines and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Invoice with invoice discount
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLines("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 lines and invoice discount
        VerifyCrMemoWithInvDiscount(SalesCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInZUGFeRDFormatVerifyCrMemoWithInvoiceDiscountsAndLineDiscount();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO 575895] Export posted sales cr.memo creates electronic document in ZUGFeRD format with 2 cr.memo lines with discount and invoice discount
        Initialize();

        // [GIVEN] Create and Post Sales Cr. Memo with invoice discount and line discount on one line
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithTwoLinesLineDiscount("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, true));

        // [WHEN] Export ZUGFeRD Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] ZUGFeRD Electronic Document is created with 2 lines with line discount and invoice discount
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
        CreateSalesLine(SalesHeader, LineType, false);

        if InvoiceDiscount then
            ApplyInvoiceDiscount(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesDocumentWithTwoLine(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader, LineType, false);
        CreateSalesLine(SalesHeader, LineType, false);

        if InvoiceDiscount then
            ApplyInvoiceDiscount(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesDocumentWithTwoLineLineDiscount(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader, LineType, false);
        CreateSalesLine(SalesHeader, LineType, true);

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
        PaymentMethod: Record "Payment Method";
        PaymentTermsCode: Code[10];
    begin
        LibraryERM.FindPostCode(PostCode);
        PaymentTermsCode := LibraryERM.FindPaymentTermsCode();
        LibraryERM.FindPaymentMethod(PaymentMethod);
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
        SalesHeader.Validate("Payment Method Code", PaymentMethod.Code);
        SalesHeader.Validate("Due Date", LibraryRandom.RandDate(LibraryRandom.RandIntInRange(5, 10)));
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

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; LineType: Enum "Sales Line Type"; LineDiscount: Boolean);
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
        SalesLine.Validate("Tax Category", LibraryRandom.RandText(2));
        if LineDiscount then
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
        SalesLine.Modify(true);
    end;

    local procedure ExportInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        PDFDocument: Codeunit "PDF Document";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        PDFInStream: InStream;
        PdfAttachmentStream: InStream;
    begin
        SourceDocumentHeader.GetTable(SalesInvoiceHeader);
        SourceDocumentLines.GetTable(SalesInvoiceLine);
        ZUGFeRDFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);

        TempBlob.CreateInStream(PdfInStream);
        PDFDocument.GetDocumentAttachmentStream(PdfInStream, TempBlob2);
        TempBlob2.CreateInStream(PdfAttachmentStream);
        TempXMLBuffer.LoadFromStream(PdfAttachmentStream);
    end;

    local procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        PDFDocument: Codeunit "PDF Document";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        PDFInStream: InStream;
        PdfAttachmentStream: InStream;
    begin
        SourceDocumentHeader.GetTable(SalesCrMemoHeader);
        SourceDocumentLines.GetTable(SalesCrMemoLine);
        ZUGFeRDFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);

        TempBlob.CreateInStream(PdfInStream);
        PDFDocument.GetDocumentAttachmentStream(PdfInStream, TempBlob2);
        TempBlob2.CreateInStream(PdfAttachmentStream);
        TempXMLBuffer.LoadFromStream(PdfAttachmentStream);
    end;

    local procedure VerifyHeaderData(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/rsm:CrossIndustryInvoice', Locked = true;
        Path: Text;
    begin
        Path := DocumentTok + '/rsm:ExchangedDocument/ram:TypeCode';
        Assert.AreEqual('380', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/rsm:ExchangedDocument/ram:ID';
        Assert.AreEqual(SalesInvoiceHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString';
        Assert.AreEqual(FormatDate(SalesInvoiceHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));

    end;

    local procedure VerifyHeaderData(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentCreditNoteTok: Label '/rsm:CrossIndustryInvoice', Locked = true;
        Path: Text;
    begin
        Path := DocumentCreditNoteTok + '/rsm:ExchangedDocument/ram:TypeCode';
        Assert.AreEqual('381', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentCreditNoteTok + '/rsm:ExchangedDocument/ram:ID';
        Assert.AreEqual(SalesCrMemoHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentCreditNoteTok + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString';
        Assert.AreEqual(FormatDate(SalesCrMemoHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyBuyerReference(BuyerReference: Text[50]; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerReference';
        Assert.AreEqual(BuyerReference, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySellerData(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:Name';
        Assert.AreEqual(CompanyInformation.Name, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:PostalTradeAddress/ram:PostcodeCode';
        Assert.AreEqual(CompanyInformation."Post Code", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:PostalTradeAddress/ram:CityName';
        Assert.AreEqual(CompanyInformation.City, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));

        Path := DocumentTok + '/ram:SpecifiedTaxRegistration/ram:ID';
        Assert.AreEqual(GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyBuyerData(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentPartyTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty', Locked = true;
        Path: Text;
    begin
        Path := DocumentPartyTok + '/ram:Name';
        Assert.AreEqual(SalesInvoiceHeader."Bill-to Name", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentPartyTok + '/ram:SpecifiedTaxRegistration/ram:ID';
        Assert.AreEqual(GetVATRegistrationNo(SalesInvoiceHeader."VAT Registration No.", CompanyInformation."Country/Region Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyBuyerData(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentBuyerTradePartyTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty', Locked = true;
        Path: Text;
    begin
        Path := DocumentBuyerTradePartyTok + '/ram:Name';
        Assert.AreEqual(SalesCrMemoHeader."Bill-to Name", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentBuyerTradePartyTok + '/ram:SpecifiedTaxRegistration/ram:ID';
        Assert.AreEqual(GetVATRegistrationNo(SalesCrMemoHeader."VAT Registration No.", CompanyInformation."Country/Region Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyPaymentMeans(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text; CurrencyCode: Code[10]);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:InvoiceCurrencyCode';
        Assert.AreEqual(GetCurrencyCode(CurrencyCode), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode';
        Assert.AreEqual('58', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:IBANID';
        Assert.AreEqual(GetIBAN(CompanyInformation.IBAN), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyPaymentTerms(PaymentTermsCode: Code[10]; DueDate: Date; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        PaymentTerms: Record "Payment Terms";
        Path: Text;
    begin
        PaymentTerms.Get(PaymentTermsCode);
        Path := DocumentTok + '/ram:Description';
        Assert.AreEqual(PaymentTerms.Description, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:DueDateDateTime/udt:DateTimeString';
        Assert.AreEqual(FormatDate(DueDate), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTaxTotalTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax', Locked = true;
        Path: Text;
    begin
        Path := DocumentTaxTotalTok + '/ram:CalculatedAmount';
        Assert.AreEqual(FormatDecimal(GetTotalTaxAmount(SalesInvoiceHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTaxTotalsTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax', Locked = true;
        Path: Text;
    begin
        Path := DocumentTaxTotalsTok + '/ram:CalculatedAmount';
        Assert.AreEqual(FormatDecimal(GetTotalTaxAmount(SalesCrMemoHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesInvoiceHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalTok + '/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/ram:TaxBasisTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/ram:GrandTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/ram:DuePayableAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalsTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesCrMemoHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalsTok + '/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/ram:TaxBasisTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/ram:GrandTotalAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/ram:DuePayableAmount';
        Assert.AreEqual(FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceLine(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem', Locked = true;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
        VerifyFirstSalesInvoiceLine(SalesInvoiceLine, TempXMLBuffer, DocumentTok);
        SalesInvoiceLine.Next();
        VerifySecondSalesInvoiceLine(SalesInvoiceLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyFirstSalesInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:AssociatedDocumentLineDocument/ram:LineID';
        Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity';
        Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeProduct/ram:Name';
        Assert.AreEqual(SalesInvoiceLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount';
        Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode';
        Assert.AreEqual(SalesInvoiceLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondSalesInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:AssociatedDocumentLineDocument/ram:LineID';
        Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity';
        Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeProduct/ram:Name';
        Assert.AreEqual(SalesInvoiceLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount';
        Assert.AreEqual(FormatFourDecimal(SalesInvoiceLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode';
        Assert.AreEqual(SalesInvoiceLine."Tax Category", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceLineWithDiscount(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindLast();
        Path := DocumentTok + '/ram:Reason';
        Assert.AreEqual('Line Discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:ActualAmount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceWithInvDiscount(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesInvoiceHeader.CalcFields("Invoice Discount Amount");
        Path := DocumentTok + '/ram:Reason';
        Assert.AreEqual('Document discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:ActualAmount';
        Assert.AreEqual(FormatDecimal(SalesInvoiceHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoLine(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem', Locked = true;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        VerifyFirstSalesICrMemoLine(SalesCrMemoLine, TempXMLBuffer, DocumentTok);
        SalesCrMemoLine.Next();
        VerifySecondSalesCrMemoLine(SalesCrMemoLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyFirstSalesICrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:AssociatedDocumentLineDocument/ram:LineID';
        Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity';
        Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeProduct/ram:Name';
        Assert.AreEqual(SalesCrMemoLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount';
        Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode';
        Assert.AreEqual(SalesCrMemoLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/ram:AssociatedDocumentLineDocument/ram:LineID';
        Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity';
        Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedTradeProduct/ram:Name';
        Assert.AreEqual(SalesCrMemoLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount';
        Assert.AreEqual(FormatFourDecimal(SalesCrMemoLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode';
        Assert.AreEqual(SalesCrMemoLine."Tax Category", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoLineWithDiscounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindLast();
        Path := DocumentTok + '/ram:Reason';
        Assert.AreEqual('Line Discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:ActualAmount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoWithInvDiscount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTok: Label '/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesCrMemoHeader.CalcFields("Invoice Discount Amount");
        Path := DocumentTok + '/ram:Reason';
        Assert.AreEqual('Document discount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/ram:ActualAmount';
        Assert.AreEqual(FormatDecimal(SalesCrMemoHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
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

    local procedure GetIBAN(IBAN: Text[50]) IBANFormatted: Text[50]
    begin
        // Format IBAN to remove spaces and ensure it is in uppercase
        if IBAN = '' then
            exit('');
        IBANFormatted := UpperCase(DelChr(IBAN, '=', ' '));
        exit(CopyStr(IBANFormatted, 1, 50));
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

    procedure FormatDate(VarDate: Date): Text[20];
    begin
        if VarDate = 0D then
            exit('17530101');
        exit(Format(VarDate, 0, '<Year4><Month,2><Day,2>'));
    end;

    procedure FormatDecimal(VarDecimal: Decimal): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Format(VarDecimal, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()));
    end;

    procedure FormatFourDecimal(VarDecimal: Decimal): Text
    begin
        exit(Format(VarDecimal, 0, '<Precision,4:4><Standard Format,9>'))
    end;

    local procedure Initialize();
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"ZUGFeRD XML Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"ZUGFeRD XML Document Tests");
        IsInitialized := true;
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        EDocumentService.DeleteAll();
        EDocumentService.Get(LibraryEdocument.CreateService("E-Document Format"::ZUGFeRD, "Service Integration"::"No Integration"));
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"ZUGFeRD XML Document Tests");
    end;
}

