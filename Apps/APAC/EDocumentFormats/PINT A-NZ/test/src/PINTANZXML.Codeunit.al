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
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Bank.Setup;

codeunit 148004 "PINT A-NZ XML"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        PINTANZ: Codeunit "PINT A-NZ";
        IsInitialized: Boolean;
        WrongValueForPathErr: Label 'Wrong value for path %1', Locked = true;

    [Test]
    procedure ExportInvoice_SellerNode()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with Seller data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Seller Data has been exported correctly
        CompanyInformation.Get();
        VerifySeller(TempXMLBuffer, CompanyInformation, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_BuyerNode_AU()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with Buyer data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer from Austalia exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Buyer Data has been exported correctly
        VerifyBuyer(TempXMLBuffer, Customer, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_BuyerNode_NZ()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with Buyer data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer from New Zealand exist
        CreateCustomer(Customer, 'NZ', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Buyer Data has been exported correctly
        VerifyBuyer(TempXMLBuffer, Customer, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_FileHeader()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with FileHeader data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] FileHeader Data has been exported correctly
        VerifyFileHeader(TempXMLBuffer, SalesInvoiceHeader, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_InvoiceHeader()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with Invoice header data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Invoice Header Node has been exported correctly
        VerifyInvoiceTotals(TempXMLBuffer, SalesInvoiceHeader, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_InvoiceLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with Invoices lines data
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", 1);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Invoice Lines Node has been exported correctly
        VerifyInvoiceLine(TempXMLBuffer, SalesInvoiceLine, '/Invoice');
    end;

    [Test]
    procedure ExportInvoice_MultipleInvoiceLines()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        TempXMLBuffer: Record "XML Buffer" temporary;
        NumberOfLines: Integer;
        VATRate: Decimal;
    begin
        // [SCENARIO 538637] Export invoice with alot of Invoice lines
        Initialize();

        // [GIVEN] VAT Posting Setup exists
        VATRate := LibraryRandom.RandDecInDecimalRange(5, 15, 2);
        CreateVATPostingSetup(VATPostingSetup, VATRate, 'S');

        // [GIVEN] Seller and buyer exist
        CreateCustomer(Customer, 'AU', VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Create invoice for customer
        NumberOfLines := LibraryRandom.RandIntInRange(5, 10);
        CreateAndPostSalesInvoiceWithExtraLines(SalesInvoiceHeader, SalesInvoiceLine, Customer, VATPostingSetup."VAT Prod. Posting Group", NumberOfLines);

        // [WHEN] Export invoice
        ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempXMLBuffer);

        // [THEN] Verify number of lines in the file
        VerifyNumberOfLines(TempXMLBuffer, '/Invoice', NumberOfLines);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"PINT A-NZ XML");
        if not IsInitialized then begin
            LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"PINT A-NZ XML");
            IsInitialized := true;
            UpdateCompanyInformation();
            LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"PINT A-NZ XML");
        end;
    end;

    local procedure AddLineToSalesHeader(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; VATProdPostingGroup: Code[20])
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        Item."VAT Prod. Posting Group" := VATProdPostingGroup;
        Item.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

    local procedure AddYourReferenceToSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."Your Reference" := LibraryUtility.GenerateGUID();
        SalesHeader.Modify();
    end;

    local procedure CreateAndPostSalesInvoiceWithExtraLines(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; Customer: Record "Customer"; VATProdPostingGroup: Code[20]; ExtraLines: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        CreateSalesInvoiceWithExtraLines(SalesHeader, SalesLine, Customer, VATProdPostingGroup, ExtraLines);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader, SalesInvoiceLine);
    end;

    local procedure CreateCustomer(var Customer: Record Customer; CountryCode: Code[2]; VATBusPostingGroup: Code[20])
    begin
        LibrarySales.CreateCustomerWithAddressAndContactInfo(Customer);
        Customer.Validate("Country/Region Code", CountryCode);
        Customer.Validate(City, LibraryUtility.GenerateGUID());
        Customer.Validate("Post Code", LibraryUtility.GenerateGUID());
        Customer."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CountryCode);
        Customer.GLN := CopyStr(LibraryUtility.GenerateRandomNumericText(13), 1, 13);
        Customer.ABN := CopyStr(LibraryUtility.GenerateRandomNumericText(11), 1, 11);
        Customer."VAT Bus. Posting Group" := VATBusPostingGroup;
        Customer.Modify();
    end;

    local procedure CreateSalesInvoiceWithExtraLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; Customer: Record "Customer"; VATProdPostingGroup: Code[20]; NumberOfLines: Integer)
    var
        i: Integer;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        AddYourReferenceToSalesHeader(SalesHeader);
        for i := 1 to NumberOfLines do
            AddLineToSalesHeader(SalesHeader, SalesLine, VATProdPostingGroup);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATRate: Decimal; TaxCategory: Text[10])
    begin
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", VATRate);
        VATPostingSetup."Tax Category" := TaxCategory;
        VATPostingSetup.Modify();
    end;

    local procedure PostSalesInvoice(SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, false, true));
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
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
        EDocument."Document Type" := EDocument."Document Type"::"Sales Invoice";
        PINTANZ.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        TempBlobToXMLBuffer(TempBlob, TempXMLBuffer);
    end;

    local procedure UpdateCompanyInformation()
    var
        SWIFTCode: Record "SWIFT Code";
        CompanyInformation: Record "Company Information";
    begin
        SWIFTCode.Init();
        SWIFTCode.Validate(Code, CopyStr(LibraryUtility.GenerateRandomCode(SWIFTCode.FieldNo(Code), DATABASE::"SWIFT Code"), 1, LibraryUtility.GetFieldLength(DATABASE::"SWIFT Code", SWIFTCode.FieldNo(Code))));
        SWIFTCode.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(SWIFTCode.Name)));
        SWIFTCode.Insert(true);

        CompanyInformation.Get();
        CompanyInformation."SWIFT Code" := SWIFTCode.Code;
        CompanyInformation.Modify();
    end;

    local procedure TempBlobToXMLBuffer(var TempBlob: Codeunit "Temp Blob"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);
    end;

    local procedure VerifySeller(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information"; DocumentPrefix: Text)
    var
        SellerPrefixTok: Label '/cac:AccountingSupplierParty/cac:Party', Locked = true;
        Path: Text;
    begin
        // VAT Reg No
        Path := DocumentPrefix + SellerPrefixTok + '/cac:PartyTaxScheme/cbc:CompanyID';
        Assert.AreEqual(CompanyInformation."Country/Region Code" + CompanyInformation."VAT Registration No.", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));

        // Seller Name
        Path := DocumentPrefix + SellerPrefixTok + '/cac:PartyName/cbc:Name';
        Assert.AreEqual(CompanyInformation.Name, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyBuyer(var TempXMLBuffer: Record "XML Buffer" temporary; Customer: Record "Customer"; DocumentPrefix: Text)
    var
        BuyerPrefixTok: Label '/cac:AccountingCustomerParty/cac:Party', Locked = true;
        Path: Text;
        ExpectedValue: Text;
    begin
        // Seller Name
        Path := DocumentPrefix + BuyerPrefixTok + '/cac:PartyName/cbc:Name';
        Assert.AreEqual(Customer.Name, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));

        // Country code
        Path := DocumentPrefix + BuyerPrefixTok + '/cac:PostalAddress/cac:Country/cbc:IdentificationCode';
        Assert.AreEqual(Customer."Country/Region Code", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));

        // GLN or ABN
        Path := DocumentPrefix + BuyerPrefixTok + '/cbc:EndpointID';
        if Customer."Country/Region Code" = 'AU' then
            ExpectedValue := Customer.ABN
        else
            ExpectedValue := Customer.GLN;
        Assert.AreEqual(ExpectedValue, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyFileHeader(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; DocumentPrefix: Text)
    var
        CustomizationIDTok: Label 'urn:peppol:pint:billing-1@aunz-1', Locked = true;
        ProfileIDTok: Label 'urn:peppol:bis:billing', Locked = true;
        Path: Text;
    begin
        // Customization ID
        Path := DocumentPrefix + '/cbc:CustomizationID';
        Assert.AreEqual(CustomizationIDTok, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));

        // Profile ID
        Path := DocumentPrefix + '/cbc:ProfileID';
        Assert.AreEqual(ProfileIDTok, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));

        // Buyer Reference
        Path := DocumentPrefix + '/cbc:BuyerReference';
        Assert.AreEqual(SalesInvoiceHeader."Your Reference", GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyInvoiceTotals(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; DocumentPrefix: Text)
    var
        Amount: Decimal;
        Path: Text;
    begin
        SalesInvoiceHeader.CalcFields("Amount Including VAT", Amount);

        // Total tax
        Path := DocumentPrefix + '/cac:TaxTotal/cbc:TaxAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader."Amount", Amount, StrSubstNo(WrongValueForPathErr, Path));

        // Total with tax
        Path := DocumentPrefix + '/cac:LegalMonetaryTotal/cbc:PayableAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount Including VAT", Amount, StrSubstNo(WrongValueForPathErr, Path));

        // Total without tax
        Path := DocumentPrefix + '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceHeader."Amount", Amount, StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyInvoiceLine(var TempXMLBuffer: Record "XML Buffer" temporary; SalesInvoiceLine: Record "Sales Invoice Line"; DocumentPrefix: Text)
    var
        LineTok: Label '/cac:InvoiceLine', Locked = true;
        Amount: Decimal;
        Path: Text;
    begin
        // Quantity
        Path := DocumentPrefix + LineTok + '/cbc:InvoicedQuantity';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine.Quantity, Amount, StrSubstNo(WrongValueForPathErr, Path));

        // Unit Price
        Path := DocumentPrefix + LineTok + '/cac:Price/cbc:PriceAmount';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine."Unit Price", Amount, StrSubstNo(WrongValueForPathErr, Path));

        // Tax percent
        Path := DocumentPrefix + LineTok + '/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent';
        Evaluate(Amount, GetNodeByPathWithError(TempXMLBuffer, Path));
        Assert.AreEqual(SalesInvoiceLine."VAT %", Amount, StrSubstNo(WrongValueForPathErr, Path));

        // Description
        Path := DocumentPrefix + LineTok + '/cac:Item/cbc:Name';
        Assert.AreEqual(SalesInvoiceLine.Description, GetNodeByPathWithError(TempXMLBuffer, Path), StrSubstNo(WrongValueForPathErr, Path));
    end;

    local procedure VerifyNumberOfLines(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentPrefix: Text; NumberOfLines: Integer)
    var
        InvoiceLineTok: Label '/cac:InvoiceLine', Locked = true;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, DocumentPrefix + InvoiceLineTok);
        Assert.RecordCount(TempXMLBuffer, NumberOfLines);
    end;
}