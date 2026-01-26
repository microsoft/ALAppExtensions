// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Telemetry;
using System.Utilities;

codeunit 10775 "Factura-E Import"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'EDocument Format Factura-E', Locked = true;
        StartEventNameTok: Label 'Import initiated. Parsing basic info.', Locked = true;
        ContinueEventNameTok: Label 'Parsing complete info.', Locked = true;
        EndEntEventNameTok: Label 'Import completed. %1 #%2 created.', Locked = true;
        LCYCode: Code[10];

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        DocStream: InStream;
    begin
        FeatureTelemetry.LogUsage('0000OCU', FeatureNameTok, StartEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        GLSetup.Get();
        LCYCode := GLSetup."LCY Code";

        EDocument.Direction := EDocument.Direction::Incoming;

        ParseDocumentBasicInfo(EDocument, TempXMLBuffer);
        OnAfterParseBasicInfo(EDocument, TempBlob);
    end;

    procedure ParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocStream: InStream;
    begin
        FeatureTelemetry.LogUsage('0000OCV', FeatureNameTok, ContinueEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        CreateDocument(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
        FeatureTelemetry.LogUsage('0000OCW', FeatureNameTok, StrSubstNo(EndEntEventNameTok, EDocument."Document Type", EDocument."Incoming E-Document No."));

        OnAfterParseCompleteInfo(EDocument, PurchaseHeader, PurchaseLine, TempBlob);
    end;

    local procedure ParseSellerParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        Vendor: Record Vendor;
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocumentHelper: Codeunit "E-Document Helper";
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        VendorNo: Code[20];
        VendorId: Text;
        SellerPartyLbl: Label '/namespace:Facturae/Parties/SellerParty/', Locked = true;
    begin
        VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, SellerPartyLbl + 'TaxIdentification/TaxIdentificationNumber'), 1, MaxStrLen(VATRegistrationNo));
        VendorNo := EDocumentImportHelper.FindVendor('', '', VATRegistrationNo);

        if VendorNo = '' then begin
            VendorId := GetNodeByPath(TempXMLBuffer, SellerPartyLbl + 'PartyIdentificationType');

            if VendorId <> '' then begin
                EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
                ServiceParticipant.SetRange("Participant Type", ServiceParticipant."Participant Type"::Vendor);
                ServiceParticipant.SetRange("Participant Identifier", VendorId);
                ServiceParticipant.SetRange(Service, EDocumentService.Code);
                if not ServiceParticipant.FindFirst() then begin
                    ServiceParticipant.SetRange(Service);
                    if ServiceParticipant.FindFirst() then;
                end;
            end;

            VendorNo := ServiceParticipant.Participant;
        end;

        if VendorNo = '' then begin
            VendorName := GetNameDependingOnType(TempXMLBuffer, SellerPartyLbl);
            VendorAddress := GetAddressDependingOnType(TempXMLBuffer, SellerPartyLbl);
            VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
            EDocument."Bill-to/Pay-to Name" := CopyStr(VendorName, 1, MaxStrLen(EDocument."Bill-to/Pay-to Name"));
        end;

        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocument."Bill-to/Pay-to No." := Vendor."No.";
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        end;
    end;

    local procedure GetNameDependingOnType(var TempXMLBuffer: Record "XML Buffer" temporary; PathPrefix: Text) Name: Text
    begin
        if GetNodeByPath(TempXMLBuffer, PathPrefix + 'TaxIdentification/PersonTypeCode') = 'F' then begin
            // Person
            Name := GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/Name');
            Name += ' ' + GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/FirstSurname');
            Name += ' ' + GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/SecondSurname');
        end else
            // Company
            Name := GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/CorporateName');
    end;

    local procedure GetAddressDependingOnType(var TempXMLBuffer: Record "XML Buffer" temporary; PathPrefix: Text) Address: Text
    begin
        if GetNodeByPath(TempXMLBuffer, PathPrefix + 'TaxIdentification/ResidenceTypeCode') = 'R' then
            // Local
            Address := GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/AddressInSpain/Address')
        else
            // Foreign
            Address := GetNodeByPath(TempXMLBuffer, PathPrefix + 'LegalEntity/OverseasAddress/Address');
    end;

    local procedure ParseBuyerParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        BuyerPartyLbl: Label '/namespace:Facturae/Parties/BuyerParty/', Locked = true;
    begin
        EDocument."Receiving Company Name" := CopyStr(GetNameDependingOnType(TempXMLBuffer, BuyerPartyLbl), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetAddressDependingOnType(TempXMLBuffer, BuyerPartyLbl), 1, MaxStrLen(EDocument."Receiving Company Address"));
        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, BuyerPartyLbl + 'TaxIdentification/TaxIdentificationNumber'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
        EDocument."Receiving Company Id" := CopyStr(GetNodeByPath(TempXMLBuffer, BuyerPartyLbl + 'PartyIdentificationType'), 1, MaxStrLen(EDocument."Receiving Company Id"));
    end;

    local procedure ParseDocumentBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        IssueDate: Text;
        Currency: Text;
        AmountInclVAT: Text;
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/namespace:Facturae/FileHeader/Batch/BatchIdentifier'), 1, MaxStrLen(EDocument."Document No."));
        ParseSellerParty(EDocument, TempXMLBuffer);
        ParseBuyerParty(EDocument, TempXMLBuffer);

        IssueDate := GetNodeByPath(TempXMLBuffer, '/namespace:Facturae/Invoice/InvoiceIssueData/IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        AmountInclVAT := GetNodeByPath(TempXMLBuffer, '/namespace:Facturae/FileHeader/Batch/TotalOutstandingAmount/TotalAmount');
        if AmountInclVAT <> '' then
            Evaluate(EDocument."Amount Incl. VAT", AmountInclVAT, 9);

        Currency := GetNodeByPath(TempXMLBuffer, '/namespace:Facturae/FileHeader/Batch/InvoiceCurrencyCode');
        Currency := ISOCurrencyToRegularCode(Currency);
        if LCYCode <> Currency then
            EDocument."Currency Code" := CopyStr(Currency, 1, MaxStrLen(EDocument."Currency Code"));
    end;

    local procedure ISOCurrencyToRegularCode(ISOCode: Text): Text
    var
        Currency: Record Currency;
    begin
        Currency.SetRange("ISO Code", ISOCode);
        if Currency.FindFirst() then
            exit(Currency.Code);
        exit(ISOCode);
    end;

    local procedure CreateDocument(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        LineNo: Integer;
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Buy-from Vendor No." := EDocument."Bill-to/Pay-to No.";
        PurchaseHeader."Currency Code" := EDocument."Currency Code";
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice; // Invoice by default, will be changed to Cr.Memo if relevant fields are found
        PurchaseHeader.Insert();
        LineNo := 0;

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseInvoice(PurchaseHeader, PurchaseLine, TempXMLBuffer.Path, TempXMLBuffer.Value, LineNo);
            until TempXMLBuffer.Next() = 0;

        // Apply all header changes
        PurchaseHeader.Modify();

        // Insert last line
        PurchaseLine.Insert();

    end;

    local procedure ParseInvoice(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; Path: Text; Value: Text; var LineNo: Integer)
    var
        AmountInclVAT: Decimal;
        PathPrefixTxt: Label '/namespace:Facturae/Invoices/Invoice', Locked = true;
    begin
        case Path of
            PathPrefixTxt + '/InvoiceHeader/InvoiceNumber':
                PurchaseHeader."Vendor Invoice No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            PathPrefixTxt + '/Corrective':
                PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
            PathPrefixTxt + '/Corrective/InvoiceNumber':
                PurchaseHeader."Applies-to Doc. No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Applies-to Doc. No."));
            PathPrefixTxt + '/InvoiceHeader/InvoiceIssueData/IssueDate':
                if Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
                    Evaluate(PurchaseHeader."Order Date", Value, 9);
                end;
            PathPrefixTxt + '/InvoiceHeader/InvoiceIssueData/InvoiceCurrencyCode':
                PurchaseHeader."Currency Code" := CopyStr(ISOCurrencyToRegularCode(Value), 1, MaxStrLen(PurchaseHeader."Currency Code"));
            PathPrefixTxt + '/InvoiceHeader/InvoiceIssueData/LanguageName':
                PurchaseHeader."Language Code" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Language Code"));
            PathPrefixTxt + '/InvoiceTotals/GeneralDiscounts/Discount/DiscountAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", Value, 9);
            PathPrefixTxt + '/Items/InvoiceLine':
                begin
                    if PurchaseLine."Document Type" <> PurchaseLine."Document Type"::Quote then
                        PurchaseLine.Insert();

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    LineNo += 10000;
                    PurchaseLine."Line No." := LineNo;
                end;
            PathPrefixTxt + '/Items/InvoiceLine/Quantity':
                if Value <> '' then
                    Evaluate(PurchaseLine.Quantity, Value, 9);
            PathPrefixTxt + '/Items/InvoiceLine/UnitOfMeasure':
                PurchaseLine."Unit of Measure Code" := TryGetUOMCodeFromInternationalCode(Value);
            PathPrefixTxt + '/Items/InvoiceLine/ReceiverContractReference':
                PurchaseHeader."Your Reference" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            PathPrefixTxt + '/Items/InvoiceLine/GrossAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine.Amount, Value, 9);
            PathPrefixTxt + '/Items/InvoiceLine/ItemDescription':
                PurchaseLine.Description := CopyStr(Value, 1, MaxStrLen(PurchaseLine.Description));
            PathPrefixTxt + '/Items/InvoiceLine/IssuerContractReference':
                PurchaseLine."Description 2" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Description 2"));
            PathPrefixTxt + '/Items/InvoiceLine/DiscountsAndRebates/Discount/DiscountAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Line Discount Amount", Value, 9);
            PathPrefixTxt + '/Items/TaxesOutputs/Tax/TaxAmount/TotalAmount':
                if Value <> '' then begin
                    Evaluate(AmountInclVAT, Value, 9);
                    AmountInclVAT += PurchaseLine.Amount;
                    PurchaseLine."Amount Including VAT" := AmountInclVAT;
                end;
            PathPrefixTxt + '/Items/InvoiceLine/ArticleCode':
                PurchaseLine."Item Reference No." := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            PathPrefixTxt + '/Items/InvoiceLine/UnitPriceWithoutTax':
                if Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
            PathPrefixTxt + '/Items/InvoiceLine/TransactionDate':
                if Value <> '' then
                    Evaluate(PurchaseLine."Order Date", Value, 9);
        end;
    end;

    local procedure GetNodeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);

        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure TryGetUOMCodeFromInternationalCode(TextValue: Text): Code[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
        Code: Integer;
    begin
        if TextValue = '' then
            exit('');

        Evaluate(Code, TextValue, 9);
        UnitOfMeasure.SetRange("International Standard Code", Enum::"Factura-E Units of Measure".Names().Get(Code));
        if UnitOfMeasure.FindFirst() then
            exit(UnitOfMeasure.Code);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    begin
    end;
}