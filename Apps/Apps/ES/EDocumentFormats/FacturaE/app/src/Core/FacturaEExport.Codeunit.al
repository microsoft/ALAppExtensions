// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Period;
using Microsoft.Foundation.UOM;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Telemetry;
using System.Utilities;

codeunit 10774 "Factura-E Export"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'EDocument Format Factura-E', Locked = true;
        StartEventNameTok: Label 'Export initiated. IsBatch is: %1', Locked = true;
        EndEventNameTok: Label 'Export completed', Locked = true;

    procedure Export(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        OnBeforeExport(SourceDocumentHeader, SourceDocumentLines, TempBlob, IsBatch);
        FeatureTelemetry.LogUsage('0000OCR', FeatureNameTok, StrSubstNo(StartEventNameTok, Format(IsBatch)));
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();

        case SourceDocumentHeader.Number of
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(SalesInvoiceLine);
                    ExportInvoice(SalesInvoiceHeader, SalesInvoiceLine, TempBlob, IsBatch);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(SalesCrMemoLine);
                    ExportCreditMemo(SalesCrMemoHeader, SalesCrMemoLine, TempBlob, IsBatch);
                end;
        end;
        FeatureTelemetry.LogUsage('0000OCT', FeatureNameTok, EndEventNameTok);
        OnAfterExport(SourceDocumentHeader, SourceDocumentLines, TempBlob, IsBatch);
    end;

    local procedure ExportInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        RootXMLNode: XmlElement;
        XMLDocOut: XmlDocument;
        FileHeaderNode: XmlElement;
        InvoicesNode: XmlElement;
        PartiesNode: XmlElement;
        FileOutStream: OutStream;
        FileHeaderData, SellerData, BuyerData : Dictionary of [Text, Text];
        FileHeaderTotals: Dictionary of [Text, Decimal];
    begin
        TempBlob.CreateOutStream(FileOutStream);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        GatherSellerData(SellerData);
        GatherBuyerData(BuyerData, SalesInvoiceHeader."Bill-to Customer No.");
        InvoicesNode := CreateInvoicesNode(FileHeaderTotals, SalesInvoiceHeader, SalesInvoiceLine, IsBatch);
        GatherFileHeaderData(FileHeaderData, SalesInvoiceHeader, FileHeaderTotals);

        PartiesNode := CreatePartiesNode(SellerData, BuyerData);
        FileHeaderNode := CreateFileHeaderNode(FileHeaderData, FileHeaderTotals);

        RootXMLNode.Add(FileHeaderNode);
        RootXMLNode.Add(PartiesNode);
        RootXMLNode.Add(InvoicesNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure ExportCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        RootXMLNode: XmlElement;
        FileHeaderNode: XmlElement;
        InvoicesNode: XmlElement;
        PartiesNode: XmlElement;
        XMLDocOut: XmlDocument;
        FileOutStream: OutStream;
        FileHeaderData, SellerData, BuyerData : Dictionary of [Text, Text];
        FileHeaderTotals: Dictionary of [Text, Decimal];
    begin
        TempBlob.CreateOutStream(FileOutStream);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        GatherSellerData(SellerData);
        GatherBuyerData(BuyerData, SalesCrMemoHeader."Bill-to Customer No.");
        InvoicesNode := CreateInvoicesNode(FileHeaderTotals, SalesCrMemoHeader, SalesCrMemoLine, IsBatch);
        GatherFileHeaderData(FileHeaderData, SalesCrMemoHeader, FileHeaderTotals);
        PartiesNode := CreatePartiesNode(SellerData, BuyerData);
        FileHeaderNode := CreateFileHeaderNode(FileHeaderData, FileHeaderTotals);

        RootXMLNode.Add(FileHeaderNode);
        RootXMLNode.Add(PartiesNode);
        RootXMLNode.Add(InvoicesNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure GatherFileHeaderData(var FileHeaderData: Dictionary of [Text, Text]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var FileHeaderTotals: Dictionary of [Text, Decimal])
    var
        Count: Integer;
    begin
        Count := FileHeaderTotals.Get('Count');
        FileHeaderData.Add('SchemaVersion', '3.2.2');
        if Count > 1 then
            FileHeaderData.Add('Modality', 'L')
        else
            FileHeaderData.Add('Modality', 'I');
        FileHeaderData.Add('InvoiceIssuerType', 'EM');
        FileHeaderData.Add('BatchIdentifier', CopyStr(SalesInvoiceHeader."No.", 1, 70));
        FileHeaderData.Add('InvoicesCount', Format(Count));
        FileHeaderData.Add('InvoiceCurrencyCode', GetCurrencyISOCode(SalesInvoiceHeader."Currency Code"));
    end;

    local procedure GatherFileHeaderData(var FileHeaderData: Dictionary of [Text, Text]; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FileHeaderTotals: Dictionary of [Text, Decimal])
    var
        Count: Integer;
    begin
        Count := FileHeaderTotals.Get('Count');
        FileHeaderData.Add('SchemaVersion', '3.2.2');
        if Count > 1 then
            FileHeaderData.Add('Modality', 'L')
        else
            FileHeaderData.Add('Modality', 'I');
        FileHeaderData.Add('InvoiceIssuerType', 'EM');
        FileHeaderData.Add('BatchIdentifier', CopyStr(SalesCrMemoHeader."No.", 1, 70));
        FileHeaderData.Add('InvoicesCount', Format(Count));
        FileHeaderData.Add('InvoiceCurrencyCode', GetCurrencyISOCode(SalesCrMemoHeader."Currency Code"));
    end;

    local procedure GatherSellerData(var SellerData: Dictionary of [Text, Text])
    var
        CountrySymbol: Text[1];
        CountryISO: Text[3];
    begin
        SellerData.Add('PersonTypeCode', 'J');
        CountryCodeToSymbolAndISO(CompanyInformation."Country/Region Code", CountrySymbol, CountryISO);
        SellerData.Add('ResidenceTypeCode', CountrySymbol);
        SellerData.Add('TaxIdentificationNumber', CopyStr(CompanyInformation."VAT Registration No.", 1, 30));
        SellerData.Add('CorporateName', CopyStr(CompanyInformation.Name + CompanyInformation."Name 2", 1, 80));
        SellerData.Add('Address', CopyStr(CompanyInformation.Address + CompanyInformation."Address 2", 1, 80));
        SellerData.Add('PostCode', CopyStr(CompanyInformation."Post Code", 1, 5));
        SellerData.Add('Town', CopyStr(CompanyInformation.City, 1, 50));
        SellerData.Add('Province', CopyStr(CompanyInformation.County, 1, 20));
        SellerData.Add('CountryCode', CopyStr(CountryISO, 1, 3));
        SellerData.Add('Telephone', CopyStr(CompanyInformation."Phone No.", 1, 15));
        SellerData.Add('ElectronicMail', CopyStr(CompanyInformation."E-Mail", 1, 60));
    end;

    local procedure GatherBuyerData(var BuyerData: Dictionary of [Text, Text]; BillToCustomerNo: Code[20])
    var
        Customer: Record "Customer";
        CountrySymbol: Text[1];
        CountryISO: Text[3];
    begin
        Customer.Get(BillToCustomerNo);
        if Customer."Partner Type" = Customer."Partner Type"::Person then
            BuyerData.Add('PersonTypeCode', 'F')
        else
            BuyerData.Add('PersonTypeCode', 'J');
        CountryCodeToSymbolAndISO(Customer."Country/Region Code", CountrySymbol, CountryISO);
        BuyerData.Add('ResidenceTypeCode', CountrySymbol);
        BuyerData.Add('TaxIdentificationNumber', CopyStr(Customer."VAT Registration No.", 1, 30));
        if Customer."Partner Type" = Customer."Partner Type"::Person then begin
            BuyerData.Add('Name', CopyStr(Customer.Name, 1, 40));
            BuyerData.Add('FirstSurname', CopyStr(Customer."Name 2", 1, 40));
        end else
            BuyerData.Add('CorporateName', CopyStr(Customer.Name + Customer."Name 2", 1, 80));
        BuyerData.Add('Address', CopyStr(Customer.Address + Customer."Address 2", 1, 80));
        BuyerData.Add('PostCode', CopyStr(Customer."Post Code", 1, 5));
        BuyerData.Add('Town', CopyStr(Customer.City, 1, 50));
        BuyerData.Add('Province', CopyStr(Customer.County, 1, 20));
        BuyerData.Add('CountryCode', CopyStr(CountryISO, 1, 3));
        BuyerData.Add('Telephone', CopyStr(Customer."Phone No.", 1, 15));
        BuyerData.Add('ElectronicMail', CopyStr(Customer."E-Mail", 1, 60));
    end;

    local procedure CreateFileHeaderNode(var FileHeaderData: Dictionary of [Text, Text]; var FileHeaderTotals: Dictionary of [Text, Decimal]) FileHeaderNode: XmlElement
    var
        BatchNode: XmlElement;
        TempXmlNode: XmlElement;
    begin
        FileHeaderNode := XmlElement.Create('FileHeader', '');
        FileHeaderNode.Add(XmlElement.Create('SchemaVersion', '', FileHeaderData.Get('SchemaVersion')));
        FileHeaderNode.Add(XmlElement.Create('Modality', '', FileHeaderData.Get('Modality')));
        FileHeaderNode.Add(XmlElement.Create('InvoiceIssuerType', '', FileHeaderData.Get('InvoiceIssuerType')));

        BatchNode := XmlElement.Create('Batch', '');
        BatchNode.Add(XmlElement.Create('BatchIdentifier', '', FileHeaderData.Get('BatchIdentifier')));
        BatchNode.Add(XmlElement.Create('InvoicesCount', '', FileHeaderData.Get('InvoicesCount')));

        TempXmlNode := XmlElement.Create('TotalInvoicesAmount', '');
        TempXmlNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(FileHeaderTotals.Get('TotalInvoicesAmount'))));
        BatchNode.Add(TempXmlNode);

        TempXmlNode := XmlElement.Create('TotalOutstandingAmount', '');
        TempXmlNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(FileHeaderTotals.Get('TotalInvoicesAmount'))));
        BatchNode.Add(TempXmlNode);

        TempXmlNode := XmlElement.Create('TotalExecutableAmount', '');
        TempXmlNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(FileHeaderTotals.Get('TotalInvoicesAmount'))));
        BatchNode.Add(TempXmlNode);

        BatchNode.Add(XmlElement.Create('InvoiceCurrencyCode', '', FileHeaderData.Get('InvoiceCurrencyCode')));

        FileHeaderNode.Add(BatchNode);
    end;

    local procedure CreatePartiesNode(var SellerData: Dictionary of [Text, Text]; var BuyerData: Dictionary of [Text, Text]) PartiesNode: XmlElement
    var
        SellerPartyNode: XmlElement;
        BuyerPartyNode: XmlElement;
    begin
        PartiesNode := XmlElement.Create('Parties', '');

        SellerPartyNode := XmlElement.Create('SellerParty', '');
        AddPartyNode(SellerPartyNode, SellerData);

        BuyerPartyNode := XmlElement.Create('BuyerParty', '');
        AddPartyNode(BuyerPartyNode, BuyerData);

        PartiesNode.Add(SellerPartyNode);
        PartiesNode.Add(BuyerPartyNode);
    end;

    local procedure AddPartyNode(var PartyNode: XmlElement; var PartyData: Dictionary of [Text, Text])
    var
        TaxIdentificationNode: XmlElement;
        LegalEntityNode: XmlElement;
        TempXmlNode: XmlElement;
    begin
        // Parties -> SellerParty/BuyerParty -> TaxIdentification
        TaxIdentificationNode := XmlElement.Create('TaxIdentification', '');
        TaxIdentificationNode.Add(XmlElement.Create('PersonTypeCode', '', PartyData.Get('PersonTypeCode')));
        TaxIdentificationNode.Add(XmlElement.Create('ResidenceTypeCode', '', PartyData.Get('ResidenceTypeCode')));
        TaxIdentificationNode.Add(XmlElement.Create('TaxIdentificationNumber', '', PartyData.Get('TaxIdentificationNumber')));
        PartyNode.Add(TaxIdentificationNode);

        // Parties -> SellerParty/BuyerParty -> LegalEntity
        LegalEntityNode := XmlElement.Create('LegalEntity', '');
        if PartyData.ContainsKey('Name') then begin
            LegalEntityNode.Add(XmlElement.Create('Name', '', PartyData.Get('Name')));
            LegalEntityNode.Add(XmlElement.Create('FirstSurname', '', PartyData.Get('FirstSurname')));
        end else
            LegalEntityNode.Add(XmlElement.Create('CorporateName', '', PartyData.Get('CorporateName')));

        // Parties -> SellerParty/BuyerParty -> LegalEntity -> Address
        if PartyData.Get('ResidenceTypeCode') = 'R' then begin
            // Local
            TempXmlNode := XmlElement.Create('AddressInSpain', '');
            TempXmlNode.Add(XmlElement.Create('Address', '', PartyData.Get('Address')));
            TempXmlNode.Add(XmlElement.Create('PostCode', '', PartyData.Get('PostCode')));
            TempXmlNode.Add(XmlElement.Create('Town', '', PartyData.Get('Town')));
            TempXmlNode.Add(XmlElement.Create('Province', '', PartyData.Get('Province')));
            TempXmlNode.Add(XmlElement.Create('CountryCode', '', PartyData.Get('CountryCode')));
        end else begin
            // Foreign
            TempXmlNode := XmlElement.Create('OverseasAddress', '');
            TempXmlNode.Add(XmlElement.Create('Address', '', PartyData.Get('Address')));
            TempXmlNode.Add(XmlElement.Create('PostCodeAndTown', '', PartyData.Get('PostCode')));
            TempXmlNode.Add(XmlElement.Create('Province', '', PartyData.Get('Province')));
            TempXmlNode.Add(XmlElement.Create('CountryCode', '', PartyData.Get('CountryCode')));
        end;
        LegalEntityNode.Add(TempXmlNode);

        // Parties -> SellerParty/BuyerParty -> LegalEntity -> ContactDetails
        TempXmlNode := XmlElement.Create('ContactDetails', '');
        TempXmlNode.Add(XmlElement.Create('Telephone', '', PartyData.Get('Telephone')));
        TempXmlNode.Add(XmlElement.Create('ElectronicMail', '', PartyData.Get('ElectronicMail')));
        LegalEntityNode.Add(TempXmlNode);

        PartyNode.Add(LegalEntityNode);
    end;

    local procedure CreateInvoicesNode(var FileHeaderTotals: Dictionary of [Text, Decimal]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; IsBatch: Boolean) InvoicesNode: XmlElement
    begin
        InvoicesNode := XmlElement.Create('Invoices', '');

        if IsBatch then
            repeat
                AddInvoiceNode(InvoicesNode, SalesInvoiceHeader, SalesInvoiceLine, FileHeaderTotals);
            until SalesInvoiceHeader.Next() = 0
        else
            AddInvoiceNode(InvoicesNode, SalesInvoiceHeader, SalesInvoiceLine, FileHeaderTotals);
    end;

    local procedure CreateInvoicesNode(var FileHeaderTotals: Dictionary of [Text, Decimal]; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; IsBatch: Boolean) InvoicesNode: XmlElement
    begin
        InvoicesNode := XmlElement.Create('Invoices', '');

        if IsBatch then
            repeat
                AddInvoiceNode(InvoicesNode, SalesCrMemoHeader, SalesCrMemoLine, FileHeaderTotals);
            until SalesCrMemoHeader.Next() = 0
        else
            AddInvoiceNode(InvoicesNode, SalesCrMemoHeader, SalesCrMemoLine, FileHeaderTotals);
    end;

    local procedure AddInvoiceNode(var InvoicesNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var FileHeaderTotals: Dictionary of [Text, Decimal])
    var
        InvoiceNode: XmlElement;
        InvoiceHeaderNode: XmlElement;
        InvoiceIssueDataNode: XmlElement;
        TaxesOutputsNode: XmlElement;
        InvoiceLineNode: XmlElement;
        InvoiceTotalsNode: XmlElement;
        TotalsData, VATBases, VATAmounts : Dictionary of [Text, Decimal];
    begin
        InvoiceNode := XmlElement.Create('Invoice', '');

        // Lines
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        CreateLineNodes(InvoiceLineNode, SalesCrMemoHeader, SalesCrMemoLine, TotalsData, VATBases, VATAmounts);

        // InvoiceTotals
        CreateInvoiceTotalsNode(InvoiceTotalsNode, TotalsData);

        // TaxesOutputs
        CreateTaxesOutputsNode(TaxesOutputsNode, VATBases, VATAmounts);

        // InvoiceIssueData
        CreateInvoiceIssueDataNode(InvoiceIssueDataNode, SalesCrMemoHeader);

        // InvoiceHeader
        CreateInvoiceHeaderNode(InvoiceHeaderNode, SalesCrMemoHeader);

        // Add in correct order
        InvoiceNode.Add(InvoiceHeaderNode);
        InvoiceNode.Add(InvoiceIssueDataNode);
        InvoiceNode.Add(TaxesOutputsNode);
        InvoiceNode.Add(InvoiceTotalsNode);
        InvoiceNode.Add(InvoiceLineNode);

        InvoicesNode.Add(InvoiceNode);

        AddToTotals(FileHeaderTotals, 'TotalInvoicesAmount', TotalsData.Get('GrossAmount') + TotalsData.Get('TaxAmount'));
        AddToTotals(FileHeaderTotals, 'Count', 1);
    end;

    local procedure AddInvoiceNode(var InvoicesNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; var FileHeaderTotals: Dictionary of [Text, Decimal])
    var
        InvoiceNode: XmlElement;
        InvoiceHeaderNode: XmlElement;
        InvoiceIssueDataNode: XmlElement;
        TaxesOutputsNode: XmlElement;
        InvoiceLineNode: XmlElement;
        InvoiceTotalsNode: XmlElement;
        TotalsData, VATBases, VATAmounts : Dictionary of [Text, Decimal];
    begin
        InvoiceNode := XmlElement.Create('Invoice', '');

        // Lines
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        CreateLineNodes(InvoiceLineNode, SalesInvoiceHeader, SalesInvoiceLine, TotalsData, VATBases, VATAmounts);

        // InvoiceTotals
        CreateInvoiceTotalsNode(InvoiceTotalsNode, TotalsData);

        // TaxesOutputs
        CreateTaxesOutputsNode(TaxesOutputsNode, VATBases, VATAmounts);

        // InvoiceIssueData
        CreateInvoiceIssueDataNode(InvoiceIssueDataNode, SalesInvoiceHeader);

        // InvoiceHeader
        CreateInvoiceHeaderNode(InvoiceHeaderNode, SalesInvoiceHeader);

        // Add in correct order
        InvoiceNode.Add(InvoiceHeaderNode);
        InvoiceNode.Add(InvoiceIssueDataNode);
        InvoiceNode.Add(TaxesOutputsNode);
        InvoiceNode.Add(InvoiceTotalsNode);
        InvoiceNode.Add(InvoiceLineNode);

        InvoicesNode.Add(InvoiceNode);

        AddToTotals(FileHeaderTotals, 'TotalInvoicesAmount', TotalsData.Get('GrossAmount') + TotalsData.Get('TaxAmount'));
        AddToTotals(FileHeaderTotals, 'Count', 1);
    end;

    local procedure CreateInvoiceHeaderNode(var InvoiceHeaderNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        InvoiceHeaderNode := XmlElement.Create('InvoiceHeader', '');
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceNumber', '', CopyStr(SalesInvoiceHeader."No.", 1, 30)));
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceDocumentType', '', ConvertInvoiceTypeToSymbols(SalesInvoiceHeader."Invoice Type")));
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceClass', '', ConvertInvoiceTypeToClass(SalesInvoiceHeader."Invoice Type")));
    end;

    local procedure CreateInvoiceHeaderNode(var InvoiceHeaderNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CorrectiveNode: XmlElement;
    begin
        InvoiceHeaderNode := XmlElement.Create('InvoiceHeader', '');
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceNumber', '', CopyStr(SalesCrMemoHeader."No.", 1, 30)));
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceDocumentType', '', ConvertInvoiceTypeToSymbols(SalesCrMemoHeader."Invoice Type")));
        InvoiceHeaderNode.Add(XmlElement.Create('InvoiceClass', '', ConvertInvoiceTypeToClass(SalesCrMemoHeader."Invoice Type")));
        // Corrective Node
        CreateCorrectiveNode(CorrectiveNode, SalesCrMemoHeader);
        InvoiceHeaderNode.Add(CorrectiveNode);
    end;

    local procedure CreateCorrectiveNode(var CorrectiveNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        TaxPeriodNode: XmlElement;
        StartingDate, EndingDate : Text;
        ReasonCode, ReasonDescription : Text;
    begin
        CorrectiveNode := XmlElement.Create('Corrective', '');
        GetReasonCodeAndDescription(ReasonCode, ReasonDescription, SalesCrMemoHeader);
        CorrectiveNode.Add(XmlElement.Create('ReasonCode', '', ReasonCode));
        CorrectiveNode.Add(XmlElement.Create('ReasonDescription', '', ReasonDescription));
        TaxPeriodNode := XmlElement.Create('TaxPeriod', '');
        GetStartingAndEndingDate(StartingDate, EndingDate, SalesCrMemoHeader);
        TaxPeriodNode.Add(XmlElement.Create('StartDate', '', StartingDate));
        TaxPeriodNode.Add(XmlElement.Create('EndDate', '', EndingDate));
        CorrectiveNode.Add(TaxPeriodNode);
        CorrectiveNode.Add(XmlElement.Create('CorrectionMethod', '', '02'));
        CorrectiveNode.Add(XmlElement.Create('CorrectionMethodDescription', '', 'Rectificación por diferencias'));
    end;

    local procedure CreateInvoiceIssueDataNode(var InvoiceIssueDataNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        TempXmlNode: XmlElement;
    begin
        InvoiceIssueDataNode := XmlElement.Create('InvoiceIssueData', '');
        TempXmlNode := XmlElement.Create('IssueDate', '', Format(SalesInvoiceHeader."Posting Date", 0, 9));
        InvoiceIssueDataNode.Add(TempXmlNode);
        TempXmlNode := XmlElement.Create('InvoiceCurrencyCode', '', GetCurrencyISOCode(SalesInvoiceHeader."Currency Code"));
        InvoiceIssueDataNode.Add(TempXmlNode);
        if SalesInvoiceHeader."Currency Code" <> '' then begin
            TempXmlNode := XmlElement.Create('ExchangeRateDetails', '');
            TempXmlNode.Add(XmlElement.Create('ExchangeRate', '', ToXMLDecimal8(SalesInvoiceHeader."Currency Factor")));
            TempXmlNode.Add(XmlElement.Create('ExchangeRateDate', '', Format(SalesInvoiceHeader."Posting Date", 0, 9)));
            InvoiceIssueDataNode.Add(TempXmlNode);
        end;
        InvoiceIssueDataNode.Add(XmlElement.Create('TaxCurrencyCode', '', GetCurrencyISOCode(SalesInvoiceHeader."Currency Code")));
        InvoiceIssueDataNode.Add(XmlElement.Create('LanguageName', '', CopyStr(SalesInvoiceHeader."Language Code", 1, 2).ToLower()));
    end;

    local procedure CreateInvoiceIssueDataNode(var InvoiceIssueDataNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        TempXmlNode: XmlElement;
    begin
        InvoiceIssueDataNode := XmlElement.Create('InvoiceIssueData', '');
        TempXmlNode := XmlElement.Create('IssueDate', '', Format(SalesCrMemoHeader."Posting Date", 0, 9));
        InvoiceIssueDataNode.Add(TempXmlNode);
        TempXmlNode := XmlElement.Create('InvoiceCurrencyCode', '', GetCurrencyISOCode(SalesCrMemoHeader."Currency Code"));
        InvoiceIssueDataNode.Add(TempXmlNode);
        if SalesCrMemoHeader."Currency Code" <> '' then begin
            TempXmlNode := XmlElement.Create('ExchangeRateDetails', '');
            TempXmlNode.Add(XmlElement.Create('ExchangeRate', '', ToXMLDecimal8(SalesCrMemoHeader."Currency Factor")));
            TempXmlNode.Add(XmlElement.Create('ExchangeRateDate', '', Format(SalesCrMemoHeader."Posting Date", 0, 9)));
            InvoiceIssueDataNode.Add(TempXmlNode);
        end;
        InvoiceIssueDataNode.Add(XmlElement.Create('TaxCurrencyCode', '', GetCurrencyISOCode(SalesCrMemoHeader."Currency Code")));
        InvoiceIssueDataNode.Add(XmlElement.Create('LanguageName', '', CopyStr(SalesCrMemoHeader."Language Code", 1, 2).ToLower()));
    end;

    local procedure CreateLineNodes(var InvoiceLineNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; var TotalsData: Dictionary of [Text, Decimal]; var VATBases: Dictionary of [Text, Decimal]; var VATAmounts: Dictionary of [Text, Decimal])
    var
        UnitOfMeasure: Record "Unit of Measure";
        SingleLineNode: XmlElement;
        DiscountsNode: XmlElement;
        DiscountNode: XmlElement;
        TaxesOutputsNode: XmlElement;
        TaxNode: XmlElement;
        TaxAmountNode: XmlElement;
        TaxableBaseNode: XmlElement;
        UnitOfMeasureInteger: Integer;
        DiscountAmount, TotalCost, GrossAmount, TaxableBase, TaxAmount : Decimal;
        ItemDescription: Text;
    begin
        InvoiceLineNode := XmlElement.Create('Items', '');
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.FindSet() then
            repeat
                SingleLineNode := XmlElement.Create('InvoiceLine', '');
                ItemDescription := SalesInvoiceLine.Description;
                if SalesInvoiceLine."Description 2" <> '' then
                    ItemDescription += ' ' + SalesInvoiceLine."Description 2";
                SingleLineNode.Add(XmlElement.Create('ItemDescription', '', CopyStr(ItemDescription, 1, 2500)));
                SingleLineNode.Add(XmlElement.Create('Quantity', '', ToXMLDecimal8(SalesInvoiceLine.Quantity)));
                if SalesInvoiceLine."Unit of Measure Code" <> '' then begin
                    UnitOfMeasure.Get(SalesInvoiceLine."Unit of Measure Code");
                    if Enum::"Factura-E Units of Measure".Names().Contains(UnitOfMeasure."International Standard Code") then begin
                        UnitOfMeasureInteger := Enum::"Factura-E Units of Measure".Names().IndexOf(UnitOfMeasure."International Standard Code");
                        SingleLineNode.Add(XmlElement.Create('UnitOfMeasure', '', Format(UnitOfMeasureInteger)));
                    end;
                end;
                SingleLineNode.Add(XmlElement.Create('UnitPriceWithoutTax', '', ToXMLDecimal8(GetUnitPrice(SalesInvoiceHeader, SalesInvoiceLine))));
                TotalCost := GetUnitPrice(SalesInvoiceHeader, SalesInvoiceLine) * SalesInvoiceLine.Quantity;
                SingleLineNode.Add(XmlElement.Create('TotalCost', '', ToXMLDecimal8(TotalCost)));
                AddToTotals(TotalsData, 'TotalCost', TotalCost);
                // Discount
                DiscountAmount := SalesInvoiceLine."Line Discount Amount";
                if DiscountAmount <> 0 then begin
                    DiscountsNode := XmlElement.Create('DiscountsAndRebates', '');
                    DiscountNode := XmlElement.Create('Discount', '');
                    DiscountNode.Add(XmlElement.Create('DiscountReason', '', ToXMLDecimal2(SalesInvoiceLine."Line Discount %") + '%'));
                    DiscountNode.Add(XmlElement.Create('DiscountAmount', '', ToXMLDecimal8(DiscountAmount)));
                    DiscountsNode.Add(DiscountNode);
                    SingleLineNode.Add(DiscountsNode);
                end;
                AddToTotals(TotalsData, 'InvoiceDiscountAmount', SalesInvoiceLine."Inv. Discount Amount");

                GrossAmount := TotalCost - DiscountAmount;
                SingleLineNode.Add(XmlElement.Create('GrossAmount', '', ToXMLDecimal8(GrossAmount)));
                AddToTotals(TotalsData, 'GrossAmount', GrossAmount);
                // TaxesOutputs
                TaxesOutputsNode := XmlElement.Create('TaxesOutputs', '');

                TaxNode := XmlElement.Create('Tax', '');
                TaxNode.Add(XmlElement.Create('TaxTypeCode', '', '01'));
                TaxNode.Add(XmlElement.Create('TaxRate', '', ToXMLDecimal8(SalesInvoiceLine."VAT %" + SalesInvoiceLine."EC %")));

                TaxableBaseNode := XmlElement.Create('TaxableBase', '');
                TaxableBase := SalesInvoiceLine."VAT Base Amount";
                TaxableBaseNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(TaxableBase)));
                TaxNode.Add(TaxableBaseNode);
                AddToTotals(VATBases, ToXMLDecimal8(SalesInvoiceLine."VAT %" + SalesInvoiceLine."EC %"), TaxableBase);

                TaxAmountNode := XmlElement.Create('TaxAmount', '');
                TaxAmount := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount;
                TaxAmountNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(TaxAmount)));
                TaxNode.Add(TaxAmountNode);
                AddToTotals(VATAmounts, ToXMLDecimal8(SalesInvoiceLine."VAT %" + SalesInvoiceLine."EC %"), TaxAmount);
                AddToTotals(TotalsData, 'TaxAmount', TaxAmount);

                TaxesOutputsNode.Add(TaxNode);
                SingleLineNode.Add(TaxesOutputsNode);
                if SalesInvoiceLine."Item Reference No." <> '' then
                    SingleLineNode.Add(XmlElement.Create('ArticleCode', '', SalesInvoiceLine."Item Reference No."));

                InvoiceLineNode.Add(SingleLineNode);
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure CreateLineNodes(var InvoiceLineNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TotalsData: Dictionary of [Text, Decimal]; var VATBases: Dictionary of [Text, Decimal]; var VATAmounts: Dictionary of [Text, Decimal])
    var
        UnitOfMeasure: Record "Unit of Measure";
        SingleLineNode: XmlElement;
        DiscountsNode: XmlElement;
        DiscountNode: XmlElement;
        TaxesOutputsNode: XmlElement;
        TaxNode: XmlElement;
        TaxAmountNode: XmlElement;
        TaxableBaseNode: XmlElement;
        UnitOfMeasureInteger: Integer;
        DiscountAmount, TotalCost, GrossAmount, TaxableBase, TaxAmount : Decimal;
        ItemDescription: Text;
    begin
        InvoiceLineNode := XmlElement.Create('Items', '');
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        if SalesCrMemoLine.FindSet() then
            repeat
                SingleLineNode := XmlElement.Create('InvoiceLine', '');
                ItemDescription := SalesCrMemoLine.Description;
                if SalesCrMemoLine."Description 2" <> '' then
                    ItemDescription += ' ' + SalesCrMemoLine."Description 2";
                SingleLineNode.Add(XmlElement.Create('ItemDescription', '', CopyStr(ItemDescription, 1, 2500)));
                SingleLineNode.Add(XmlElement.Create('Quantity', '', ToXMLDecimal8(SalesCrMemoLine.Quantity)));
                if SalesCrMemoLine."Unit of Measure Code" <> '' then begin
                    UnitOfMeasure.Get(SalesCrMemoLine."Unit of Measure Code");
                    if Enum::"Factura-E Units of Measure".Names().Contains(UnitOfMeasure."International Standard Code") then begin
                        UnitOfMeasureInteger := Enum::"Factura-E Units of Measure".Names().IndexOf(UnitOfMeasure."International Standard Code");
                        SingleLineNode.Add(XmlElement.Create('UnitOfMeasure', '', Format(UnitOfMeasureInteger)));
                    end;
                end;
                SingleLineNode.Add(XmlElement.Create('UnitPriceWithoutTax', '', ToXMLDecimal8(GetUnitPrice(SalesCrMemoHeader, SalesCrMemoLine))));
                TotalCost := GetUnitPrice(SalesCrMemoHeader, SalesCrMemoLine) * SalesCrMemoLine.Quantity;
                SingleLineNode.Add(XmlElement.Create('TotalCost', '', ToXMLDecimal8(TotalCost)));
                AddToTotals(TotalsData, 'TotalCost', TotalCost);
                // Discount
                DiscountAmount := SalesCrMemoLine."Line Discount Amount";
                if DiscountAmount <> 0 then begin
                    DiscountsNode := XmlElement.Create('DiscountsAndRebates', '');
                    DiscountNode := XmlElement.Create('Discount', '');
                    DiscountNode.Add(XmlElement.Create('DiscountReason', '', ToXMLDecimal2(SalesCrMemoLine."Line Discount %") + '%'));
                    DiscountNode.Add(XmlElement.Create('DiscountAmount', '', ToXMLDecimal8(DiscountAmount)));
                    DiscountsNode.Add(DiscountNode);
                    SingleLineNode.Add(DiscountsNode);
                end;
                AddToTotals(TotalsData, 'InvoiceDiscountAmount', SalesCrMemoLine."Inv. Discount Amount");

                GrossAmount := TotalCost - DiscountAmount;
                SingleLineNode.Add(XmlElement.Create('GrossAmount', '', ToXMLDecimal8(GrossAmount)));
                AddToTotals(TotalsData, 'GrossAmount', GrossAmount);
                // TaxesOutputs
                TaxesOutputsNode := XmlElement.Create('TaxesOutputs', '');

                TaxNode := XmlElement.Create('Tax', '');
                TaxNode.Add(XmlElement.Create('TaxTypeCode', '', '01'));
                TaxNode.Add(XmlElement.Create('TaxRate', '', ToXMLDecimal8(SalesCrMemoLine."VAT %" + SalesCrMemoLine."EC %")));

                TaxableBaseNode := XmlElement.Create('TaxableBase', '');
                TaxableBase := SalesCrMemoLine."VAT Base Amount";
                TaxableBaseNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(TaxableBase)));
                TaxNode.Add(TaxableBaseNode);
                AddToTotals(VATBases, ToXMLDecimal8(SalesCrMemoLine."VAT %" + SalesCrMemoLine."EC %"), TaxableBase);

                TaxAmountNode := XmlElement.Create('TaxAmount', '');
                TaxAmount := SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount;
                TaxAmountNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(TaxAmount)));
                TaxNode.Add(TaxAmountNode);
                AddToTotals(VATAmounts, ToXMLDecimal8(SalesCrMemoLine."VAT %" + SalesCrMemoLine."EC %"), TaxAmount);
                AddToTotals(TotalsData, 'TaxAmount', TaxAmount);

                TaxesOutputsNode.Add(TaxNode);
                SingleLineNode.Add(TaxesOutputsNode);
                if SalesCrMemoLine."Item Reference No." <> '' then
                    SingleLineNode.Add(XmlElement.Create('ArticleCode', '', SalesCrMemoLine."Item Reference No."));

                InvoiceLineNode.Add(SingleLineNode);
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure CreateInvoiceTotalsNode(var InvoiceTotalsNode: XmlElement; var TotalsData: Dictionary of [Text, Decimal])
    var
        InvoiceDiscountAmount: Decimal;
        GrossAmount: Decimal;
        GeneralDiscountsNode: XmlElement;
        DiscountNode: XmlElement;
    begin
        InvoiceTotalsNode := XmlElement.Create('InvoiceTotals', '');
        GrossAmount := TotalsData.Get('GrossAmount');
        InvoiceTotalsNode.Add(XmlElement.Create('TotalGrossAmount', '', ToXMLDecimal8(GrossAmount)));
        // Invoice discount
        InvoiceDiscountAmount := TotalsData.Get('InvoiceDiscountAmount');
        if (InvoiceDiscountAmount <> 0) and (GrossAmount <> 0) then begin
            GeneralDiscountsNode := XmlElement.Create('GeneralDiscounts', '');
            DiscountNode := XmlElement.Create('Discount', '');
            DiscountNode.Add(XmlElement.Create('DiscountReason', '', ToXMLDecimal2(InvoiceDiscountAmount / GrossAmount * 100) + '%'));
            DiscountNode.Add(XmlElement.Create('DiscountAmount', '', ToXMLDecimal8(InvoiceDiscountAmount)));
            GeneralDiscountsNode.Add(DiscountNode);
            InvoiceTotalsNode.Add(GeneralDiscountsNode);
        end;
        // Rest totals
        InvoiceTotalsNode.Add(XmlElement.Create('TotalGrossAmountBeforeTaxes', '', ToXMLDecimal8(TotalsData.Get('GrossAmount') - TotalsData.Get('InvoiceDiscountAmount'))));
        InvoiceTotalsNode.Add(XmlElement.Create('TotalTaxOutputs', '', ToXMLDecimal8(TotalsData.Get('TaxAmount'))));
        InvoiceTotalsNode.Add(XmlElement.Create('TotalTaxesWithheld', '', '0'));
        InvoiceTotalsNode.Add(XmlElement.Create('InvoiceTotal', '', ToXMLDecimal8(TotalsData.Get('GrossAmount') - TotalsData.Get('InvoiceDiscountAmount') + TotalsData.Get('TaxAmount'))));
        InvoiceTotalsNode.Add(XmlElement.Create('TotalOutstandingAmount', '', ToXMLDecimal8(TotalsData.Get('GrossAmount') - TotalsData.Get('InvoiceDiscountAmount') + TotalsData.Get('TaxAmount'))));
        InvoiceTotalsNode.Add(XmlElement.Create('TotalExecutableAmount', '', ToXMLDecimal8(TotalsData.Get('GrossAmount') - TotalsData.Get('InvoiceDiscountAmount') + TotalsData.Get('TaxAmount'))));
    end;

    local procedure CreateTaxesOutputsNode(var TaxesOutputsNode: XmlElement; var VATBases: Dictionary of [Text, Decimal]; var VATAmounts: Dictionary of [Text, Decimal])
    var
        TempXMLNode: XmlElement;
        TaxNode: XmlElement;
        VATCode: Text;
    begin
        TaxesOutputsNode := XmlElement.Create('TaxesOutputs', '');
        foreach VATCode in VATBases.Keys() do begin
            TaxNode := XmlElement.Create('Tax', '');
            TaxNode.Add(XmlElement.Create('TaxTypeCode', '', '01'));
            TaxNode.Add(XmlElement.Create('TaxRate', '', VATCode));
            TempXMLNode := XmlElement.Create('TaxableBase', '');
            TempXMLNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(VATBases.Get(VATCode))));
            TaxNode.Add(TempXMLNode);
            TempXMLNode := XmlElement.Create('TaxAmount', '');
            TempXMLNode.Add(XmlElement.Create('TotalAmount', '', ToXMLDecimal8(VATAmounts.Get(VATCode))));
            TaxNode.Add(TempXMLNode);

            TaxesOutputsNode.Add(TaxNode);
        end;
    end;

    local procedure AddToTotals(var TotalsData: Dictionary of [Text, Decimal]; KeyText: Text; Value: Decimal)
    begin
        if TotalsData.ContainsKey(KeyText) then
            TotalsData.Set(KeyText, TotalsData.Get(KeyText) + Value)
        else
            TotalsData.Add(KeyText, Value);
    end;

    local procedure CountryCodeToSymbolAndISO(CountryRegionCode: Code[10]; var CountrySymbol: Text[1]; var CountryISO: Text[3])
    var
        CountryRegion: Record "Country/Region";
        FacturaECountires: Codeunit "Factura-E Countries";
    begin
        if CountryRegionCode = 'ES' then
            CountrySymbol := 'R'
        else
            if CountryRegion.IsEUCountry(CountryRegionCode) then
                CountrySymbol := 'U'
            else
                CountrySymbol := 'E';

        CountryRegion.Get(CountryRegionCode);
        CountryISO := FacturaECountires.Convert2LetterCountryCodeTo3LetterCountryCode(CountryRegion."ISO Code");
    end;

    local procedure ConvertInvoiceTypeToSymbols(SIIInvoiceType: Enum "SII Sales Invoice Type"): Text[2]
    begin
        if SIIInvoiceType = Enum::"SII Sales Invoice Type"::"F1 Invoice" then
            exit('FC');
        if SIIInvoiceType = Enum::"SII Sales Invoice Type"::"F2 Simplified Invoice" then
            exit('FA');
        exit('FC');
    end;

    local procedure ConvertInvoiceTypeToClass(SIIInvoiceType: Enum "SII Sales Invoice Type"): Text[2]
    begin
        if SIIInvoiceType in [Enum::"SII Sales Invoice Type"::"F1 Invoice",
                              Enum::"SII Sales Invoice Type"::"F2 Simplified Invoice",
                              Enum::"SII Sales Invoice Type"::"F3 Invoice issued to replace simplified invoices"] then
            exit('OO');
        if SIIInvoiceType = Enum::"SII Sales Invoice Type"::"F4 Invoice summary entry" then
            exit('OC');
        exit('OR');
    end;

    local procedure GetReasonCodeAndDescription(var ReasonCode: Text; var ReasonDescription: Text; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CodeAndDescription: Text;
    begin
        CodeAndDescription := Format(SalesCrMemoHeader."Factura-E Reason Code");
        ReasonCode := CopyStr(CodeAndDescription, 1, 2);
        ReasonDescription := CopyStr(CodeAndDescription, 4, 100);
    end;

    local procedure GetStartingAndEndingDate(var StartingDate: Text; var EndingDate: Text; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        AccountingPeriod: Record "Accounting Period";
    begin
        VATReturnPeriod.SetFilter("Start Date", '<=%1', SalesCrMemoHeader."Posting Date");
        VATReturnPeriod.SetFilter("End Date", '>=%1', SalesCrMemoHeader."Posting Date");
        if VATReturnPeriod.FindFirst() then begin
            StartingDate := Format(VATReturnPeriod."Start Date", 0, 9);
            EndingDate := Format(VATReturnPeriod."End Date", 0, 9);
            exit;
        end;
        AccountingPeriod.SetFilter("Starting Date", '<=%1', SalesCrMemoHeader."Posting Date");
        if AccountingPeriod.FindLast() then begin
            StartingDate := Format(AccountingPeriod."Starting Date", 0, 9);
            EndingDate := Format(AccountingPeriod.GetFiscalYearEndDate(AccountingPeriod."Starting Date"), 0, 9);
            exit;
        end;
        StartingDate := Format(CalcDate('<-CY>', SalesCrMemoHeader."Posting Date"), 0, 9);
        EndingDate := Format(CalcDate('<CY>', SalesCrMemoHeader."Posting Date"), 0, 9);
    end;

    local procedure GetUnitPrice(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"): Decimal
    begin
        if not SalesInvoiceHeader."Prices Including VAT" then
            exit(SalesInvoiceLine."Unit Price");

        exit(SalesInvoiceLine."Unit Price" / (1 + ((SalesInvoiceLine."VAT %" + SalesInvoiceLine."EC %") / 100)));
    end;

    local procedure GetUnitPrice(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"): Decimal
    begin
        if not SalesCrMemoHeader."Prices Including VAT" then
            exit(SalesCrMemoLine."Unit Price");

        exit(SalesCrMemoLine."Unit Price" / (1 + ((SalesCrMemoLine."VAT %" + SalesCrMemoLine."EC %") / 100)));
    end;

    local procedure GetCurrencyISOCode(CurrencyCode: Code[10]): Text[3]
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then
            exit(CopyStr(GeneralLedgerSetup."LCY Code", 1, 3));
        Currency.Get(CurrencyCode);
        exit(Currency."ISO Code");
    end;

    local procedure GetBasicXMLHeader(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>' +
             '<namespace:Facturae xmlns:namespace2="http://uri.etsi.org/01903/v1.2.2#" xmlns:namespace3="http://www.w3.org/2000/09/xmldsig#" ' +
             'xmlns:namespace="http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml" />');
    end;

    local procedure ToXMLDecimal2(Value: Decimal): Text
    begin
        exit(Format(Round(Value, 0.01), 0, 9));
    end;

    local procedure ToXMLDecimal8(Value: Decimal): Text
    begin
        exit(Format(Round(Value, 0.00000001), 0, 9));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExport(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExport(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    begin
    end;
}