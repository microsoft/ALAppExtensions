// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.CRM.Team;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.IO;
using System.Utilities;

codeunit 13923 "PEPPOL BIS XML Document Tests"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun();
    begin
        // [FEATURE] [PEPPOL BIS 3.0 DE E-document]
    end;

    var
        CompanyInformation: Record "Company Information";
        EDocumentService: Record "E-Document Service";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryEdocument: Codeunit "Library - E-Document";
        Assert: Codeunit Assert;
        ExportPeppolBISFormat: Codeunit "EDoc PEPPOL BIS 3.0 DE";
        IncorrectValueErr: Label 'Incorrect value for %1', Comment = '%1 = Field or element name';
        IsInitialized: Boolean;

    #region SalesInvoice
    [Test]
    procedure ExportSalesInvSellerContactFromCompanyInfo()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales invoice in PEPPOL BIS 3.0 DE format with seller contact (BG-6) from company information when no salesperson is assigned
        Initialize();

        // [GIVEN] Sales Invoice "SI" without salesperson
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithoutSalesperson("Sales Document Type"::Invoice));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] Seller contact (BG-6) is populated from company information
        VerifySellerContactFromCompanyInfo(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact');
    end;

    [Test]
    procedure ExportSalesInvSellerContactFromSalesperson()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Salesperson: Record "Salesperson/Purchaser";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales invoice in PEPPOL BIS 3.0 DE format with seller contact (BG-6) from salesperson
        Initialize();

        // [GIVEN] Salesperson "S" with contact info
        CreateSalesperson(Salesperson);

        // [GIVEN] Sales Invoice "SI" with salesperson "S"
        SalesInvoiceHeader.Get(CreateAndPostSalesDocumentWithSalesperson("Sales Document Type"::Invoice, Salesperson.Code));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] Seller contact (BG-6) is populated from salesperson "S"
        VerifySellerContactFromSalesperson(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact', Salesperson);
    end;

    [Test]
    procedure ExportSalesInvSellerContactExists()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales invoice in PEPPOL BIS 3.0 DE format always contains seller contact element (DE-R-002 compliance)
        Initialize();

        // [GIVEN] Sales Invoice "SI"
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] Contact element exists under AccountingSupplierParty
        VerifySellerContactExists(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact');
    end;

    [Test]
    procedure ExportSalesInvEndpointIDSchemeIDPreserved()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales invoice in PEPPOL BIS 3.0 DE format preserves schemeID attribute on EndpointID elements (BR-62, BR-63)
        Initialize();

        // [GIVEN] Sales Invoice "SI"
        SalesInvoiceHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::Invoice));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportInvoice(SalesInvoiceHeader, TempXMLBuffer);

        // [THEN] Seller endpoint (BT-34) retains schemeID attribute
        Assert.AreNotEqual('', GetNodeByPath(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID'), StrSubstNo(IncorrectValueErr, 'BT-34 schemeID'));

        // [THEN] Buyer endpoint (BT-49) retains schemeID attribute
        Assert.AreNotEqual('', GetNodeByPath(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID'), StrSubstNo(IncorrectValueErr, 'BT-49 schemeID'));
    end;
    #endregion

    #region SalesCreditMemo
    [Test]
    procedure ExportSalesCrMemoSellerContactFromCompanyInfo()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales credit memo in PEPPOL BIS 3.0 DE format with seller contact (BG-6) from company information when no salesperson is assigned
        Initialize();

        // [GIVEN] Sales Credit Memo "SCM" without salesperson
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithoutSalesperson("Sales Document Type"::"Credit Memo"));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] Seller contact (BG-6) is populated from company information
        VerifySellerContactFromCompanyInfo(TempXMLBuffer, '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact');
    end;

    [Test]
    procedure ExportSalesCrMemoSellerContactFromSalesperson()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Salesperson: Record "Salesperson/Purchaser";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales credit memo in PEPPOL BIS 3.0 DE format with seller contact (BG-6) from salesperson
        Initialize();

        // [GIVEN] Salesperson "S" with contact info
        CreateSalesperson(Salesperson);

        // [GIVEN] Sales Credit Memo "SCM" with salesperson "S"
        SalesCrMemoHeader.Get(CreateAndPostSalesDocumentWithSalesperson("Sales Document Type"::"Credit Memo", Salesperson.Code));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] Seller contact (BG-6) is populated from salesperson "S"
        VerifySellerContactFromSalesperson(TempXMLBuffer, '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact', Salesperson);
    end;

    [Test]
    procedure ExportSalesCrMemoSellerContactExists()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales credit memo in PEPPOL BIS 3.0 DE format always contains seller contact element (DE-R-002 compliance)
        Initialize();

        // [GIVEN] Sales Credit Memo "SCM"
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo"));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] Contact element exists under AccountingSupplierParty
        VerifySellerContactExists(TempXMLBuffer, '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact');
    end;

    [Test]
    procedure ExportSalesCrMemoEndpointIDSchemeIDPreserved()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 622979] Export posted sales credit memo in PEPPOL BIS 3.0 DE format preserves schemeID attribute on EndpointID elements (BR-62, BR-63)
        Initialize();

        // [GIVEN] Sales Credit Memo "SCM"
        SalesCrMemoHeader.Get(CreateAndPostSalesDocument("Sales Document Type"::"Credit Memo"));

        // [WHEN] Export PEPPOL BIS 3.0 DE Electronic Document
        ExportCreditMemo(SalesCrMemoHeader, TempXMLBuffer);

        // [THEN] Seller endpoint (BT-34) retains schemeID attribute
        Assert.AreNotEqual('', GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID'), StrSubstNo(IncorrectValueErr, 'BT-34 schemeID'));

        // [THEN] Buyer endpoint (BT-49) retains schemeID attribute
        Assert.AreNotEqual('', GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID'), StrSubstNo(IncorrectValueErr, 'BT-49 schemeID'));
    end;
    #endregion

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"PEPPOL BIS XML Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"PEPPOL BIS XML Document Tests");
        IsInitialized := true;

        CompanyInformation.Get();
        CompanyInformation.IBAN := LibraryUtility.GenerateMOD97CompliantCode();
        CompanyInformation."SWIFT Code" := LibraryUtility.GenerateGUID();
        CompanyInformation."E-Mail" := LibraryUtility.GenerateRandomEmail();
        CompanyInformation."Contact Person" := CopyStr(LibraryUtility.GenerateRandomText(50), 1, 50);
        CompanyInformation."Phone No." := CopyStr(LibraryUtility.GenerateRandomText(20), 1, 20);
        CompanyInformation.Modify();

        EDocumentService.DeleteAll();
        EDocumentService.Get(LibraryEdocument.CreateService("E-Document Format"::"PEPPOL BIS 3.0 DE", "Service Integration"::"No Integration"));
        EDocumentService."Buyer Reference Mandatory" := true;
        EDocumentService."Buyer Reference" := "E-Document Buyer Reference"::"Your Reference";
        EDocumentService.Modify();
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"PEPPOL BIS XML Document Tests");
    end;

    local procedure CreateAndPostSalesDocument(DocumentType: Enum "Sales Document Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType));
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesDocumentWithoutSalesperson(DocumentType: Enum "Sales Document Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType));
        SalesHeader.Validate("Salesperson Code", '');
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostSalesDocumentWithSalesperson(DocumentType: Enum "Sales Document Type"; SalespersonCode: Code[20]): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(DocumentType, CreateSalesDocumentWithLine(DocumentType));
        SalesHeader.Validate("Salesperson Code", SalespersonCode);
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateSalesDocumentWithLine(DocumentType: Enum "Sales Document Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesHeader(SalesHeader, DocumentType);
        CreateSalesLine(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
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

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.DeleteAll();
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.Validate("VAT Registration No.", CompanyInformation."VAT Registration No.");
        Customer.Validate("E-Invoice Routing No.", LibraryUtility.GenerateRandomText(20));
        Customer.Validate("E-Mail", LibraryUtility.GenerateRandomEmail());
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        UnitOfMeasure."International Standard Code" := LibraryUtility.GenerateGUID();
        UnitOfMeasure.Modify(true);
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 5));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 5));
        SalesLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.Validate("Tax Category", LibraryRandom.RandText(2));
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesperson(var Salesperson: Record "Salesperson/Purchaser")
    begin
        Salesperson.Init();
        Salesperson.Validate(Code, LibraryUtility.GenerateRandomCode(Salesperson.FieldNo(Code), DATABASE::"Salesperson/Purchaser"));
        Salesperson.Validate(Name, CopyStr(LibraryUtility.GenerateRandomText(50), 1, 50));
        Salesperson.Validate("Phone No.", CopyStr(LibraryUtility.GenerateRandomText(20), 1, 20));
        Salesperson.Validate("E-Mail", LibraryUtility.GenerateRandomEmail());
        Salesperson.Insert(true);
    end;

    local procedure ExportInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
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
        EDocument."Document Type" := EDocument."Document Type"::"Sales Invoice";
        ExportPeppolBISFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlob.CreateInStream(FileInStream);
        TempXMLBuffer.LoadFromStream(FileInStream);
    end;

    local procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempXMLBuffer: Record "XML Buffer" temporary)
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
        EDocument."Document Type" := EDocument."Document Type"::"Sales Credit Memo";
        ExportPeppolBISFormat.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlob.CreateInStream(FileInStream);
        TempXMLBuffer.LoadFromStream(FileInStream);
    end;

    local procedure VerifySellerContactExists(var TempXMLBuffer: Record "XML Buffer" temporary; ContactPath: Text)
    var
        Path: Text;
    begin
        Path := ContactPath + '/cbc:Name';
        Assert.AreNotEqual('', GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySellerContactFromCompanyInfo(var TempXMLBuffer: Record "XML Buffer" temporary; ContactPath: Text)
    var
        Path: Text;
    begin
        Path := ContactPath + '/cbc:Name';
        Assert.AreEqual(CompanyInformation."Contact Person", GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ContactPath + '/cbc:Telephone';
        Assert.AreEqual(CompanyInformation."Phone No.", GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ContactPath + '/cbc:ElectronicMail';
        Assert.AreEqual(CompanyInformation."E-Mail", GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure VerifySellerContactFromSalesperson(var TempXMLBuffer: Record "XML Buffer" temporary; ContactPath: Text; Salesperson: Record "Salesperson/Purchaser")
    var
        Path: Text;
    begin
        Path := ContactPath + '/cbc:Name';
        Assert.AreEqual(Salesperson.Name, GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ContactPath + '/cbc:Telephone';
        Assert.AreEqual(Salesperson."Phone No.", GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
        Path := ContactPath + '/cbc:ElectronicMail';
        Assert.AreEqual(Salesperson."E-Mail", GetNodeByPath(TempXMLBuffer, Path), StrSubstNo(IncorrectValueErr, Path));
    end;

    local procedure GetNodeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Path, XPath);
        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.GetValue());
        exit('');
    end;
}
