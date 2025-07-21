// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;
using Microsoft.Foundation.Address;

codeunit 28006 "PINT A-NZ Export"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        XmlNamespaceCBCTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;

    procedure PINTANZValidation(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        TempVATPostingSetup: Record "VAT Posting Setup" temporary;
        DummyTaxAmount: Decimal;
        DummyCurrencyCode: Code[3];
        IsInvoice: Boolean;
        WrongLengthCustomerErr: Label '%1 length must be exactly %2 characters in %3 %4', Comment = '%1 = field name, %2 = number, %3 = table name, %4 = id code';
        WrongLengthCompanyInfoErr: Label '%1 length must be exactly %2 characters in %3', Comment = '%1 = field name, %2 = number, %3 = table name';
        TaxCategoryErr: Label 'Tax Category must be in [UNCL5305] code list: (E, S, Z, G, O) in %1: %2 %3', Comment = '%1 = Table Name, %2 = identifier code, %3 = identifier code';
        TaxCategoryPctErr: Label 'Tax percent must be 0 for Tax Category %1 in %2: %3 %4', Comment = '%1 = tax category code, %2 = Table Name, %3 = identifier code, %4 = identifier code';
    begin
        CompanyInformation.Get();
        GetInfoFromHeader(SourceDocumentHeader, DummyTaxAmount, DummyCurrencyCode, Customer, TempVATPostingSetup, IsInvoice);

        // ABN/GLN length for company info (AU - ABN - 11, NZ - GLN - 13)
        if IsAU(CompanyInformation."Country/Region Code") then
            if not (StrLen(CompanyInformation.ABN) = 11) then
                Error(WrongLengthCompanyInfoErr, CompanyInformation.FieldCaption(ABN), 11, CompanyInformation.TableCaption());
        if IsNZ(CompanyInformation."Country/Region Code") then
            if not (StrLen(CompanyInformation.GLN) = 13) then
                Error(WrongLengthCompanyInfoErr, CompanyInformation.FieldCaption(GLN), 13, CompanyInformation.TableCaption());

        // ABN/GLN length for customer info (AU - ABN - 11, NZ - GLN - 13)
        if IsAU(Customer."Country/Region Code") then
            if not (StrLen(Customer.ABN) = 11) then
                Error(WrongLengthCustomerErr, Customer.FieldCaption(ABN), 11, Customer.TableCaption(), Customer."No.");
        if IsNZ(Customer."Country/Region Code") then
            if not (StrLen(Customer.GLN) = 13) then
                Error(WrongLengthCustomerErr, Customer.FieldCaption(GLN), 13, Customer.TableCaption(), Customer."No.");

        // VAT Posting Setup (s) tax category must be in [UNCL5305] code list: [E, S, Z, G, O]. S - Standard, E - Exempt, Z - Zero, G - Free export item, tax not charged, O - Outside scope of tax
        // Rates must match the tax category: Z, E = 0
        if TempVATPostingSetup.FindSet() then
            repeat
                if not (TempVATPostingSetup."Tax Category" in ['E', 'S', 'Z', 'G', 'O']) then
                    Error(TaxCategoryErr, TempVATPostingSetup.TableCaption(), TempVATPostingSetup."VAT Bus. Posting Group", TempVATPostingSetup."VAT Prod. Posting Group");
                if TempVATPostingSetup."Tax Category" in ['E', 'Z'] then
                    if TempVATPostingSetup."VAT %" <> 0 then
                        Error(TaxCategoryPctErr, TempVATPostingSetup."Tax Category", TempVATPostingSetup.TableCaption(), TempVATPostingSetup."VAT Bus. Posting Group", TempVATPostingSetup."VAT Prod. Posting Group");
            until TempVATPostingSetup.Next() = 0;
    end;

    procedure AddPINTANZSpecific(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        TempDummyVATPostingSetup: Record "VAT Posting Setup" temporary;
        TaxAmount: Decimal;
        CurrencyCode: Code[3];
        InStream: InStream;
        OutStream: OutStream;
        XmlDoc: XmlDocument;
        XmlNSManager: XmlNamespaceManager;
        XmlNode, XmlNewNode : XmlNode;
        TaxElement: XmlElement;
        NodeList: XmlNodeList;
        IDType, IDValue, HeaderTok : Text;
        IsInvoice: Boolean;
        InvoiceTok: Label '/ns1:Invoice', Locked = true;
        CreditMemoTok: Label '/ns1:CreditMemo', Locked = true;
        AccountingSupplierPartyTok: Label '/cac:AccountingSupplierParty', Locked = true;
        AccountingCustomerPartyTok: Label '/cac:AccountingCustomerParty', Locked = true;
        PartyEndpointIDTok: Label '/cac:Party/cbc:EndpointID', Locked = true;
        TaxTotalAmountTok: Label '/cac:TaxTotal/cbc:TaxAmount', Locked = true;
        TaxSubtotalAmountTok: Label '/cac:TaxTotal/cac:TaxSubtotal/cbc:TaxAmount', Locked = true;
        CustomizationIDTok: Label '/cbc:CustomizationID', Locked = true;
        ProfileIDTok: Label '/cbc:ProfileID', Locked = true;
        TaxIDTok: Label '//cac:TaxScheme/cbc:ID', Locked = true;
        PartyLegalEntityTok: Label '/cac:Party/cac:PartyLegalEntity/cbc:CompanyID', Locked = true;
        AUNZCustomizationTok: Label 'urn:peppol:pint:billing-1@aunz-1', Locked = true;
        AUNZProfileTok: Label 'urn:peppol:bis:billing', Locked = true;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);

        CompanyInformation.Get();
        GetInfoFromHeader(SourceDocumentHeader, TaxAmount, CurrencyCode, Customer, TempDummyVATPostingSetup, IsInvoice);
        if IsInvoice then
            HeaderTok := InvoiceTok
        else
            HeaderTok := CreditMemoTok;

        XmlNSManager := CreateNamespaceManager(XmlDoc);

        // [ibr-cl-25]-Endpoint identifier scheme identifier (ibt-034-1), (ibt-049-1) MUST belong to the CEF EAS code list
        if XmlDoc.SelectSingleNode(HeaderTok + AccountingSupplierPartyTok + PartyEndpointIDTok, XmlNSManager, XmlNode) then
            if IsAUNZ(CompanyInformation."Country/Region Code") then begin
                IDType := GetSchemaIDTok(CompanyInformation."Country/Region Code");
                IDValue := GetIDValueCompany(CompanyInformation);
                XmlNewNode := XmlElement.Create('EndpointID', XmlNamespaceCBCTok, XmlAttribute.Create('schemeID', IDType), IDValue).AsXmlNode();
                XmlNode.ReplaceWith(XmlNewNode);
            end;

        // [ibr-cl-25]-Endpoint identifier scheme identifier (ibt-034-1), (ibt-049-1) MUST belong to the CEF EAS code list
        if XmlDoc.SelectSingleNode(HeaderTok + AccountingCustomerPartyTok + PartyEndpointIDTok, XmlNSManager, XmlNode) then
            if IsAUNZ(Customer."Country/Region Code") then begin
                IDType := GetSchemaIDTok(Customer."Country/Region Code");
                IDValue := GetIDValueCustomer(Customer);
                XmlNewNode := XmlElement.Create('EndpointID', XmlNamespaceCBCTok, XmlAttribute.Create('schemeID', IDType), IDValue).AsXmlNode();
                XmlNode.ReplaceWith(XmlNewNode);
            end;

        // [aligned-ibrp-001-aunz]-Specification identifier (ibt-024) MUST start with the value 'urn:peppol:pint:billing-1@aunz-1'.
        if XmlDoc.SelectSingleNode(HeaderTok + CustomizationIDTok, XmlNSManager, XmlNode) then begin
            XmlNewNode := XmlElement.Create('CustomizationID', XmlNamespaceCBCTok, AUNZCustomizationTok).AsXmlNode();
            XmlNode.ReplaceWith(XmlNewNode);
        end;

        // [aligned-ibrp-002]-Business process (ibt-023) MUST be in the format 'urn:peppol:bis:billing'.
        if XmlDoc.SelectSingleNode(HeaderTok + ProfileIDTok, XmlNSManager, XmlNode) then begin
            XmlNewNode := XmlElement.Create('ProfileID', XmlNamespaceCBCTok, AUNZProfileTok).AsXmlNode();
            XmlNode.ReplaceWith(XmlNewNode);
        end;

        // [aligned-ibrp-047-aunz]-Each tax breakdown (ibg-23) MUST be defined through a tax category code (ibt-118).
        if XmlDoc.SelectNodes(HeaderTok + TaxIDTok, XmlNSManager, NodeList) then
            foreach XmlNode in NodeList do begin
                XmlNewNode := XmlElement.Create('ID', XmlNamespaceCBCTok, 'GST').AsXmlNode();
                XmlNode.ReplaceWith(XmlNewNode);
            end;

        // [ibr-co-15]-Invoice total amount with Tax (ibt-112) = Invoice total amount without Tax (ibt-109) + Invoice total Tax amount (ibt-110).
        if XmlDoc.SelectSingleNode(HeaderTok + TaxTotalAmountTok, XmlNSManager, XmlNode) then begin
            TaxElement := XmlElement.Create('TaxAmount', XmlNamespaceCBCTok, Format(TaxAmount, 0, 9));
            TaxElement.SetAttribute('currencyID', CurrencyCode);
            XmlNewNode := TaxElement.AsXmlNode();
            XmlNode.ReplaceWith(XmlNewNode);
        end;

        if XmlDoc.SelectSingleNode(HeaderTok + TaxSubtotalAmountTok, XmlNSManager, XmlNode) then
            XmlNode.ReplaceWith(XmlNewNode);

        // [aligned-ibr-001-aunz]-An invoice must contain the Seller's ABN (ibt-030) if Seller country (ibt-040) is Australia
        if XmlDoc.SelectSingleNode(HeaderTok + AccountingSupplierPartyTok + PartyLegalEntityTok, XmlNSManager, XmlNode) then
            if IsAUNZ(CompanyInformation."Country/Region Code") then begin
                IDType := GetSchemaIDTok(CompanyInformation."Country/Region Code");
                IDValue := GetIDValueCompany(CompanyInformation);
                XmlNewNode := XmlElement.Create('CompanyID', XmlNamespaceCBCTok, XmlAttribute.Create('schemeID', IDType), IDValue).AsXmlNode();
                XmlNode.ReplaceWith(XmlNewNode);
            end;

        // [aligned-ibr-004-aunz]-An invoice must contain the Buyer's ABN (ibt-047) if Buyer country (ibt-055) is Australia
        if XmlDoc.SelectSingleNode(HeaderTok + AccountingCustomerPartyTok + PartyLegalEntityTok, XmlNSManager, XmlNode) then
            if IsAUNZ(Customer."Country/Region Code") then begin
                IDType := GetSchemaIDTok(Customer."Country/Region Code");
                IDValue := GetIDValueCustomer(Customer);
                XmlNewNode := XmlElement.Create('CompanyID', XmlNamespaceCBCTok, XmlAttribute.Create('schemeID', IDType), IDValue).AsXmlNode();
                XmlNode.ReplaceWith(XmlNewNode);
            end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.WriteTo(OutStream);
    end;

    local procedure GetInfoFromHeader(var SourceDocumentHeader: RecordRef; var TaxAmount: Decimal; var CurrencyCode: Code[3]; var Customer: Record "Customer"; var TempVATPostingSetup: Record "VAT Posting Setup" temporary; var IsInvoice: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        case SourceDocumentHeader.Number of
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.SetRecFilter();
                    SalesInvoiceHeader.FindFirst();
                    SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
                    TaxAmount := SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount;
                    CurrencyCode := CopyStr(SalesInvoiceHeader."Currency Code", 1, 3);
                    Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    if SalesInvoiceLine.FindSet() then
                        repeat
                            VATPostingSetup.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
                            TempVATPostingSetup := VATPostingSetup;
                            if TempVATPostingSetup.Insert() then;
                        until SalesInvoiceLine.Next() = 0;
                    IsInvoice := true;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.SetRecFilter();
                    SalesCrMemoHeader.FindFirst();
                    SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
                    TaxAmount := SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount;
                    CurrencyCode := CopyStr(SalesCrMemoHeader."Currency Code", 1, 3);
                    Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");
                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    if SalesCrMemoLine.FindSet() then
                        repeat
                            VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group");
                            TempVATPostingSetup := VATPostingSetup;
                            if TempVATPostingSetup.Insert() then;
                        until SalesCrMemoLine.Next() = 0;
                    IsInvoice := false;
                end;
        end;
        GeneralLedgerSetup.Get();
        if CurrencyCode = '' then
            CurrencyCode := CopyStr(GeneralLedgerSetup."LCY Code", 1, 3);
    end;

    local procedure GetSchemaIDTok(CountryRegionCode: Code[10]): Text
    var
        ABNIDTok: Label '0151', Locked = true;
        NZBNIDTok: Label '0088', Locked = true;
    begin
        if IsAU(CountryRegionCode) then
            exit(ABNIDTok);
        if IsNZ(CountryRegionCode) then
            exit(NZBNIDTok);
    end;

    local procedure GetIDValueCompany(CompanyInformation: Record "Company Information"): Text
    begin
        if IsAU(CompanyInformation."Country/Region Code") then
            exit(CompanyInformation.ABN);
        if IsNZ(CompanyInformation."Country/Region Code") then
            exit(CompanyInformation.GLN);
        exit(CompanyInformation."VAT Registration No.")
    end;

    local procedure GetIDValueCustomer(Customer: Record "Customer"): Text
    begin
        if IsAU(Customer."Country/Region Code") then
            exit(Customer.ABN);
        if IsNZ(Customer."Country/Region Code") then
            exit(Customer.GLN);
        exit(Customer."VAT Registration No.")
    end;

    local procedure IsAU(CountryRegionCode: Code[10]): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.Get(CountryRegionCode) then
            exit(false);
        if CountryRegion."ISO Code" = 'AU' then
            exit(true);
    end;

    local procedure IsNZ(CountryRegionCode: Code[10]): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.Get(CountryRegionCode) then
            exit(false);
        if CountryRegion."ISO Code" = 'NZ' then
            exit(true);
    end;

    local procedure IsAUNZ(CountryRegionCode: Code[10]): Boolean
    begin
        if IsAU(CountryRegionCode) or IsNZ(CountryRegionCode) then
            exit(true);
    end;

    local procedure CreateNamespaceManager(XmlDoc: XmlDocument) Manager: XmlNamespaceManager
    var
        XmlNamespaceCACTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        XmlNamespaceNS1Tok: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
    begin
        Manager.NameTable(XmlDoc.NameTable());
        Manager.AddNamespace('cbc', XmlNamespaceCBCTok);
        Manager.AddNamespace('cac', XmlNamespaceCACTok);
        Manager.AddNamespace('ns1', XmlNamespaceNS1Tok);
    end;
}