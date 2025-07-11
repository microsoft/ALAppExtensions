// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;
using Microsoft.Purchases.Document;
using System.IO;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 13911 "EDoc Import OIOUBL"
{
    Access = Internal;
    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        GLSetup.Get();
        LCYCode := GLSetup."LCY Code";

        EDocument.Direction := EDocument.Direction::Incoming;

        case UpperCase(GetDocumentType(TempXMLBuffer)) of
            'INVOICE':
                ParseInvoiceBasicInfo(EDocument, TempXMLBuffer);
            'CREDITNOTE':
                ParseCreditMemoBasicInfo(EDocument, TempXMLBuffer);
            'REMINDER':
                ParseReminderOrFinChargeMemoBasicInfo(EDocument, TempXMLBuffer);
        end;
    end;

    procedure ParseCompleteInfo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream);
        TempXMLBuffer.LoadFromStream(DocStream);

        PurchaseHeader."Buy-from Vendor No." := EDocument."Bill-to/Pay-to No.";
        PurchaseHeader."Currency Code" := EDocument."Currency Code";
        PurchaseHeader."Amount Including VAT" := EDocument."Amount Incl. VAT";
        PurchaseHeader.Amount := EDocument."Amount Excl. VAT";

        case UpperCase(GetDocumentType(TempXMLBuffer)) of
            'INVOICE':
                CreateInvoice(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
            'CREDITNOTE':
                CreateCreditMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
            'REMINDER':
                CreateReminderOrFinChargeMemo(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
        end;
    end;

    local procedure ParseAccountingSupplierParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        Vendor: Record Vendor;
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        VendorNo: Code[20];
    begin
        // Vendor
        if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') = 'DK:CVR' then
            VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(VATRegistrationNo));

        if VATRegistrationNo = '' then
            if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID') = 'DK:CVR' then
                VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(VATRegistrationNo));

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

        if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID') = 'GLN' then
            EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));
        if EDocument."Receiving Company GLN" = '' then
            if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID') = 'GLN' then
                EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));

        if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID') = 'DK:CVR' then
            EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
        if EDocument."Receiving Company VAT Reg. No." = '' then
            if GetAttributeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID') = 'DK:CVR' then
                EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
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

        DueDate := GetNodeByPath(TempXMLBuffer, '/Invoice/cac:PaymentMeans/cbc:PaymentDueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount'), 9);
        EDocument."Amount Excl. VAT" := EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT";

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
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/CreditNote/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount'), 9);
        EDocument."Amount Excl. VAT" := EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT";

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        if LCYCode <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure ParseReminderOrFinChargeMemoBasicInfo(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        DueDate, IssueDate : Text;
        Currency: Text[10];
    begin
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Reminder/cbc:ID'), 1, MaxStrLen(EDocument."Document No."));
        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, 'Reminder');
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, 'Reminder');

        DueDate := GetNodeByPath(TempXMLBuffer, '/Reminder/cac:PaymentMeans/cbc:PaymentDueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, '/Reminder/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, '/Reminder/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, '/Reminder/cac:LegalMonetaryTotal/cbc:PayableAmount'), 9);

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, '/Reminder/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        if LCYCode <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure CreateInvoice(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Invoice/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        // Currency
        PurchaseHeader.Insert();

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseInvoice(PurchaseHeader, PurchaseLine, TempXMLBuffer.Path, TempXMLBuffer.Value);
            until TempXMLBuffer.Next() = 0;

        // Insert last line
        PurchaseLine.Insert();
        PurchaseHeader.Modify();

        // Allowance charge
        CreateInvoiceAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
    end;

    local procedure CreateCreditMemo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    var
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/CreditNote/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert();

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseCreditMemo(PurchaseHeader, PurchaseLine, TempXMLBuffer.Path, TempXMLBuffer.Value);
            until TempXMLBuffer.Next() = 0;

        // Insert last line
        PurchaseLine.Insert();
        PurchaseHeader.Modify();

        // Allowance charge
        CreateInvoiceAllowanceChargeLines(EDocument, PurchaseHeader, PurchaseLine, TempXMLBuffer);
    end;

    local procedure CreateReminderOrFinChargeMemo(var EDocument: Record "E-Document"; var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Invoice";
        PurchaseHeader."No." := CopyStr(GetNodeByPath(TempXMLBuffer, '/Reminder/cbc:ID'), 1, MaxStrLen(PurchaseHeader."No."));
        PurchaseHeader.Insert();

        TempXMLBuffer.Reset();
        if TempXMLBuffer.FindSet() then
            repeat
                ParseReminder(PurchaseHeader, PurchaseLine, TempXMLBuffer.Path, TempXMLBuffer.Value);
            until TempXMLBuffer.Next() = 0;

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

    local procedure ParseCreditMemo(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; Path: Text; Value: Text)
    var
    begin
        case Path of
            '/CreditNote/cbc:ID':
                PurchaseHeader."Vendor Cr. Memo No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Cr. Memo No."));
            '/CreditNote/cbc:DueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", Value, 9);
            '/CreditNote/cbc:IssueDate':
                if Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/CreditNote/cac:OrderReference/cbc:SalesOrderID':
                PurchaseHeader."Vendor Order No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Order No."));
            '/CreditNote/cac:OrderReference/cbc:CustomerReference':
                PurchaseHeader."Your Reference" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/CreditNote/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", Value, 9);
            '/CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Amount Including VAT", Value, 9);
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
                SetLineType(PurchaseLine, Value);
        end
    end;

    local procedure ParseInvoice(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; Path: Text; Value: Text)
    begin
        case Path of
            '/Invoice/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/Invoice/cbc:DueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", Value, 9);
            '/Invoice/cbc:IssueDate':
                if Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            '/Invoice/cac:OrderReference/cbc:SalesOrderID':
                PurchaseHeader."Vendor Order No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Order No."));
            '/Invoice/cac:OrderReference/cbc:CustomerReference':
                PurchaseHeader."Your Reference" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Your Reference"));
            '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID':
                begin
                    PurchaseHeader."Buy-from Contact" := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact"));
                    PurchaseHeader."Pay-to Contact" := PurchaseHeader."Buy-from Contact";
                end;
            '/Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Invoice Discount Value", Value, 9);
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
            '/Invoice/cac:InvoiceLine/cac:Price/cbc:PriceAmount':
                if Value <> '' then
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
            '/Invoice/cac:InvoiceLine/cac:Price/cbc:BaseQuantity':
                if Value <> '' then
                    Evaluate(PurchaseLine."Quantity (Base)", Value, 9);
            '/Invoice/cac:InvoiceLine/cbc:Note':
                SetLineType(PurchaseLine, Value);
        end;
    end;

    local procedure ParseReminder(var PurchaseHeader: Record "Purchase Header" temporary; var PurchaseLine: record "Purchase Line" temporary; Path: Text; Value: Text)
    begin
        case Path of
            '/Reminder/cbc:ID':
                PurchaseHeader."Vendor Invoice No." := CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
            '/Reminder/cbc:IssueDate':
                if Value <> '' then begin
                    Evaluate(PurchaseHeader."Document Date", Value, 9);
                    PurchaseHeader."Posting Date" := PurchaseHeader."Document Date";
                end;
            'Reminder/cac:PaymentMeans/cbc:PaymentDueDate':
                if Value <> '' then
                    Evaluate(PurchaseHeader."Due Date", Value, 9);
            '/Reminder/cac:ReminderLine':
                begin
                    if PurchaseLine."Document No." <> '' then
                        PurchaseLine.Insert();

                    PurchaseLine.Init();
                    PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                end;
            '/Reminder/cac:ReminderLine/cbc:ID':
                Evaluate(PurchaseLine."Line No.", Value, 9);
            '/Reminder/cac:ReminderLine/cbc:DebitLineAmount':
                if Value <> '' then begin
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
                    PurchaseLine.Quantity := 1;
                end;
            '/Reminder/cac:ReminderLine/cbc:DebitLineAmount/@currencyID':
                PurchaseLine."Currency Code" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Currency Code"));
            '/Reminder/cac:ReminderLine/cbc:CreditLineAmount':
                if Value <> '' then begin
                    Evaluate(PurchaseLine."Direct Unit Cost", Value, 9);
                    PurchaseLine."Direct Unit Cost" *= -1;
                    PurchaseLine.Quantity := 1;
                end;
            '/Reminder/cac:ReminderLine/cbc:CreditLineAmount/@currencyID':
                PurchaseLine."Currency Code" := CopyStr(Value, 1, MaxStrLen(PurchaseLine."Currency Code"));
            '/Reminder/cac:ReminderLine/cbc:Note':
                PurchaseLine.Description := CopyStr(Value, 1, MaxStrLen(PurchaseLine.Description));
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

    local procedure GetAttributeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetFilter(Path, XPath);

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

    var
        EDocumentImportHelper: codeunit "E-Document Import Helper";
        LCYCode: Code[10];
}