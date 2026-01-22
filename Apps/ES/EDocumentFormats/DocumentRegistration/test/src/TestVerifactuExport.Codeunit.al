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
        Verifactu.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
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
}

