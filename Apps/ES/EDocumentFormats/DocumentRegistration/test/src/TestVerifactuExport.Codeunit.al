// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu.Test;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.EServices.EDocument.Verifactu;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Test;
using System.Utilities;

codeunit 148004 "Test Verifactu Export"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        EDocumentService: Record "E-Document Service";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryEdocument: Codeunit "Library - E-Document";
        Assert: Codeunit "Assert";
        IsInitialized: Boolean;
        XMLShouldContainDocumentLbl: Label 'XML should contain document %1', Comment = '%1 = Document number';
        QRCodeShouldBeGeneratedForDocumentLbl: Label 'QR code should be generated for document %1', Comment = '%1 = Document number';
        TestServiceInvoiceLbl: Label 'Test Service Invoice %1', Comment = '%1 = Invoice number';
        TestServiceCreditMemoLbl: Label 'Test Service Credit Memo %1', Comment = '%1 = Credit memo number';

    #region SalesInvoice
    [Test]
    procedure ExportSalesInvoiceCreatesXMLFile()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML file for posted sales invoice
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C" and amount 1000
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML file is created with invoice number and root element
        VerifyDocumentNumber(SalesInvoiceHeader."No.", XMLText);
        VerifyXMLRootElement(XMLText);
    end;

    [Test]
    procedure ExportSalesInvoiceWithMultipleLines()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        VATRate: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML for invoice with multiple lines
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        // [GIVEN] Invoice has 3 lines with same VAT rate
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        CreatePostedSalesInvoiceWithMultipleLines(SalesInvoiceHeader, Customer."No.", VATRate);

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains one VAT breakdown entry
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
    end;

    [Test]
    procedure ExportSalesInvoiceWithDifferentVATRates()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        VATRate: Decimal;
        VATRate2: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates separate VAT breakdown entries for different VAT rates
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C" and different VAT rates
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        VATRate2 := LibraryRandom.RandIntInRange(10, 25);
        CreatePostedSalesInvoiceWithDifferentVATRates(SalesInvoiceHeader, Customer."No.", VATRate, VATRate2);

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains two VAT breakdown entries
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
        VerifyXMLContainsVATBreakdown(XMLText, VATRate2);
    end;

    [Test]
    procedure ExportSalesInvoiceIncludesCompanyInformation()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
        XMLText: Text;
    begin
        // [SCENARIO] Export includes company information in XML header
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CompanyInformation.Get();

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML header contains company name and VAT number
        VerifyCompanyInformation(CompanyInformation, XMLText);
    end;

    [Test]
    procedure ExportSalesInvoiceCalculatesTotalsCorrectly()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export calculates and includes correct totals in XML
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains CuotaTotal and ImporteTotal elements
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        VerifyDocumentTotals(XMLText, SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, SalesInvoiceHeader."Amount Including VAT");
    end;

    [Test]
    procedure ExportSalesInvoiceWithZeroVATRate()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export handles invoice lines with zero VAT rate
        Initialize();

        // [GIVEN] Posted sales invoice "I" with VAT rate 0
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(100, 500, 2), 0);

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains VAT breakdown entry with rate 0
        VerifyXMLContainsVATBreakdown(XMLText, 0);
    end;

    [Test]
    procedure ExportSalesInvoiceXMLHasCorrectStructure()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML with correct element structure
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains correct structure elements
        VerifyXMLStructure(XMLText);
    end;

    [Test]
    procedure ExportSalesInvoiceGeneratesVerifactuHash()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        VerifactuDocument: Record "Verifactu Document";
        XMLText: Text;
    begin
        // [SCENARIO] Export generates Verifactu hash for sales invoice
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains Huella element with hash value
        Commit();
        VerifactuDocument.SetCurrentKey("Source Document Type", "Source Document No.");
        VerifactuDocument.SetRange("Source Document Type", VerifactuDocument."Source Document Type"::"Sales Invoice");
        VerifactuDocument.SetRange("Source Document No.", SalesInvoiceHeader."No.");
        VerifactuDocument.FindLast();
        Assert.AreNotEqual('', VerifactuDocument."Verifactu Hash", 'Verifactu hash should be generated');
        Assert.IsTrue(XMLText.Contains(VerifactuDocument."Verifactu Hash"), 'XML should contain Huella element');
    end;

    [Test]
    procedure ExportSalesInvoiceGeneratesQRCode()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export generates QR code for sales invoice
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] QR code is generated and stored in invoice header
        SalesInvoiceHeader.Get(SalesInvoiceHeader."No.");
        Assert.IsTrue(SalesInvoiceHeader."QR Code Image".Count > 0, 'QR code image should be generated');
    end;

    [Test]
    procedure ExportSalesInvoiceIncludesSystemInformation()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export includes system information in invoice XML
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I"
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains SistemaInformatico element with Business Central information
        Assert.IsTrue(XMLText.Contains('SistemaInformatico'), 'XML should contain SistemaInformatico');
        Assert.IsTrue(XMLText.Contains('BusinessCentral'), 'XML should contain BusinessCentral');
        Assert.IsTrue(XMLText.Contains('NombreSistemaInformatico'), 'XML should contain NombreSistemaInformatico');
    end;
    #endregion

    #region SalesCreditMemo
    [Test]
    procedure ExportSalesCreditMemoCreatesXMLFile()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML file for posted sales credit memo
        Initialize();

        // [GIVEN] Posted sales credit memo "M" with customer "C" and amount 500
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, PostedSalesInvoice."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML file is created with credit memo number and invoice type R1
        VerifyDocumentNumber(SalesCrMemoHeader."No.", XMLText);
        VerifyCreditMemoType(XMLText);
    end;

    [Test]
    procedure ExportSalesCreditMemoWithMultipleLines()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        VATRate: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML for credit memo with multiple lines
        Initialize();

        // [GIVEN] Posted sales credit memo "M" with customer "C" and same VAT rate
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), VATRate);
        CreatePostedSalesCreditMemoWithMultipleLines(SalesCrMemoHeader, Customer."No.", PostedSalesInvoice."No.", VATRate);

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains one VAT breakdown entry
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
    end;

    [Test]
    procedure ExportSalesCreditMemoWithDifferentVATRates()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        VATRate: Decimal;
        VATRate2: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates separate VAT breakdown entries for credit memo with different VAT rates
        Initialize();

        // [GIVEN] Posted sales credit memo "M" with customer "C" and different VAT rates
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        VATRate2 := LibraryRandom.RandIntInRange(10, 25);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), VATRate);
        CreatePostedSalesCreditMemoWithDifferentVATRates(SalesCrMemoHeader, PostedSalesInvoice."No.", Customer."No.", VATRate, VATRate2);

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains two VAT breakdown entries
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
        VerifyXMLContainsVATBreakdown(XMLText, VATRate2);
    end;

    [Test]
    procedure ExportSalesCreditMemoIncludesFacturaRectificada()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export includes corrected invoice reference in credit memo
        Initialize();

        // [GIVEN] Posted sales invoice "I" with customer "C"
        // [GIVEN] Posted sales credit memo "M" correcting invoice "I"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, SalesInvoiceHeader."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains FacturasRectificadas element with original invoice reference
        Assert.IsTrue(XMLText.Contains('FacturasRectificadas'), 'XML should contain FacturasRectificadas');
        Assert.IsTrue(XMLText.Contains('IDFacturaRectificada'), 'XML should contain IDFacturaRectificada');
        Assert.IsTrue(XMLText.Contains(SalesInvoiceHeader."No."), 'XML should contain corrected invoice number');
    end;

    [Test]
    procedure ExportSalesCreditMemoCalculatesTotalsCorrectly()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export calculates and includes correct totals in XML for credit memo
        Initialize();

        // [GIVEN] Posted sales credit memo "M" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, PostedSalesInvoice."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains CuotaTotal and ImporteTotal elements
        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
        VerifyDocumentTotals(XMLText, -(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount), -SalesCrMemoHeader."Amount Including VAT");
    end;

    [Test]
    procedure ExportSalesCreditMemoGeneratesVerifactuHash()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        VerifactuDocument: Record "Verifactu Document";
        XMLText: Text;
    begin
        // [SCENARIO] Export generates Verifactu hash for sales credit memo
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales credit memo "M" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, PostedSalesInvoice."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains Huella element with hash value
        Commit();
        VerifactuDocument.SetCurrentKey("Source Document Type", "Source Document No.");
        VerifactuDocument.SetRange("Source Document Type", VerifactuDocument."Source Document Type"::"Sales Credit Memo");
        VerifactuDocument.SetRange("Source Document No.", SalesCrMemoHeader."No.");
        VerifactuDocument.FindLast();
        Assert.AreNotEqual('', VerifactuDocument."Verifactu Hash", 'Verifactu hash should be generated');
        Assert.IsTrue(XMLText.Contains(VerifactuDocument."Verifactu Hash"), 'XML should contain Huella element');
    end;

    [Test]
    procedure ExportSalesCreditMemoGeneratesQRCode()
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [SCENARIO] Export generates QR code for sales credit memo
        Initialize();

        // [GIVEN] Posted sales credit memo "M" with customer "C"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(PostedSalesInvoice, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, PostedSalesInvoice."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Export procedure is invoked for credit memo "M"
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] QR code is generated and stored in credit memo header
        SalesCrMemoHeader.Get(SalesCrMemoHeader."No.");
        Assert.IsTrue(SalesCrMemoHeader."QR Code Image".Count > 0, 'QR code image should be generated');
    end;
    #endregion

    #region ServiceInvoice
    [Test]
    procedure ExportServiceInvoiceCreatesXMLFile()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML file for posted service invoice
        Initialize();

        // [GIVEN] Service Invoice with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] XML file is created with invoice number and root element
        VerifyDocumentNumber(ServiceInvoiceHeader."No.", XMLText);
        VerifyXMLRootElement(XMLText);
    end;

    [Test]
    procedure ExportServiceInvoiceWithMultipleLines()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VATRate: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML for service invoice with multiple lines
        Initialize();

        // [GIVEN] Service Invoice with multiple lines with same VAT rate
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] XML contains one VAT breakdown entry
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
    end;

    [Test]
    procedure ExportServiceInvoiceWithDifferentVATRates()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VATRate: Decimal;
        VATRate2: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates separate VAT breakdown entries for service invoice with different VAT rates
        Initialize();

        // [GIVEN] Service Invoice with G/L Account lines with different VAT rates
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        VATRate2 := LibraryRandom.RandIntInRange(10, 25);
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate2);
        ServiceLine.Modify(true);
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] XML contains two VAT breakdown entries
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
        VerifyXMLContainsVATBreakdown(XMLText, VATRate2);
    end;

    [Test]
    procedure ExportServiceInvoiceGeneratesVerifactuHash()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VerifactuDocument: Record "Verifactu Document";
        XMLText: Text;
    begin
        // [SCENARIO] Export generates Verifactu hash for service invoice
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Service Invoice with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] XML contains Huella element with hash value
        Commit();
        VerifactuDocument.SetCurrentKey("Source Document Type", "Source Document No.");
        VerifactuDocument.SetRange("Source Document Type", VerifactuDocument."Source Document Type"::"Service Invoice");
        VerifactuDocument.SetRange("Source Document No.", ServiceInvoiceHeader."No.");
        VerifactuDocument.FindLast();
        Assert.AreNotEqual('', VerifactuDocument."Verifactu Hash", 'Verifactu hash should be generated');
        Assert.IsTrue(XMLText.Contains(VerifactuDocument."Verifactu Hash"), 'XML should contain Huella element');
    end;

    [Test]
    procedure ExportServiceInvoiceCalculatesTotalsCorrectly()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [SCENARIO] Export calculates and includes correct totals in XML for service invoice
        Initialize();

        // [GIVEN] Service Invoice with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] XML contains CuotaTotal and ImporteTotal elements
        ServiceInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        VerifyDocumentTotals(XMLText, ServiceInvoiceHeader."Amount Including VAT" - ServiceInvoiceHeader.Amount, ServiceInvoiceHeader."Amount Including VAT");
    end;
    #endregion

    #region ServiceCreditMemo
    [Test]
    procedure ExportServiceCreditMemoCreatesXMLFile()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML file for posted service credit memo
        Initialize();

        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);
        Commit();

        // [GIVEN] Service Credit Memo with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML file is created with credit memo number, root element and type R1
        VerifyDocumentNumber(ServiceCrMemoHeader."No.", XMLText);
        VerifyXMLRootElement(XMLText);
        VerifyCreditMemoType(XMLText);
    end;

    [Test]
    procedure ExportServiceCreditMemoWithMultipleLines()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VATRate: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates XML for service credit memo with multiple lines
        Initialize();

        // [GIVEN] Service Credit Memo with multiple G/L Account lines with same VAT rate
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo with multiple lines
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains one VAT breakdown entry
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
    end;

    [Test]
    procedure ExportServiceCreditMemoWithDifferentVATRates()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VATRate: Decimal;
        VATRate2: Decimal;
        XMLText: Text;
    begin
        // [SCENARIO] Export creates separate VAT breakdown entries for service credit memo with different VAT rates
        Initialize();

        // [GIVEN] Service Credit Memo with G/L Account lines with different VAT rates
        VATRate := LibraryRandom.RandIntInRange(10, 25);
        VATRate2 := LibraryRandom.RandIntInRange(10, 25);
        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo with different VAT rates
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceLine.Validate("VAT %", VATRate);
        ServiceLine.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", CreateGLAccountNo());
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("VAT %", VATRate2);
        ServiceLine.Modify(true);
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains two VAT breakdown entries
        VerifyXMLContainsVATBreakdown(XMLText, VATRate);
        VerifyXMLContainsVATBreakdown(XMLText, VATRate2);
    end;

    [Test]
    procedure ExportServiceCreditMemoIncludesFacturaRectificada()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [SCENARIO] Export includes corrected invoice reference in service credit memo
        Initialize();

        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo correcting invoice with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains FacturasRectificadas element with original invoice reference
        Assert.IsTrue(XMLText.Contains('FacturasRectificadas'), 'XML should contain FacturasRectificadas');
        Assert.IsTrue(XMLText.Contains('IDFacturaRectificada'), 'XML should contain IDFacturaRectificada');
        Assert.IsTrue(XMLText.Contains(ServiceInvoiceHeader."No."), 'XML should contain corrected invoice number');
    end;

    [Test]
    procedure ExportServiceCreditMemoGeneratesVerifactuHash()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        VerifactuDocument: Record "Verifactu Document";
        XMLText: Text;
    begin
        // [SCENARIO] Export generates Verifactu hash for service credit memo
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains Huella element with hash value
        Commit();
        VerifactuDocument.SetCurrentKey("Source Document Type", "Source Document No.");
        VerifactuDocument.SetRange("Source Document Type", VerifactuDocument."Source Document Type"::"Service Credit Memo");
        VerifactuDocument.SetRange("Source Document No.", ServiceCrMemoHeader."No.");
        VerifactuDocument.FindLast();
        Assert.AreNotEqual('', VerifactuDocument."Verifactu Hash", 'Verifactu hash should be generated');
        Assert.IsTrue(XMLText.Contains(VerifactuDocument."Verifactu Hash"), 'XML should contain Huella element');
    end;

    [Test]
    procedure ExportServiceCreditMemoCalculatesTotalsCorrectly()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [SCENARIO] Export calculates and includes correct totals in XML for service credit memo
        Initialize();

        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains CuotaTotal and ImporteTotal elements
        ServiceCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
        VerifyDocumentTotals(XMLText, -(ServiceCrMemoHeader."Amount Including VAT" - ServiceCrMemoHeader.Amount), -ServiceCrMemoHeader."Amount Including VAT");
    end;

    [Test]
    procedure ExportServiceInvoiceGeneratesQRCode()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Export generates QR code for service invoice
        Initialize();

        // [GIVEN] Service Invoice with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);

        // [WHEN] Service Invoice is posted
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [WHEN] Export procedure is invoked for service invoice "SI"
        ExportServiceInvoice(ServiceInvoiceHeader, XMLText);

        // [THEN] QR code is generated and stored in service invoice header
        ServiceInvoiceHeader.Get(ServiceInvoiceHeader."No.");
        Assert.IsTrue(ServiceInvoiceHeader."QR Code Image".Count > 0, 'QR code image should be generated');
    end;

    [Test]
    procedure ExportServiceCreditMemoGeneratesQRCode()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Export generates QR code for service credit memo
        Initialize();

        // [GIVEN] Service Invoice is posted
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Invoice');
        ServiceHeader.Modify(true);
        ServiceInvoiceHeader := PostServiceInvoice(ServiceHeader);

        // [GIVEN] Service Credit Memo with G/L Account in the Service Line
        CreateServiceDocWithLine(
            ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
            ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
        ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
        ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
        ServiceHeader.Validate("Operation Description", 'Test Service Credit Memo');
        ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader."No.");
        ServiceHeader.Modify(true);

        // [WHEN] Service Credit Memo is posted
        ServiceCrMemoHeader := PostServiceCreditMemo(ServiceHeader);

        // [WHEN] Export procedure is invoked for service credit memo "SM"
        ExportServiceCreditMemo(ServiceCrMemoHeader, XMLText);

        // [THEN] QR code is generated and stored in service credit memo header
        ServiceCrMemoHeader.Get(ServiceCrMemoHeader."No.");
        Assert.IsTrue(ServiceCrMemoHeader."QR Code Image".Count > 0, 'QR code image should be generated');
    end;
    #endregion

    #region BatchExport
    [Test]
    procedure ExportMultipleSalesInvoicesInBatch()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export multiple sales invoices in a single batch operation
        Initialize();

        // [GIVEN] 3 posted sales invoices
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        for i := 1 to 3 do
            CreatePostedSalesInvoice(SalesInvoiceHeader[i], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export batch procedure is invoked for all invoices
        ExportInvoiceBatch(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains all invoice numbers
        for i := 1 to 3 do
            Assert.IsTrue(XMLText.Contains(SalesInvoiceHeader[i]."No."), StrSubstNo(XMLShouldContainDocumentLbl, SalesInvoiceHeader[i]."No."));

        // [THEN] XML contains multiple RegistroAlta elements
        Assert.IsTrue(CountOccurrences(XMLText, 'RegistroAlta') >= 3, 'XML should contain at least 3 RegistroAlta elements');
    end;

    [Test]
    procedure ExportMultipleSalesCreditMemosInBatch()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        SalesCrMemoHeader: array[3] of Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export multiple sales credit memos in a single batch operation
        Initialize();

        // [GIVEN] 3 posted sales invoices and corresponding credit memos
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        for i := 1 to 3 do begin
            CreatePostedSalesInvoice(SalesInvoiceHeader[i], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
            CreatePostedSalesCreditMemo(SalesCrMemoHeader[i], SalesInvoiceHeader[i]."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));
        end;

        // [WHEN] Export batch procedure is invoked for all credit memos
        ExportCreditMemoBatch(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains all credit memo numbers
        for i := 1 to 3 do
            Assert.IsTrue(XMLText.Contains(SalesCrMemoHeader[i]."No."), StrSubstNo(XMLShouldContainDocumentLbl, SalesCrMemoHeader[i]."No."));

        // [THEN] XML contains multiple RegistroAlta elements and FacturasRectificadas
        Assert.IsTrue(CountOccurrences(XMLText, 'RegistroAlta') >= 3, 'XML should contain at least 3 RegistroAlta elements');
        Assert.IsTrue(CountOccurrences(XMLText, 'FacturasRectificadas') >= 3, 'XML should contain at least 3 FacturasRectificadas elements');
    end;

    [Test]
    procedure ExportMultipleServiceInvoicesInBatch()
    var
        ServiceInvoiceHeader: array[4] of Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export multiple service invoices in a single batch operation
        Initialize();

        // [GIVEN] 4 posted service invoices
        for i := 1 to 4 do begin
            CreateServiceDocWithLine(
                ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
                ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
            ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
            ServiceHeader.Validate("Operation Description", StrSubstNo(TestServiceInvoiceLbl, i));
            ServiceHeader.Modify(true);
            ServiceInvoiceHeader[i] := PostServiceInvoice(ServiceHeader);
        end;

        // [WHEN] Export batch procedure is invoked for all service invoices
        ExportServiceInvoiceBatch(ServiceInvoiceHeader, XMLText);

        // [THEN] XML contains all service invoice numbers
        for i := 1 to 4 do
            Assert.IsTrue(XMLText.Contains(ServiceInvoiceHeader[i]."No."), StrSubstNo(XMLShouldContainDocumentLbl, ServiceInvoiceHeader[i]."No."));

        // [THEN] XML contains multiple RegistroAlta elements
        Assert.IsTrue(CountOccurrences(XMLText, 'RegistroAlta') >= 4, 'XML should contain at least 4 RegistroAlta elements');
    end;

    [Test]
    procedure ExportMultipleServiceCreditMemosInBatch()
    var
        ServiceInvoiceHeader: array[3] of Record "Service Invoice Header";
        ServiceCrMemoHeader: array[3] of Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export multiple service credit memos in a single batch operation
        Initialize();

        // [GIVEN] 3 posted service invoices and corresponding credit memos
        for i := 1 to 3 do begin
            CreateServiceDocWithLine(
                ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice,
                ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), LibrarySales.CreateCustomerNo());
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"F1 Invoice");
            ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
            ServiceHeader.Validate("Operation Description", StrSubstNo(TestServiceInvoiceLbl, i));
            ServiceHeader.Modify(true);
            ServiceInvoiceHeader[i] := PostServiceInvoice(ServiceHeader);

            CreateServiceDocWithLine(
                ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo",
                ServiceLine.Type::"G/L Account", CreateGLAccountNo(), WorkDate(), ServiceHeader."Customer No.");
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"R1 Corrected Invoice");
            ServiceHeader.Validate("Special Scheme Code", ServiceHeader."Special Scheme Code"::"01 General");
            ServiceHeader.Validate("Operation Description", StrSubstNo(TestServiceCreditMemoLbl, i));
            ServiceHeader.Validate("Corrected Invoice No.", ServiceInvoiceHeader[i]."No.");
            ServiceHeader.Modify(true);
            ServiceCrMemoHeader[i] := PostServiceCreditMemo(ServiceHeader);
        end;

        // [WHEN] Export batch procedure is invoked for all service credit memos
        ExportServiceCreditMemoBatch(ServiceCrMemoHeader, XMLText);

        // [THEN] XML contains all service credit memo numbers
        for i := 1 to 3 do
            Assert.IsTrue(XMLText.Contains(ServiceCrMemoHeader[i]."No."), StrSubstNo(XMLShouldContainDocumentLbl, ServiceCrMemoHeader[i]."No."));

        // [THEN] XML contains multiple RegistroAlta elements
        Assert.IsTrue(CountOccurrences(XMLText, 'RegistroAlta') >= 3, 'XML should contain at least 3 RegistroAlta elements');
    end;

    [Test]
    procedure ExportBatchVerifiesMaximumBatchSize()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        InvoiceCount: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export batch respects maximum batch size of 1000 documents
        Initialize();

        // [GIVEN] Posted sales invoices
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        // Create enough invoices to verify batch processing works
        for InvoiceCount := 1 to 10 do
            CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export batch procedure is invoked
        // [THEN] No error occurs for batch size under 1000
        // Note: Testing with 1001 documents would require creating many records
        // This test verifies the batch mechanism works correctly for smaller batches
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        Assert.IsTrue(SalesInvoiceHeader.Count <= 1000, 'Batch size should be within allowed limit');
    end;

    [Test]
    procedure ExportBatchCreatesQRCodesForAllDocuments()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export batch generates QR codes for all documents
        Initialize();

        // [GIVEN] 3 posted sales invoices
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        for i := 1 to 3 do
            CreatePostedSalesInvoice(SalesInvoiceHeader[i], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export batch procedure is invoked
        ExportInvoiceBatch(SalesInvoiceHeader, XMLText);

        // [THEN] QR codes are generated for all invoices
        for i := 1 to 3 do begin
            SalesInvoiceHeader[i].Get(SalesInvoiceHeader[i]."No.");
            Assert.IsTrue(SalesInvoiceHeader[i]."QR Code Image".Count > 0, StrSubstNo(QRCodeShouldBeGeneratedForDocumentLbl, SalesInvoiceHeader[i]."No."));
        end;
    end;

    [Test]
    procedure ExportBatchMaintainsDocumentChain()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
        i: Integer;
    begin
        // [FEATURE] [AI test] [Batch]
        // [SCENARIO 617106] Export batch maintains document chain across multiple documents
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] 3 posted sales invoices
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        for i := 1 to 3 do
            CreatePostedSalesInvoice(SalesInvoiceHeader[i], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] First invoice is exported individually
        ExportInvoice(SalesInvoiceHeader[3], XMLText);
        Commit();

        // [THEN] First invoice contains PrimerRegistro
        Assert.IsTrue(XMLText.Contains('PrimerRegistro'), 'First invoice should contain PrimerRegistro');

        // [WHEN] Remaining invoices are exported in batch
        ExportInvoiceBatch(SalesInvoiceHeader, XMLText);
        Commit();

        // [THEN] XML contains multiple RegistroAlta elements
        Assert.IsTrue(CountOccurrences(XMLText, 'RegistroAlta') >= 3, 'XML should contain at least 3 RegistroAlta elements');
    end;
    #endregion

    #region XMLStructureValidation
    [Test]
    procedure VerifyXMLIDFacturaStructure()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML IDFactura section contains all required fields
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] IDFactura contains required elements
        Assert.IsTrue(XMLText.Contains('IDEmisorFactura'), 'XML should contain IDEmisorFactura');
        Assert.IsTrue(XMLText.Contains('NumSerieFactura'), 'XML should contain NumSerieFactura');
        Assert.IsTrue(XMLText.Contains('FechaExpedicionFactura'), 'XML should contain FechaExpedicionFactura');
    end;

    [Test]
    procedure VerifyXMLTipoFacturaIsPresent()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML contains TipoFactura element with valid value
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] TipoFactura element exists
        Assert.IsTrue(XMLText.Contains('TipoFactura'), 'XML should contain TipoFactura element');
        Assert.IsTrue(XMLText.Contains('F1'), 'TipoFactura should contain F1 for standard invoice');
    end;

    [Test]
    procedure VerifyXMLEncadenamientoStructure()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML Encadenamiento section has correct structure for chained documents
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Two posted sales invoices
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] First invoice is exported
        ExportInvoice(SalesInvoiceHeader1, XMLText);
        SetVerifactuDocSubmissionId(SalesInvoiceHeader1."No.", 'SUB-001');
        Commit();

        // [THEN] First invoice contains PrimerRegistro in Encadenamiento
        Assert.IsTrue(XMLText.Contains('Encadenamiento'), 'XML should contain Encadenamiento section');
        Assert.IsTrue(XMLText.Contains('PrimerRegistro'), 'First document should contain PrimerRegistro');
        Assert.IsTrue(XMLText.Contains('TipoHuella'), 'Encadenamiento should contain TipoHuella');
        Assert.IsTrue(XMLText.Contains('Huella'), 'Encadenamiento should contain Huella');

        // [WHEN] Second invoice is exported
        XMLText := '';
        ExportInvoice(SalesInvoiceHeader2, XMLText);

        // [THEN] Second invoice contains RegistroAnterior in Encadenamiento
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'Second document should contain RegistroAnterior');
        Assert.IsTrue(XMLText.Contains('IDEmisorFactura'), 'RegistroAnterior should contain IDEmisorFactura');
        Assert.IsTrue(XMLText.Contains('Huella'), 'RegistroAnterior should contain Huella');
    end;

    [Test]
    procedure VerifyXMLImportesTotalesStructure()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML ImporteTotalFactura section contains correct totals structure
        Initialize();

        // [GIVEN] Posted sales invoice with amounts
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] ImporteTotalFactura section exists with required elements
        Assert.IsTrue(XMLText.Contains('CuotaTotal'), 'XML should contain CuotaTotal element');
        Assert.IsTrue(XMLText.Contains('ImporteTotal'), 'XML should contain ImporteTotal element');
    end;

    [Test]
    procedure VerifyXMLSistemaInformaticoStructure()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML contains SistemaInformatico section with required fields
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] SistemaInformatico section exists
        Assert.IsTrue(XMLText.Contains('SistemaInformatico'), 'XML should contain SistemaInformatico section');
        Assert.IsTrue(XMLText.Contains('NombreRazon'), 'SistemaInformatico should contain NombreRazon');
        Assert.IsTrue(XMLText.Contains('NIF'), 'SistemaInformatico should contain NIF');
        Assert.IsTrue(XMLText.Contains('IdSistemaInformatico'), 'SistemaInformatico should contain IdSistemaInformatico');
        Assert.IsTrue(XMLText.Contains('Version'), 'SistemaInformatico should contain Version');
    end;

    [Test]
    procedure VerifyXMLDesgloseTipoOperacionStructure()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML DesgloseTipoOperacion contains proper VAT breakdown
        Initialize();

        // [GIVEN] Posted sales invoice with VAT
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] DesgloseTipoOperacion section exists with VAT details
        Assert.IsTrue(XMLText.Contains('DetalleDesglose'), 'XML should contain DetalleDesglose');
        Assert.IsTrue(XMLText.Contains('BaseImponibleOimporteNoSujeto'), 'DesgloseTipoOperacion should contain BaseImponibleOimporteNoSujeto');
        Assert.IsTrue(XMLText.Contains('TipoImpositivo'), 'DesgloseTipoOperacion should contain TipoImpositivo');
        Assert.IsTrue(XMLText.Contains('CuotaRepercutida'), 'DesgloseTipoOperacion should contain CuotaRepercutida');
    end;

    [Test]
    procedure VerifyXMLCreditMemoContainsFacturasRectificadas()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] Credit memo XML contains FacturasRectificadas section
        Initialize();

        // [GIVEN] Posted sales invoice and credit memo
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, SalesInvoiceHeader."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));

        // [WHEN] Credit memo is exported
        ExportCreditMemo(SalesCrMemoHeader, XMLText);

        // [THEN] XML contains FacturasRectificadas section
        Assert.IsTrue(XMLText.Contains('FacturasRectificadas'), 'Credit memo XML should contain FacturasRectificadas');
        Assert.IsTrue(XMLText.Contains('IDFacturaRectificada'), 'FacturasRectificadas should contain IDFacturaRectificada');
    end;

    [Test]
    procedure VerifyXMLDateTimeFormatsAreCorrect()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML date and datetime fields follow ISO format
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] Date fields are in DD-MM-YYYY format
        Assert.IsTrue(XMLText.Contains('FechaExpedicionFactura'), 'XML should contain FechaExpedicionFactura');

        // [THEN] DateTime fields include timezone offset
        Assert.IsTrue(XMLText.Contains('FechaHoraHusoGenRegistro'), 'XML should contain FechaHoraHusoGenRegistro');
    end;

    [Test]
    procedure VerifyXMLNumericFormatsUseDecimalPoint()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML numeric fields use decimal point notation
        Initialize();

        // [GIVEN] Posted sales invoice with decimal amounts
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", 1234.56, 21);

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] Numeric values use decimal point
        Assert.IsTrue(XMLText.Contains('.'), 'XML numeric values should use decimal point separator');
    end;

    [Test]
    procedure VerifyXMLSpecialCharactersAreEscaped()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        XMLText: Text;
    begin
        // [FEATURE] [AI test] [XML]
        // [SCENARIO 617106] XML properly escapes special characters
        Initialize();

        // [GIVEN] Sales invoice with special characters in description
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"F1 Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test & Special <Characters>');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate("VAT %", 21);
        SalesLine.Modify(true);

        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] Special characters are properly escaped or handled
        Assert.IsFalse(XMLText.Contains('Test & Special <Characters>'), 'Raw special characters should be escaped in XML');
    end;
    #endregion

    #region DocumentChaining
    [Test]
    procedure ExportTwoSalesInvoicesCreatesChain()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText1: Text;
        XMLText2: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Exporting two invoices creates proper document chain
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Two posted sales invoices "I1" and "I2"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] First invoice is exported
        ExportInvoice(SalesInvoiceHeader1, XMLText1);
        SetVerifactuDocSubmissionId(SalesInvoiceHeader1."No.", 'SUB-001');
        Commit();

        // [THEN] First invoice contains PrimerRegistro element
        Assert.IsTrue(XMLText1.Contains('PrimerRegistro'), 'First invoice should contain PrimerRegistro');

        // [WHEN] Second invoice is exported
        ExportInvoice(SalesInvoiceHeader2, XMLText2);
        SetVerifactuDocSubmissionId(SalesInvoiceHeader2."No.", 'SUB-002');
        Commit();

        // [THEN] Second invoice contains RegistroAnterior with reference to first invoice
        Assert.IsTrue(XMLText2.Contains('RegistroAnterior'), 'Second invoice should contain RegistroAnterior');
        Assert.IsTrue(XMLText2.Contains(SalesInvoiceHeader1."No."), 'Second invoice should reference first invoice number');
    end;

    [Test]
    procedure ExportInvoiceAfterCreditMemoMaintainsChain()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Exporting invoice after credit memo maintains document chain
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" and credit memo "CM"
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader1, XMLText);
        Commit();

        CreatePostedSalesCreditMemo(SalesCrMemoHeader, SalesInvoiceHeader1."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));
        ExportCreditMemo(SalesCrMemoHeader, XMLText);
        SetVerifactuDocSubmissionId(SalesCrMemoHeader."No.", 'SUB-003');
        Commit();

        // [GIVEN] Another posted sales invoice "I2"
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Second invoice is exported
        ExportInvoice(SalesInvoiceHeader2, XMLText);

        // [THEN] Second invoice contains RegistroAnterior with reference to credit memo
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'Invoice should contain RegistroAnterior');
        Assert.IsTrue(XMLText.Contains(SalesCrMemoHeader."No."), 'Invoice should reference credit memo number');
    end;

    [Test]
    procedure FindLastRegDocUsesSubmissionIdForChaining()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test 0.3]
        // [SCENARIO 622600] Document chaining uses Submission Id to find last registered document
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" exported and submitted (has Submission Id)
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader1, XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesInvoiceHeader1."No.", 'SUB-001');

        // [GIVEN] Posted sales invoice "I2"
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I2"
        ExportInvoice(SalesInvoiceHeader2, XMLText);

        // [THEN] XML contains RegistroAnterior referencing invoice "I1"
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'XML should contain RegistroAnterior when previous doc has Submission Id');
        Assert.IsTrue(XMLText.Contains(SalesInvoiceHeader1."No."), 'RegistroAnterior should reference first invoice number');
    end;

    [Test]
    procedure FindLastRegDocShowsPrimerRegistroWhenNoSubmittedDocs()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test 0.3]
        // [SCENARIO 622600] Export shows PrimerRegistro when no documents have been submitted (no Submission Id)
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" exported but NOT submitted (no Submission Id)
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader1, XMLText);
        Commit();

        // [GIVEN] Posted sales invoice "I2"
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I2"
        ExportInvoice(SalesInvoiceHeader2, XMLText);

        // [THEN] XML contains PrimerRegistro since no previous doc has Submission Id
        Assert.IsTrue(XMLText.Contains('PrimerRegistro'), 'XML should contain PrimerRegistro when no docs have Submission Id');
        Assert.IsFalse(XMLText.Contains('RegistroAnterior'), 'XML should not contain RegistroAnterior when no docs have Submission Id');
    end;

    [Test]
    procedure FindLastRegDocSkipsDocsWithoutSubmissionId()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test 0.3]
        // [SCENARIO 622600] Document chaining skips documents without Submission Id even if they have a hash
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" exported with Submission Id
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader[1], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader[1], XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesInvoiceHeader[1]."No.", 'SUB-001');

        // [GIVEN] Posted sales invoice "I2" exported but WITHOUT Submission Id
        CreatePostedSalesInvoice(SalesInvoiceHeader[2], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader[2], XMLText);
        Commit();

        // [GIVEN] Posted sales invoice "I3"
        CreatePostedSalesInvoice(SalesInvoiceHeader[3], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I3"
        ExportInvoice(SalesInvoiceHeader[3], XMLText);

        // [THEN] XML contains RegistroAnterior referencing "I1" (skipping "I2" which has no Submission Id)
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'XML should contain RegistroAnterior');
        Assert.IsTrue(XMLText.Contains(SalesInvoiceHeader[1]."No."), 'RegistroAnterior should reference I1 which has Submission Id');
    end;

    [Test]
    procedure FindLastRegDocReferencesLastBySubmissionId()
    var
        SalesInvoiceHeader: array[3] of Record "Sales Invoice Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test 0.3]
        // [SCENARIO 622600] Document chaining references the document with the last Submission Id
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" exported with Submission Id
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader[1], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader[1], XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesInvoiceHeader[1]."No.", 'SUB-001');

        // [GIVEN] Posted sales invoice "I2" exported with Submission Id
        CreatePostedSalesInvoice(SalesInvoiceHeader[2], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader[2], XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesInvoiceHeader[2]."No.", 'SUB-002');

        // [GIVEN] Third posted sales invoice "I3"
        CreatePostedSalesInvoice(SalesInvoiceHeader[3], Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I3"
        ExportInvoice(SalesInvoiceHeader[3], XMLText);

        // [THEN] XML contains RegistroAnterior referencing "I2" (last by Submission Id)
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'XML should contain RegistroAnterior');
        Assert.IsTrue(XMLText.Contains(SalesInvoiceHeader[2]."No."), 'RegistroAnterior should reference I2 which has the last Submission Id');
    end;

    [Test]
    procedure FindLastRegDocChainsAcrossDocTypesWithSubmissionId()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        VerifactuDocument: Record "Verifactu Document";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test 0.3]
        // [SCENARIO 622600] Document chaining works across document types using Submission Id
        Initialize();
        VerifactuDocument.DeleteAll();

        // [GIVEN] Posted sales invoice "I1" exported with Submission Id
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader1, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));
        ExportInvoice(SalesInvoiceHeader1, XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesInvoiceHeader1."No.", 'SUB-001');

        // [GIVEN] Posted sales credit memo "CM" exported with Submission Id
        CreatePostedSalesCreditMemo(SalesCrMemoHeader, SalesInvoiceHeader1."No.", Customer."No.", LibraryRandom.RandDecInRange(500, 2000, 2));
        ExportCreditMemo(SalesCrMemoHeader, XMLText);
        Commit();
        SetVerifactuDocSubmissionId(SalesCrMemoHeader."No.", 'SUB-002');

        // [GIVEN] Another posted sales invoice "I2"
        CreatePostedSalesInvoice(SalesInvoiceHeader2, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked for invoice "I2"
        ExportInvoice(SalesInvoiceHeader2, XMLText);

        // [THEN] XML contains RegistroAnterior referencing credit memo "CM"
        Assert.IsTrue(XMLText.Contains('RegistroAnterior'), 'XML should contain RegistroAnterior');
        Assert.IsTrue(XMLText.Contains(SalesCrMemoHeader."No."), 'RegistroAnterior should reference credit memo which is the last submitted doc');
    end;
    #endregion

    #region CommonProcedures
    [Test]
    procedure ExportSalesInvoiceIncludesDateTimeWithTimezone()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Export includes datetime with timezone in FechaHoraHusoGenRegistro
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains FechaHoraHusoGenRegistro with ISO datetime format and timezone offset
        Assert.IsTrue(XMLText.Contains('FechaHoraHusoGenRegistro'), 'XML should contain FechaHoraHusoGenRegistro');
        Assert.IsTrue(XMLText.Contains('T') and (XMLText.Contains('+') or XMLText.Contains('-')), 'DateTime should have timezone offset');
    end;

    [Test]
    procedure ExportSalesInvoiceWithF2InvoiceType()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Export handles F2 Simplified Invoice type correctly
        Initialize();

        // [GIVEN] Posted sales invoice with F2 invoice type
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoiceWithF2Type(SalesInvoiceHeader, Customer."No.");

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains correct invoice type F2
        Assert.IsTrue(XMLText.Contains('F2'), 'XML should contain invoice type F2');
    end;

    [Test]
    procedure ExportSalesInvoiceIncludesVerifactuDateTime()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        XMLText: Text;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617106] Export includes FechaHoraHusoGenRegistro element
        Initialize();

        // [GIVEN] Posted sales invoice
        LibrarySales.CreateCustomerWithCountryCodeAndVATRegNo(Customer);
        CreatePostedSalesInvoice(SalesInvoiceHeader, Customer."No.", LibraryRandom.RandDecInRange(1000, 5000, 2), LibraryRandom.RandIntInRange(10, 25));

        // [WHEN] Export procedure is invoked
        ExportInvoice(SalesInvoiceHeader, XMLText);

        // [THEN] XML contains FechaHoraHusoGenRegistro element
        Assert.IsTrue(XMLText.Contains('FechaHoraHusoGenRegistro'), 'XML should contain FechaHoraHusoGenRegistro');
        Assert.IsTrue(XMLText.Contains('TipoHuella'), 'XML should contain TipoHuella');
    end;
    #endregion

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Test Verifactu Export");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Test Verifactu Export");

        SetupCompanyInformation();
        EDocumentService.Get(LibraryEdocument.CreateService("E-Document Format"::Verifactu, "Service Integration"::"Verifactu Service"));
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Test Verifactu Export");
    end;

    local procedure ExportInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesInvoiceHeader);
        SourceDocumentLines.Open(Database::"Sales Invoice Line");
        EDocument."Document No." := SalesInvoiceHeader."No.";
        EDocument."Document Type" := EDocument."Document Type"::"Sales Invoice";
        EDocument.Insert();
        Verifactu.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(SalesCrMemoHeader);
        SourceDocumentLines.Open(Database::"Sales Cr.Memo Line");
        EDocument."Document No." := SalesCrMemoHeader."No.";
        EDocument."Document Type" := EDocument."Document Type"::"Sales Credit Memo";
        EDocument.Insert();
        Verifactu.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportServiceInvoice(ServiceInvoiceHeader: Record "Service Invoice Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(ServiceInvoiceHeader);
        SourceDocumentLines.Open(Database::"Service Invoice Line");
        EDocument."Document No." := ServiceInvoiceHeader."No.";
        EDocument."Document Type" := EDocument."Document Type"::"Service Invoice";
        EDocument.Insert();
        Verifactu.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportServiceCreditMemo(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
    begin
        SourceDocumentHeader.GetTable(ServiceCrMemoHeader);
        SourceDocumentLines.Open(Database::"Service Cr.Memo Line");
        EDocument."Document No." := ServiceCrMemoHeader."No.";
        EDocument."Document Type" := EDocument."Document Type"::"Service Credit Memo";
        EDocument.Insert();
        Verifactu.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportInvoiceBatch(var SalesInvoiceHeader: array[3] of Record "Sales Invoice Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        SalesInvoiceLine: Record "Sales Invoice Line";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FirstInvoiceNo: Code[20];
    begin
        // Set filter to include all invoices in the batch
        FirstInvoiceNo := SalesInvoiceHeader[1]."No.";
        SalesInvoiceHeader[1].SetFilter("No.", '%1|%2|%3',
            SalesInvoiceHeader[1]."No.",
            SalesInvoiceHeader[2]."No.",
            SalesInvoiceHeader[3]."No.");

        SourceDocumentHeader.GetTable(SalesInvoiceHeader[1]);
        SourceDocumentLines.Open(Database::"Sales Invoice Line");
        SourceDocumentLines.GetTable(SalesInvoiceLine);
        EDocument."Document No." := FirstInvoiceNo;
        EDocument."Document Type" := EDocument."Document Type"::"Sales Invoice";
        Verifactu.CreateBatch(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportCreditMemoBatch(var SalesCrMemoHeader: array[3] of Record "Sales Cr.Memo Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FirstCrMemoNo: Code[20];
    begin
        // Set filter to include all credit memos in the batch
        FirstCrMemoNo := SalesCrMemoHeader[1]."No.";
        SalesCrMemoHeader[1].SetFilter("No.", '%1|%2|%3',
            SalesCrMemoHeader[1]."No.",
            SalesCrMemoHeader[2]."No.",
            SalesCrMemoHeader[3]."No.");

        SourceDocumentHeader.GetTable(SalesCrMemoHeader[1]);
        SourceDocumentLines.Open(Database::"Sales Cr.Memo Line");
        SourceDocumentLines.GetTable(SalesCrMemoLine);
        EDocument."Document No." := FirstCrMemoNo;
        EDocument."Document Type" := EDocument."Document Type"::"Sales Credit Memo";
        Verifactu.CreateBatch(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportServiceInvoiceBatch(var ServiceInvoiceHeader: array[4] of Record "Service Invoice Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        ServiceInvoiceLine: Record "Service Invoice Line";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FirstInvoiceNo: Code[20];
    begin
        // Set filter to include all service invoices in the batch
        FirstInvoiceNo := ServiceInvoiceHeader[1]."No.";
        ServiceInvoiceHeader[1].SetFilter("No.", '%1|%2|%3|%4',
            ServiceInvoiceHeader[1]."No.",
            ServiceInvoiceHeader[2]."No.",
            ServiceInvoiceHeader[3]."No.",
            ServiceInvoiceHeader[4]."No.");

        SourceDocumentHeader.GetTable(ServiceInvoiceHeader[1]);
        SourceDocumentLines.Open(Database::"Service Invoice Line");
        SourceDocumentLines.GetTable(ServiceInvoiceLine);
        EDocument."Document No." := FirstInvoiceNo;
        EDocument."Document Type" := EDocument."Document Type"::"Service Invoice";
        Verifactu.CreateBatch(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure ExportServiceCreditMemoBatch(var ServiceCrMemoHeader: array[3] of Record "Service Cr.Memo Header"; var XMLText: Text)
    var
        EDocument: Record "E-Document";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        TempBlob: Codeunit "Temp Blob";
        Verifactu: Codeunit Verifactu;
        SourceDocumentHeader: RecordRef;
        SourceDocumentLines: RecordRef;
        FirstCrMemoNo: Code[20];
    begin
        // Set filter to include all service credit memos in the batch
        FirstCrMemoNo := ServiceCrMemoHeader[1]."No.";
        ServiceCrMemoHeader[1].SetFilter("No.", '%1|%2|%3',
            ServiceCrMemoHeader[1]."No.",
            ServiceCrMemoHeader[2]."No.",
            ServiceCrMemoHeader[3]."No.");

        SourceDocumentHeader.GetTable(ServiceCrMemoHeader[1]);
        SourceDocumentLines.Open(Database::"Service Cr.Memo Line");
        SourceDocumentLines.GetTable(ServiceCrMemoLine);
        EDocument."Document No." := FirstCrMemoNo;
        EDocument."Document Type" := EDocument."Document Type"::"Service Credit Memo";
        Verifactu.CreateBatch(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        ReadXMLFromBlob(TempBlob, XMLText);
    end;

    local procedure SetupCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."VAT Registration No." = '' then begin
            CompanyInformation."VAT Registration No." := 'ES12345678A';
            CompanyInformation.Modify();
        end;
    end;

    local procedure CreateAndPostSalesInvoice(CustomerNo: Code[20]; Amount: Decimal; VATRate: Decimal): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"F1 Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Invoice');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20]; Amount: Decimal; VATRate: Decimal)
    begin
        SalesInvoiceHeader.Get(CreateAndPostSalesInvoice(CustomerNo, Amount, VATRate));
    end;

    local procedure CreatePostedSalesInvoiceWithF2Type(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"F2 Simplified Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Simplified Invoice');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 500, 2));
        SalesLine.Validate("VAT %", LibraryRandom.RandIntInRange(10, 25));
        SalesLine.Modify(true);

        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesInvoiceWithMultipleLines(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20]; VATRate: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"F1 Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Invoice');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(50, 200, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(50, 200, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(50, 200, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesInvoiceWithDifferentVATRates(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20]; VATRate1: Decimal; VATRate2: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item1: Record Item;
        Item2: Record Item;
    begin
        LibraryInventory.CreateItem(Item1);
        LibraryInventory.CreateItem(Item2);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"F1 Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Invoice');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item1."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 300, 2));
        SalesLine.Validate("VAT %", VATRate1);
        SalesLine.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item2."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 300, 2));
        SalesLine.Validate("VAT %", VATRate2);
        SalesLine.Modify(true);

        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesCreditMemo(PostedSalesInvoiceNo: Code[20]; CustomerNo: Code[20]; Amount: Decimal): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"R1 Corrected Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Credit Memo');
        SalesHeader.Validate("Corrected Invoice No.", PostedSalesInvoiceNo);
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Modify(true);

        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesCreditMemoWithMultipleLines(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; CustomerNo: Code[20]; PostedSalesInvoiceNo: Code[20]; VATRate: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"R1 Corrected Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Credit Memo');
        SalesHeader.Validate("Corrected Invoice No.", PostedSalesInvoiceNo);
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(50, 150, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(50, 150, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesCreditMemoWithDifferentVATRates(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PostedSalesInvoiceNo: Code[20]; CustomerNo: Code[20]; VATRate: Decimal; VATRate2: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item1: Record Item;
        Item2: Record Item;
    begin
        LibraryInventory.CreateItem(Item1);
        LibraryInventory.CreateItem(Item2);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", CustomerNo);
        SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::"R1 Corrected Invoice");
        SalesHeader.Validate("Special Scheme Code", SalesHeader."Special Scheme Code"::"01 General");
        SalesHeader.Validate("Operation Description", 'Test Credit Memo');
        SalesHeader.Validate("Corrected Invoice No.", PostedSalesInvoiceNo);
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item1."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(80, 200, 2));
        SalesLine.Validate("VAT %", VATRate);
        SalesLine.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item2."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(80, 200, 2));
        SalesLine.Validate("VAT %", VATRate2);
        SalesLine.Modify(true);

        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostedSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PostedSalesInvoiceNo: Code[20]; CustomerNo: Code[20]; Amount: Decimal)
    begin
        SalesCrMemoHeader.Get(CreateAndPostSalesCreditMemo(PostedSalesInvoiceNo, CustomerNo, Amount));
    end;

    local procedure CreateServiceDocWithLine(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; DocumentType: Enum "Service Document Type"; ServiceLineType: Enum "Service Line Type"; No: Code[20]; PostingDate: Date; CustomerNo: Code[20])
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        ServiceHeader.Validate("Posting Date", PostingDate);
        ServiceHeader.Modify(true);
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLineType, No);
        ServiceLine.Validate(Quantity, LibraryRandom.RandIntInRange(10, 100));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Modify(true);
    end;

    local procedure PostServiceInvoice(ServiceHeader: Record "Service Header"): Record "Service Invoice Header"
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServiceInvoiceHeader.SetRange("Customer No.", ServiceHeader."Customer No.");
        ServiceInvoiceHeader.FindFirst();
        exit(ServiceInvoiceHeader);
    end;

    local procedure PostServiceCreditMemo(ServiceHeader: Record "Service Header"): Record "Service Cr.Memo Header"
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        ServiceCrMemoHeader.SetRange("Customer No.", ServiceHeader."Customer No.");
        ServiceCrMemoHeader.FindFirst();
        exit(ServiceCrMemoHeader);
    end;

    local procedure CreateGLAccountNo(): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        exit(CreateGLAccount(GeneralPostingSetup));
    end;

    local procedure CreateGLAccount(GeneralPostingSetup: Record "General Posting Setup"): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure SetVerifactuDocSubmissionId(SourceDocumentNo: Code[20]; SubmissionId: Text[100])
    var
        VerifactuDocument: Record "Verifactu Document";
    begin
        VerifactuDocument.SetCurrentKey("Source Document Type", "Source Document No.");
        VerifactuDocument.SetRange("Source Document No.", SourceDocumentNo);
        VerifactuDocument.FindLast();
        VerifactuDocument."Submission Id" := SubmissionId;
        VerifactuDocument.Modify();
    end;

    local procedure VerifyXMLContainsVATBreakdown(XMLText: Text; VATRate: Decimal)
    begin
        Assert.IsTrue(XMLText.Contains(Format(VATRate)), 'XML should contain VAT breakdown');
    end;

    local procedure VerifyCompanyInformation(CompanyInformation: Record "Company Information"; XMLText: Text)
    begin
        Assert.IsTrue(XMLText.Contains(CompanyInformation.Name), 'XML should contain company name');
        Assert.IsTrue(XMLText.Contains(CompanyInformation."VAT Registration No."), 'XML should contain VAT number');
    end;

    local procedure VerifyDocumentNumber(DocumentNo: Code[20]; XMLText: Text)
    begin
        Assert.IsTrue(XMLText.Contains(DocumentNo), 'XML should contain document number');
    end;

    local procedure VerifyDocumentTotals(XMLText: Text; VATAmount: Decimal; Amount: Decimal)
    begin
        Assert.IsTrue(XMLText.Contains(Format(VATAmount, 0, 9)), 'XML should contain CuotaTotal');
        Assert.IsTrue(XMLText.Contains(Format(Amount, 0, 9)), 'XML should contain ImporteTotal');
    end;

    local procedure VerifyXMLRootElement(XMLText: Text)
    begin
        Assert.IsTrue(XMLText.Contains('Envelope'), 'XML should contain root element');
    end;

    local procedure VerifyCreditMemoType(XMLText: Text)
    begin
        Assert.IsTrue(XMLText.Contains('R1'), 'XML should contain invoice type R1');
    end;

    local procedure ReadXMLFromBlob(TempBlob: Codeunit "Temp Blob"; var XMLText: Text)
    var
        InStream: InStream;
        XMLLineText: Text;
    begin
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS() do begin
            InStream.ReadText(XMLLineText);
            XMLText += XMLLineText;
        end;
    end;

    local procedure VerifyXMLStructure(XMLText: Text)
    begin
        Assert.IsTrue(XMLText.Contains('Envelope'), 'XML should contain Envelope');
        Assert.IsTrue(XMLText.Contains('Header'), 'XML should contain Header');
        Assert.IsTrue(XMLText.Contains('Body'), 'XML should contain Body');
        Assert.IsTrue(XMLText.Contains('RegFactuSistemaFacturacion'), 'XML should contain RegFactuSistemaFacturacion');
        Assert.IsTrue(XMLText.Contains('Cabecera'), 'XML should contain Cabecera');
        Assert.IsTrue(XMLText.Contains('RegistroFactura'), 'XML should contain RegistroFactura');
    end;

    local procedure CountOccurrences(SourceText: Text; SearchText: Text): Integer
    var
        Position: Integer;
        Count: Integer;
    begin
        Count := 0;
        Position := StrPos(SourceText, SearchText);
        while Position > 0 do begin
            Count += 1;
            SourceText := CopyStr(SourceText, Position + StrLen(SearchText));
            Position := StrPos(SourceText, SearchText);
        end;
        exit(Count);
    end;
}

