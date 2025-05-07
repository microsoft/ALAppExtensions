// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using System.IO;
using System.Text;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using System.Telemetry;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;

codeunit 13915 "Import XRechnung Document"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'E-document XRechnung Format', Locked = true;
        StartEventNameTok: Label 'E-document XRechnung import started. Parsing basic information.', Locked = true;
        ContinueEventNameTok: Label 'Parsing complete information for E-document XRechnung import.', Locked = true;
        EndEventNameTok: Label 'E-document XRechnung import completed. %1 #%2 created.', Locked = true;

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocumentType: Text;
        DocumentNamespace: Text;
        DocStream: InStream;
        DocumentTypeLbl: Label '%1:%2', Comment = '%1 = Namespace, %2 = Document type';
    begin
        FeatureTelemetry.LogUsage('0000EXH', FeatureNameTok, StartEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        EDocument.Direction := EDocument.Direction::Incoming;
        DocumentType := GetDocumentType(TempXMLBuffer, DocumentNamespace);

        case UpperCase(DocumentType) of
            'INVOICE':
                if DocumentNamespace <> '' then
                    ParseInvoiceBasicInfo(EDocument, TempXMLBuffer, StrSubstNo(DocumentTypeLbl, DocumentNamespace, DocumentType))
                else
                    ParseInvoiceBasicInfo(EDocument, TempXMLBuffer, DocumentType);
            'CREDITNOTE':
                if DocumentNamespace <> '' then
                    ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer, StrSubstNo(DocumentTypeLbl, DocumentNamespace, DocumentType))
                else
                    ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer, DocumentType);
        end;
    end;

    procedure ParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocumentType: Text;
        DocumentNamespace: Text;
        DocStream: InStream;
        DocumentTypeLbl: Label '%1:%2', Comment = '%1 = Namespace, %2 = Document type';
    begin
        FeatureTelemetry.LogUsage('0000EXI', FeatureNameTok, ContinueEventNameTok);
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        PurchaseHeader."Buy-from Vendor No." := EDocument."Bill-to/Pay-to No.";
        PurchaseHeader."Currency Code" := EDocument."Currency Code";
        DocumentType := GetDocumentType(TempXMLBuffer, DocumentNamespace);

        case UpperCase(DocumentType) of
            'INVOICE':
                if DocumentNamespace <> '' then
                    CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, StrSubstNo(DocumentTypeLbl, DocumentNamespace, DocumentType))
                else
                    CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentType);
            'CREDITNOTE':
                if DocumentNamespace <> '' then
                    CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, StrSubstNo(DocumentTypeLbl, DocumentNamespace, DocumentType))
                else
                    CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentType);
        end;
        FeatureTelemetry.LogUsage('0000EXJ', FeatureNameTok, StrSubstNo(EndEventNameTok, EDocument."Document Type", EDocument."Incoming E-Document No."));
    end;

    local procedure GetDocumentType(var TempXMLBuffer: Record "XML Buffer" temporary; var Namespace: Text): Text
    var
        InvalidXMLFileErr: Label 'Invalid XML file';
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange("Parent Entry No.", 0);
        if not TempXMLBuffer.FindFirst() then
            Error(InvalidXMLFileErr);

        Namespace := TempXMLBuffer.Namespace;
        TempXMLBuffer.Reset();
        exit(TempXMLBuffer.Name);
    end;

    local procedure GetNodeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);
        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure GetAttributeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetFilter(Path, XPath);
        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure ParseAccountingSupplierParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        Vendor: Record Vendor;
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        GLN: Text[13];
        VendorNo: Code[20];
    begin
        VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(VATRegistrationNo));

        if VATRegistrationNo = '' then
            VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(VATRegistrationNo));

        GLN := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(GLN));
        VendorNo := EDocumentImportHelper.FindVendor('', GLN, VATRegistrationNo);
        if VendorNo = '' then begin
            VendorName := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name'), 1, MaxStrLen(VendorName));
            VendorAddress := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(VendorAddress));
            VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
            EDocument."Bill-to/Pay-to Name" := CopyStr(VendorName, 1, MaxStrLen(EDocument."Bill-to/Pay-to Name"));
        end;

        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocument."Bill-to/Pay-to No." := Vendor."No.";
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        end;
    end;

    local procedure ParseAccountingCustomerParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    begin
        EDocument."Receiving Company Name" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName'), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(EDocument."Receiving Company Address"));

        EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));
        if EDocument."Receiving Company GLN" = '' then
            if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID') = '0094' then
                EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));

        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
        if EDocument."Receiving Company VAT Reg. No." = '' then
            if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID') in ['EM', '0198', '9930'] then
                EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
    end;

    local procedure CreateAllowanceChargeLines(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        LineNo: Integer;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetFilter(Path, '/' + DocumentType + '/cac:AllowanceCharge*');

        PurchaseLine.FindLast();
        LineNo := PurchaseLine."Line No." + 10000;

        if TempXMLBuffer.FindSet() then
            repeat
                case TempXMLBuffer.Path of
                    '/' + DocumentType + '/cac:AllowanceCharge/cbc:ChargeIndicator':
                        if TempXMLBuffer.Value = 'true' then begin
                            SetGLAccountAndInsertLine(EDocument, PurchaseLine, LineNo);

                            PurchaseLine.Init();
                            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                            PurchaseLine."Document No." := PurchaseHeader."No.";
                            PurchaseLine."Line No." := LineNo;
                            PurchaseLine.Quantity := 1;
                            PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                        end;
                    '/' + DocumentType + '/cac:AllowanceCharge/cbc:Amount':
                        if TempXMLBuffer.Value <> '' then begin
                            Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
                            Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                        end;
                    '/' + DocumentType + '/cac:AllowanceCharge/cbc:AllowanceChargeReason':
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
    #region Invoice

    local procedure ParseInvoiceBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DueDate, IssueDate : Text;
        CurrencyCode: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:ID'), 1, MaxStrLen(EDocument."Incoming E-Document No."));
        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, DocumentType);
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, DocumentType);

        DueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:DueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);
        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount'), 9);

        CurrencyCode := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if CurrencyCode <> GeneralLedgerSetup."LCY Code" then
            EDocument."Currency Code" := CurrencyCode;
    end;

    local procedure CreateInvoice(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        LastLineNo: Integer;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert(true);

        LastLineNo := GetLastLineNo(PurchaseHeader);

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseInvoice(
                    PurchaseHeader, PurchaseLine, DocumentType, LastLineNo,
                    DocumentAttachment, DocumentAttachmentData, EDocument, TempXMLBuffer);
            until TempXMLBuffer.Next() = 0;

        //Insert last attachment
        AddAttachment(DocumentAttachment, DocumentAttachmentData, EDocument);

        // Insert last line
        PurchaseLine.Insert(true);
        PurchaseHeader.Modify(true);

        CreateAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentType);
    end;

    local procedure AddAttachment(var DocumentAttachment: Record "Document Attachment"; var DocumentAttachmentData: Codeunit "Temp Blob"; var EDocument: Record "E-Document")
    var
        EDocAttachmentProcessor: Codeunit "E-Doc. Attachment Processor";
        IStream: InStream;
    begin
        if DocumentAttachment."No." = '' then
            exit;

        DocumentAttachmentData.CreateInStream(IStream, TextEncoding::UTF8);
        EDocAttachmentProcessor.Insert(EDocument, IStream, DocumentAttachment.FindUniqueFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension"));
        Clear(DocumentAttachment);
    end;

    local procedure AddEmbeddedObject(var DocumentAttachmentData: Codeunit "Temp Blob"; Value: Text; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
        OStream: OutStream;
    begin
        DocumentAttachmentData.CreateOutStream(OStream, TextEncoding::UTF8);
        TempXMLBuffer.CalcFields("Value BLOB");
        TempXMLBuffer."Value BLOB".CreateInStream(IStream);
        IStream.Read(Value, IStream.Length);
        Base64Convert.FromBase64(Value, OStream);
    end;

    local procedure ParseInvoice(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentType: Text; var LastLineNo: Integer; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        case TempXMLBuffer.Path of
            '/' + DocumentType + '/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/' + DocumentType + '/cbc:DueDate':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cbc:IssueDate':
                if TempXMLBuffer.Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", TempXMLBuffer.Value, 9);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/' + DocumentType + '/cbc:BuyerReference':
                PurchaseHeader."Your Reference" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", TempXMLBuffer.Value, 9);
            //Lines
            '/' + DocumentType + '/cac:InvoiceLine':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert(true);

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LastLineNo + 10000;
                    LastLineNo := PurchaseLine."Line No.";
                end;
            '/' + DocumentType + '/cac:InvoiceLine/cbc:InvoicedQuantity':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine.Quantity, TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode':
                PurchaseLine."Unit of Measure Code" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/' + DocumentType + '/cac:InvoiceLine/cbc:LineExtensionAmount':
                begin
                    if TempXMLBuffer.Value <> '' then
                        Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                    PurchaseLine."VAT Base Amount" := PurchaseLine.Amount;
                end;
            '/' + DocumentType + '/cac:InvoiceLine/cac:AllowanceCharge/cbc:MultiplierFactorNumeric':
                Evaluate(PurchaseLine."Line Discount %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:InvoiceLine/cac:Item/cbc:Description':
                PurchaseLine."Description 2" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Description 2"));
            '/' + DocumentType + '/cac:InvoiceLine/cac:Item/cbc:Name':
                PurchaseLine.Description := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine.Description));
            '/' + DocumentType + '/cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID':
                PurchaseLine."Item Reference No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/' + DocumentType + '/cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID':
                PurchaseLine."No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."No."));
            '/' + DocumentType + '/cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."VAT %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:InvoiceLine/cac:Price/cbc:PriceAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cbc:ID':
                begin
                    AddAttachment(DocumentAttachment, DocumentAttachmentData, EDocument);

                    DocumentAttachment.Init();
                    DocumentAttachment."No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(DocumentAttachment."No."));
                end;
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject':
                AddEmbeddedObject(DocumentAttachmentData, TempXMLBuffer.Value, TempXMLBuffer);
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode':
                DocumentAttachment.Validate("File Extension", EDocumentImportHelper.DetermineFileType(TempXMLBuffer.Value));
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename':
                DocumentAttachment."File Name" := CopyStr(TempXMLBuffer.Value.Split('.').Get(1), 1, MaxStrLen(DocumentAttachment."File Name"));
        end;
        OnAfterParseInvoice(EDocument, PurchaseHeader, PurchaseLine, DocumentAttachment, DocumentAttachmentData, TempXMLBuffer);
    end;
    #endregion

    #region Credit Memo
    local procedure ParseCreditMemoBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DueDate, IssueDate : Text;
        CurrencyCode: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:ID'), 1, MaxStrLen(EDocument."Incoming E-Document No."));
        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, DocumentType);
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, DocumentType);

        DueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:DueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);
        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount'), 9);

        CurrencyCode := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if CurrencyCode <> GeneralLedgerSetup."LCY Code" then
            EDocument."Currency Code" := CurrencyCode;
    end;

    local procedure CreateCreditMemo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        LastLineNo: Integer;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert(true);

        LastLineNo := GetLastLineNo(PurchaseHeader);

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseCreditMemo(
                    PurchaseHeader, PurchaseLine, DocumentType, LastLineNo,
                    DocumentAttachment, DocumentAttachmentData, EDocument, TempXMLBuffer);
            until TempXMLBuffer.Next() = 0;

        //Insert last attachment
        AddAttachment(DocumentAttachment, DocumentAttachmentData, EDocument);

        // Insert last line
        PurchaseLine.Insert(true);
        PurchaseHeader.Modify(true);

        CreateAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer, DocumentType);
    end;

    local procedure ParseCreditMemo(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; DocumentType: Text; var LastLineNo: Integer; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        case TempXMLBuffer.Path of
            '/' + DocumentType + '/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/' + DocumentType + '/cbc:DueDate':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cbc:IssueDate':
                if TempXMLBuffer.Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", TempXMLBuffer.Value, 9);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/' + DocumentType + '/cbc:BuyerReference':
                PurchaseHeader."Your Reference" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/' + DocumentType + '/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", TempXMLBuffer.Value, 9);
            //Lines
            '/' + DocumentType + '/cac:CreditNoteLine':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert(true);

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LastLineNo + 10000;
                    LastLineNo := PurchaseLine."Line No.";
                end;
            '/' + DocumentType + '/cac:CreditNoteLine/cbc:CreditedQuantity':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine.Quantity, TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:CreditNoteLine/cbc:CreditedQuantity/@unitCode':
                PurchaseLine."Unit of Measure Code" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/' + DocumentType + '/cac:CreditNoteLine/cbc:LineExtensionAmount':
                begin
                    if TempXMLBuffer.Value <> '' then
                        Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                    PurchaseLine."VAT Base Amount" := PurchaseLine.Amount;
                end;
            '/' + DocumentType + '/cac:CreditNoteLine/cac:AllowanceCharge/cbc:MultiplierFactorNumeric':
                Evaluate(PurchaseLine."Line Discount %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Item/cbc:Description':
                PurchaseLine."Description 2" := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Description 2"));
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Item/cbc:Name':
                PurchaseLine.Description := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine.Description));
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Item/cac:SellersItemIdentification/cbc:ID':
                PurchaseLine."Item Reference No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Item/cac:StandardItemIdentification/cbc:ID':
                PurchaseLine."No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(PurchaseLine."No."));
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."VAT %", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:CreditNoteLine/cac:Price/cbc:PriceAmount':
                if TempXMLBuffer.Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cbc:ID':
                begin
                    AddAttachment(DocumentAttachment, DocumentAttachmentData, EDocument);

                    DocumentAttachment.Init();
                    DocumentAttachment."No." := CopyStr(TempXMLBuffer.Value, 1, MaxStrLen(DocumentAttachment."No."));
                end;
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject':
                AddEmbeddedObject(DocumentAttachmentData, TempXMLBuffer.Value, TempXMLBuffer);
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode':
                DocumentAttachment.Validate("File Extension", EDocumentImportHelper.DetermineFileType(TempXMLBuffer.Value));
            '/' + DocumentType + '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename':
                DocumentAttachment."File Name" := CopyStr(TempXMLBuffer.Value.Split('.').Get(1), 1, MaxStrLen(DocumentAttachment."File Name"));
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