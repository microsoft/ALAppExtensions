// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using System.IO;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using System.Telemetry;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;

codeunit 13919 "Import ZUGFeRD Document"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'E-document ZUGFeRD Format', Locked = true;
        StartEventNameTok: Label 'E-document ZUGFeRD import started. Parsing basic information.', Locked = true;
        ContinueEventNameTok: Label 'Parsing complete information for E-document ZUGFeRD import.', Locked = true;
        EndEventNameTok: Label 'E-document ZUGFeRD import completed. %1 #%2 created.', Locked = true;

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        PDFDocument: Codeunit "PDF Document";
        DocumentType: Text;
        DocumentNamespace: Text;
        PDFInStream: InStream;
        PdfAttachmentStream: InStream;
        DocumentElementLbl: Label '%1:%2', Comment = '%1 = Namespace, %2 = Document', Locked = true;
        NoXMLFileErr: Label 'No invoice attachment found in the PDF file. Please check the PDF file.';
        CrossIndustryInvoiceLbl: Label 'CrossIndustryInvoice', Locked = true;
        UnsupportedDocumentTypeErr: Label 'Unsupported document type: %1', Comment = '%1 = Document type';
    begin
        FeatureTelemetry.LogUsage('0000ESH', FeatureNameTok, StartEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(PdfInStream);
        Clear(TempBlob);
        if not PDFDocument.GetDocumentAttachmentStream(PdfInStream, TempBlob) then
            Error(NoXMLFileErr);

        TempBlob.CreateInStream(PdfAttachmentStream);
        TempXMLBuffer.LoadFromStream(PdfAttachmentStream);
        EDocument.Direction := EDocument.Direction::Incoming;
        DocumentNamespace := GetNamespace(TempXMLBuffer);
        DocumentType := GetDocumentType(TempXMLBuffer, DocumentNamespace);

        case UpperCase(DocumentType) of
            '380', '384', '751', '877':
                if DocumentNamespace <> '' then
                    ParseInvoiceBasicInfo(EDocument, TempXMLBuffer, StrSubstNo(DocumentElementLbl, DocumentNamespace, CrossIndustryInvoiceLbl))
                else
                    ParseInvoiceBasicInfo(EDocument, TempXMLBuffer, CrossIndustryInvoiceLbl);
            '381', '261':
                if DocumentNamespace <> '' then
                    ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer, StrSubstNo(DocumentElementLbl, DocumentNamespace, CrossIndustryInvoiceLbl))
                else
                    ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer, CrossIndustryInvoiceLbl)
            else begin
                FeatureTelemetry.LogUsage('0000EXE', FeatureNameTok, StrSubstNo(UnsupportedDocumentTypeErr, DocumentType));
                Error(UnsupportedDocumentTypeErr, DocumentType);
            end;
        end;
    end;

    procedure ParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocumentType: Text;
        DocumentNamespace: Text;
        PdfAttachmentStream: InStream;
        DocumentElementLbl: Label '%1:%2', Comment = '%1 = Namespace, %2 = Document', Locked = true;
        CrossIndustryInvoiceLbl: Label 'CrossIndustryInvoice', Locked = true;
    begin
        FeatureTelemetry.LogUsage('0000EXS', FeatureNameTok, ContinueEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(PdfAttachmentStream);
        TempXMLBuffer.LoadFromStream(PdfAttachmentStream);
        EDocument.Direction := EDocument.Direction::Incoming;
        DocumentNamespace := GetNamespace(TempXMLBuffer);
        DocumentType := GetDocumentType(TempXMLBuffer, DocumentNamespace);

        PurchaseHeader."Buy-from Vendor No." := EDocument."Bill-to/Pay-to No.";
        PurchaseHeader."Currency Code" := EDocument."Currency Code";

        case UpperCase(DocumentType) of
            '380', '384', '751', '877':
                if DocumentNamespace <> '' then
                    CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, StrSubstNo(DocumentElementLbl, DocumentNamespace, CrossIndustryInvoiceLbl))
                else
                    CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, CrossIndustryInvoiceLbl);
            '381', '261':
                if DocumentNamespace <> '' then
                    CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, StrSubstNo(DocumentElementLbl, DocumentNamespace, CrossIndustryInvoiceLbl))
                else
                    CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, CrossIndustryInvoiceLbl);
        end;
        FeatureTelemetry.LogUsage('0000WXJ', FeatureNameTok, StrSubstNo(EndEventNameTok, EDocument."Document Type", EDocument."Incoming E-Document No."));
    end;

    local procedure GetNamespace(var TempXMLBuffer: Record "XML Buffer" temporary): Text
    var
        Namespace: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        if TempXMLBuffer.FindFirst() then begin
            Namespace := TempXMLBuffer.Namespace;
            TempXMLBuffer.Reset();
            exit(Namespace);
        end;
        exit('');
    end;

    local procedure GetDocumentType(var TempXMLBuffer: Record "XML Buffer" temporary; Namespace: Text) DocumentType: Text
    begin
        if Namespace <> '' then
            DocumentType := GetNodeByPath(TempXMLBuffer, '/' + Namespace + ':CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode')
        else
            DocumentType := GetNodeByPath(TempXMLBuffer, '/CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode');
    end;

    local procedure EvaluateDate(DateText: Text): Date
    var
        DMY: Date;
    begin
        // Format 20241115 (yyyymmdd)
        Evaluate(DMY, CopyStr(DateText, 7, 2) + '.' + CopyStr(DateText, 5, 2) + '.' + CopyStr(DateText, 1, 4));
        exit(DMY);
    end;

    local procedure GetNodeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);
        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure GetLastLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No.");
        exit(0);
    end;

    local procedure GetAttributeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetFilter(Path, XPath);
        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure CreateAllowanceChargeLines(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        LineNo: Integer;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetFilter(Path, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge');

        PurchaseLine.FindLast();
        LineNo := PurchaseLine."Line No." + 10000;

        if TempXMLBuffer.FindSet() then
            repeat
                case TempXMLBuffer.Path of
                    '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator':
                        if TempXMLBuffer.Value = 'true' then begin
                            SetGLAccountAndInsertLine(EDocument, PurchaseLine, LineNo);

                            PurchaseLine.Init();
                            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                            PurchaseLine."Document No." := PurchaseHeader."No.";
                            PurchaseLine."Line No." := LineNo;
                            PurchaseLine.Quantity := 1;
                            PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                        end;
                    '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount':
                        if TempXMLBuffer.Value <> '' then begin
                            Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
                            Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                        end;
                    '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:Reason':
                        PurchaseLine.Description := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine.Description));
                end;
            until TempXMLBuffer.Next() = 0;

        SetGLAccountAndInsertLine(EDocument, PurchaseLine, LineNo);
    end;

    local procedure SetGLAccountAndInsertLine(var EDocument: Record "E-Document"; var PurchaseLine: record "Purchase Line" temporary; var LineNo: Integer)
    var
        RecRef: RecordRef;
    begin
        if PurchaseLine."Line No." = LineNo then begin
            RecRef.GetTable(PurchaseLine);
            EDocumentImportHelper.FindGLAccountForLine(EDocument, RecRef);
            PurchaseLine."No." := RecRef.Field(PurchaseLine.FieldNo("No.")).Value;
            PurchaseLine.Insert(true);
            LineNo += 10000;
        end;
    end;

    local procedure ParseSellerTradeParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        Vendor: Record Vendor;
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        GLN: Text[13];
        VendorNo: Code[20];
    begin
        if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID') = 'VA' then
            VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID'), 1, MaxStrLen(VATRegistrationNo));

        if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID') = '0002' then
            GLN := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedLegalOrganization/ram:ID'), 1, MaxStrLen(GLN));
        VendorNo := EDocumentImportHelper.FindVendor('', GLN, VATRegistrationNo);
        if VendorNo = '' then begin
            VendorName := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:Name'), 1, MaxStrLen(VendorName));
            VendorAddress := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + 'rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineOne'), 1, MaxStrLen(VendorAddress));

            VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
            EDocument."Bill-to/Pay-to Name" := CopyStr(VendorName, 1, MaxStrLen(EDocument."Bill-to/Pay-to Name"));
        end;

        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocument."Bill-to/Pay-to No." := Vendor."No.";
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        end;
    end;

    local procedure ParseBuyerTradeParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    begin
        EDocument."Receiving Company Name" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:Name'), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + 'rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineOne'), 1, MaxStrLen(EDocument."Receiving Company Address"));
        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
    end;

    #region Invoice
    procedure ParseInvoiceBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentElement: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DueDate, IssueDate : Text;
        CurrencyCode: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:ID'), 1, MaxStrLen(EDocument."Incoming E-Document No."));

        ParseSellerTradeParty(EDocument, TempXMLBuffer, DocumentElement);
        ParseBuyerTradeParty(EDocument, TempXMLBuffer, DocumentElement);

        IssueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString');
        if IssueDate <> '' then
            EDocument."Document Date" := EvaluateDate(IssueDate);
        DueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString');
        if DueDate <> '' then
            EDocument."Due Date" := EvaluateDate(DueDate);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount'), 9);

        CurrencyCode := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if CurrencyCode <> GeneralLedgerSetup."LCY Code" then
            EDocument."Currency Code" := CurrencyCode;
    end;

    local procedure CreateInvoice(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentElement: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        LastLineNo: Integer;
        HasInvoiceDiscount, HasLineDiscount : Boolean;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert(true);

        LastLineNo := GetLastLineNo(PurchaseHeader);

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseInvoice(
                    PurchaseHeader, PurchaseLine, DocumentElement, LastLineNo,
                    DocumentAttachment, DocumentAttachmentData, EDocument, TempXMLBuffer, HasInvoiceDiscount, HasLineDiscount);
            until TempXMLBuffer.Next() = 0;

        // Insert last line
        if PurchaseLine."Document No." <> '' then
            PurchaseLine.Insert(true);
        PurchaseHeader.Modify(true);

        CreateAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentElement);
    end;

    local procedure ParseInvoice(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentType: Text; var LastLineNo: Integer; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; var HasInvoiceDiscount: Boolean; var HasLineDiscount: Boolean)
    begin
        case TempXMLBuffer.Path of
            '/' + DocumentType + '/rsm:ExchangedDocument/ram:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/' + DocumentType + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString':
                if TempXMLBuffer.Value <> '' then begin
                    PurchaseHeader."Document Date" := EvaluateDate(TempXMLBuffer.Value);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:Name':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString':
                if TempXMLBuffer.Value <> '' then begin
                    PurchaseHeader."Due Date" := EvaluateDate(TempXMLBuffer.Value);
                    EDocument."Due Date" := PurchaseHeader."Due Date";
                end;
            //invoice discount
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator':
                case TempXMLBuffer.Value of
                    'true', '1':
                        HasInvoiceDiscount := false;
                    'false', '0':
                        HasInvoiceDiscount := true;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount':
                if HasInvoiceDiscount then
                    Evaluate(PurchaseLine."Inv. Discount Amount", TempXMLBuffer.Value, 9);
            //lines
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert(true);

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LastLineNo + 10000;
                    LastLineNo := PurchaseLine."Line No.";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedTradeProduct/ram:GlobalID':
                PurchaseLine."Item Reference No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine.Quantity, TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode':
                if TempXMLBuffer.Value <> '' then
                    PurchaseLine."Unit of Measure Code" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount':
                begin
                    if TempXMLBuffer.Value <> '' then
                        Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                    PurchaseLine."VAT Base Amount" := PurchaseLine.Amount;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."VAT %", TempXMLBuffer.Value, 9);
            //line discount
            '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator':
                case
                     TempXMLBuffer.Value of
                    'true', '1':
                        begin
                            PurchaseLine."Line Discount %" := 0;
                            HasLineDiscount := false;
                        end;
                    'false', '0':
                        begin
                            PurchaseLine."Line Discount %" := 0;
                            HasLineDiscount := true;
                        end;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/ram:ActualAmount':
                if HasLineDiscount then
                    Evaluate(PurchaseLine."Line Discount %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedTradeProduct/ram:Name':
                PurchaseLine.Description := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine.Description));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
        end;
        OnAfterParseInvoice(EDocument, PurchaseHeader, PurchaseLine, DocumentAttachment, DocumentAttachmentData, TempXMLBuffer);
    end;
    #endregion

    #region Credit Memo
    local procedure ParseCreditMemoBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentElement: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DueDate, IssueDate : Text;
        CurrencyCode: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:ID'), 1, MaxStrLen(EDocument."Incoming E-Document No."));

        ParseSellerTradeParty(EDocument, TempXMLBuffer, DocumentElement);
        ParseBuyerTradeParty(EDocument, TempXMLBuffer, DocumentElement);

        IssueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString');
        if IssueDate <> '' then
            EDocument."Document Date" := EvaluateDate(IssueDate);
        DueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString');
        if DueDate <> '' then
            EDocument."Due Date" := EvaluateDate(DueDate);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount'), 9);

        CurrencyCode := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if CurrencyCode <> GeneralLedgerSetup."LCY Code" then
            EDocument."Currency Code" := CurrencyCode;
    end;

    local procedure CreateCreditMemo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentElement: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        LastLineNo: Integer;
        HasInvoiceDiscount, HasLineDiscount : Boolean;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentElement + '/rsm:ExchangedDocument/ram:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert(true);

        LastLineNo := GetLastLineNo(PurchaseHeader);

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseCreditMemo(
                    PurchaseHeader, PurchaseLine, DocumentElement, LastLineNo,
                    DocumentAttachment, DocumentAttachmentData, EDocument, TempXMLBuffer, HasInvoiceDiscount, HasLineDiscount);
            until TempXMLBuffer.Next() = 0;

        // Insert last line
        if PurchaseLine."Document No." <> '' then
            PurchaseLine.Insert(true);
        PurchaseHeader.Modify(true);

        CreateAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentElement);
    end;

    local procedure ParseCreditMemo(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentType: Text; var LastLineNo: Integer; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; var HasInvoiceDiscount: Boolean; var HasLineDiscount: Boolean)
    begin
        case TempXMLBuffer.Path of
            '/' + DocumentType + '/rsm:ExchangedDocument/ram:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/' + DocumentType + '/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString':
                if TempXMLBuffer.Value <> '' then begin
                    PurchaseHeader."Document Date" := EvaluateDate(TempXMLBuffer.Value);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:Name':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString':
                if TempXMLBuffer.Value <> '' then begin
                    PurchaseHeader."Due Date" := EvaluateDate(TempXMLBuffer.Value);
                    EDocument."Due Date" := PurchaseHeader."Due Date";
                end;
            //invoice discount
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator':
                case TempXMLBuffer.Value of
                    'true', '1':
                        HasInvoiceDiscount := false;
                    'false', '0':
                        HasInvoiceDiscount := true;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ActualAmount':
                if HasInvoiceDiscount then
                    Evaluate(PurchaseLine."Inv. Discount Amount", TempXMLBuffer.Value, 9);
            //lines
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert(true);

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LastLineNo + 10000;
                    LastLineNo := PurchaseLine."Line No.";
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedTradeProduct/ram:GlobalID':
                PurchaseLine."Item Reference No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine.Quantity, TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode':
                if TempXMLBuffer.Value <> '' then
                    PurchaseLine."Unit of Measure Code" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount':
                begin
                    if TempXMLBuffer.Value <> '' then
                        Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                    PurchaseLine."VAT Base Amount" := PurchaseLine.Amount;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."VAT %", TempXMLBuffer.Value, 9);
            //line discount
            '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/udt:Indicator':
                case
                     TempXMLBuffer.Value of
                    'true', '1':
                        begin
                            PurchaseLine."Line Discount %" := 0;
                            HasLineDiscount := false;
                        end;
                    'false', '0':
                        begin
                            PurchaseLine."Line Discount %" := 0;
                            HasLineDiscount := true;
                        end;
                end;
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeAllowanceCharge/ram:ChargeIndicator/ram:ActualAmount':
                if HasLineDiscount then
                    Evaluate(PurchaseLine."Line Discount %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedTradeProduct/ram:Name':
                PurchaseLine.Description := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine.Description));
            '/' + DocumentType + '/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
        end;
        OnAfterParseCreditMemo(EDocument, PurchaseHeader, PurchaseLine, DocumentAttachment, DocumentAttachmentData, TempXMLBuffer);
    end;
    #endregion

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseInvoice(EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; TempXMLBuffer: Record "XML Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseCreditMemo(EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; TempXMLBuffer: Record "XML Buffer" temporary)
    begin
    end;
}