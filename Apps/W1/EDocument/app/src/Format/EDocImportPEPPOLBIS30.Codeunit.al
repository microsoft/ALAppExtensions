namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.Purchases.Document;
using System.IO;
using System.Text;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 6166 "EDoc Import PEPPOL BIS 3.0"
{

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        TempXMLBuffer.LoadFromStream(DocStream);

        GLSetup.Get();
        LCYCode := GLSetup."LCY Code";

        EDocument.Direction := EDocument.Direction::Incoming;

        case UpperCase(GetDocumentType(TempXMLBuffer)) of
            'INVOICE':
                ParseInvoiceBasicInfo(EDocument, TempXMLBuffer);
            'CREDITNOTE':
                ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer);
        end;
    end;

    procedure ParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        TempXMLBuffer.LoadFromStream(DocStream);

        PurchaseHeader."Buy-from Vendor No." := EDocument."Bill-to/Pay-to No.";
        PurchaseHeader."Currency Code" := EDocument."Currency Code";

        case UpperCase(GetDocumentType(TempXMLBuffer)) of
            'INVOICE':
                CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
            'CREDITNOTE':
                CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
        end;
    end;

    local procedure ParseInvoiceBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DueDate, IssueDate : Text;
        Currency: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:ID'), 1, MaxStrLen(EDocument."Document No."));
        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, 'Invoice');
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, 'Invoice');

        DueDate := GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:DueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount'), 9);

        EDocument."Order No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cac:OrderReference/cbc:ID'), 1, MaxStrLen(EDocument."Order No."));

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        if LCYCode <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure ParseCreditMemoBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DueDate, IssueDate : Text;
        Currency: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:ID'), 1, MaxStrLen(EDocument."Document No."));
        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, 'CreditNote');
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, 'CreditNote');

        DueDate := GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:PaymentMeans/cbc:PaymentDueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount'), 9);

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        if LCYCode <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure ParseAccountingSupplierParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        Vendor: Record Vendor;
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        VendorNo: Code[20];
    begin
        // Vendor
        VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(VATRegistrationNo));
        VendorNo := EDocumentImportHelper.FindVendor('', '', VATRegistrationNo);
        if VendorNo = '' then begin
            VendorName := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name'), 1, MaxStrLen(VATRegistrationNo));
            VendorAddress := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(VATRegistrationNo));
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
        EDocument."Receiving Company Name" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name'), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(EDocument."Receiving Company Address"));
        EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));
        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
    end;

    local procedure CreateInvoice(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        InStream: InStream;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader."Vendor Order No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cac:OrderReference/cbc:ID'), 1, MaxStrLen(PurchaseHeader."Vendor Order No."));
        // Currency
        PurchaseHeader.Insert();

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseInvoice(EDocument, PurchaseHeader, PurchaseLine, DocumentAttachment, DocumentAttachmentData, TempXMLBuffer);
            until TempXMLBuffer.Next() = 0;

        // Insert last document attachment
        if DocumentAttachment."No." <> '' then begin
            DocumentAttachmentData.CreateInStream(InStream, TextEncoding::UTF8);
            EDocumentAttachmentGen.Insert(EDocument, InStream, DocumentAttachment.FindUniqueFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension"));
            Clear(DocumentAttachment);
        end;

        // Insert last line
        PurchaseLine.Insert();
        PurchaseHeader.Modify();

        // Allowance charge
        CreateInvoiceAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
    end;

    local procedure CreateCreditMemo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentData: Codeunit "Temp Blob";
        InStream: InStream;
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert();

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseCreditMemo(EDocument, PurchaseHeader, PurchaseLine, DocumentAttachment, DocumentAttachmentData, TempXMLBuffer);
            until TempXMLBuffer.Next() = 0;

        // Insert last document attachment
        if DocumentAttachment."No." <> '' then begin
            DocumentAttachmentData.CreateInStream(InStream, TextEncoding::UTF8);
            EDocumentAttachmentGen.Insert(EDocument, InStream, DocumentAttachment.FindUniqueFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension"));
            Clear(DocumentAttachment);
        end;

        // Insert last line
        PurchaseLine.Insert();
        PurchaseHeader.Modify();

        // Allowance charge
        CreateInvoiceAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
    end;

    local procedure CreateInvoiceAllowanceChargeLines(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        LineNo: Integer;
        DocumentText: Text;
    begin
        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice":
                DocumentText := '/Invoice';
            EDocument."Document Type"::"Purchase Credit Memo":
                DocumentText := '/CreditNote';
        end;

        TempXMLBuffer.Reset();
        TempXMLBuffer.SetFilter(Path, DocumentText + '/cac:AllowanceCharge*');

        PurchaseLine.FindLast();
        LineNo := PurchaseLine."Line No." + 10000;

        if TempXMLBuffer.FindSet() then
            repeat
                case TempXMLBuffer.Path of
                    DocumentText + '/cac:AllowanceCharge/cbc:ChargeIndicator':
                        if TempXMLBuffer.Value = 'true' then begin
                            SetGLAccountAndInsertLine(EDocument, PurchaseLine, LineNo);

                            PurchaseLine.Init();
                            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                            PurchaseLine."Document No." := PurchaseHeader."No.";
                            PurchaseLine."Line No." := LineNo;
                            PurchaseLine.Quantity := 1;
                            PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                        end;
                    DocumentText + '/cac:AllowanceCharge/cbc:Amount':
                        if TempXMLBuffer.Value <> '' then begin
                            Evaluate(PurchaseLine."Direct Unit Cost", TempXMLBuffer.Value, 9);
                            Evaluate(PurchaseLine.Amount, TempXMLBuffer.Value, 9);
                        end;
                    DocumentText + '/cac:AllowanceCharge/cbc:AllowanceChargeReason':
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
            PurchaseLine.Insert();
            LineNo += 10000;
        end;
    end;

    /// <summary>
    /// Parses credit memo information line by line from TempXMLBuffer.
    /// We handle the insert of Purchase Order Line and Document Attachment after the call to this function.
    /// </summary>
    local procedure ParseCreditMemo(EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
        InStream: InStream;
        Path, Value : Text;
    begin
        Path := TempXMLBuffer.Path;
        Value := TempXMLBuffer.Value;
        case Path of
            '/CreditNote/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/CreditNote/cbc:IssueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
            '/CreditNote/cac:OrderReference/cbc:ID':
                PurchaseHeader."Vendor Order No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Order No."));
            '/CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID':
                PurchaseHeader."Applies-to Doc. No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Applies-to Doc. No."));
            '/CreditNote/cac:PayeeParty/cac:PartyName/cbc:Name':
                PurchaseHeader."Pay-to Name" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Name"));
            '/CreditNote/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", Value, 9);
            '/CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Amount Including VAT", Value, 9);
            '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID':
                PurchaseHeader."Your Reference" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName':
                PurchaseHeader."Buy-from Address" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Address"));
            '/CreditNote/cac:PayeeParty/cac:PartyLegalEntity/cbc:CompanyID', '/CreditNote/cac:PayeeParty/cac:PartyIdentification/cbc:ID':
                PurchaseHeader."VAT Registration No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."VAT Registration No."));
            '/CreditNote/cac:PaymentMeans/cbc:PaymentDueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", Value, 9);
            '/CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader.Amount, Value, 9);
            '/CreditNote/cac:AdditionalDocumentReference/cbc:ID':
                begin
                    if DocumentAttachment."No." <> '' then begin
                        DocumentAttachmentData.CreateInStream(InStream, TextEncoding::UTF8);
                        EDocumentAttachmentGen.Insert(EDocument, InStream, DocumentAttachment.FindUniqueFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension"));
                        Clear(DocumentAttachment);
                    end;

                    DocumentAttachment.Init();
                    DocumentAttachment."No." := CopyStr(PurchaseHeader."Vendor Invoice No.", 1, MaxStrLen(DocumentAttachment."No."));
                end;
            '/CreditNote/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject':
                begin
                    DocumentAttachmentData.CreateOutStream(OutStream, TextEncoding::UTF8);
                    TempXMLBuffer.CalcFields("Value BLOB");
                    TempXMLBuffer."Value BLOB".CreateInStream(InStream);
                    InStream.Read(Value, InStream.Length);
                    Base64Convert.FromBase64(Value, OutStream);
                end;
            '/CreditNote/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode':
                DocumentAttachment.Validate("File Extension", DetermineFileType(Value));
            '/CreditNote/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename':
                DocumentAttachment."File Name" := CopyStr(Value.Split('.').Get(1), 1, MaxStrLen(DocumentAttachment."File Name"));
            '/CreditNote/cac:CreditNoteLine':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert();

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                end;
            '/CreditNote/cac:CreditNoteLine/cbc:CreditedQuantity':
                if Value <> '' then
                    Evaluate(PurchaseLine.Quantity, Value, 9);
            '/CreditNote/cac:CreditNoteLine/cbc:CreditedQuantity/@unitCode':
                PurchaseLine."Unit of Measure Code" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/CreditNote/cac:CreditNoteLine/cbc:LineExtensionAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine.Amount, Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:AllowanceCharge/cbc:Amount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Line Discount Amount", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:TaxTotal/cbc:TaxAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Amount Including VAT", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:Item/cbc:Description':
                PurchaseLine."Description 2" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Description 2"));
            '/CreditNote/cac:CreditNoteLine/cac:Item/cbc:Name':
                PurchaseLine.Description := CopyStr(Value, 1, MaxStrLen(PurchaseLine.Description));
            '/CreditNote/cac:CreditNoteLine/cac:Item/cac:SellersItemIdentification/cbc:ID':
                PurchaseLine."Item Reference No." := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/CreditNote/cac:CreditNoteLine/cac:Item/cac:StandardItemIdentification/cbc:ID':
                PurchaseLine."No." := CopyStr(Value, 1, MaxStrLen(PurchaseLine."No."));
            '/CreditNote/cac:CreditNoteLine/cbc:ID':
                Evaluate(PurchaseLine."Line No.", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent':
                if Value <> '' then
                    Evaluate(PurchaseLine."VAT %", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:Price/cbc:PriceAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cac:Price/cbc:BaseQuantity':
                if Value <> '' then
                    Evaluate(PurchaseLine."Quantity (Base)", Value, 9);
            '/CreditNote/cac:CreditNoteLine/cbc:Note':
                setlineType(PurchaseLine, Value);
        end
    end;

    /// <summary>
    /// Parses invoice information line by line from TempXMLBuffer.
    /// We handle the insert of Purchase Order Line and Document Attachment after the call to this function.
    /// </summary>
    local procedure ParseInvoice(EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: Record "Purchase Line" temporary; var DocumentAttachment: Record "Document Attachment"; DocumentAttachmentData: Codeunit "Temp Blob"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
        InStream: InStream;
        Path, Value : Text;
    begin
        Path := TempXMLBuffer.Path;
        Value := TempXMLBuffer.Value;
        case Path of
            '/Invoice/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/Invoice/cac:OrderReference/cbc:ID':
                PurchaseHeader."Vendor Order No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Order No."));
            '/Invoice/cac:PayeeParty/cac:PartyName/cbc:Name':
                PurchaseHeader."Pay-to Name" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Name"));
            '/Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", Value, 9);
            '/Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Amount Including VAT", Value, 9);
            '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID':
                PurchaseHeader."Your Reference" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName':
                PurchaseHeader."Buy-from Address" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Address"));
            '/Invoice/cac:PayeeParty/cac:PartyLegalEntity/cbc:CompanyID':
                PurchaseHeader."VAT Registration No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."VAT Registration No."));
            '/Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader.Amount, Value, 9);
            '/Invoice/cbc:DueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", Value, 9);
            '/Invoice/cbc:IssueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
            '/Invoice/cac:AdditionalDocumentReference/cbc:ID':
                begin
                    if DocumentAttachment."No." <> '' then begin
                        DocumentAttachmentData.CreateInStream(InStream, TextEncoding::UTF8);
                        EDocumentAttachmentGen.Insert(EDocument, InStream, DocumentAttachment.FindUniqueFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension"));
                        Clear(DocumentAttachment);
                    end;

                    DocumentAttachment.Init();
                    DocumentAttachment."No." := CopyStr(Value, 1, MaxStrLen(DocumentAttachment."No."));
                end;
            '/Invoice/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject':
                begin
                    DocumentAttachmentData.CreateOutStream(OutStream, TextEncoding::UTF8);
                    TempXMLBuffer.CalcFields("Value BLOB");
                    TempXMLBuffer."Value BLOB".CreateInStream(InStream);
                    InStream.Read(Value, InStream.Length);
                    Base64Convert.FromBase64(Value, OutStream);
                end;
            '/Invoice/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode':
                DocumentAttachment.Validate("File Extension", DetermineFileType(Value));
            '/Invoice/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename':
                DocumentAttachment."File Name" := CopyStr(Value.Split('.').Get(1), 1, MaxStrLen(DocumentAttachment."File Name"));
            '/Invoice/cac:InvoiceLine':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert();

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                end;
            '/Invoice/cac:InvoiceLine/cbc:InvoicedQuantity':
                if Value <> '' then
                    Evaluate(PurchaseLine.Quantity, Value, 9);
            '/Invoice/cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode':
                PurchaseLine."Unit of Measure Code" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Unit of Measure Code"));
            '/Invoice/cac:InvoiceLine/cbc:LineExtensionAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine.Amount, Value, 9);

            '/Invoice/cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Line Discount Amount", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:TaxTotal/cbc:TaxAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Amount Including VAT", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:Item/cbc:Description':
                PurchaseLine."Description 2" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Description 2"));
            '/Invoice/cac:InvoiceLine/cac:Item/cbc:Name':
                PurchaseLine.Description := CopyStr(Value, 1, MaxStrLen(PurchaseLine.Description));
            '/Invoice/cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID':
                PurchaseLine."Item Reference No." := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Item Reference No."));
            '/Invoice/cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID':
                PurchaseLine."No." := CopyStr(Value, 1, MaxStrLen(PurchaseLine."No."));
            '/Invoice/cac:InvoiceLine/cbc:ID':
                Evaluate(PurchaseLine."Line No.", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent':
                if Value <> '' then
                    Evaluate(PurchaseLine."VAT %", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:Price/cbc:PriceAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:Price/cbc:BaseQuantity':
                if Value <> '' then
                    Evaluate(PurchaseLine."Quantity (Base)", Value, 9);
            '/Invoice/cac:InvoiceLine/cbc:Note':
                setlineType(PurchaseLine, Value);
        end;
    end;

    procedure DetermineFileType(MimeType: Text) FileExension: Text
    begin
        case MimeType of
            'image/jpeg':
                exit('jpeg');
            'image/png':
                exit('png');
            'application/pdf':
                exit('pdf');
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'application/vnd.oasis.opendocument.spreadsheet':
                exit('xlsx');
            else
                exit('');
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

    local procedure GetDocumentType(var TempXMLBuffer: Record "XML Buffer" temporary): Text
    var
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange("Parent Entry No.", 0);

        if not TempXMLBuffer.FindFirst() then
            Error('Invalid XML file');

        TempXMLBuffer.Reset();
        exit(TempXMLBuffer.Name);
    end;

    local procedure SetLineType(var PurchaseLine: record "Purchase Line" temporary; Value: Text): Text
    var
    begin
        case UpperCase(Value) of
            'ITEM':
                PurchaseLine.Type := PurchaseLine.Type::Item;
            'CHARGE (ITEM)':
                PurchaseLine.Type := PurchaseLine.Type::"Charge (Item)";
            'RESOURCE':
                PurchaseLine.Type := PurchaseLine.Type::Resource;
            'G/L ACCOUNT':
                PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Log", 'OnBeforeExportDataStorage', '', false, false)]
    local procedure SetFileExt(EDocumentLog: Record "E-Document Log"; var FileName: Text)
    begin
        FileName += '.xml';
    end;

    var
        EDocumentAttachmentGen: Codeunit "E-Doc. Attachment Processor";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        LCYCode: Code[10];
}