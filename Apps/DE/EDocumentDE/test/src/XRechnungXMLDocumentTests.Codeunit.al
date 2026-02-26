// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Test;
using System.IO;
using System.Utilities;

codeunit 13918 "XRechnung XML Document Tests"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun();
    begin
        // [FEATURE] [XRechnung E-document]
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EDocumentService: Record "E-Document Service";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryEdocument: Codeunit "Library - E-Document";
        Assert: Codeunit Assert;
        ExportXRechnungFormat: Codeunit "XRechnung Format";
        ExportXRechnungDocument: Codeunit "Export XRechnung Document";
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
    procedure ExportPostedSalesInvoiceInXRechnungFormatMandateBuyerReferenceAsYourReference();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Mandate buyer reference as your reference when releasing sales invoice for XRechnung format
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create Sales Invoice with your reference = XX
        SalesHeader.Get("Sales Document Type"::Invoice, CreateSalesDocumentWithLine("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Remove your reference
        SalesHeader.Validate("Your Reference", '');
        SalesHeader.Modify(false);

        // [THEN] Error message is shown when releasing the sales invoice
        asserterror CheckSalesHeader(SalesHeader);
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
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifyPDFEmbeddedToXML()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export posted sales invoice creates electronic document in XRechnung format with embedded PDF
        Initialize();

        // [GIVEN] Enable Embedding of PDF in export
        SetEdocumentServiceEmbedPDFInExport(true);

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] PDF is embedded in the XML
        VerifyInvoicePDFEmbeddedToXML(TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesInvoiceInXRechnungFormatVerifySellerAddressFromRespCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export posted sales invoice creates electronic document in XRechnung format with seller info from responsibility center
        Initialize();

        // [GIVEN] Responsibility Center
        CreateResponsibilityCenter(ResponsibilityCenter);

        // [GIVEN] Create and Post Sales Invoice.
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithRespCenter("Sales Document Type"::Invoice, Enum::"Sales Line Type"::Item, ResponsibilityCenter.Code));

        // [WHEN] Export XRechnung Electronic Document.
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ubl:Invoice/cac:AccountingSupplierParty/cac:Party', ResponsibilityCenter);
    end;
    #endregion

    #region ServiceInvoice
    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyHeaderData();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with header data from the document
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created
        VerifyHeaderData(ServiceInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post Service Invoice with Customer X, E-invoice routing no. = XY
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XY
        Customer.Get(ServiceInvoiceHeader."Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/ubl:Invoice');
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyBuyerReferenceAsYourReference();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post Service Invoice with your reference = XX
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XX
        VerifyBuyerReference(ServiceInvoiceHeader."Your Reference", TempXMLBuffer, '/ubl:Invoice');
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatMandateBuyerReferenceAsYourReference();
    var
        ServiceHeader: Record "Service Header";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Mandate buyer reference as your reference when releasing service invoice for XRechnung format
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create Service Invoice with your reference = XX
        ServiceHeader.Get(ServiceHeader."Document Type"::Invoice, CreateServiceDocumentWithLine());

        // [WHEN] Remove your reference
        ServiceHeader.Validate("Your Reference", '');
        ServiceHeader.Modify(false);

        // [THEN] Error message is shown when releasing the service invoice
        asserterror CheckServiceHeader(ServiceHeader);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyAccountingSupplierParty();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with company data as accounting supplier party
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ubl:Invoice/cac:AccountingSupplierParty/cac:Party');
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyAccountingCustomerParty();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with customer data as accounting customer party
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with customer data as accounting customer party
        VerifyAccountingCustomerParty(ServiceInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyPaymentMeans();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with bank information as payment means
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with bank information as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/ubl:Invoice/cac:PaymentMeans');
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyPaymentTerms();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with payment terms
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with payment terms
        VerifyPaymentTerms(ServiceInvoiceHeader."Payment Terms Code", TempXMLBuffer, '/ubl:Invoice/cac:PaymentTerms');
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyTaxTotal();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with different tax totals
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with different tax totals
        VerifyTaxTotals(ServiceInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyLegalMonetaryTotal();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with document totals
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(ServiceInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyInvoiceLine();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with 2 invoice lines
        Initialize();

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocumentWithTwoLines());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 invoice lines
        VerifyServiceInvoiceLine(ServiceInvoiceHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifyPDFEmbeddedToXML()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with embedded PDF
        Initialize();

        // [GIVEN] Enable Embedding of PDF in export
        SetEdocumentServiceEmbedPDFInExport(true);

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] PDF is embedded in the XML
        VerifyInvoicePDFEmbeddedToXML(TempXMLBuffer);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportPostedServiceInvoiceInXRechnungFormatVerifySellerAddressFromRespCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service invoice creates electronic document in XRechnung format with seller info from responsibility center
        Initialize();

        // [GIVEN] Responsibility Center
        CreateResponsibilityCenter(ResponsibilityCenter);

        // [GIVEN] Create and Post Service Invoice.
        ServiceInvoiceHeader.Get(CreateAndPostServiceDocumentWithRespCenter(ResponsibilityCenter.Code));

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceInvoice(ServiceInvoiceHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ubl:Invoice/cac:AccountingSupplierParty/cac:Party', ResponsibilityCenter);
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
    procedure ExportPostedSalesCrMemoInXRechnungFormatMandateBuyerReferenceAsYourReference();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Mandate buyer reference as your reference when releasing sales credit memo for XRechnung format
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create Sales Invoice with your reference = XX
        SalesHeader.Get("Sales Document Type"::"Credit Memo", CreateSalesDocumentWithLine("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Remove your reference
        SalesHeader.Validate("Your Reference", '');
        SalesHeader.Modify(false);

        // [THEN] Error message is shown when releasing the sales invoice
        asserterror CheckSalesHeader(SalesHeader);
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
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifyPDFEmbeddedToXML()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export posted sales cr. memo creates electronic document in XRechnung format with embedded PDF
        Initialize();

        // [GIVEN] Enable Embedding of PDF in export
        SetEdocumentServiceEmbedPDFInExport(true);

        // [GIVEN] Create and Post Sales Cr. Memo.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, false));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] PDF is embedded in the XML
        VerifyCrMemoPDFEmbeddedToXML(TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedSalesCrMemoInXRechnungFormatVerifySellerAddressFromRespCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [SCENARIO] Export posted sales credit memo creates electronic document in XRechnung format with seller info from responsibility center
        Initialize();

        // [GIVEN] Responsibility Center
        CreateResponsibilityCenter(ResponsibilityCenter);

        // [GIVEN] Create and Post Sales Invoice.
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithRespCenter("Sales Document Type"::"Credit Memo", Enum::"Sales Line Type"::Item, ResponsibilityCenter.Code));

        // [WHEN] Export XRechnung Electronic Document.
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ns0:CreditNote/cac:AccountingSupplierParty/cac:Party', ResponsibilityCenter);
    end;
    #endregion

    #region ServiceCreditMemo
    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyHeaderData();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with header data from the document
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created
        VerifyHeaderData(ServiceCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyBuyerReferenceAsCustomerReference();
    var
        Customer: Record Customer;
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [GIVEN] Create and Post service cr. memo with Customer X, E-invoice routing no. = XY
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XY
        Customer.Get(ServiceCrMemoHeader."Customer No.");
        VerifyBuyerReference(Customer."E-Invoice Routing No.", TempXMLBuffer, '/ns0:CreditNote');
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyBuyerReferenceAsYourReference();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with your reference from the document
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create and Post service cr. memo with your reference = XX
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with buyer reference XX
        VerifyBuyerReference(ServiceCrMemoHeader."Your Reference", TempXMLBuffer, '/ns0:CreditNote');
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatMandateBuyerReferenceAsYourReference();
    var
        ServiceHeader: Record "Service Header";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Mandate buyer reference as your reference when releasing service credit memo for XRechnung format
        Initialize();

        // [GIVEN] Set Buyer reference = your reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Your Reference");

        // [GIVEN] Create Service Credit Memo with your reference = XX
        ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", CreateServiceCrMemoDocumentWithLine());

        // [WHEN] Remove your reference
        ServiceHeader.Validate("Your Reference", '');
        ServiceHeader.Modify(false);

        // [THEN] Error message is shown when releasing the service credit memo
        asserterror CheckServiceHeader(ServiceHeader);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyAccountingSupplierParty();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with company data as accounting supplier party
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ns0:CreditNote/cac:AccountingSupplierParty/cac:Party');
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyAccountingCustomerParty();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with customer data as accounting customer party
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with customer data as accounting customer party
        VerifyAccountingCustomerParty(ServiceCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyPaymentMeans();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with bank information as payment means
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with bank information as payment means
        VerifyPaymentMeans(TempXMLBuffer, '/ns0:CreditNote/cac:PaymentMeans');
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyPaymentTerms();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with payment terms
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with payment terms
        VerifyPaymentTerms(ServiceCrMemoHeader."Payment Terms Code", TempXMLBuffer, '/ns0:CreditNote/cac:PaymentTerms');
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyTaxTotal();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with different tax totals
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with different tax totals
        VerifyTaxTotals(ServiceCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyLegalMonetaryTotal();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with document totals
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with document totals
        VerifyLegalMonetaryTotal(ServiceCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyCrMemoLine();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with 2 cr.memo lines
        Initialize();

        // [GIVEN] Create and Post service cr. memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocumentWithTwoLines());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with 2 cr.memo lines
        VerifyServiceCrMemoLine(ServiceCrMemoHeader, TempXMLBuffer);
    end;

    [Test]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifyPDFEmbeddedToXML()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service cr. memo creates electronic document in XRechnung format with embedded PDF
        Initialize();

        // [GIVEN] Enable Embedding of PDF in export
        SetEdocumentServiceEmbedPDFInExport(true);

        // [GIVEN] Create and Post Service Cr. Memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocument());

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] PDF is embedded in the XML
        VerifyCrMemoPDFEmbeddedToXML(TempXMLBuffer);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportPostedServiceCrMemoInXRechnungFormatVerifySellerAddressFromRespCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 604872] Export posted service credit memo creates electronic document in XRechnung format with seller info from responsibility center
        Initialize();

        // [GIVEN] Responsibility Center
        CreateResponsibilityCenter(ResponsibilityCenter);

        // [GIVEN] Create and Post Service Credit Memo.
        ServiceCrMemoHeader.Get(CreateAndPostServiceCrMemoDocumentWithRespCenter(ResponsibilityCenter.Code));

        // [WHEN] Export XRechnung Electronic Document.
        ExportServiceCreditMemo(ServiceCrMemoHeader, TempXMLBuffer);

        // [THEN] XRechnung Electronic Document is created with company data as accounting supplier party
        VerifyAccountingSupplierParty(TempXMLBuffer, '/ns0:CreditNote/cac:AccountingSupplierParty/cac:Party', ResponsibilityCenter);
    end;
    #endregion

    #region InvoiceDiscount
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
    #region PurchaseInvoice
    [Test]
    procedure ReleasePurchaseInvoiceInXRechnungFormat();
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Release purchase invoice regardless if XRechnung format is setup with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [WHEN] Create and release Purchase Invoice
        CreatePurchDocument(PurchaseHeader, "Purchase Document Type"::Invoice);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        // [THEN] No error occurs
    end;
    #endregion

    #region PurchaseCreditMemo
    [Test]
    procedure ReleasePurchaseCreditMemoInXRechnungFormat();
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Release purchase credit memo regardless if XRechnung format is setup with customer reference
        Initialize();

        // [GIVEN] Set Buyer reference = customer reference
        SetEdocumentServiceBuyerReference("E-Document Buyer Reference"::"Customer Reference");

        // [WHEN] Create and release Purchase credit Memo
        CreatePurchDocument(PurchaseHeader, "Purchase Document Type"::"Credit Memo");
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);

        // [THEN] No error occurs
    end;
    #endregion

    local procedure CreateAndPostSalesDocument(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType, LineType, InvoiceDiscount));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostServiceDocument(): Code[20];
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::Invoice, CreateServiceDocumentWithLine());
        exit(PostServiceDocument(ServiceHeader));
    end;

    local procedure CreateAndPostServiceDocumentWithTwoLines(): Code[20];
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::Invoice, CreateServiceDocumentWithTwoLines());
        exit(PostServiceDocument(ServiceHeader));
    end;

    local procedure CreateAndPostServiceDocumentWithRespCenter(RespCenterCode: Code[10]): Code[20];
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::Invoice, CreateServiceDocumentWithLine());
        ServiceHeader.Validate("Responsibility Center", RespCenterCode);
        ServiceHeader.Modify(true);
        exit(PostServiceDocument(ServiceHeader));
    end;

    local procedure PostServiceDocument(var ServiceHeader: Record "Service Header"): Code[20]
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServiceInvoiceHeader.FindLast();
        exit(ServiceInvoiceHeader."No.");
    end;

    local procedure CreateAndPostServiceCrMemoDocument(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", CreateServiceCrMemoDocumentWithLine());
        exit(PostServiceCrMemoDocument(ServiceHeader));
    end;

    local procedure CreateAndPostServiceCrMemoDocumentWithTwoLines(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", CreateServiceCrMemoDocumentWithTwoLines());
        exit(PostServiceCrMemoDocument(ServiceHeader));
    end;

    local procedure CreateAndPostServiceCrMemoDocumentWithRespCenter(RespCenterCode: Code[10]): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", CreateServiceCrMemoDocumentWithLine());
        ServiceHeader.Validate("Responsibility Center", RespCenterCode);
        ServiceHeader.Modify(true);
        exit(PostServiceCrMemoDocument(ServiceHeader));
    end;

    local procedure PostServiceCrMemoDocument(var ServiceHeader: Record "Service Header"): Code[20]
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServiceCrMemoHeader.FindLast();
        exit(ServiceCrMemoHeader."No.");
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

    local procedure CreateAndPostSalesDocumentWithRespCenter(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; RespCenterCode: Code[10]): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType, LineType, false, RespCenterCode));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePurchDocument(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, DocumentType);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 5));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(50, 5));
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type")
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
    end;

    local procedure CreateSalesDocumentWithLine(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean): Code[20]
    begin
        exit(CreateSalesDocumentWithLine(DocumentType, LineType, InvoiceDiscount, ''));
    end;

    local procedure CreateSalesDocumentWithLine(DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type"; InvoiceDiscount: Boolean; RespCenterCode: Code[20]): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        if RespCenterCode <> '' then begin
            SalesHeader.Validate("Responsibility Center", RespCenterCode);
            SalesHeader.Modify(true);
        end;
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
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount * LibraryRandom.RandDecInRange(40, 60, 5) / 100, SalesHeader);
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

    local procedure CreateResponsibilityCenter(var ResponsibilityCenter: Record "Responsibility Center")
    begin
        ResponsibilityCenter.Init();
        ResponsibilityCenter.Validate(Code, LibraryUtility.GenerateRandomCode(ResponsibilityCenter.FieldNo(Code), DATABASE::"Responsibility Center"));
        ResponsibilityCenter.Validate(Name, ResponsibilityCenter.Code);  // Validating Code as Name because value is not important.
        ResponsibilityCenter.Insert(true);
        ResponsibilityCenter.Address := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(ResponsibilityCenter.Address));
        ResponsibilityCenter."Address 2" := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(ResponsibilityCenter."Address 2"));
        ResponsibilityCenter."Post Code" := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(ResponsibilityCenter."Post Code"));
        ResponsibilityCenter.City := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(ResponsibilityCenter.City));
        ResponsibilityCenter."Country/Region Code" := CompanyInformation."Country/Region Code";
        ResponsibilityCenter.Modify(true);
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
        SalesLine, SalesHeader, LineType, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 5));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 5));
        SalesLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.Validate("Tax Category", LibraryRandom.RandText(2));
        if LineDiscount then
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 5));
        SalesLine.Modify(true);
    end;

    local procedure CreateServiceDocumentWithLine(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceHeader(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        exit(ServiceHeader."No.");
    end;

    local procedure CreateServiceDocumentWithTwoLines(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceHeader(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        exit(ServiceHeader."No.");
    end;

    local procedure CreateServiceHeader(var ServiceHeader: Record "Service Header")
    var
        PostCode: Record "Post Code";
        PaymentTermsCode: Code[10];
    begin
        LibraryERM.FindPostCode(PostCode);
        PaymentTermsCode := LibraryERM.FindPaymentTermsCode();
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CreateCustomer());
        ServiceHeader.Validate("Bill-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.Validate("Bill-to City", PostCode.City);
        ServiceHeader.Validate("Ship-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.Validate("Ship-to City", PostCode.City);
        ServiceHeader.Validate(Address, LibraryUtility.GenerateGUID());
        ServiceHeader.Validate(City, PostCode.City);
        ServiceHeader.Validate("Your Reference", LibraryUtility.GenerateRandomText(20));
        ServiceHeader.Validate("Payment Terms Code", PaymentTermsCode);
        ServiceHeader.Modify(true);
    end;

    local procedure CreateServiceLine(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        UnitOfMeasure."International Standard Code" := LibraryUtility.GenerateGUID();
        UnitOfMeasure.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItemNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        ServiceLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        ServiceLine.Modify(true);
    end;

    local procedure CreateServiceCrMemoDocumentWithLine(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceCrMemoHeader(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        exit(ServiceHeader."No.");
    end;

    local procedure CreateServiceCrMemoDocumentWithTwoLines(): Code[20]
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceCrMemoHeader(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        CreateServiceLine(ServiceHeader);
        exit(ServiceHeader."No.");
    end;

    local procedure CreateServiceCrMemoHeader(var ServiceHeader: Record "Service Header")
    var
        PostCode: Record "Post Code";
        PaymentTermsCode: Code[10];
    begin
        LibraryERM.FindPostCode(PostCode);
        PaymentTermsCode := LibraryERM.FindPaymentTermsCode();
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", CreateCustomer());
        ServiceHeader.Validate("Bill-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.Validate("Bill-to City", PostCode.City);
        ServiceHeader.Validate("Ship-to Address", LibraryUtility.GenerateGUID());
        ServiceHeader.Validate("Ship-to City", PostCode.City);
        ServiceHeader.Validate(Address, LibraryUtility.GenerateGUID());
        ServiceHeader.Validate(City, PostCode.City);
        ServiceHeader.Validate("Your Reference", LibraryUtility.GenerateRandomText(20));
        ServiceHeader.Validate("Payment Terms Code", PaymentTermsCode);
        ServiceHeader.Modify(true);
    end;

    local procedure CheckServiceHeader(ServiceHeader: Record "Service Header")
    var
        SourceDocumentHeader: RecordRef;
    begin
        SourceDocumentHeader.GetTable(ServiceHeader);
        ExportXRechnungFormat.Check(SourceDocumentHeader, EDocumentService, "E-Document Processing Phase"::Release);
    end;

    local procedure CheckSalesHeader(SalesHeader: Record "Sales Header")
    var
        SourceDocumentHeader: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesHeader);
        ExportXRechnungFormat.Check(SourceDocumentHeader, EDocumentService, "E-Document Processing Phase"::Release);
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

    local procedure ExportServiceInvoice(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FileInStream: InStream;
    begin
        SourceDocumentHeader.GetTable(ServiceInvoiceHeader);
        SourceDocumentLines.GetTable(ServiceInvoiceLine);
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

    local procedure ExportServiceCreditMemo(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FileInStream: InStream;
    begin
        SourceDocumentHeader.GetTable(ServiceCrMemoHeader);
        SourceDocumentLines.GetTable(ServiceCrMemoLine);
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

    local procedure VerifyHeaderData(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceDocumentTok: Label '/ubl:Invoice', Locked = true;
        Path: Text;
    begin
        Path := ServiceDocumentTok + '/cbc:InvoiceTypeCode';
        Assert.AreEqual('380', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentTok + '/cbc:ID';
        Assert.AreEqual(ServiceInvoiceHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentTok + '/cbc:IssueDate';
        Assert.AreEqual(FormatDate(ServiceInvoiceHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentTok + '/cbc:DocumentCurrencyCode';
        Assert.AreEqual(GetCurrencyCode(ServiceInvoiceHeader."Currency Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyHeaderData(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceDocumentCreditNoteTok: Label '/ns0:CreditNote', Locked = true;
        Path: Text;
    begin
        Path := ServiceDocumentCreditNoteTok + '/cbc:CreditNoteTypeCode';
        Assert.AreEqual('381', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentCreditNoteTok + '/cbc:ID';
        Assert.AreEqual(ServiceCrMemoHeader."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentCreditNoteTok + '/cbc:IssueDate';
        Assert.AreEqual(FormatDate(ServiceCrMemoHeader."Posting Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentCreditNoteTok + '/cbc:DocumentCurrencyCode';
        Assert.AreEqual(GetCurrencyCode(ServiceCrMemoHeader."Currency Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyBuyerReference(BuyerReference: Text[50]; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:BuyerReference';
        Assert.AreEqual(BuyerReference, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingSupplierParty(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    begin
        VerifyAccountingSupplierParty(TempXMLBuffer, DocumentTok, CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
    end;

    local procedure VerifyAccountingSupplierParty(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text; ResponsibilityCenter: Record "Responsibility Center")
    begin
        VerifyAccountingSupplierParty(TempXMLBuffer, DocumentTok, ResponsibilityCenter.Address, ResponsibilityCenter."Post Code", ResponsibilityCenter.City);
    end;

    local procedure VerifyAccountingSupplierParty(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text; Address: Text; PostCode: Code[20]; City: Text[30])
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(Address, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(City, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:PostalAddress/cbc:PostalZone';
        Assert.AreEqual(PostCode, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));

        Path := DocumentTok + '/cac:PartyTaxScheme/cbc:CompanyID';
        Assert.AreEqual(GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingCustomerParty(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesDocumentPartyTok: Label '/ubl:Invoice/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
    begin
        Path := SalesDocumentPartyTok + '/cbc:EndpointID';
        Assert.AreEqual(SalesInvoiceHeader."Sell-to E-Mail", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := SalesDocumentPartyTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(SalesInvoiceHeader."Bill-to Address", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := SalesDocumentPartyTok + '/cac:PostalAddress/cbc:CityName';
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

    local procedure VerifyAccountingCustomerParty(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DocumentServicePartyTok: Label '/ubl:Invoice/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
    begin
        Path := DocumentServicePartyTok + '/cbc:EndpointID';
        Assert.AreEqual(ServiceInvoiceHeader."E-Mail", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentServicePartyTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(ServiceInvoiceHeader."Bill-to Address", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentServicePartyTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(ServiceInvoiceHeader."Bill-to City", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyAccountingCustomerParty(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceDocumentAccountingCustomerPartyTok: Label '/ns0:CreditNote/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
    begin
        Path := ServiceDocumentAccountingCustomerPartyTok + '/cbc:EndpointID';
        Assert.AreEqual(ServiceCrMemoHeader."E-Mail", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentAccountingCustomerPartyTok + '/cac:PostalAddress/cbc:StreetName';
        Assert.AreEqual(ServiceCrMemoHeader."Bill-to Address", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentAccountingCustomerPartyTok + '/cac:PostalAddress/cbc:CityName';
        Assert.AreEqual(ServiceCrMemoHeader."Bill-to City", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
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
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(GetTotalTaxAmount(SalesInvoiceHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        DocumentTaxTotalsTok: Label '/ns0:CreditNote/cac:TaxTotal', Locked = true;
        Path: Text;
    begin
        Path := DocumentTaxTotalsTok + '/cbc:TaxAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(GetTotalTaxAmount(SalesCrMemoHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceDocumentTaxTotalTok: Label '/ubl:Invoice/cac:TaxTotal', Locked = true;
        Path: Text;
    begin
        Path := ServiceDocumentTaxTotalTok + '/cbc:TaxAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(GetTotalTaxAmount(ServiceInvoiceHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyTaxTotals(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceDocumentTaxTotalsTok: Label '/ns0:CreditNote/cac:TaxTotal', Locked = true;
        Path: Text;
    begin
        Path := ServiceDocumentTaxTotalsTok + '/cbc:TaxAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(GetTotalTaxAmount(ServiceCrMemoHeader)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalTok: Label '/ubl:Invoice/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesInvoiceHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalTok + '/cbc:PayableAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        LineAmounts: Dictionary of [Text, Decimal];
        DocumentLegalMonetaryTotalsTok: Label '/ns0:CreditNote/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(SalesCrMemoHeader, LineAmounts);
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentLegalMonetaryTotalsTok + '/cbc:PayableAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(SalesCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        LineAmounts: Dictionary of [Text, Decimal];
        ServiceDocumentLegalMonetaryTotalTok: Label '/ubl:Invoice/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(ServiceInvoiceHeader, LineAmounts);
        Path := ServiceDocumentLegalMonetaryTotalTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceInvoiceHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalTok + '/cbc:PayableAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceInvoiceHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyLegalMonetaryTotal(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        LineAmounts: Dictionary of [Text, Decimal];
        ServiceDocumentLegalMonetaryTotalsTok: Label '/ns0:CreditNote/cac:LegalMonetaryTotal', Locked = true;
        Path: Text;
    begin
        CalculateLineAmounts(ServiceCrMemoHeader, LineAmounts);
        Path := ServiceDocumentLegalMonetaryTotalsTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalsTok + '/cbc:TaxExclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceCrMemoHeader.FieldName(Amount))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalsTok + '/cbc:TaxInclusiveAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ServiceDocumentLegalMonetaryTotalsTok + '/cbc:PayableAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(LineAmounts.Get(ServiceCrMemoHeader.FieldName("Amount Including VAT"))), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceLine(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/ubl:Invoice/cac:InvoiceLine', Locked = true;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
        VerifyFirstInvoiceLine(SalesInvoiceLine, TempXMLBuffer, DocumentTok);
        SalesInvoiceLine.Next();
        VerifySecondInvoiceLine(SalesInvoiceLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyServiceInvoiceLine(ServiceInvoiceHeader: Record "Service Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        DocumentTok: Label '/ubl:Invoice/cac:InvoiceLine', Locked = true;
    begin
        ServiceInvoiceLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
        ServiceInvoiceLine.FindSet();
        VerifyFirstServiceInvoiceLine(ServiceInvoiceLine, TempXMLBuffer, DocumentTok);
        ServiceInvoiceLine.Next();
        VerifySecondServiceInvoiceLine(ServiceInvoiceLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyFirstServiceInvoiceLine(ServiceInvoiceLine: Record "Service Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(ServiceInvoiceLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:InvoicedQuantity';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(ServiceInvoiceLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(ServiceInvoiceLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(ServiceInvoiceLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(ServiceInvoiceLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceInvoiceLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondServiceInvoiceLine(ServiceInvoiceLine: Record "Service Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(ServiceInvoiceLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:InvoicedQuantity';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceInvoiceLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(ServiceInvoiceLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(ServiceInvoiceLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(ServiceInvoiceLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceInvoiceLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyServiceCrMemoLine(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        DocumentTok: Label '/ns0:CreditNote/cac:CreditNoteLine', Locked = true;
    begin
        ServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
        ServiceCrMemoLine.FindSet();
        VerifyFirstServiceCrMemoLine(ServiceCrMemoLine, TempXMLBuffer, DocumentTok);
        ServiceCrMemoLine.Next();
        VerifySecondServiceCrMemoLine(ServiceCrMemoLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyFirstServiceCrMemoLine(ServiceCrMemoLine: Record "Service Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(ServiceCrMemoLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:CreditedQuantity ';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceCrMemoLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(ServiceCrMemoLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(ServiceCrMemoLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(ServiceCrMemoLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceCrMemoLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondServiceCrMemoLine(ServiceCrMemoLine: Record "Service Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(ServiceCrMemoLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:CreditedQuantity ';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceCrMemoLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(ServiceCrMemoLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(ServiceCrMemoLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(ServiceCrMemoLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(ServiceCrMemoLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyFirstInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:InvoicedQuantity';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesInvoiceLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(SalesInvoiceLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(SalesInvoiceLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesInvoiceLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
        Assert.AreEqual(SalesInvoiceLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:StartDate';
        Assert.AreEqual(FormatDate(SalesInvoiceLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:EndDate';
        Assert.AreEqual(FormatDate(SalesInvoiceLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text);
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(SalesInvoiceLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:InvoicedQuantity';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesInvoiceLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(SalesInvoiceLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(SalesInvoiceLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesInvoiceLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
        Assert.AreEqual(SalesInvoiceLine."Tax Category", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:StartDate';
        Assert.AreEqual(FormatDate(SalesInvoiceLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:EndDate';
        Assert.AreEqual(FormatDate(SalesInvoiceLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoiceLineWithDiscount(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTok: Label '/ubl:Invoice/cac:InvoiceLine/cac:AllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindLast();
        Path := DocumentTok + '/cbc:AllowanceChargeReason';
        Assert.AreEqual('LineDiscount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
        Assert.AreEqual(ExportXRechnungDocument.FormatFiveDecimal(SalesInvoiceLine."Line Discount %"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceLine."Unit Price" * SalesInvoiceLine.Quantity), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
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
        Assert.AreEqual(ExportXRechnungDocument.FormatFiveDecimal(100 * SalesInvoiceHeader."Invoice Discount Amount" / (SalesInvoiceHeader."Invoice Discount Amount" + SalesInvoiceHeader.Amount)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesInvoiceHeader."Invoice Discount Amount" + SalesInvoiceHeader.Amount), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoLine(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/ns0:CreditNote/cac:CreditNoteLine', Locked = true;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        VerifyFirstCrMemoLine(SalesCrMemoLine, TempXMLBuffer, DocumentTok);
        SalesCrMemoLine.Next();
        VerifySecondCrMemoLine(SalesCrMemoLine, TempXMLBuffer, DocumentTok);
    end;

    local procedure VerifyFirstCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:CreditedQuantity ';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesCrMemoLine."Quantity"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoLine."Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(SalesCrMemoLine."Description", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(SalesCrMemoLine."No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesCrMemoLine."Unit Price"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
        Assert.AreEqual(SalesCrMemoLine."Tax Category", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:StartDate';
        Assert.AreEqual(FormatDate(SalesCrMemoLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:EndDate';
        Assert.AreEqual(FormatDate(SalesCrMemoLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySecondCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentTok: Text)
    var
        Path: Text;
    begin
        Path := DocumentTok + '/cbc:ID';
        Assert.AreEqual(Format(SalesCrMemoLine."Line No."), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:CreditedQuantity ';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesCrMemoLine."Quantity"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:LineExtensionAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoLine."Amount"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(SalesCrMemoLine."Description", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:SellersItemIdentification/cbc:ID';
        Assert.AreEqual(SalesCrMemoLine."No.", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Price/cbc:PriceAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimalUnlimited(SalesCrMemoLine."Unit Price"), GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:ID';
        Assert.AreEqual(SalesCrMemoLine."Tax Category", GetLastNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:StartDate';
        Assert.AreEqual(FormatDate(SalesCrMemoLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cac:InvoicePeriod/cbc:EndDate';
        Assert.AreEqual(FormatDate(SalesCrMemoLine."Shipment Date"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyCrMemoLineWithDiscounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary);
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentTok: Label '/ns0:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge', Locked = true;
        Path: Text;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindLast();
        Path := DocumentTok + '/cbc:AllowanceChargeReason';
        Assert.AreEqual('LineDiscount', GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:MultiplierFactorNumeric';
        Assert.AreEqual(ExportXRechnungDocument.FormatFiveDecimal(SalesCrMemoLine."Line Discount %"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoLine."Line Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoLine."Unit Price" * SalesCrMemoLine.Quantity), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
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
        Assert.AreEqual(ExportXRechnungDocument.FormatFiveDecimal(100 * SalesCrMemoHeader."Invoice Discount Amount" / (SalesCrMemoHeader."Invoice Discount Amount" + SalesCrMemoHeader.Amount)), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:Amount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoHeader."Invoice Discount Amount"), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := DocumentTok + '/cbc:BaseAmount';
        Assert.AreEqual(ExportXRechnungDocument.FormatDecimal(SalesCrMemoHeader."Invoice Discount Amount" + SalesCrMemoHeader.Amount), GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifyInvoicePDFEmbeddedToXML(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.SetRange(Path, '/ubl:Invoice/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject');
        Assert.RecordIsNotEmpty(TempXMLBuffer, '');
    end;

    local procedure VerifyCrMemoPDFEmbeddedToXML(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.SetRange(Path, '/ns0:CreditNote/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject');
        Assert.RecordIsNotEmpty(TempXMLBuffer, '');
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10];
    begin
        if CurrencyCode <> '' then
            exit(CurrencyCode);

        exit(GeneralLedgerSetup."LCY Code");
    end;

    local procedure SetEdocumentServiceEmbedPDFInExport(NewEmbedPDFInExport: Boolean);
    begin
        EDocumentService."Embed PDF in export" := NewEmbedPDFInExport;
        EDocumentService.Modify();
    end;

    local procedure SetEdocumentServiceBuyerReference(EInvoiceBuyerReference: Enum "E-Document Buyer Reference");
    begin
        EDocumentService."Buyer Reference Mandatory" := true;
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

    local procedure CalculateLineAmounts(ServiceInvoiceHeader: Record "Service Invoice Header"; var LineAmounts: Dictionary of [Text, Decimal])
    var
        ServiceInvLine: Record "Service Invoice Line";
        Currency: Record Currency;
    begin
        GetCurrencyCode(ServiceInvoiceHeader."Currency Code", Currency);
        ServiceInvLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
        ServiceInvLine.FindSet();
        if ServiceInvoiceHeader."Prices Including VAT" then
            repeat
                ServiceInvLine."Line Discount Amount" := Round(ServiceInvLine."Line Discount Amount" / (1 + ServiceInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceInvLine."Inv. Discount Amount" := Round(ServiceInvLine."Inv. Discount Amount" / (1 + ServiceInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceInvLine."Unit Price" := Round(ServiceInvLine."Unit Price" / (1 + ServiceInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceInvLine.Modify(true);
            until ServiceInvLine.Next() = 0;

        ServiceInvLine.CalcSums(Amount, "Amount Including VAT", "Inv. Discount Amount");

        if not LineAmounts.ContainsKey(ServiceInvLine.FieldName(Amount)) then
            LineAmounts.Add(ServiceInvLine.FieldName(Amount), ServiceInvLine.Amount);
        if not LineAmounts.ContainsKey(ServiceInvLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(ServiceInvLine.FieldName("Amount Including VAT"), ServiceInvLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(ServiceInvLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(ServiceInvLine.FieldName("Inv. Discount Amount"), ServiceInvLine."Inv. Discount Amount");
    end;

    local procedure CalculateLineAmounts(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var LineAmounts: Dictionary of [Text, Decimal])
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        Currency: Record Currency;
    begin
        GetCurrencyCode(ServiceCrMemoHeader."Currency Code", Currency);
        ServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
        ServiceCrMemoLine.FindSet();
        if ServiceCrMemoHeader."Prices Including VAT" then
            repeat
                ServiceCrMemoLine."Line Discount Amount" := Round(ServiceCrMemoLine."Line Discount Amount" / (1 + ServiceCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceCrMemoLine."Inv. Discount Amount" := Round(ServiceCrMemoLine."Inv. Discount Amount" / (1 + ServiceCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceCrMemoLine."Unit Price" := Round(ServiceCrMemoLine."Unit Price" / (1 + ServiceCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
                ServiceCrMemoLine.Modify(true);
            until ServiceCrMemoLine.Next() = 0;

        ServiceCrMemoLine.CalcSums(Amount, "Amount Including VAT", "Inv. Discount Amount");

        if not LineAmounts.ContainsKey(ServiceCrMemoLine.FieldName(Amount)) then
            LineAmounts.Add(ServiceCrMemoLine.FieldName(Amount), ServiceCrMemoLine.Amount);
        if not LineAmounts.ContainsKey(ServiceCrMemoLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(ServiceCrMemoLine.FieldName("Amount Including VAT"), ServiceCrMemoLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(ServiceCrMemoLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(ServiceCrMemoLine.FieldName("Inv. Discount Amount"), ServiceCrMemoLine."Inv. Discount Amount");
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

    local procedure GetTotalTaxAmount(ServiceInvoiceHeader: Record "Service Invoice Header"): Decimal
    var
        ServiceInvLine: Record "Service Invoice Line";
    begin
        ServiceInvLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
        ServiceInvLine.SetFilter(
          "VAT Calculation Type", '%1|%2|%3',
          ServiceInvLine."VAT Calculation Type"::"Normal VAT",
          ServiceInvLine."VAT Calculation Type"::"Full VAT",
          ServiceInvLine."VAT Calculation Type"::"Reverse Charge VAT");
        ServiceInvLine.CalcSums(Amount, "Amount Including VAT");
        ServiceInvLine.SetRange("VAT Calculation Type");
        exit(ServiceInvLine."Amount Including VAT" - ServiceInvLine.Amount);
    end;

    local procedure GetTotalTaxAmount(ServiceCrMemoHeader: Record "Service Cr.Memo Header"): Decimal
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        ServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
        ServiceCrMemoLine.SetFilter(
          "VAT Calculation Type", '%1|%2|%3',
          ServiceCrMemoLine."VAT Calculation Type"::"Normal VAT",
          ServiceCrMemoLine."VAT Calculation Type"::"Full VAT",
          ServiceCrMemoLine."VAT Calculation Type"::"Reverse Charge VAT");
        ServiceCrMemoLine.CalcSums(Amount, "Amount Including VAT");
        ServiceCrMemoLine.SetRange("VAT Calculation Type");
        exit(ServiceCrMemoLine."Amount Including VAT" - ServiceCrMemoLine.Amount);
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

    local procedure Initialize();
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"XRechnung XML Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"XRechnung XML Document Tests");
        IsInitialized := true;
        CompanyInformation.Get();
        CompanyInformation.IBAN := LibraryUtility.GenerateMOD97CompliantCode();
        CompanyInformation."SWIFT Code" := LibraryUtility.GenerateGUID();
        CompanyInformation."E-Mail" := LibraryUtility.GenerateRandomEmail();
        CompanyInformation.Modify();
        GeneralLedgerSetup.Get();
        EDocumentService.DeleteAll();
        EDocumentService.Get(LibraryEdocument.CreateService("E-Document Format"::XRechnung, "Service Integration"::"No Integration"));
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"XRechnung XML Document Tests");
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}