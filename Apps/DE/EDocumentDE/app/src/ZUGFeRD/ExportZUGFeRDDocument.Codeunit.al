// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Telemetry;
using Microsoft.eServices.EDocument;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Sales.Customer;
using System.Utilities;
using Microsoft.Foundation.Reporting;
using System.IO;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.History;
using Microsoft.Foundation.UOM;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using System.Reflection;

codeunit 13917 "Export ZUGFeRD Document"
{
    TableNo = "Record Export Buffer";
    EventSubscriberInstance = Manual;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EDocumentService: Record "E-Document Service";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
        FeatureNameTok: Label 'E-document ZUGFeRD Format', Locked = true;
        StartEventNameTok: Label 'E-document ZUGFeRD export started', Locked = true;
        EndEventNameTok: Label 'E-document ZUGFeRD export completed', Locked = true;
        XmlNamespaceRSM: Text;
        XmlNamespaceRAM: Text;
        XmlNamespaceUDT: Text;

    trigger OnRun();
    begin
        BindSubscription(ExportZUGFeRDDocument);
        ExportSalesDocument(Rec);
        UnbindSubscription(ExportZUGFeRDDocument);
    end;

    procedure ExportSalesDocument(var RecordExportBuffer: Record "Record Export Buffer")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempBlob: Codeunit "Temp Blob";
        FileOutStream: OutStream;
        FileInStream: InStream;
    begin
        FeatureTelemetry.LogUsage('0000EXD', FeatureNameTok, StartEventNameTok);

        case RecordExportBuffer.RecordID.TableNo of
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.Get(RecordExportBuffer.RecordID);
                    if not GenerateSalesInvoicePDFAttachment(SalesInvoiceHeader, TempBlob) then
                        exit;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(RecordExportBuffer.RecordID);
                    if not GenerateSalesCrMemoPDFAttachment(SalesCrMemoHeader, TempBlob) then
                        exit;
                end;
        end;
        TempBlob.CreateInStream(FileInStream);
        RecordExportBuffer."File Content".CreateOutStream(FileOutStream, TextEncoding::UTF8);
        CopyStream(FileOutStream, FileInStream);
        RecordExportBuffer.Modify();
        FeatureTelemetry.LogUsage('0000EXE', FeatureNameTok, EndEventNameTok);
    end;

    procedure GenerateSalesInvoicePDFAttachment(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportSelections: Record "Report Selections";
    begin
        SalesInvoiceHeader.SetRange("No.", SalesInvoiceHeader."No.");
        ReportSelections.GetPdfReportForCust(
            TempBlob, "Report Selection Usage"::"S.Invoice",
            SalesInvoiceHeader, SalesInvoiceHeader."Bill-to Customer No.");
        exit(TempBlob.HasValue());
    end;

    procedure GenerateSalesCrMemoPDFAttachment(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportSelections: Record "Report Selections";
    begin
        SalesCrMemoHeader.SetRange("No.", SalesCrMemoHeader."No.");
        ReportSelections.GetPdfReportForCust(
            TempBlob, "Report Selection Usage"::"S.Cr.Memo",
            SalesCrMemoHeader, SalesCrMemoHeader."Bill-to Customer No.");
        exit(TempBlob.HasValue());
    end;

    procedure CreateXML(SalesInvoiceHeader: Record "Sales Invoice Header"; var FileOutstream: Outstream)
    var
        SalesInvLine: Record "Sales Invoice Line";
        Currency: Record Currency;
        CurrencyCode: Code[10];
        RootXMLNode: XmlElement;
        XMLDoc: XmlDocument;
        XMLDocText: Text;
        LineAmounts: Dictionary of [Text, Decimal];
        LineVATAmount: Dictionary of [Decimal, Decimal];
        LineAmount: Dictionary of [Decimal, Decimal];
        LineDiscAmount: Dictionary of [Decimal, Decimal];
    begin
        GetSetups();
        FindEDocumentService();
        if not DocumentLinesExist(SalesInvoiceHeader, SalesInvLine) then
            exit;

        XmlDocument.ReadFrom(GetInvoiceXMLHeader(), XMLDoc);
        XmlDoc.GetRoot(RootXMLNode);

        InitializeNamespaces();
        CurrencyCode := GetCurrencyCode(SalesInvoiceHeader."Currency Code", Currency);
        CalculateLineAmounts(SalesInvoiceHeader, SalesInvLine, Currency, LineAmounts);
        InsertVATAmounts(SalesInvLine, LineVATAmount, LineAmount, LineDiscAmount, SalesInvoiceHeader."Prices Including VAT", Currency);
        InsertHeaderData(RootXMLNode, SalesInvoiceHeader);
        InsertSupplyChainTradeTransaction(RootXMLNode, SalesInvoiceHeader, SalesInvLine, CurrencyCode, Currency, LineAmount, LineVATAmount, LineAmounts, LineDiscAmount);
        OnCreateXMLOnBeforeSalesInvXmlDocumentWriteToFile(XMLDoc, SalesInvoiceHeader);
        XMLDoc.WriteTo(XMLDocText);
        FileOutstream.WriteText(XMLDocText);
        Clear(XMLDoc);
    end;

    procedure CreateXML(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FileOutstream: Outstream)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Currency: Record Currency;
        CurrencyCode: Code[10];
        RootXMLNode: XmlElement;
        XMLDoc: XmlDocument;
        XMLDocText: Text;
        LineAmounts: Dictionary of [Text, Decimal];
        LineVATAmount: Dictionary of [Decimal, Decimal];
        LineAmount: Dictionary of [Decimal, Decimal];
        LineDiscAmount: Dictionary of [Decimal, Decimal];
    begin
        GetSetups();
        FindEDocumentService();
        if not DocumentLinesExist(SalesCrMemoHeader, SalesCrMemoLine) then
            exit;

        XmlDocument.ReadFrom(GetInvoiceXMLHeader(), XMLDoc);
        XmlDoc.GetRoot(RootXMLNode);

        InitializeNamespaces();
        CurrencyCode := GetCurrencyCode(SalesCrMemoHeader."Currency Code", Currency);
        CalculateLineAmounts(SalesCrMemoHeader, SalesCrMemoLine, Currency, LineAmounts);
        InsertVATAmounts(SalesCrMemoLine, LineVATAmount, LineAmount, LineDiscAmount, SalesCrMemoHeader."Prices Including VAT", Currency);
        InsertHeaderData(RootXMLNode, SalesCrMemoHeader);
        InsertSupplyChainTradeTransaction(RootXMLNode, SalesCrMemoHeader, SalesCrMemoLine, CurrencyCode, Currency, LineAmount, LineVATAmount, LineAmounts, LineDiscAmount);
        OnCreateXMLOnBeforeSalesCrMemoXmlDocumentWriteToFile(XMLDoc, SalesCrMemoHeader);
        XMLDoc.WriteTo(XMLDocText);
        FileOutstream.WriteText(XMLDocText);
        Clear(XMLDoc);
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

    local procedure InitializeNamespaces()
    begin
        XmlNamespaceRSM := 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100';
        XmlNamespaceRAM := 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100';
        XmlNamespaceUDT := 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100';
    end;

    local procedure GetInvoiceXMLHeader(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?>' +
        '<rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100" ' +
        'xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100" ' +
        'xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" ' +
        'xmlns:xs="http://www.w3.org/2001/XMLSchema" ' +
        'xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" />');
    end;

    local procedure InsertHeaderData(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        ExchangedDocumentContextElement, GuidelineSpecifiedDocumentContextParameterElement, BusinessProcessContextElement, ExchangedDocumentElement, IssueDateTimeElement : XmlElement;
    begin
        ExchangedDocumentContextElement := XmlElement.Create('ExchangedDocumentContext', XmlNamespaceRSM);
        BusinessProcessContextElement := XmlElement.Create('BusinessProcessSpecifiedDocumentContextParameter', XmlNamespaceRAM);
        BusinessProcessContextElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0'));
        ExchangedDocumentContextElement.Add(BusinessProcessContextElement);

        GuidelineSpecifiedDocumentContextParameterElement := XmlElement.Create('GuidelineSpecifiedDocumentContextParameter', XmlNamespaceRAM);
        GuidelineSpecifiedDocumentContextParameterElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, 'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0'));
        ExchangedDocumentContextElement.Add(GuidelineSpecifiedDocumentContextParameterElement);
        RootXMLNode.Add(ExchangedDocumentContextElement);
        ExchangedDocumentElement := XmlElement.Create('ExchangedDocument', XmlNamespaceRSM);
        ExchangedDocumentElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, SalesInvoiceHeader."No."));
        ExchangedDocumentElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, '380')); // Invoice type code

        IssueDateTimeElement := XmlElement.Create('IssueDateTime', XmlNamespaceRAM);
        IssueDateTimeElement.Add(XmlElement.Create('DateTimeString', XmlNamespaceUDT, XmlAttribute.Create('format', '102'), FormatDate(SalesInvoiceHeader."Posting Date")));
        ExchangedDocumentElement.Add(IssueDateTimeElement);
        RootXMLNode.Add(ExchangedDocumentElement);
        OnAfterInsertSalesInvHeaderData(RootXMLNode, SalesInvoiceHeader);
    end;

    local procedure InsertHeaderData(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        ExchangedDocumentContextElement, GuidelineSpecifiedDocumentContextParameterElement, BusinessProcessContextElement, ExchangedDocumentElement, IssueDateTimeElement : XmlElement;
    begin
        ExchangedDocumentContextElement := XmlElement.Create('ExchangedDocumentContext', XmlNamespaceRSM);
        BusinessProcessContextElement := XmlElement.Create('BusinessProcessSpecifiedDocumentContextParameter', XmlNamespaceRAM);
        BusinessProcessContextElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0'));
        ExchangedDocumentContextElement.Add(BusinessProcessContextElement);

        GuidelineSpecifiedDocumentContextParameterElement := XmlElement.Create('GuidelineSpecifiedDocumentContextParameter', XmlNamespaceRAM);
        GuidelineSpecifiedDocumentContextParameterElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, 'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0'));
        ExchangedDocumentContextElement.Add(GuidelineSpecifiedDocumentContextParameterElement);
        RootXMLNode.Add(ExchangedDocumentContextElement);
        ExchangedDocumentElement := XmlElement.Create('ExchangedDocument', XmlNamespaceRSM);
        ExchangedDocumentElement.Add(XmlElement.Create('ID', XmlNamespaceRAM, SalesCrMemoHeader."No."));
        ExchangedDocumentElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, '381')); // Credit memo type code

        IssueDateTimeElement := XmlElement.Create('IssueDateTime', XmlNamespaceRAM);
        IssueDateTimeElement.Add(XmlElement.Create('DateTimeString', XmlNamespaceUDT, XmlAttribute.Create('format', '102'), FormatDate(SalesCrMemoHeader."Posting Date")));
        ExchangedDocumentElement.Add(IssueDateTimeElement);
        RootXMLNode.Add(ExchangedDocumentElement);
        OnAfterInsertSalesCrMemoHeaderData(RootXMLNode, SalesCrMemoHeader);
    end;

    local procedure InsertApplicableHeaderTradeAgreement(var RootXMLNode: XmlElement; CustomerNo: Code[20]; YourReference: Text[35])
    var
        Customer: Record Customer;
        HeaderTradeAgreementElement, SellerTradePartyElement, BuyerTradePartyElement, SpecifiedTaxRegistrationElement, IDElement : XmlElement;
        PostalTradeAddressElement, ContactElement : XmlElement;
        SellerIDAttr, BuyerIDAttr : XmlAttribute;
    begin
        HeaderTradeAgreementElement := XmlElement.Create('ApplicableHeaderTradeAgreement', XmlNamespaceRAM);
        HeaderTradeAgreementElement.Add(XmlElement.Create('BuyerReference', XmlNamespaceRAM, GetBuyerReference(YourReference, CustomerNo)));

        // Seller
        SellerTradePartyElement := XmlElement.Create('SellerTradeParty', XmlNamespaceRAM);
        if CompanyInformation."Use GLN in Electronic Document" and (CompanyInformation.GLN <> '') then begin
            SellerIDAttr := XmlAttribute.Create('schemeID', '0088');
            SellerTradePartyElement.Add(XmlElement.Create('GlobalID', XmlNamespaceRAM, SellerIDAttr, CompanyInformation.GLN));
        end;
        SellerTradePartyElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, CompanyInformation.Name));

        // Seller Contact
        if CompanyInformation."Phone No." <> '' then begin
            ContactElement := XmlElement.Create('DefinedTradeContact', XmlNamespaceRAM);
            ContactElement.Add(XmlElement.Create('PersonName', XmlNamespaceRAM, CompanyInformation."Contact Person"));
            ContactElement.Add(XmlElement.Create('TelephoneUniversalCommunication', XmlNamespaceRAM,
                XmlElement.Create('CompleteNumber', XmlNamespaceRAM, CompanyInformation."Phone No.")));
            if CompanyInformation."E-Mail" <> '' then
                ContactElement.Add(XmlElement.Create('EmailURIUniversalCommunication', XmlNamespaceRAM,
                    XmlElement.Create('URIID', XmlNamespaceRAM, CompanyInformation."E-Mail")));
            SellerTradePartyElement.Add(ContactElement);
        end;

        // Seller Address
        PostalTradeAddressElement := XmlElement.Create('PostalTradeAddress', XmlNamespaceRAM);
        PostalTradeAddressElement.Add(XmlElement.Create('PostcodeCode', XmlNamespaceRAM, CompanyInformation."Post Code"));
        PostalTradeAddressElement.Add(XmlElement.Create('LineOne', XmlNamespaceRAM, CompanyInformation.Address));
        PostalTradeAddressElement.Add(XmlElement.Create('CityName', XmlNamespaceRAM, CompanyInformation.City));
        PostalTradeAddressElement.Add(XmlElement.Create('CountryID', XmlNamespaceRAM, GetCountryRegionCode(CompanyInformation."Country/Region Code")));
        SellerTradePartyElement.Add(PostalTradeAddressElement);

        if CompanyInformation."VAT Registration No." <> '' then begin
            SellerIDAttr := XmlAttribute.Create('schemeID', 'VA');
            IDElement := XmlElement.Create('ID', XmlNamespaceRAM, SellerIDAttr, GetVATRegistrationNo(CompanyInformation."VAT Registration No.", CompanyInformation."Country/Region Code"));
            SpecifiedTaxRegistrationElement := XmlElement.Create('SpecifiedTaxRegistration', XmlNamespaceRAM);
            SpecifiedTaxRegistrationElement.Add(IDElement);
            SellerTradePartyElement.Add(SpecifiedTaxRegistrationElement);
        end;
        HeaderTradeAgreementElement.Add(SellerTradePartyElement);

        // Buyer
        Customer.Get(CustomerNo);
        BuyerTradePartyElement := XmlElement.Create('BuyerTradeParty', XmlNamespaceRAM);
        BuyerTradePartyElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, Customer.Name));

        // Buyer Contact
        if Customer."Phone No." <> '' then begin
            ContactElement := XmlElement.Create('DefinedTradeContact', XmlNamespaceRAM);
            ContactElement.Add(XmlElement.Create('PersonName', XmlNamespaceRAM, Customer.Contact));
            ContactElement.Add(XmlElement.Create('TelephoneUniversalCommunication', XmlNamespaceRAM,
                XmlElement.Create('CompleteNumber', XmlNamespaceRAM, Customer."Phone No.")));
            if Customer."E-Mail" <> '' then
                ContactElement.Add(XmlElement.Create('EmailURIUniversalCommunication', XmlNamespaceRAM,
                    XmlElement.Create('URIID', XmlNamespaceRAM, Customer."E-Mail")));
            BuyerTradePartyElement.Add(ContactElement);
        end;

        // Buyer Address
        PostalTradeAddressElement := XmlElement.Create('PostalTradeAddress', XmlNamespaceRAM);
        PostalTradeAddressElement.Add(XmlElement.Create('PostcodeCode', XmlNamespaceRAM, Customer."Post Code"));
        PostalTradeAddressElement.Add(XmlElement.Create('LineOne', XmlNamespaceRAM, Customer.Address));
        PostalTradeAddressElement.Add(XmlElement.Create('CityName', XmlNamespaceRAM, Customer.City));
        PostalTradeAddressElement.Add(XmlElement.Create('CountryID', XmlNamespaceRAM, GetCountryRegionCode(Customer."Country/Region Code")));
        BuyerTradePartyElement.Add(PostalTradeAddressElement);

        if Customer."VAT Registration No." <> '' then begin
            BuyerIDAttr := XmlAttribute.Create('schemeID', 'VA');
            IDElement := XmlElement.Create('ID', XmlNamespaceRAM, BuyerIDAttr, GetVATRegistrationNo(Customer."VAT Registration No.", Customer."Country/Region Code"));
            SpecifiedTaxRegistrationElement := XmlElement.Create('SpecifiedTaxRegistration', XmlNamespaceRAM);
            SpecifiedTaxRegistrationElement.Add(IDElement);
            BuyerTradePartyElement.Add(SpecifiedTaxRegistrationElement);
        end;
        HeaderTradeAgreementElement.Add(BuyerTradePartyElement);
        RootXMLNode.Add(HeaderTradeAgreementElement);
    end;

    local procedure InsertApplicableHeaderTradeDelivery(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DeliveryElement, ShipToPartyElement, PostalAddressElement : XmlElement;
    begin
        DeliveryElement := XmlElement.Create('ApplicableHeaderTradeDelivery', XmlNamespaceRAM);

        ShipToPartyElement := XmlElement.Create('ShipToTradeParty', XmlNamespaceRAM);
        ShipToPartyElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, SalesInvoiceHeader."Sell-to Customer Name"));

        PostalAddressElement := XmlElement.Create('PostalTradeAddress', XmlNamespaceRAM);
        PostalAddressElement.Add(XmlElement.Create('PostcodeCode', XmlNamespaceRAM, SalesInvoiceHeader."Sell-to Post Code"));
        PostalAddressElement.Add(XmlElement.Create('LineOne', XmlNamespaceRAM, SalesInvoiceHeader."Sell-to Address"));
        PostalAddressElement.Add(XmlElement.Create('CityName', XmlNamespaceRAM, SalesInvoiceHeader."Sell-to City"));
        PostalAddressElement.Add(XmlElement.Create('CountryID', XmlNamespaceRAM, GetCountryRegionCode(SalesInvoiceHeader."Sell-to Country/Region Code")));

        ShipToPartyElement.Add(PostalAddressElement);
        DeliveryElement.Add(ShipToPartyElement);
        RootXMLNode.Add(DeliveryElement);
    end;

    local procedure InsertApplicableHeaderTradeDelivery(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        DeliveryElement, ShipToPartyElement, PostalAddressElement : XmlElement;
    begin
        DeliveryElement := XmlElement.Create('ApplicableHeaderTradeDelivery', XmlNamespaceRAM);

        ShipToPartyElement := XmlElement.Create('ShipToTradeParty', XmlNamespaceRAM);
        ShipToPartyElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, SalesCrMemoHeader."Sell-to Customer Name"));

        PostalAddressElement := XmlElement.Create('PostalTradeAddress', XmlNamespaceRAM);
        PostalAddressElement.Add(XmlElement.Create('PostcodeCode', XmlNamespaceRAM, SalesCrMemoHeader."Sell-to Post Code"));
        PostalAddressElement.Add(XmlElement.Create('LineOne', XmlNamespaceRAM, SalesCrMemoHeader."Sell-to Address"));
        PostalAddressElement.Add(XmlElement.Create('CityName', XmlNamespaceRAM, SalesCrMemoHeader."Sell-to City"));
        PostalAddressElement.Add(XmlElement.Create('CountryID', XmlNamespaceRAM, GetCountryRegionCode(SalesCrMemoHeader."Sell-to Country/Region Code")));

        ShipToPartyElement.Add(PostalAddressElement);
        DeliveryElement.Add(ShipToPartyElement);
        RootXMLNode.Add(DeliveryElement);
    end;

    local procedure InsertApplicableHeaderTradeSettlement(var RootXMLNode: XmlElement; var SalesInvHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line"; CurrencyCode: Code[10]; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal])
    var
        SettlementElement, MonetarySummationElement : XmlElement;
    begin
        SettlementElement := XmlElement.Create('ApplicableHeaderTradeSettlement', XmlNamespaceRAM);

        SettlementElement.Add(XmlElement.Create('InvoiceCurrencyCode', XmlNamespaceRAM, CurrencyCode));
        InsertPaymentMethod(SettlementElement, SalesInvHeader."Payment Method Code");
        InsertTradeTax(SettlementElement, SalesInvLine, LineAmount, LineVATAmount);
        InsertInvDiscountAllowanceCharge(SettlementElement, SalesInvLine, LineDiscAmount, LineAmounts);

        InsertPaymentTerms(SettlementElement, SalesInvHeader."Payment Terms Code");
        MonetarySummationElement := XmlElement.Create('SpecifiedTradeSettlementHeaderMonetarySummation', XmlNamespaceRAM);
        MonetarySummationElement.Add(XmlElement.Create('LineTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesInvHeader.Amount + LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount")))));
        MonetarySummationElement.Add(XmlElement.Create('AllowanceTotalAmount', XmlNamespaceRAM, FormatDecimal(LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount")))));
        MonetarySummationElement.Add(XmlElement.Create('TaxBasisTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesInvHeader.Amount)));
        MonetarySummationElement.Add(XmlElement.Create('TaxTotalAmount', XmlNamespaceRAM, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(SalesInvHeader."Amount Including VAT" - SalesInvHeader.Amount)));
        MonetarySummationElement.Add(XmlElement.Create('GrandTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesInvHeader."Amount Including VAT")));
        MonetarySummationElement.Add(XmlElement.Create('TotalPrepaidAmount', XmlNamespaceRAM, FormatDecimal(0)));
        MonetarySummationElement.Add(XmlElement.Create('DuePayableAmount', XmlNamespaceRAM, FormatDecimal(SalesInvHeader."Amount Including VAT")));

        SettlementElement.Add(MonetarySummationElement);
        RootXMLNode.Add(SettlementElement);
    end;

    local procedure InsertApplicableHeaderTradeSettlement(var RootXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyCode: Code[10]; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal])
    var
        SettlementElement, MonetarySummationElement : XmlElement;
    begin
        SettlementElement := XmlElement.Create('ApplicableHeaderTradeSettlement', XmlNamespaceRAM);

        SettlementElement.Add(XmlElement.Create('InvoiceCurrencyCode', XmlNamespaceRAM, CurrencyCode));
        InsertPaymentMethod(SettlementElement, SalesCrMemoHeader."Payment Method Code");
        InsertTradeTax(SettlementElement, SalesCrMemoLine, LineAmount, LineVATAmount);
        InsertInvDiscountAllowanceCharge(SettlementElement, SalesCrMemoLine, LineDiscAmount, LineAmounts);

        InsertPaymentTerms(SettlementElement, SalesCrMemoHeader."Payment Terms Code");
        MonetarySummationElement := XmlElement.Create('SpecifiedTradeSettlementHeaderMonetarySummation', XmlNamespaceRAM);
        MonetarySummationElement.Add(XmlElement.Create('LineTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesCrMemoHeader.Amount + LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount")))));
        MonetarySummationElement.Add(XmlElement.Create('AllowanceTotalAmount', XmlNamespaceRAM, FormatDecimal(LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount")))));
        MonetarySummationElement.Add(XmlElement.Create('TaxBasisTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesCrMemoHeader.Amount)));
        MonetarySummationElement.Add(XmlElement.Create('TaxTotalAmount', XmlNamespaceRAM, XmlAttribute.Create('currencyID', CurrencyCode), FormatDecimal(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount)));
        MonetarySummationElement.Add(XmlElement.Create('GrandTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesCrMemoHeader."Amount Including VAT")));
        MonetarySummationElement.Add(XmlElement.Create('TotalPrepaidAmount', XmlNamespaceRAM, FormatDecimal(0)));
        MonetarySummationElement.Add(XmlElement.Create('DuePayableAmount', XmlNamespaceRAM, FormatDecimal(SalesCrMemoHeader."Amount Including VAT")));

        SettlementElement.Add(MonetarySummationElement);
        RootXMLNode.Add(SettlementElement);
    end;

    local procedure InsertTradeTax(var SettlementElement: XmlElement; var SalesInvLine: Record "Sales Invoice Line"; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal])
    begin
        if SalesInvLine.FindSet() then
            repeat
                if LineVATAmount.ContainsKey(SalesInvLine."VAT %") and LineAmount.ContainsKey(SalesInvLine."VAT %") then begin
                    InsertTaxElement(SettlementElement, FormatDecimal(LineVATAmount.Get(SalesInvLine."VAT %")), FormatDecimal(LineAmount.Get(SalesInvLine."VAT %")),
                        GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"), FormatFourDecimal(SalesInvLine."VAT %"),
                        SalesInvLine."VAT %" = 0);
                    LineAmount.Remove(SalesInvLine."VAT %");
                    LineVATAmount.Remove(SalesInvLine."VAT %");
                end;
            until SalesInvLine.Next() = 0;

        SalesInvLine.SetRange("VAT %");
        SalesInvLine.SetRange("VAT Calculation Type");
    end;

    local procedure InsertTradeTax(var SettlementElement: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal])
    begin
        if SalesCrMemoLine.FindSet() then
            repeat
                if LineVATAmount.ContainsKey(SalesCrMemoLine."VAT %") and LineAmount.ContainsKey(SalesCrMemoLine."VAT %") then begin
                    InsertTaxElement(SettlementElement, FormatDecimal(LineVATAmount.Get(SalesCrMemoLine."VAT %")), FormatDecimal(LineAmount.Get(SalesCrMemoLine."VAT %")),
                        GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"), FormatFourDecimal(SalesCrMemoLine."VAT %"),
                        SalesCrMemoLine."VAT %" = 0);

                    LineAmount.Remove(SalesCrMemoLine."VAT %");
                    LineVATAmount.Remove(SalesCrMemoLine."VAT %");
                end;
            until SalesCrMemoLine.Next() = 0;

        SalesCrMemoLine.SetRange("VAT %");
        SalesCrMemoLine.SetRange("VAT Calculation Type");
    end;

    local procedure InsertTaxElement(var SettlementElement: XmlElement; CalculatedAmount: Text; BasisAmount: Text; CategoryCode: Text; RateApplicablePercent: Text; ZeroVAT: Boolean)
    var
        TaxElement: XmlElement;
    begin
        TaxElement := XmlElement.Create('ApplicableTradeTax', XmlNamespaceRAM);
        TaxElement.Add(XmlElement.Create('CalculatedAmount', XmlNamespaceRAM, CalculatedAmount));
        TaxElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, 'VAT'));
        if ZeroVAT then
            TaxElement.Add(XmlElement.Create('ExemptionReason', XmlNamespaceRAM, 'VATEX-EU-O'));
        TaxElement.Add(XmlElement.Create('BasisAmount', XmlNamespaceRAM, BasisAmount));
        TaxElement.Add(XmlElement.Create('CategoryCode', XmlNamespaceRAM, CategoryCode));
        TaxElement.Add(XmlElement.Create('RateApplicablePercent', XmlNamespaceRAM, RateApplicablePercent));
        SettlementElement.Add(TaxElement);
    end;

    local procedure InsertCategoryTradeTax(var RootElement: XmlElement; CategoryCode: Text; RateApplicablePercent: Text)
    var
        TaxElement: XmlElement;
    begin
        TaxElement := XmlElement.Create('CategoryTradeTax', XmlNamespaceRAM);
        TaxElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, 'VAT'));
        TaxElement.Add(XmlElement.Create('CategoryCode', XmlNamespaceRAM, CategoryCode));
        TaxElement.Add(XmlElement.Create('RateApplicablePercent', XmlNamespaceRAM, RateApplicablePercent));
        RootElement.Add(TaxElement);
    end;

    procedure InsertSupplyChainTradeTransaction(var RootXMLNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; CurrencyCode: Code[10]; Currency: Record Currency; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal])
    var
        SupplyChainTradeTransactionElement: XmlElement;
        IncludedLineItemElement: XmlElement;
        AssociatedDocumentLineElement: XmlElement;
        SpecifiedTradeProductElement: XmlElement;
        SpecifiedLineTradeAgreementElement: XmlElement;
        NetPriceProductTradePriceElement: XmlElement;
        ChargeAmountElement: XmlElement;
        SpecifiedLineTradeDeliveryElement: XmlElement;
        BilledQuantityElement: XmlElement;
        SpecifiedLineTradeSettlementElement: XmlElement;
        ApplicableTradeTaxElement: XmlElement;
        SpecifiedTradeSettlementLineMonetarySummationElement: XmlElement;
    begin
        SupplyChainTradeTransactionElement := XmlElement.Create('SupplyChainTradeTransaction', XmlNamespaceRSM);
        if SalesInvoiceLine.FindSet() then
            repeat
                IncludedLineItemElement := XmlElement.Create('IncludedSupplyChainTradeLineItem', XmlNamespaceRAM);
                if SalesInvoiceHeader."Prices Including VAT" then
                    ExcludeVAT(SalesInvoiceLine, Currency."Amount Rounding Precision");
                AssociatedDocumentLineElement := XmlElement.Create('AssociatedDocumentLineDocument', XmlNamespaceRAM);
                AssociatedDocumentLineElement.Add(XmlElement.Create('LineID', XmlNamespaceRAM, Format(SalesInvoiceLine."Line No.")));
                IncludedLineItemElement.Add(AssociatedDocumentLineElement);

                SpecifiedTradeProductElement := XmlElement.Create('SpecifiedTradeProduct', XmlNamespaceRAM);
                SpecifiedTradeProductElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, SalesInvoiceLine.Description));
                IncludedLineItemElement.Add(SpecifiedTradeProductElement);

                SpecifiedLineTradeAgreementElement := XmlElement.Create('SpecifiedLineTradeAgreement', XmlNamespaceRAM);
                NetPriceProductTradePriceElement := XmlElement.Create('NetPriceProductTradePrice', XmlNamespaceRAM);
                ChargeAmountElement := XmlElement.Create('ChargeAmount', XmlNamespaceRAM, FormatFourDecimal(SalesInvoiceLine."Unit Price"));
                NetPriceProductTradePriceElement.Add(ChargeAmountElement);
                SpecifiedLineTradeAgreementElement.Add(NetPriceProductTradePriceElement);
                IncludedLineItemElement.Add(SpecifiedLineTradeAgreementElement);

                SpecifiedLineTradeDeliveryElement := XmlElement.Create('SpecifiedLineTradeDelivery', XmlNamespaceRAM);
                BilledQuantityElement := XmlElement.Create('BilledQuantity', XmlNamespaceRAM, FormatFourDecimal(SalesInvoiceLine.Quantity));
                BilledQuantityElement.SetAttribute('unitCode', GetUoMCode(SalesInvoiceLine."Unit of Measure Code"));
                SpecifiedLineTradeDeliveryElement.Add(BilledQuantityElement);
                IncludedLineItemElement.Add(SpecifiedLineTradeDeliveryElement);

                // Trade Settlement - VAT
                SpecifiedLineTradeSettlementElement := XmlElement.Create('SpecifiedLineTradeSettlement', XmlNamespaceRAM);

                ApplicableTradeTaxElement := XmlElement.Create('ApplicableTradeTax', XmlNamespaceRAM);
                ApplicableTradeTaxElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, 'VAT'));
                ApplicableTradeTaxElement.Add(XmlElement.Create('CategoryCode', XmlNamespaceRAM, GetTaxCategoryID(SalesInvoiceLine."Tax Category", SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group")));
                ApplicableTradeTaxElement.Add(XmlElement.Create('RateApplicablePercent', XmlNamespaceRAM, FormatFourDecimal(SalesInvoiceLine."VAT %")));
                SpecifiedLineTradeSettlementElement.Add(ApplicableTradeTaxElement);

                InsertAllowanceCharge(SpecifiedLineTradeSettlementElement, 'Line Discount', GetTaxCategoryID(SalesInvoiceLine."Tax Category", SalesInvoiceLine."VAT Bus. Posting Group",
                                   SalesInvoiceLine."VAT Prod. Posting Group"), SalesInvoiceLine."Line Discount Amount", SalesInvoiceLine."VAT %", false);

                SpecifiedTradeSettlementLineMonetarySummationElement := XmlElement.Create('SpecifiedTradeSettlementLineMonetarySummation', XmlNamespaceRAM);
                SpecifiedTradeSettlementLineMonetarySummationElement.Add(XmlElement.Create('LineTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesInvoiceLine.Amount + SalesInvoiceLine."Inv. Discount Amount")));
                SpecifiedLineTradeSettlementElement.Add(SpecifiedTradeSettlementLineMonetarySummationElement);

                IncludedLineItemElement.Add(SpecifiedLineTradeSettlementElement);
                SupplyChainTradeTransactionElement.Add(IncludedLineItemElement);
            until SalesInvoiceLine.Next() = 0;
        InsertApplicableHeaderTradeAgreement(SupplyChainTradeTransactionElement, SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Your Reference");
        InsertApplicableHeaderTradeDelivery(SupplyChainTradeTransactionElement, SalesInvoiceHeader);
        SalesInvoiceHeader.CalcFields("Amount Including VAT", Amount);
        InsertApplicableHeaderTradeSettlement(SupplyChainTradeTransactionElement, SalesInvoiceHeader, SalesInvoiceLine, CurrencyCode, LineAmount, LineVATAmount, LineAmounts, LineDiscAmount);

        RootXMLNode.Add(SupplyChainTradeTransactionElement);
    end;

    procedure InsertSupplyChainTradeTransaction(var RootXMLNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyCode: Code[10]; Currency: Record Currency; var LineAmount: Dictionary of [Decimal, Decimal]; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal])
    var
        SupplyChainTradeTransactionElement: XmlElement;
        IncludedLineItemElement: XmlElement;
        AssociatedDocumentLineElement: XmlElement;
        SpecifiedTradeProductElement: XmlElement;
        SpecifiedLineTradeAgreementElement: XmlElement;
        NetPriceProductTradePriceElement: XmlElement;
        ChargeAmountElement: XmlElement;
        SpecifiedLineTradeDeliveryElement: XmlElement;
        BilledQuantityElement: XmlElement;
        SpecifiedLineTradeSettlementElement: XmlElement;
        ApplicableTradeTaxElement: XmlElement;
        SpecifiedTradeSettlementLineMonetarySummationElement: XmlElement;
    begin
        SupplyChainTradeTransactionElement := XmlElement.Create('SupplyChainTradeTransaction', XmlNamespaceRSM);
        if SalesCrMemoLine.FindSet() then
            repeat
                IncludedLineItemElement := XmlElement.Create('IncludedSupplyChainTradeLineItem', XmlNamespaceRAM);
                if SalesCrMemoHeader."Prices Including VAT" then
                    ExcludeVAT(SalesCrMemoLine, Currency."Amount Rounding Precision");
                AssociatedDocumentLineElement := XmlElement.Create('AssociatedDocumentLineDocument', XmlNamespaceRAM);
                AssociatedDocumentLineElement.Add(XmlElement.Create('LineID', XmlNamespaceRAM, Format(SalesCrMemoLine."Line No.")));
                IncludedLineItemElement.Add(AssociatedDocumentLineElement);

                SpecifiedTradeProductElement := XmlElement.Create('SpecifiedTradeProduct', XmlNamespaceRAM);
                SpecifiedTradeProductElement.Add(XmlElement.Create('Name', XmlNamespaceRAM, SalesCrMemoLine.Description));
                IncludedLineItemElement.Add(SpecifiedTradeProductElement);

                SpecifiedLineTradeAgreementElement := XmlElement.Create('SpecifiedLineTradeAgreement', XmlNamespaceRAM);
                NetPriceProductTradePriceElement := XmlElement.Create('NetPriceProductTradePrice', XmlNamespaceRAM);
                ChargeAmountElement := XmlElement.Create('ChargeAmount', XmlNamespaceRAM, FormatFourDecimal(SalesCrMemoLine."Unit Price"));
                NetPriceProductTradePriceElement.Add(ChargeAmountElement);
                SpecifiedLineTradeAgreementElement.Add(NetPriceProductTradePriceElement);
                IncludedLineItemElement.Add(SpecifiedLineTradeAgreementElement);

                SpecifiedLineTradeDeliveryElement := XmlElement.Create('SpecifiedLineTradeDelivery', XmlNamespaceRAM);
                BilledQuantityElement := XmlElement.Create('BilledQuantity', XmlNamespaceRAM, FormatFourDecimal(SalesCrMemoLine.Quantity));
                BilledQuantityElement.SetAttribute('unitCode', GetUoMCode(SalesCrMemoLine."Unit of Measure Code"));
                SpecifiedLineTradeDeliveryElement.Add(BilledQuantityElement);
                IncludedLineItemElement.Add(SpecifiedLineTradeDeliveryElement);

                // Trade Settlement - VAT
                SpecifiedLineTradeSettlementElement := XmlElement.Create('SpecifiedLineTradeSettlement', XmlNamespaceRAM);

                ApplicableTradeTaxElement := XmlElement.Create('ApplicableTradeTax', XmlNamespaceRAM);
                ApplicableTradeTaxElement.Add(XmlElement.Create('TypeCode', XmlNamespaceRAM, 'VAT'));
                ApplicableTradeTaxElement.Add(XmlElement.Create('CategoryCode', XmlNamespaceRAM, GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group")));
                ApplicableTradeTaxElement.Add(XmlElement.Create('RateApplicablePercent', XmlNamespaceRAM, FormatFourDecimal(SalesCrMemoLine."VAT %")));
                SpecifiedLineTradeSettlementElement.Add(ApplicableTradeTaxElement);

                InsertAllowanceCharge(SpecifiedLineTradeSettlementElement, 'Line Discount', GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group",
                    SalesCrMemoLine."VAT Prod. Posting Group"), SalesCrMemoLine."Line Discount Amount", SalesCrMemoLine."VAT %", false);
                SpecifiedTradeSettlementLineMonetarySummationElement := XmlElement.Create('SpecifiedTradeSettlementLineMonetarySummation', XmlNamespaceRAM);
                SpecifiedTradeSettlementLineMonetarySummationElement.Add(XmlElement.Create('LineTotalAmount', XmlNamespaceRAM, FormatDecimal(SalesCrMemoLine.Amount + SalesCrMemoLine."Inv. Discount Amount")));
                SpecifiedLineTradeSettlementElement.Add(SpecifiedTradeSettlementLineMonetarySummationElement);

                IncludedLineItemElement.Add(SpecifiedLineTradeSettlementElement);
                SupplyChainTradeTransactionElement.Add(IncludedLineItemElement);
            until SalesCrMemoLine.Next() = 0;
        InsertApplicableHeaderTradeAgreement(SupplyChainTradeTransactionElement, SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Your Reference");
        InsertApplicableHeaderTradeDelivery(SupplyChainTradeTransactionElement, SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT", Amount);
        InsertApplicableHeaderTradeSettlement(SupplyChainTradeTransactionElement, SalesCrMemoHeader, SalesCrMemoLine, CurrencyCode, LineAmount, LineVATAmount, LineAmounts, LineDiscAmount);

        RootXMLNode.Add(SupplyChainTradeTransactionElement);
    end;

    local procedure InsertPaymentTerms(var RootXMLNode: XmlElement; PaymentTermsCode: Code[10])
    var
        PaymentTerms: Record "Payment Terms";
        PaymentTermsElement: XmlElement;
        PaymentTermsDescriptionElement: XmlElement;
    begin
        if PaymentTermsCode = '' then
            exit;
        if not PaymentTerms.Get(PaymentTermsCode) then
            exit;

        PaymentTermsElement := XmlElement.Create('SpecifiedTradePaymentTerms', XmlNamespaceRAM);
        PaymentTermsDescriptionElement := XmlElement.Create('Description', XmlNamespaceRAM, PaymentTerms.Description);
        PaymentTermsElement.Add(PaymentTermsDescriptionElement);
        RootXMLNode.Add(PaymentTermsElement);
    end;

    local procedure InsertPaymentMethod(var RootXMLNode: XmlElement; PaymentMethodCode: Code[10])
    var
        PaymentMethod: Record "Payment Method";
        PaymentMethodElement, PaymentMethodTypeCodeElement, PaymentMethodIBANElement : XmlElement;
    begin
        if PaymentMethodCode = '' then
            exit;
        if not PaymentMethod.Get(PaymentMethodCode) then
            exit;
        PaymentMethodElement := XmlElement.Create('SpecifiedTradeSettlementPaymentMeans', XmlNamespaceRAM);
        PaymentMethodTypeCodeElement := XmlElement.Create('TypeCode', XmlNamespaceRAM, '58'); //generic for Credit transfer
        PaymentMethodElement.Add(PaymentMethodTypeCodeElement);

        PaymentMethodIBANElement := XmlElement.Create('PayeePartyCreditorFinancialAccount', XmlNamespaceRAM);
        PaymentMethodIBANElement.Add(XmlElement.Create('IBANID', XmlNamespaceRAM, GetIBAN(CompanyInformation.IBAN)));
        PaymentMethodElement.Add(PaymentMethodIBANElement);
        RootXMLNode.Add(PaymentMethodElement);
    end;

    local procedure InsertInvDiscountAllowanceCharge(var RootXMLNode: XmlElement; var SalesInvLine: Record "Sales Invoice Line"; var LineDiscAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal])
    var
        InvDiscountAmount: Decimal;
    begin
        InvDiscountAmount := LineAmounts.Get(SalesInvLine.FieldName("Inv. Discount Amount"));
        if InvDiscountAmount = 0 then
            exit;
        if SalesInvLine.FindSet() then
            repeat
                if LineDiscAmount.ContainsKey(SalesInvLine."VAT %") then begin
                    InsertAllowanceCharge(
                               RootXMLNode, 'Document discount',
                               GetTaxCategoryID(SalesInvLine."Tax Category", SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group"),
                               LineDiscAmount.Get(SalesInvLine."VAT %"), SalesInvLine."VAT %", true);
                    LineDiscAmount.Remove(SalesInvLine."VAT %");
                end;
            until SalesInvLine.Next() = 0;
    end;

    local procedure InsertInvDiscountAllowanceCharge(var RootXMLNode: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var LineDiscAmount: Dictionary of [Decimal, Decimal]; var LineAmounts: Dictionary of [Text, Decimal])
    var
        InvDiscountAmount: Decimal;
    begin
        InvDiscountAmount := LineAmounts.Get(SalesCrMemoLine.FieldName("Inv. Discount Amount"));
        if InvDiscountAmount = 0 then
            exit;
        if SalesCrMemoLine.FindSet() then
            repeat
                if LineDiscAmount.ContainsKey(SalesCrMemoLine."VAT %") then begin
                    InsertAllowanceCharge(
                               RootXMLNode, 'Document discount',
                               GetTaxCategoryID(SalesCrMemoLine."Tax Category", SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group"),
                               LineDiscAmount.Get(SalesCrMemoLine."VAT %"), SalesCrMemoLine."VAT %", true);
                    LineDiscAmount.Remove(SalesCrMemoLine."VAT %");
                end;
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure InsertAllowanceCharge(var RootXMLNode: XmlElement; AllowanceChargeReason: Text; TaxCategory: Text; Amount: Decimal; Percent: Decimal; InsertCategoryTax: Boolean)
    var
        AllowanceChargeElement: XmlElement;
    begin
        AllowanceChargeElement := XmlElement.Create('SpecifiedTradeAllowanceCharge', XmlNamespaceRAM);
        AllowanceChargeElement.Add(XmlElement.Create('ChargeIndicator', XmlNamespaceRAM, XmlElement.Create('Indicator', XmlNamespaceUDT, false)));
        AllowanceChargeElement.Add(XmlElement.Create('ActualAmount', XmlNamespaceRAM, FormatDecimal(Amount)));
        AllowanceChargeElement.Add(XmlElement.Create('Reason', XmlNamespaceRAM, AllowanceChargeReason));
        if InsertCategoryTax then
            InsertCategoryTradeTax(AllowanceChargeElement, TaxCategory, FormatFourDecimal(Percent));
        RootXMLNode.Add(AllowanceChargeElement);
    end;

    local procedure CalculateLineAmounts(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    var
        TotalInvDiscountAmount: Decimal;
    begin
        repeat
            if SalesInvoiceHeader."Prices Including VAT" then
                SalesInvLine."Inv. Discount Amount" := Round(SalesInvLine."Inv. Discount Amount" / (1 + SalesInvLine."VAT %" / 100), Currency."Amount Rounding Precision");
            TotalInvDiscountAmount += SalesInvLine."Inv. Discount Amount";
        until SalesInvLine.Next() = 0;

        SalesInvLine.CalcSums(Amount, "Amount Including VAT");

        if not LineAmounts.ContainsKey(SalesInvLine.FieldName(Amount)) then
            LineAmounts.Add(SalesInvLine.FieldName(Amount), SalesInvLine.Amount);
        if not LineAmounts.ContainsKey(SalesInvLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(SalesInvLine.FieldName("Amount Including VAT"), SalesInvLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(SalesInvLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(SalesInvLine.FieldName("Inv. Discount Amount"), TotalInvDiscountAmount);
        OnAfterCalculateInvoiceLineAmounts(SalesInvoiceHeader, SalesInvLine, Currency, LineAmounts);
    end;

    local procedure CalculateLineAmounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; Currency: Record Currency; var LineAmounts: Dictionary of [Text, Decimal])
    var
        TotalInvDiscountAmount: Decimal;
    begin
        repeat
            if SalesCrMemoHeader."Prices Including VAT" then
                SalesCrMemoLine."Inv. Discount Amount" := Round(SalesCrMemoLine."Inv. Discount Amount" / (1 + SalesCrMemoLine."VAT %" / 100), Currency."Amount Rounding Precision");
            TotalInvDiscountAmount += SalesCrMemoLine."Inv. Discount Amount";
        until SalesCrMemoLine.Next() = 0;

        SalesCrMemoLine.CalcSums(Amount, "Amount Including VAT");

        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName(Amount)) then
            LineAmounts.Add(SalesCrMemoLine.FieldName(Amount), SalesCrMemoLine.Amount);
        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName("Amount Including VAT")) then
            LineAmounts.Add(SalesCrMemoLine.FieldName("Amount Including VAT"), SalesCrMemoLine."Amount Including VAT");
        if not LineAmounts.ContainsKey(SalesCrMemoLine.FieldName("Inv. Discount Amount")) then
            LineAmounts.Add(SalesCrMemoLine.FieldName("Inv. Discount Amount"), TotalInvDiscountAmount);
        OnAfterCalculateCrMemoLineAmounts(SalesCrMemoHeader, SalesCrMemoLine, Currency, LineAmounts);
    end;

    local procedure ExcludeVAT(var SalesInvLine: Record "Sales Invoice Line"; RoundingPrecision: Decimal)
    begin
        SalesInvLine."Line Discount Amount" := Round(SalesInvLine."Line Discount Amount" / (1 + SalesInvLine."VAT %" / 100), RoundingPrecision);
        SalesInvLine."Unit Price" := SalesInvLine."Unit Price" / (1 + SalesInvLine."VAT %" / 100);
        SalesInvLine."Inv. Discount Amount" := Round(SalesInvLine."Inv. Discount Amount" / (1 + SalesInvLine."VAT %" / 100), RoundingPrecision);
    end;

    local procedure ExcludeVAT(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; RoundingPrecision: Decimal)
    begin
        SalesCrMemoLine."Line Discount Amount" := Round(SalesCrMemoLine."Line Discount Amount" / (1 + SalesCrMemoLine."VAT %" / 100), RoundingPrecision);
        SalesCrMemoLine."Unit Price" := SalesCrMemoLine."Unit Price" / (1 + SalesCrMemoLine."VAT %" / 100);
        SalesCrMemoLine."Inv. Discount Amount" := Round(SalesCrMemoLine."Inv. Discount Amount" / (1 + SalesCrMemoLine."VAT %" / 100), RoundingPrecision);
    end;

    local procedure InsertVATAmounts(var SalesInvLine: Record "Sales Invoice Line"; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmount: Dictionary of [Decimal, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal]; PricesIncVAT: Boolean; Currency: Record Currency)
    begin
        if SalesInvLine.FindSet() then
            repeat
                AddAmountForVAT(SalesInvLine."VAT %", SalesInvLine."Amount Including VAT" - SalesInvLine.Amount, LineVATAmount);
                AddAmountForVAT(SalesInvLine."VAT %", SalesInvLine.Amount, LineAmount);
                if PricesIncVAT then
                    ExcludeVAT(SalesInvLine, Currency."Amount Rounding Precision");
                AddAmountForVAT(SalesInvLine."VAT %", SalesInvLine."Inv. Discount Amount", LineDiscAmount);
            until SalesInvLine.Next() = 0;
    end;

    local procedure InsertVATAmounts(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var LineVATAmount: Dictionary of [Decimal, Decimal]; var LineAmount: Dictionary of [Decimal, Decimal]; var LineDiscAmount: Dictionary of [Decimal, Decimal]; PricesIncVAT: Boolean; Currency: Record Currency)
    begin
        if SalesCrMemoLine.FindSet() then
            repeat
                AddAmountForVAT(SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount, LineVATAmount);
                AddAmountForVAT(SalesCrMemoLine."VAT %", SalesCrMemoLine.Amount, LineAmount);
                if PricesIncVAT then
                    ExcludeVAT(SalesCrMemoLine, Currency."Amount Rounding Precision");
                AddAmountForVAT(SalesCrMemoLine."VAT %", SalesCrMemoLine."Inv. Discount Amount", LineDiscAmount);
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure AddAmountForVAT(VATPercent: Decimal; NewAmount: Decimal; var TotalAmounts: Dictionary of [Decimal, Decimal])
    begin
        if not TotalAmounts.ContainsKey(VATPercent) then
            TotalAmounts.Add(VATPercent, NewAmount)
        else
            TotalAmounts.Set(VATPercent, TotalAmounts.Get(VATPercent) + NewAmount);
    end;

    local procedure GetBuyerReference(YourReference: Text[35]; SellToCustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        case EDocumentService."Buyer Reference" of
            EDocumentService."Buyer Reference"::"Customer Reference":
                begin
                    Customer.Get(SellToCustomerNo);
                    exit(Customer."E-Invoice Routing No.");
                end;
            EDocumentService."Buyer Reference"::"Your Reference":
                exit(YourReference);
        end;
    end;

    local procedure GetIBAN(IBAN: Text[50]) IBANFormatted: Text[50]
    begin
        // Format IBAN to remove spaces and ensure it is in uppercase
        if IBAN = '' then
            exit('');
        IBANFormatted := UpperCase(DelChr(IBAN, '=', ' '));
        exit(CopyStr(IBANFormatted, 1, 50));
    end;
    #region CommonFunctions
    local procedure GetSetups()
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
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
        exit(Format(VarDecimal, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()))
    end;

    procedure FormatFourDecimal(VarDecimal: Decimal): Text
    begin
        exit(Format(VarDecimal, 0, '<Precision,4:4><Standard Format,9>'))
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

    local procedure GetTaxCategoryID(TaxCategory: Code[10]; VATBusPostingGroup: Code[20]; VATProductPostingGroup: Code[20]): Text[10];
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if TaxCategory <> '' then
            exit(TaxCategory);
        if not VATPostingSetup.Get(VATBusPostingGroup, VATProductPostingGroup) then
            exit('');
        exit(VATPostingSetup."Tax Category");
    end;

    local procedure FindEDocumentService()
    begin
        EDocumentService.SetRange("Document Format", EDocumentService."Document Format"::ZUGFeRD);
        if EDocumentService.FindLast() then;
        OnAfterFindEDocumentService(EDocumentService);
    end;
    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindEDocumentService(var EDocumentService: Record "E-Document Service")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesInvHeaderData(var XMLCurrNode: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeSalesInvXmlDocumentWriteToFile(var XMLDoc: XmlDocument; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDocumentLinesExistOnAfterFilterSalesInvLine(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesCrMemoHeaderData(var XMLCurrNode: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeSalesCrMemoXmlDocumentWriteToFile(var XMLDoc: XmlDocument; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
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

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Invoice", 'OnPreReportOnBeforeInitializePDF', '', false, false)]
    local procedure OnBeforeInitializePDFSalesInvoice(SalesInvHeader: Record "Sales Invoice Header"; var CreateZUGFeRDXML: Boolean)
    begin
        CreateZUGFeRDXML := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Credit Memo", 'OnPreReportOnBeforeInitializePDF', '', false, false)]
    local procedure OnBeforeInitializePDFSalesCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CreateZUGFeRDXML: Boolean)
    begin
        CreateZUGFeRDXML := true;
    end;
}