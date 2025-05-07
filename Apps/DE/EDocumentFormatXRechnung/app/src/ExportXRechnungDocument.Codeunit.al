// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Attachment;
using System.Text;
using Microsoft.Finance.VAT.Setup;
using System.Utilities;
using System.Telemetry;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument;
using Microsoft.Foundation.UOM;
using Microsoft.Foundation.Address;
using Microsoft.Finance.Currency;
using System.IO;
using Microsoft.Sales.History;

codeunit 13916 "Export XRechnung Document"
{
    TableNo = "Record Export Buffer";
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EDocumentService: Record "E-Document Service";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'E-document XRechnung Format', Locked = true;
        StartEventNameTok: Label 'E-document XRechnung export started', Locked = true;
        EndEventNameTok: Label 'E-document XRechnung export completed', Locked = true;
        XmlNamespaceCBC: Text;
        XmlNamespaceCAC: Text;

    trigger OnRun();
    begin
        case Rec.RecordID.TableNo of
            Database::"Sales Invoice Header":
                ExportSalesInvoice(Rec);
            Database::"Sales Cr.Memo Header":
                ExportSalesCreditMemo(Rec);
        end;
    end;

    procedure ExportSalesInvoice(var Rec: Record "Record Export Buffer")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecordRef: RecordRef;
        FileOutStream: OutStream;
    begin
        FeatureTelemetry.LogUsage('0000EXD', FeatureNameTok, StartEventNameTok);
        RecordRef.Get(Rec.RecordID);
        RecordRef.SetTable(SalesInvoiceHeader);

        FindEDocumentService(Rec."Electronic Document Format");
        Rec."File Content".CreateOutStream(FileOutStream, TextEncoding::UTF8);
        CreateXML(SalesInvoiceHeader, FileOutStream);
        Rec.Modify();
        FeatureTelemetry.LogUsage('0000EXE', FeatureNameTok, EndEventNameTok);
    end;

    procedure ExportSalesCreditMemo(var Rec: Record "Record Export Buffer")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecordRef: RecordRef;
        FileOutStream: OutStream;
    begin
        FeatureTelemetry.LogUsage('0000EXF', FeatureNameTok, StartEventNameTok);
        RecordRef.Get(Rec.RecordID);
        RecordRef.SetTable(SalesCrMemoHeader);

        FindEDocumentService(Rec."Electronic Document Format");
        Rec."File Content".CreateOutStream(FileOutStream, TextEncoding::UTF8);
        CreateXML(SalesCrMemoHeader, FileOutStream);
        Rec.Modify();
        FeatureTelemetry.LogUsage('0000EXG', FeatureNameTok, EndEventNameTok);
    end;

    procedure CreateXML(SalesInvoiceHeader: Record "Sales Invoice Header"; var FileOutstream: Outstream)
    var
        Currency: Record "Currency";
        SalesInvLine: Record "Sales Invoice Line";
        RootXMLNode: XmlElement;
        XMLDoc: XmlDocument;
        XMLDocText: Text;
        CurrencyCode: Code[10];
        InvDiscountAmount: Decimal;
        LineAmounts: Dictionary of [Text, Decimal];
    begin
        GetSetups();
        if not DocumentLinesExist(SalesInvoiceHeader, SalesInvLine) then
            exit;

        CurrencyCode := GetCurrencyCode(SalesInvoiceHeader."Currency Code", Currency);

        XmlDocument.ReadFrom(GetInvoiceXMLHeader(), XMLDoc);
        XmlDoc.GetRoot(RootXMLNode);

        InitializeNamespaces();

        InsertHeaderData(RootXMLNode, SalesInvoiceHeader, CurrencyCode);
        InsertOrderReference(RootXMLNode, SalesInvoiceHeader);
        InsertAttachment(RootXMLNode, Database::"Sales Invoice Header", SalesInvoiceHeader."No.");
        CalculateLineAmounts(SalesInvoiceHeader, SalesInvLine, Currency, LineAmounts);
        InsertAccountingSupplierParty(RootXMLNode);
        InsertAccountingCustomerParty(RootXMLNode, SalesInvoiceHeader);
        InsertDelivery(RootXMLNode, SalesInvoiceHeader);
        InsertPaymentMeans(RootXMLNode, '68', 'PayeeFinancialAccount');
        InsertPaymentTerms(RootXMLNode, SalesInvoiceHeader."Payment Terms Code");
        InsertInvDiscountAllowanceCharge(LineAmounts, SalesInvLine, CurrencyCode, RootXMLNode, InvDiscountAmount);
        InsertTaxTotal(RootXMLNode, SalesInvLine, CurrencyCode, InvDiscountAmount);
        InsertLegalMonetaryTotal(RootXMLNode, SalesInvLine, LineAmounts, CurrencyCode);
        InsertInvoiceLine(RootXMLNode, SalesInvLine, Currency, CurrencyCode);
        OnCreateXMLOnBeforeSalesInvXmlDocumentWriteToFile(XMLDoc, SalesInvoiceHeader);
        XMLDoc.WriteTo(XMLDocText);
        FileOutstream.WriteText(XMLDocText);
        Clear(XMLDoc);
    end;

    procedure CreateXML(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FileOutstream: Outstream)
    var
        Currency: Record "Currency";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        RootXMLNode: XmlElement;
        XMLDoc: XmlDocument;
        XMLDocText: Text;
        CurrencyCode: Code[10];
        InvDiscountAmount: Decimal;
        LineAmounts: Dictionary of [Text, Decimal];
    begin
        GetSetups();
        if not DocumentLinesExist(SalesCrMemoHeader, SalesCrMemoLine) then
            exit;

        CurrencyCode := GetCurrencyCode(SalesCrMemoHeader."Currency Code", Currency);

        XmlDocument.ReadFrom(GetCrMemoXMLHeader(), XMLDoc);
        XmlDoc.GetRoot(RootXMLNode);

        InitializeNamespaces();

        InsertHeaderData(RootXMLNode, SalesCrMemoHeader, CurrencyCode);
        InsertOrderReference(RootXMLNode, SalesCrMemoHeader);
        InsertAttachment(RootXMLNode, Database::"Sales Cr.Memo Header", SalesCrMemoHeader."No.");
        CalculateLineAmounts(SalesCrMemoHeader, SalesCrMemoLine, Currency, LineAmounts);
        InsertAccountingSupplierParty(RootXMLNode);
        InsertAccountingCustomerParty(RootXMLNode, SalesCrMemoHeader);
        InsertDelivery(RootXMLNode, SalesCrMemoHeader);
        InsertPaymentMeans(RootXMLNode, '68', '');
        InsertPaymentTerms(RootXMLNode, SalesCrMemoHeader."Payment Terms Code");
        InsertInvDiscountAllowanceCharge(LineAmounts, SalesCrMemoLine, CurrencyCode, RootXMLNode, InvDiscountAmount);
        InsertTaxTotal(RootXMLNode, SalesCrMemoLine, CurrencyCode, InvDiscountAmount);
        InsertLegalMonetaryTotal(RootXMLNode, SalesCrMemoLine, LineAmounts, CurrencyCode);
        InsertCrMemoLine(RootXMLNode, SalesCrMemoLine, Currency, CurrencyCode);
        OnCreateXMLOnBeforeSalesCrMemoXmlDocumentWriteToFile(XMLDoc, SalesCrMemoHeader);
        XMLDoc.WriteTo(XMLDocText);
        FileOutstream.WriteText(XMLDocText);
        Clear(XMLDoc);
    end;

    local procedure GetInvoiceXMLHeader(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?>' +
        '<ubl:Invoice xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" ' +
        'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
        'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
        'xmlns:ccts="urn:un:unece:uncefact:documentation:2" ' +
        'xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" ' +
        'xmlns:udt="urn:un:unece:uncefact:data:speficiation:UnqualifiedDataTypesSchemaModule:2" />');
    end;

    local procedure GetCrMemoXMLHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?>' +
        '<ns0:CreditNote xmlns:ns0="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" ' +
        'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
        'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
        'xmlns:ccts="urn:un:unece:uncefact:documentation:2" ' +
        'xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" ' +
        'xmlns:udt="urn:un:unece:uncefact:data:speficiation:UnqualifiedDataTypesSchemaModule:2" />');
    end;

    local procedure InitializeNamespaces()
    begin
        XmlNamespaceCBC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        XmlNamespaceCAC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
    end;

    local procedure InsertHeaderData(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; CurrencyCode: Code[10])
    begin
        RootXMLNode.Add(XmlElement.Create('CustomizationID', XmlNamespaceCBC, 'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0'));
        RootXMLNode.Add(XmlElement.Create('ProfileID', XmlNamespaceCBC, 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0'));
        RootXMLNode.Add(XmlElement.Create('ID', XmlNamespaceCBC, SalesInvoiceHeader."No."));
        RootXMLNode.Add(XmlElement.Create('IssueDate', XmlNamespaceCBC, FormatDate(SalesInvoiceHeader."Posting Date")));
        if SalesInvoiceHeader."Due Date" <> CalcDate('<0D>') then
            RootXMLNode.Add(XmlElement.Create('DueDate', XmlNamespaceCBC, FormatDate(SalesInvoiceHeader."Due Date")));
        RootXMLNode.Add(XmlElement.Create('InvoiceTypeCode', XmlNamespaceCBC, '380'));
        RootXMLNode.Add(XmlElement.Create('DocumentCurrencyCode', XmlNamespaceCBC, CurrencyCode));
        InsertBuyerReference(RootXMLNode, SalesInvoiceHeader."Your Reference", SalesInvoiceHeader."Sell-to Customer No.");
        OnAfterInsertSalesInvHeaderData(RootXMLNode, SalesInvoiceHeader);
    end;

    local procedure InsertHeaderData(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; CurrencyCode: Code[10])
    begin
        RootXMLNode.Add(XmlElement.Create('CustomizationID', XmlNamespaceCBC, 'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0'));
        RootXMLNode.Add(XmlElement.Create('ProfileID', XmlNamespaceCBC, 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0'));
        RootXMLNode.Add(XmlElement.Create('ID', XmlNamespaceCBC, SalesCrMemoHeader."No."));
        RootXMLNode.Add(XmlElement.Create('IssueDate', XmlNamespaceCBC, FormatDate(SalesCrMemoHeader."Posting Date")));
        RootXMLNode.Add(XmlElement.Create('CreditNoteTypeCode', XmlNamespaceCBC, '381'));
        RootXMLNode.Add(XmlElement.Create('DocumentCurrencyCode', XmlNamespaceCBC, CurrencyCode));
        InsertBuyerReference(RootXMLNode, SalesCrMemoHeader."Your Reference", SalesCrMemoHeader."Sell-to Customer No.");
        OnAfterInsertSalesCrMemoHeaderData(RootXMLNode, SalesCrMemoHeader);
    end;

    local procedure InsertBuyerReference(var RootXMLNode: XmlElement; YourReference: Text[35]; SellToCustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        case EDocumentService."Buyer Reference" of
            EDocumentService."Buyer Reference"::"Customer Reference":
                begin
                    Customer.Get(SellToCustomerNo);
                    RootXMLNode.Add(XmlElement.Create('BuyerReference', XmlNamespaceCBC, Customer."E-Invoice Routing No."));
                end;
            EDocumentService."Buyer Reference"::"Your Reference":
                RootXMLNode.Add(XmlElement.Create('BuyerReference', XmlNamespaceCBC, YourReference));
        end;
    end;

    local procedure InsertInvDiscountAllowanceCharge(var LineAmounts: Dictionary of [Text, Decimal]; var SalesInvLine: Record "Sales Invoice Line"; CurrencyCode: Code[10]; var RootXMLNode: XmlElement; var InvDiscountAmount: Decimal)
    var
        BaseAmount: Decimal;
        InvDiscountPercent: Decimal;
    begin
        InvDiscountAmount := LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount"));
        if InvDiscountAmount = 0 then
            exit;
        InvDiscountPercent := GetInvoiceDiscountPercent(SalesInvLine, BaseAmount);
        InsertAllowanceCharge(
            RootXMLNode, 'Discount',
            GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"),
            InvDiscountAmount, BaseAmount,
            CurrencyCode, 0, InvDiscountPercent, true);
    end;

    local procedure InsertInvDiscountAllowanceCharge(var LineAmounts: Dictionary of [Text, Decimal]; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyCode: Code[10]; var RootXMLNode: XmlElement; var InvDiscountAmount: Decimal)
    var
        BaseAmount: Decimal;
        InvDiscountPercent: Decimal;
    begin
        InvDiscountAmount := LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount"));
        if InvDiscountAmount = 0 then
            exit;
        InvDiscountPercent := GetInvoiceDiscountPercent(SalesCrMemoLine, BaseAmount);
        InsertAllowanceCharge(
            RootXMLNode, 'Discount',
            GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"),
            InvDiscountAmount, BaseAmount,
            CurrencyCode, 0, InvDiscountPercent, true);
    end;

    local procedure InsertAccountingSupplierParty(var RootXMLNode: XmlElement)
    var
        AccountingSupplierPartyElement: XmlElement;
    begin
        AccountingSupplierPartyElement := XmlElement.Create('AccountingSupplierParty', XmlNamespaceCAC);
        InsertSupplierParty(AccountingSupplierPartyElement);
        RootXMLNode.Add(AccountingSupplierPartyElement);
    end;

    local procedure InsertDelivery(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DeliveryAddress: Record "Standard Address";
        DeliveryElement: XmlElement;
    begin
        DeliveryAddress.Address := SalesInvoiceHeader."Ship-to Address";
        DeliveryAddress."Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        DeliveryAddress.City := SalesInvoiceHeader."Ship-to City";
        DeliveryAddress."Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        DeliveryAddress."Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";

        DeliveryElement := XmlElement.Create('Delivery', XmlNamespaceCAC);

        if SalesInvoiceHeader."Shipment Date" <> CalcDate('<0D>') then
            DeliveryElement.Add(XmlElement.Create('ActualDeliveryDate', XmlNamespaceCBC, FormatDate(SalesInvoiceHeader."Shipment Date")));

        InsertDeliveryLocation(DeliveryElement, DeliveryAddress);

        RootXMLNode.Add(DeliveryElement);
    end;

    local procedure InsertDelivery(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        DeliveryAddress: Record "Standard Address";
        DeliveryElement: XmlElement;
    begin
        DeliveryAddress.Address := SalesCrMemoHeader."Ship-to Address";
        DeliveryAddress."Address 2" := SalesCrMemoHeader."Ship-to Address 2";
        DeliveryAddress.City := SalesCrMemoHeader."Ship-to City";
        DeliveryAddress."Post Code" := SalesCrMemoHeader."Ship-to Post Code";
        DeliveryAddress."Country/Region Code" := SalesCrMemoHeader."Ship-to Country/Region Code";

        DeliveryElement := XmlElement.Create('Delivery', XmlNamespaceCAC);

        if SalesCrMemoHeader."Shipment Date" <> CalcDate('<0D>') then
            DeliveryElement.Add(XmlElement.Create('ActualDeliveryDate', XmlNamespaceCBC, FormatDate(SalesCrMemoHeader."Shipment Date")));

        InsertDeliveryLocation(DeliveryElement, DeliveryAddress);

        RootXMLNode.Add(DeliveryElement);
    end;

    local procedure InsertDeliveryLocation(var DeliveryElement: XmlElement; DeliveryAddress: Record "Standard Address");
    var
        DeliveryLocationElement: XmlElement;
    begin
        DeliveryLocationElement := XmlElement.Create('DeliveryLocation', XmlNamespaceCAC);
        InsertAddress(DeliveryLocationElement, 'Address', DeliveryAddress);
        DeliveryElement.Add(DeliveryLocationElement);
    end;

    local procedure InsertAddress(var RootElement: XmlElement; ElementName: Text; Address: Record "Standard Address");
    var
        AddressElement: XmlElement;
    begin
        AddressElement := XmlElement.Create(ElementName, XmlNamespaceCAC);
        AddressElement.Add(XmlElement.Create('StreetName', XmlNamespaceCBC, Address.Address));
        if Address."Address 2" <> '' then
            AddressElement.Add(XmlElement.Create('AdditionalStreetName', XmlNamespaceCBC, Address."Address 2"));
        AddressElement.Add(XmlElement.Create('CityName', XmlNamespaceCBC, Address.City));
        AddressElement.Add(XmlElement.Create('PostalZone', XmlNamespaceCBC, Address."Post Code"));
        InsertCountry(AddressElement, GetCountryRegionCode(Address."Country/Region Code"));
        RootElement.Add(AddressElement);
    end;

    local procedure InsertCountry(var AddressElement: XmlElement; IdentificationCode: Text);
    var
        CountryElement: XmlElement;
    begin
        CountryElement := XmlElement.Create('Country', XmlNamespaceCAC);
        CountryElement.Add(XmlElement.Create('IdentificationCode', XmlNamespaceCBC, IdentificationCode));
        AddressElement.Add(CountryElement);
    end;

    local procedure InsertPaymentMeans(var RootXMLNode: XmlElement; PaymentMeansCode: Text[10]; PayeeFinancialAccount: Text[30])
    var
        PaymentMeansElement: XmlElement;
    begin
        if PaymentMeansCode = '' then
            exit;
        PaymentMeansElement := XmlElement.Create('PaymentMeans', XmlNamespaceCAC);
        PaymentMeansElement.Add(XmlElement.Create('PaymentMeansCode', XmlNamespaceCBC, PaymentMeansCode));
        if PayeeFinancialAccount <> '' then
            InsertPayeeFinancialAccount(PaymentMeansElement, PayeeFinancialAccount);
        RootXMLNode.Add(PaymentMeansElement);
    end;

    local procedure InsertPayeeFinancialAccount(var PaymentMeansElement: XmlElement; PayeeFinancialAccount: Text[30]);
    var
        PayeeFinancialAccountElement: XmlElement;
    begin
        PayeeFinancialAccountElement := XmlElement.Create(PayeeFinancialAccount, XmlNamespaceCAC);
        PayeeFinancialAccountElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, CompanyInformation."Bank Account No."));
        InsertFinancialInstitutionBranch(PayeeFinancialAccountElement);
        PaymentMeansElement.Add(PayeeFinancialAccountElement);
    end;

    local procedure InsertFinancialInstitutionBranch(var RootElement: XmlElement);
    var
        FinancialInstitutionBranchElement: XmlElement;
    begin
        FinancialInstitutionBranchElement := XmlElement.Create('FinancialInstitutionBranch', XmlNamespaceCAC);
        FinancialInstitutionBranchElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, CompanyInformation."Bank Branch No."));
        RootElement.Add(FinancialInstitutionBranchElement);
    end;

    local procedure InsertPaymentTerms(var RootXMLNode: XmlElement; PaymentTermsCode: Code[10])
    var
        PaymentTerms: Record "Payment Terms";
        PaymentTermsElement: XmlElement;
    begin
        if PaymentTermsCode = '' then
            exit;
        PaymentTermsElement := XmlElement.Create('PaymentTerms', XmlNamespaceCAC);
        if PaymentTerms.Get(PaymentTermsCode) then
            PaymentTermsElement.Add(XmlElement.Create('Note', XmlNamespaceCBC, PaymentTerms.Description));
        RootXMLNode.Add(PaymentTermsElement);
    end;

    local procedure InsertItem(var RootElement: XmlElement; var SalesInvLine: Record "Sales Invoice Line");
    var
        ItemElement: XmlElement;
    begin
        ItemElement := XmlElement.Create('Item', XmlNamespaceCAC);
        if SalesInvLine."Description 2" <> '' then
            ItemElement.Add(XmlElement.Create('Description', XmlNamespaceCBC, SalesInvLine."Description 2"));
        ItemElement.Add(XmlElement.Create('Name', XmlNamespaceCBC, CopyStr(SalesInvLine.Description, 1, 40)));
        InsertSellersItemIdentification(ItemElement, SalesInvLine."No.");
        InsertTaxCategory(ItemElement, 'ClassifiedTaxCategory', GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"), SalesInvLine."VAT %");
        RootElement.Add(ItemElement);
    end;

    local procedure InsertItem(var RootElement: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line");
    var
        ItemElement: XmlElement;
    begin
        ItemElement := XmlElement.Create('Item', XmlNamespaceCAC);
        if SalesCrMemoLine."Description 2" <> '' then
            ItemElement.Add(XmlElement.Create('Description', XmlNamespaceCBC, SalesCrMemoLine."Description 2"));
        ItemElement.Add(XmlElement.Create('Name', XmlNamespaceCBC, CopyStr(SalesCrMemoLine.Description, 1, 40)));
        InsertSellersItemIdentification(ItemElement, SalesCrMemoLine."No.");
        InsertTaxCategory(ItemElement, 'ClassifiedTaxCategory', GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"), SalesCrMemoLine."VAT %");
        RootElement.Add(ItemElement);
    end;

    local procedure InsertPrice(var RootElement: XmlElement; UnitPrice: Decimal; CurrencyCode: Code[10]);
    var
        PriceElement: XmlElement;
    begin
        PriceElement := XmlElement.Create('Price', XmlNamespaceCAC);
        PriceElement.Add(XmlElement.Create('PriceAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(UnitPrice)));
        RootElement.Add(PriceElement);
    end;

    local procedure InsertSellersItemIdentification(var ItemElement: XmlElement; ItemNo: Code[20]);
    var
        SellersItemIdElement: XmlElement;
    begin
        SellersItemIdElement := XmlElement.Create('SellersItemIdentification', XmlNamespaceCAC);
        SellersItemIdElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, ItemNo));
        ItemElement.Add(SellersItemIdElement);
    end;

    local procedure InsertPartyIdentification(var PartyElement: XmlElement; ID: Text);
    var
        PartyIdentificationElement: XmlElement;
    begin
        PartyIdentificationElement := XmlElement.Create('PartyIdentification', XmlNamespaceCAC);
        PartyIdentificationElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, ID));
        PartyElement.Add(PartyIdentificationElement);
    end;

    local procedure InsertPartyName(var PartyElement: XmlElement; Name: Text);
    var
        PartyNameElement: XmlElement;
    begin
        PartyNameElement := XmlElement.Create('PartyName', XmlNamespaceCAC);
        PartyNameElement.Add(XmlElement.Create('Name', XmlNamespaceCBC, Name));
        PartyElement.Add(PartyNameElement);
    end;

    local procedure InsertPartyTaxScheme(var PartyElement: XmlElement; VATRegistrationNo: Text[20]; CountryCode: Code[10]);
    var
        PartyTaxSchemeElement: XmlElement;
    begin
        PartyTaxSchemeElement := XmlElement.Create('PartyTaxScheme', XmlNamespaceCAC);
        PartyTaxSchemeElement.Add(XmlElement.Create('CompanyID', XmlNamespaceCBC, GetVATRegistrationNo(VATRegistrationNo, CountryCode)));
        InsertTaxScheme(PartyTaxSchemeElement);
        PartyElement.Add(PartyTaxSchemeElement);
    end;

    local procedure InsertTaxScheme(var RootElement: XmlElement)
    var
        TaxSchemeElement: XmlElement;
    begin
        TaxSchemeElement := XmlElement.Create('TaxScheme', XmlNamespaceCAC);
        TaxSchemeElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, 'VAT'));
        RootElement.Add(TaxSchemeElement);
    end;

    local procedure InsertPartyLegalEntity(var PartyElement: XmlElement);
    var
        PartyLegalEntityElement: XmlElement;
    begin
        PartyLegalEntityElement := XmlElement.Create('PartyLegalEntity', XmlNamespaceCAC);
        PartyLegalEntityElement.Add(XmlElement.Create('RegistrationName', XmlNamespaceCBC, CompanyInformation.Name));
        if CompanyInformation."Use GLN in Electronic Document" and (CompanyInformation.GLN <> '') then
            PartyLegalEntityElement.Add(XmlElement.Create('CompanyID', XmlNamespaceCBC, CompanyInformation.GLN))
        else
            PartyLegalEntityElement.Add(XmlElement.Create('CompanyID', XmlNamespaceCBC, GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code")));
        PartyElement.Add(PartyLegalEntityElement);
    end;

    local procedure InsertCustomerPartyLegalEntity(var PartyElement: XmlElement; CustomerName: Text[100]);
    var
        PartyLegalEntityElement: XmlElement;
    begin
        PartyLegalEntityElement := XmlElement.Create('PartyLegalEntity', XmlNamespaceCAC);
        PartyLegalEntityElement.Add(XmlElement.Create('RegistrationName', XmlNamespaceCBC, CustomerName));
        PartyElement.Add(PartyLegalEntityElement);
    end;

    local procedure InsertContact(var RootElement: XmlElement; ContactName: Text[100]; Email: Text[80]);
    var
        ContactElement: XmlElement;
    begin
        ContactElement := XmlElement.Create('Contact', XmlNamespaceCAC);
        ContactElement.Add(XmlElement.Create('Name', XmlNamespaceCBC, ContactName));
        if Email <> '' then
            ContactElement.Add(XmlElement.Create('ElectronicMail', XmlNamespaceCBC, Email));
        RootElement.Add(ContactElement);
    end;

    local procedure InsertContact(var RootElement: XmlElement);
    var
        ContactElement: XmlElement;
    begin
        ContactElement := XmlElement.Create('Contact', XmlNamespaceCAC);
        ContactElement.Add(XmlElement.Create('Name', XmlNamespaceCBC, CompanyInformation."Contact Person"));
        ContactElement.Add(XmlElement.Create('Telephone', XmlNamespaceCBC, CompanyInformation."Phone No."));
        ContactElement.Add(XmlElement.Create('ElectronicMail', XmlNamespaceCBC, CompanyInformation."E-Mail"));
        RootElement.Add(ContactElement);
    end;

    local procedure InsertSupplierParty(var AccountingSupplierPartyElement: XmlElement);
    var
        TempCompanyAddress: Record "Standard Address" temporary;
        PartyElement: XmlElement;
    begin
        PartyElement := XmlElement.Create('Party', XmlNamespaceCAC);

        PartyElement.Add(XmlElement.Create('EndpointID', XmlNamespaceCBC, XmlAttribute.Create('schemeID', 'EM'), CompanyInformation."E-Mail"));
        if CompanyInformation."Use GLN in Electronic Document" and (CompanyInformation.GLN <> '') then
            InsertPartyIdentification(PartyElement, CompanyInformation.GLN)
        else
            InsertPartyIdentification(PartyElement, GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code"));
        InsertPartyName(PartyElement, CompanyInformation.Name);
        TempCompanyAddress.CopyFromCompanyInformation(CompanyInformation);
        InsertAddress(PartyElement, 'PostalAddress', TempCompanyAddress);
        InsertPartyTaxScheme(PartyElement, CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code");
        InsertPartyLegalEntity(PartyElement);
        InsertContact(PartyElement);
        AccountingSupplierPartyElement.Add(PartyElement);
    end;

    local procedure InsertAccountingCustomerParty(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        BillToAddress: Record "Standard Address";
        Customer: Record Customer;
        CustomerGLN: Text[13];
        AccountingCustomerParty: XmlElement;
    begin
        BillToAddress.Address := SalesInvoiceHeader."Bill-to Address";
        BillToAddress."Address 2" := SalesInvoiceHeader."Bill-to Address 2";
        BillToAddress.City := SalesInvoiceHeader."Bill-to City";
        BillToAddress."Post Code" := SalesInvoiceHeader."Bill-to Post Code";
        BillToAddress."Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";

        if Customer.Get(SalesInvoiceHeader."Sell-to Customer No.") then;
        AccountingCustomerParty := XmlElement.Create('AccountingCustomerParty', XmlNamespaceCAC);
        if Customer."Use GLN in Electronic Document" then
            CustomerGLN := Customer.GLN;
        InsertCustomerParty(
            AccountingCustomerParty, Customer."VAT Registration No.", CustomerGLN,
            SalesInvoiceHeader."Bill-to Name", BillToAddress, SalesInvoiceHeader."Sell-to Customer Name",
            SalesInvoiceHeader."Sell-to Contact", SalesInvoiceHeader."Sell-to E-Mail");
        RootXMLNode.Add(AccountingCustomerParty);
    end;

    local procedure InsertAccountingCustomerParty(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        BillToAddress: Record "Standard Address";
        Customer: Record Customer;
        CustomerGLN: Text[13];
        AccountingCustomerParty: XmlElement;
    begin
        BillToAddress.Address := SalesCrMemoHeader."Bill-to Address";
        BillToAddress."Address 2" := SalesCrMemoHeader."Bill-to Address 2";
        BillToAddress.City := SalesCrMemoHeader."Bill-to City";
        BillToAddress."Post Code" := SalesCrMemoHeader."Bill-to Post Code";
        BillToAddress."Country/Region Code" := SalesCrMemoHeader."Bill-to Country/Region Code";

        if Customer.Get(SalesCrMemoHeader."Sell-to Customer No.") then;
        AccountingCustomerParty := XmlElement.Create('AccountingCustomerParty', XmlNamespaceCAC);
        if Customer."Use GLN in Electronic Document" then
            CustomerGLN := Customer.GLN;
        InsertCustomerParty(
            AccountingCustomerParty, Customer."VAT Registration No.", CustomerGLN,
            SalesCrMemoHeader."Bill-to Name", BillToAddress, SalesCrMemoHeader."Sell-to Customer Name",
            SalesCrMemoHeader."Sell-to Contact", SalesCrMemoHeader."Sell-to E-Mail");
        RootXMLNode.Add(AccountingCustomerParty);
    end;

    local procedure InsertCustomerParty(var AccountingCustomerParty: XmlElement; VATRegNo: Text[20]; CustomerGLN: Code[13]; PartyName: Text[100]; PostalAddress: Record "Standard Address"; CustomerName: Text[100]; ContactName: Text[100]; ContactEMail: Text[80]);
    var
        PartyElement: XmlElement;
    begin
        if ContactName = '' then
            ContactName := CustomerName;
        PartyElement := XmlElement.Create('Party', XmlNamespaceCAC);
        PartyElement.Add(XmlElement.Create('EndpointID', XmlNamespaceCBC, XmlAttribute.Create('schemeID', 'EM'), ContactEMail));
        if CustomerGLN <> '' then
            InsertPartyIdentification(PartyElement, CustomerGLN)
        else
            InsertPartyIdentification(PartyElement, GetVATRegistrationNo(VATRegNo, PostalAddress."Country/Region Code"));

        InsertPartyName(PartyElement, PartyName);
        InsertAddress(PartyElement, 'PostalAddress', PostalAddress);
        InsertPartyTaxScheme(PartyElement, VATRegNo, PostalAddress."Country/Region Code");
        InsertCustomerPartyLegalEntity(PartyElement, CustomerName);
        InsertContact(PartyElement, ContactName, ContactEMail);
        AccountingCustomerParty.Add(PartyElement);
    end;

    local procedure InsertTaxCategory(var RootElement: XmlElement; TaxCategory: Text; TaxCategoryID: Text; Percent: Decimal);
    var
        TaxCategoryElement: XmlElement;
    begin
        TaxCategoryElement := XmlElement.Create(TaxCategory, XmlNamespaceCAC);
        TaxCategoryElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, TaxCategoryID));
        TaxCategoryElement.Add(XmlElement.Create('Percent', XmlNamespaceCBC, FormatDecimal(Percent)));
        InsertTaxScheme(TaxCategoryElement);
        RootElement.Add(TaxCategoryElement);
    end;

    local procedure InsertAllowanceCharge(var RootXMLNode: XmlElement; AllowanceChargeReason: Text; TaxCategory: Text; Amount: Decimal; BaseAmount: Decimal; CurrencyCode: Code[10]; Percent: Decimal; MultiplierFactorNumeric: Decimal; InsertTaxCat: Boolean)
    var
        AllowanceChargeElement: XmlElement;
    begin
        AllowanceChargeElement := XmlElement.Create('AllowanceCharge', XmlNamespaceCAC);
        AllowanceChargeElement.Add(XmlElement.Create('ChargeIndicator', XmlNamespaceCBC, 'false'));
        AllowanceChargeElement.Add(XmlElement.Create('AllowanceChargeReason', XmlNamespaceCBC, AllowanceChargeReason));
        AllowanceChargeElement.Add(XmlElement.Create('MultiplierFactorNumeric', XmlNamespaceCBC, FormatDecimal(MultiplierFactorNumeric)));
        AllowanceChargeElement.Add(XmlElement.Create('Amount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(Amount)));
        AllowanceChargeElement.Add(XmlElement.Create('BaseAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(BaseAmount)));
        if InsertTaxCat then
            InsertTaxCategory(AllowanceChargeElement, 'TaxCategory', TaxCategory, Percent);
        RootXMLNode.Add(AllowanceChargeElement);
    end;

    local procedure InsertTaxSubtotal(var RootElement: XmlElement; TaxCategory: Code[10]; TaxableAmount: Decimal; TaxAmount: Decimal; VATPercentage: Decimal; CurrencyCode: Code[10]);
    var
        TaxSubtotalElement: XmlElement;
    begin
        TaxSubtotalElement := XmlElement.Create('TaxSubtotal', XmlNamespaceCAC);
        TaxSubtotalElement.Add(XmlElement.Create('TaxableAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(TaxableAmount)));
        TaxSubtotalElement.Add(XmlElement.Create('TaxAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(TaxAmount)));
        InsertTaxCategory(TaxSubtotalElement, 'TaxCategory', TaxCategory, VATPercentage);
        RootElement.Add(TaxSubtotalElement);
    end;

    procedure GetTaxCategoryID(TaxCategory: Code[10]; VATBusPostingGroup: Code[20]; VATProductPostingGroup: Code[20]): Text[10];
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if TaxCategory <> '' then
            exit(TaxCategory);
        if not VATPostingSetup.Get(VATBusPostingGroup, VATProductPostingGroup) then
            exit('');
        exit(VATPostingSetup."Tax Category");
    end;

    local procedure InsertTaxTotal(var RootXMLNode: XmlElement; var SalesInvLine: Record "Sales Invoice Line"; CurrencyCode: Code[10]; InvDiscountAmount: Decimal)
    var
        LineVATAmount: Dictionary of [Decimal, Decimal];
        LineAmount: Dictionary of [Decimal, Decimal];
        TaxTotalElement: XmlElement;
        SalesInvLineTotalAmount: Decimal;
    begin
        TaxTotalElement := XmlElement.Create('TaxTotal', XmlNamespaceCAC);
        TaxTotalElement.Add(XmlElement.Create('TaxAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(GetTotalTaxAmount(SalesInvLine))));

        InsertVATAmounts(SalesInvLine, LineVATAmount, LineAmount);

        SalesInvLine.SetFilter("VAT %", '<>0');
        if SalesInvLine.FindSet() then
            repeat
                if LineVATAmount.ContainsKey(SalesInvLine."VAT %") and LineAmount.ContainsKey(SalesInvLine."VAT %") then begin
                    InsertTaxSubtotal(
                        TaxTotalElement, GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"), LineAmount.Get(SalesInvLine."VAT %"),
                        LineVATAmount.Get(SalesInvLine."VAT %"), SalesInvLine."VAT %", CurrencyCode);
                    LineAmount.Remove(SalesInvLine."VAT %");
                    LineVATAmount.Remove(SalesInvLine."VAT %");
                end;
            until SalesInvLine.Next() = 0;

        SalesInvLine.SetRange("VAT %", 0);
        SalesInvLine.CalcSums(Amount);
        SalesInvLineTotalAmount := SalesInvLine.Amount;
        if SalesInvLine.FindLast() then;
        if (SalesInvLineTotalAmount > 0) or (InvDiscountAmount > 0) then
            InsertTaxSubtotal(
                TaxTotalElement, GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"), SalesInvLineTotalAmount + InvDiscountAmount, 0, SalesInvLine."VAT %", CurrencyCode);

        SalesInvLine.SetRange("VAT Calculation Type");
        SalesInvLine.SetRange("VAT %");
        RootXMLNode.Add(TaxTotalElement);
    end;

    local procedure InsertTaxTotal(var RootXMLNode: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyCode: Code[10]; InvDiscountAmount: Decimal)
    var
        LineVATAmount: Dictionary of [Decimal, Decimal];
        LineAmount: Dictionary of [Decimal, Decimal];
        TaxTotalElement: XmlElement;
        SalesCrMemoLineTotalAmount: Decimal;
    begin
        TaxTotalElement := XmlElement.Create('TaxTotal', XmlNamespaceCAC);
        TaxTotalElement.Add(XmlElement.Create('TaxAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(GetTotalTaxAmount(SalesCrMemoLine))));

        InsertVATAmounts(SalesCrMemoLine, LineVATAmount, LineAmount);

        SalesCrMemoLine.SetFilter("VAT %", '<>0');
        if SalesCrMemoLine.FindSet() then
            repeat
                if LineVATAmount.ContainsKey(SalesCrMemoLine."VAT %") and LineAmount.ContainsKey(SalesCrMemoLine."VAT %") then begin
                    InsertTaxSubtotal(
                        TaxTotalElement, GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"), LineAmount.Get(SalesCrMemoLine."VAT %"),
                        LineVATAmount.Get(SalesCrMemoLine."VAT %"), SalesCrMemoLine."VAT %", CurrencyCode);
                    LineAmount.Remove(SalesCrMemoLine."VAT %");
                    LineVATAmount.Remove(SalesCrMemoLine."VAT %");
                end;
            until SalesCrMemoLine.Next() = 0;

        SalesCrMemoLine.SetRange("VAT %", 0);
        SalesCrMemoLine.CalcSums(Amount);
        SalesCrMemoLineTotalAmount := SalesCrMemoLine.Amount;
        if SalesCrMemoLine.FindLast() then;
        if (SalesCrMemoLineTotalAmount > 0) or (InvDiscountAmount > 0) then
            InsertTaxSubtotal(
                TaxTotalElement, GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"), SalesCrMemoLineTotalAmount + InvDiscountAmount, 0, SalesCrMemoLine."VAT %", CurrencyCode);

        SalesCrMemoLine.SetRange("VAT Calculation Type");
        SalesCrMemoLine.SetRange("VAT %");
        RootXMLNode.Add(TaxTotalElement);
    end;

    local procedure InsertLegalMonetaryTotal(var RootXMLNode: XmlElement; var SalesInvLine: Record "Sales Invoice Line"; LineAmounts: Dictionary of [Text, Decimal]; CurrencyCode: Code[10])
    var
        LegalMonetaryTotalElement: XmlElement;
    begin
        LegalMonetaryTotalElement := XmlElement.Create('LegalMonetaryTotal', XmlNamespaceCAC);
        LegalMonetaryTotalElement.Add(XmlElement.Create('LineExtensionAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName(Amount)) - LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount")))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('TaxExclusiveAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName(Amount)))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('TaxInclusiveAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName("Amount Including VAT")))));
        if LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount")) > 0 then
            LegalMonetaryTotalElement.Add(XmlElement.Create('AllowanceTotalAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount")))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('PayableAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName("Amount Including VAT")))));
        RootXMLNode.Add(LegalMonetaryTotalElement);
    end;

    local procedure InsertLegalMonetaryTotal(var RootXMLNode: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; LineAmounts: Dictionary of [Text, Decimal]; CurrencyCode: Code[10])
    var
        LegalMonetaryTotalElement: XmlElement;
    begin
        LegalMonetaryTotalElement := XmlElement.Create('LegalMonetaryTotal', XmlNamespaceCAC);
        LegalMonetaryTotalElement.Add(XmlElement.Create('LineExtensionAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName(Amount)) - LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount")))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('TaxExclusiveAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName(Amount)))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('TaxInclusiveAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName("Amount Including VAT")))));
        if LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount")) > 0 then
            LegalMonetaryTotalElement.Add(XmlElement.Create('AllowanceTotalAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount")))));
        LegalMonetaryTotalElement.Add(XmlElement.Create('PayableAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName("Amount Including VAT")))));
        RootXMLNode.Add(LegalMonetaryTotalElement);
    end;

    local procedure InsertOrderLineReference(var InvoiceLineElement: XmlElement; LineNo: Integer);
    var
        OrderLineReferenceElement: XmlElement;
    begin
        OrderLineReferenceElement := XmlElement.Create('OrderLineReference', XmlNamespaceCAC);
        OrderLineReferenceElement.Add(XmlElement.Create('LineID', XmlNamespaceCBC, Format(LineNo)));
        InvoiceLineElement.Add(OrderLineReferenceElement);
    end;

    procedure InsertOrderReference(var RootElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header");
    var
        OrderReferenceElement: XmlElement;
    begin
        if SalesInvoiceHeader."External Document No." = '' then
            SalesInvoiceHeader."External Document No." := SalesInvoiceHeader."No.";
        if SalesInvoiceHeader."Order No." = '' then
            SalesInvoiceHeader."Order No." := SalesInvoiceHeader."Pre-Assigned No.";

        OrderReferenceElement := XmlElement.Create('OrderReference', XmlNamespaceCAC);
        OrderReferenceElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, SalesInvoiceHeader."External Document No."));
        OrderReferenceElement.Add(XmlElement.Create('SalesOrderID', XmlNamespaceCBC, SalesInvoiceHeader."Order No."));
        OnInsertOrderReferenceOnBeforeInsertSalesInvoiceElement(SalesInvoiceHeader, OrderReferenceElement);
        RootElement.Add(OrderReferenceElement);
    end;

    procedure InsertOrderReference(var RootElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header");
    var
        OrderReferenceElement: XmlElement;
    begin
        if SalesCrMemoHeader."External Document No." = '' then
            SalesCrMemoHeader."External Document No." := SalesCrMemoHeader."No.";
        if SalesCrMemoHeader."Return Order No." = '' then
            SalesCrMemoHeader."Return Order No." := SalesCrMemoHeader."Pre-Assigned No.";

        OrderReferenceElement := XmlElement.Create('OrderReference', XmlNamespaceCAC);
        OrderReferenceElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, SalesCrMemoHeader."External Document No."));
        OrderReferenceElement.Add(XmlElement.Create('SalesOrderID', XmlNamespaceCBC, SalesCrMemoHeader."Return Order No."));
        OnInsertOrderReferenceOnBeforeInsertSalesCrMemoElement(SalesCrMemoHeader, OrderReferenceElement);
        RootElement.Add(OrderReferenceElement);
    end;

    local procedure InsertInvoiceLine(var InvoiceElement: XmlElement; var SalesInvLine: Record "Sales Invoice Line"; Currency: Record Currency; CurrencyCode: Code[10])
    var
        InvoiceLineElement: XmlElement;
    begin
        SalesInvLine.FindSet();
        repeat
            InvoiceLineElement := XmlElement.Create('InvoiceLine', XmlNamespaceCAC);

            InvoiceLineElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, Format(SalesInvLine."Line No.")));
            InvoiceLineElement.Add(XmlElement.Create('InvoicedQuantity', XmlNamespaceCBC, XmlAttribute.Create('unitCode', GetUoMCode(SalesInvLine."Unit of Measure Code")), FormatDecimal(SalesInvLine.Quantity)));
            InvoiceLineElement.Add(XmlElement.Create('LineExtensionAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(SalesInvLine.Amount - SalesInvLine."Inv. Discount Amount")));
            InsertOrderLineReference(InvoiceLineElement, SalesInvLine."Line No.");
            if SalesInvLine."Line Discount Amount" > 0 then
                InsertAllowanceCharge(
                    InvoiceLineElement, 'LineDiscount', GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"),
                    SalesInvLine."Line Discount Amount", SalesInvLine."Unit Price" * SalesInvLine.Quantity,
                    CurrencyCode, SalesInvLine."Line Discount %", SalesInvLine."Line Discount %", false);

            InsertItem(InvoiceLineElement, SalesInvLine);
            InsertPrice(InvoiceLineElement, Round(SalesInvLine."Unit Price", Currency."Unit-Amount Rounding Precision"), CurrencyCode);
            InvoiceElement.Add(InvoiceLineElement);
        until SalesInvLine.Next() = 0;
    end;

    local procedure InsertCrMemoLine(var CrMemoElement: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; Currency: Record Currency; CurrencyCode: Code[10])
    var
        CrMemoLineElement: XmlElement;
    begin
        SalesCrMemoLine.FindSet();
        repeat
            CrMemoLineElement := XmlElement.Create('CreditNoteLine', XmlNamespaceCAC);

            CrMemoLineElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, Format(SalesCrMemoLine."Line No.")));
            CrMemoLineElement.Add(XmlElement.Create('CreditedQuantity', XmlNamespaceCBC, XmlAttribute.Create('unitCode', GetUoMCode(SalesCrMemoLine."Unit of Measure Code")), FormatDecimal(SalesCrMemoLine.Quantity)));
            CrMemoLineElement.Add(XmlElement.Create('LineExtensionAmount', XmlNamespaceCBC, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(SalesCrMemoLine.Amount - SalesCrMemoLine."Inv. Discount Amount")));
            InsertOrderLineReference(CrMemoLineElement, SalesCrMemoLine."Line No.");
            if SalesCrMemoLine."Line Discount Amount" > 0 then
                InsertAllowanceCharge(
                    CrMemoLineElement, 'LineDiscount', GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"),
                    SalesCrMemoLine."Line Discount Amount", SalesCrMemoLine."Unit Price" * SalesCrMemoLine.Quantity,
                    CurrencyCode, SalesCrMemoLine."Line Discount %", SalesCrMemoLine."Line Discount %", false);

            InsertItem(CrMemoLineElement, SalesCrMemoLine);
            InsertPrice(CrMemoLineElement, Round(SalesCrMemoLine."Unit Price", Currency."Unit-Amount Rounding Precision"), CurrencyCode);
            CrMemoElement.Add(CrMemoLineElement);
        until SalesCrMemoLine.Next() = 0;
    end;

    procedure InsertAttachment(var RootElement: XmlElement; TableNo: Integer; DocumentNo: Code[20]);
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", TableNo);
        DocumentAttachment.SetRange("No.", DocumentNo);
        if DocumentAttachment.IsEmpty() then
            exit;

        if DocumentAttachment.FindSet() then
            repeat
                AddAttachment(RootElement, DocumentAttachment);
            until DocumentAttachment.Next() = 0;
    end;

    procedure AddAttachment(var RootElement: XmlElement; var DocumentAttachment: Record "Document Attachment");
    var
        TempBlob: Codeunit "Temp Blob";
        AttachmentElement: XmlElement;
        OutStream: OutStream;
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        DocumentAttachment.ExportToStream(OutStream);
        TempBlob.CreateInStream(InStream);

        AttachmentElement := XmlElement.Create('AdditionalDocumentReference', XmlNamespaceCAC);
        AttachmentElement.Add(XmlElement.Create('ID', XmlNamespaceCBC, DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension"));
        AttachmentElement.Add(XmlElement.Create('DocumentDescription', XmlNamespaceCBC, DocumentAttachment."File Name"));
        AddAttachmentObject(AttachmentElement, InStream, DocumentAttachment);

        RootElement.Add(AttachmentElement);
    end;

    local procedure AddAttachmentObject(var AttachmentElement: XmlElement; var InStream: InStream; var DocumentAttachment: Record "Document Attachment");
    var
        Base64Convert: Codeunit "Base64 Convert";
        AttachmentObjectElement: XmlElement;
    begin
        AttachmentObjectElement := XmlElement.Create('Attachment', XmlNamespaceCAC);
        AttachmentObjectElement.Add(XmlElement.Create('EmbeddedDocumentBinaryObject', XmlNamespaceCBC,
            XmlAttribute.Create('mimeCode', GetMimeCode(DocumentAttachment)),
            XmlAttribute.Create('filename', DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension"),
            Base64Convert.ToBase64(InStream)));
        AttachmentElement.Add(AttachmentObjectElement);
    end;

    local procedure GetMimeCode(var DocumentAttachment: Record "Document Attachment"): Text;
    begin
        case DocumentAttachment."File Type" of
            "Document Attachment File Type"::Image:
                exit('image/' + LowerCase(DocumentAttachment."File Extension"));
            "Document Attachment File Type"::PDF:
                exit('application/' + LowerCase(DocumentAttachment."File Extension"));
            "Document Attachment File Type"::Excel:
                exit('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        end;
    end;

    local procedure CalculateLineAmounts(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    begin
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
        OnAfterCalculateInvoiceLineAmounts(SalesInvoiceHeader, SalesInvLine, Currency, LineAmounts);
    end;

    local procedure CalculateLineAmounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    begin
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
        OnAfterCalculateCrMemoLineAmounts(SalesCrMemoHeader, SalesCrMemoLine, Currency, LineAmounts);
    end;

    local procedure InsertVATAmounts(var SalesInvLine: Record "Sales Invoice Line"; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmount: Dictionary of [Decimal, Decimal])
    begin
        if SalesInvLine.FindSet() then
            repeat
                AddAmountForVAT(SalesInvLine."VAT %", SalesInvLine."Amount Including VAT" - SalesInvLine.Amount, LineVATAmount);
                AddAmountForVAT(SalesInvLine."VAT %", SalesInvLine.Amount, LineAmount);
            until SalesInvLine.Next() = 0;
    end;

    local procedure InsertVATAmounts(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmount: Dictionary of [Decimal, Decimal])
    begin
        if SalesCrMemoLine.FindSet() then
            repeat
                AddAmountForVAT(SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount, LineVATAmount);
                AddAmountForVAT(SalesCrMemoLine."VAT %", SalesCrMemoLine.Amount, LineAmount);
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure AddAmountForVAT(VATPercent: Decimal; NewAmount: Decimal; var TotalAmounts: Dictionary of [Decimal, Decimal])
    begin
        if not TotalAmounts.ContainsKey(VATPercent) then
            TotalAmounts.Add(VATPercent, NewAmount)
        else
            TotalAmounts.Set(VATPercent, TotalAmounts.Get(VATPercent) + NewAmount);
    end;

    local procedure GetInvoiceDiscountPercent(var SalesInvLine: Record "Sales Invoice Line"; var BaseAmount: Decimal): Decimal
    begin
        SalesInvLine.SetRange("Allow Invoice Disc.", true);
        SalesInvLine.CalcSums("Line Amount", "Inv. Discount Amount");
        BaseAmount := SalesInvLine."Line Amount";
        SalesInvLine.SetRange("Allow Invoice Disc.");
        exit(100 * SalesInvLine."Inv. Discount Amount" / BaseAmount);
    end;

    local procedure GetInvoiceDiscountPercent(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var BaseAmount: Decimal): Decimal
    begin
        SalesCrMemoLine.SetRange("Allow Invoice Disc.", true);
        SalesCrMemoLine.CalcSums("Line Amount", "Inv. Discount Amount");
        BaseAmount := SalesCrMemoLine."Line Amount";
        SalesCrMemoLine.SetRange("Allow Invoice Disc.");
        exit(100 * SalesCrMemoLine."Inv. Discount Amount" / BaseAmount);
    end;

    local procedure FindEDocumentService(EDocumentFormat: Code[20])
    begin
        if EDocumentFormat = '' then
            exit;

        if UpperCase(Format("E-Document Format"::XRechnung)) <> UpperCase(EDocumentFormat) then
            exit;
        EDocumentService.SetRange("Document Format", EDocumentService."Document Format"::XRechnung);
        if EDocumentService.FindLast() then;
        OnAfterFindEDocumentService(EDocumentService, EDocumentFormat);
    end;
    #region CommonFunctions
    procedure FormatDate(VarDate: Date): Text[20];
    begin
        if VarDate = 0D then
            exit('1753-01-01');
        exit(Format(VarDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    procedure FormatDecimal(VarDecimal: Decimal): Text[30];
    begin
        exit(Format(Round(VarDecimal, 0.01), 0, 9));
    end;

    procedure GetUoMCode(UoMCode: Code[10]): Text;
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if not UnitofMeasure.Get(UoMCode) then
            exit(Format(UoMCode));
        if UnitofMeasure."International Standard Code" <> '' then
            exit(UnitofMeasure."International Standard Code");
        exit(UoMCode);
    end;

    local procedure GetTotalTaxAmount(var SalesInvLine: Record "Sales Invoice Line"): Decimal
    begin
        SalesInvLine.SetFilter(
          "VAT Calculation Type", '%1|%2|%3',
          SalesInvLine."VAT Calculation Type"::"Normal VAT",
          SalesInvLine."VAT Calculation Type"::"Full VAT",
          SalesInvLine."VAT Calculation Type"::"Reverse Charge VAT");
        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
        SalesInvLine.SetRange("VAT Calculation Type");
        exit(SalesInvLine."Amount Including VAT" - SalesInvLine.Amount);
    end;

    local procedure GetTotalTaxAmount(var SalesCrMemoLine: Record "Sales Cr.Memo Line"): Decimal
    begin
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

    local procedure GetCountryRegionCode(CountryRegionCode: Code[10]): Code[10]
    begin
        if CountryRegionCode <> '' then
            exit(CountryRegionCode);

        CompanyInformation.TestField("Country/Region Code");
        exit(CompanyInformation."Country/Region Code");
    end;

    procedure GetVATRegistrationNo(VATRegistrationNo: Text[20]; CountryRegionCode: Code[10]): Text[30];
    begin
        if CountryRegionCode = '' then
            CountryRegionCode := GetCountryRegionCode(CountryRegionCode);
        if CopyStr(VATRegistrationNo, 1, 2) <> CountryRegionCode then
            exit(CountryRegionCode + VATRegistrationNo);
        exit(VATRegistrationNo);
    end;

    local procedure DocumentLinesExist(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line"): Boolean
    begin
        SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvLine.SetFilter(Type, '<>%1', SalesInvLine.Type::" ");
        SalesInvLine.SetFilter("No.", '<>%1', '');
        SalesInvLine.SetFilter(Quantity, '<>0');
        OnDocumentLinesExistOnAfterFilterSalesInvLine(SalesInvoiceHeader, SalesInvLine);
        if SalesInvLine.FindSet() then
            exit(true);
        exit(false);
    end;

    local procedure DocumentLinesExist(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"): Boolean
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        SalesCrMemoLine.SetFilter(Quantity, '<>0');
        OnDocumentLinesExistOnAfterFilterSalesCrMemoLine(SalesCrMemoHeader, SalesCrMemoLine);
        if SalesCrMemoLine.FindSet() then
            exit(true);
        exit(false);
    end;

    local procedure GetSetups()
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
    end;
    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeSalesInvXmlDocumentWriteToFile(var XMLDoc: XmlDocument; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeSalesCrMemoXmlDocumentWriteToFile(var XMLDoc: XmlDocument; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindEDocumentService(var EDocumentService: Record "E-Document Service"; EDocumentFormat: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesInvHeaderData(var XMLCurrNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesCrMemoHeaderData(var XMLCurrNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertOrderReferenceOnBeforeInsertSalesInvoiceElement(var SalesInvoiceHeader: Record "Sales Invoice Header"; var OrderReferenceElement: XmlElement)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertOrderReferenceOnBeforeInsertSalesCrMemoElement(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var OrderReferenceElement: XmlElement)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDocumentLinesExistOnAfterFilterSalesInvLine(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDocumentLinesExistOnAfterFilterSalesCrMemoLine(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateInvoiceLineAmounts(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateCrMemoLineAmounts(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    begin
    end;
}