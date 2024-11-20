// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Reflection;

codeunit 6108 "E-Document Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document Service Status" = rim,
                tabledata "E-Document" = m;

    /// <summary>
    /// Inserts E-Document Service Status record. Throws runtime error if record does exists.
    /// </summary>
    procedure InsertServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.Validate("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.Validate("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.Validate(Status, EDocumentStatus);
        EDocumentServiceStatus.Insert();
    end;

    /// <summary>
    /// Updates existing service status record. Throws runtime error if record does not exists.
    /// </summary>
    procedure ModifyServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.ReadIsolation(IsolationLevel::ReadCommitted);
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocumentServiceStatus.Validate(Status, EDocumentStatus);
        EDocumentServiceStatus.Modify();
    end;

    /// <summary>
    /// Updates EDocument status based on E-Document Service Status value
    /// </summary>
    procedure ModifyEDocumentStatus(var EDocument: Record "E-Document"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
#if not CLEAN26
        EDocumentLog: Codeunit "E-Document Log";
#endif
        EDocServiceCount: Integer;
#if not CLEAN26
        IsHandled: Boolean;
#endif
    begin
#if not CLEAN26
        EDocumentLog.OnUpdateEDocumentStatus(EDocument, IsHandled);
        if IsHandled then
            exit;
#endif

        // Check for errors
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5',
            EDocumentServiceStatus.Status::"Sending Error",
            EDocumentServiceStatus.Status::"Export Error",
            EDocumentServiceStatus.Status::"Cancel Error",
            EDocumentServiceStatus.Status::"Imported Document Processing Error",
            EDocumentServiceStatus.Status::"Approval Error");

        if not EDocumentServiceStatus.IsEmpty() then begin
            EDocument.Get(EDocument."Entry No");
            EDocument.Validate(Status, EDocument.Status::Error);
            EDocument.Modify(true);
            exit;
        end;

        Clear(EDocumentServiceStatus);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocServiceCount := EDocumentServiceStatus.Count();

        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5|%6',
            EDocumentServiceStatus.Status::Sent,
            EDocumentServiceStatus.Status::Exported,
            EDocumentServiceStatus.Status::"Imported Document Created",
            EDocumentServiceStatus.Status::"Journal Line Created",
            EDocumentServiceStatus.Status::Approved,
            EDocumentServiceStatus.Status::Rejected,
            EDocumentServiceStatus.Status::Canceled);

        // There can be service status for multiple services:
        // Example Service A and Service B
        // Service A -> Sent
        // Service B -> Exported
        EDocument.Get(EDocument."Entry No");
        if EDocumentServiceStatus.Count() = EDocServiceCount then
            EDocument.Validate(Status, EDocument.Status::Processed)
        else
            EDocument.Validate(Status, EDocument.Status::"In Progress");

        EDocument.Modify(true);
    end;

    procedure GetDocSendingProfileForDocRef(var RecRef: RecordRef): Record "Document Sending Profile";
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        FinChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        case RecRef.Number of
            Database::"Sales Header", Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header",
            Database::"Service Header", Database::"Service Invoice Header", Database::"Service Cr.Memo Header":
                exit(GetDocSendingProfileForCustVend(RecRef.Field(SalesHeader.FieldNo("Bill-to Customer No.")).Value, ''));

            Database::"Finance Charge Memo Header", Database::"Issued Fin. Charge Memo Header",
            Database::"Reminder Header", Database::"Issued Reminder Header":
                exit(GetDocSendingProfileForCustVend(RecRef.Field(FinChargeMemoHeader.FieldNo("Customer No.")).Value, ''));

            Database::"Purchase Header", Database::"Purch. Inv. Header", Database::"Purch. Cr. Memo Hdr.":
                exit(GetDocSendingProfileForCustVend('', RecRef.Field(PurchaseHeader.FieldNo("Pay-to Vendor No.")).Value));
        end;
    end;

    procedure GetLines(EDocument: Record "E-Document"; var SourceDocumentLines: RecordRef)
    begin
        case EDocument."Document Type" of
            EDocument."Document Type"::"Sales Invoice":
                begin
                    SourceDocumentLines.Open(Database::"Sales Invoice Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Sales Credit Memo":
                begin
                    SourceDocumentLines.Open(Database::"Sales Cr.Memo Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Service Invoice":
                begin
                    SourceDocumentLines.Open(Database::"Service Invoice Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Service Credit Memo":
                begin
                    SourceDocumentLines.Open(Database::"Service Cr.Memo Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Purchase Invoice":
                begin
                    SourceDocumentLines.Open(Database::"Purch. Inv. Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Purchase Credit Memo":
                begin
                    SourceDocumentLines.Open(Database::"Purch. Cr. Memo Line");
                    SourceDocumentLines.Field(3).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Issued Finance Charge Memo":
                begin
                    SourceDocumentLines.Open(Database::"Issued Fin. Charge Memo Line");
                    SourceDocumentLines.Field(1).SetRange(EDocument."Document No.");
                end;
            EDocument."Document Type"::"Issued Reminder":
                begin
                    SourceDocumentLines.Open(Database::"Issued Reminder Line");
                    SourceDocumentLines.Field(1).SetRange(EDocument."Document No.");
                end;
        end;
    end;

    procedure GetEDocumentCount(Status: Enum "E-Document Status"; Direction: Enum "E-Document Direction"): Integer
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange(Status, Status);
        EDocument.SetRange(Direction, Direction);

        exit(EDocument.Count());
    end;

    procedure MatchedPurchaseOrdersCount(): Integer
    var
        PurchaseHeader: Record "Purchase Header";
        Guid: Guid;
    begin
        PurchaseHeader.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        PurchaseHeader.SetFilter("E-Document Link", '<>%1', Guid);
        exit(PurchaseHeader.Count());
    end;

    procedure WaitingPurchaseEDocCount(): Integer
    var
        EDocument: Record "E-Document";
    begin
        GetWaitingPurchaseEDoc(EDocument);
        exit(EDocument.Count());
    end;

    procedure OpenWaitingPurchaseEDoc()
    var
        EDocument: Record "E-Document";
    begin
        GetWaitingPurchaseEDoc(EDocument);
        Page.Run(Page::"E-Documents", EDocument);
    end;

    local procedure GetWaitingPurchaseEDoc(var EDocument: Record "E-Document")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocument.SetRange("Document Type", Enum::"E-Document Type"::"Purchase Order");
        EDocument.SetFilter(Status, '%1|%2', Enum::"E-Document Status"::"In Progress", Enum::"E-Document Status"::Error);
        if EDocument.FindSet() then
            repeat
                EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
                EDocumentServiceStatus.SetFilter(Status, '%1|%2', Enum::"E-Document Service Status"::Pending, Enum::"E-Document Service Status"::"Imported Document Processing Error");
                if not EDocumentServiceStatus.IsEmpty() then
                    EDocument.Mark(true);
            until EDocument.Next() = 0;

        EDocument.MarkedOnly(true);
    end;

    procedure OpenMatchedPurchaseOrders()
    var
        PurchaseHeader: Record "Purchase Header";
        Guid: Guid;
    begin
        PurchaseHeader.SetFilter("E-Document Link", '<>%1', Guid);
        Page.Run(Page::"Purchase Order List", PurchaseHeader);
    end;

    procedure OpenEDocuments(Status: Enum "E-Document Status"; Direction: Enum "E-Document Direction"): Integer
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange(Status, Status);
        EDocument.SetRange(Direction, Direction);

        Page.Run(Page::"E-Documents", EDocument);
    end;

    procedure GetRecordLinkText(var EDocument: Record "E-Document"): Text
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        VariantRecord: Variant;
    begin
        if GetRecord(EDocument, VariantRecord) and DataTypeManagement.GetRecordRef(VariantRecord, RecRef) then
            exit(GetRelatedRecordCaption(EDocument, RecRef));
        exit('');
    end;

    procedure GetRecord(var EDocument: Record "E-Document"; var RelatedRecord: Variant): Boolean
    begin
        exit(GetPostedRecord(EDocument, RelatedRecord));
    end;

    procedure GetTelemetryDimensions(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var Dimensions: Dictionary of [Text, Text])
    var
        EDocument2: Record "E-Document";
    begin
        Clear(Dimensions);
        Dimensions.Add('Category', EDocTelemetryCategoryLbl);
        Dimensions.Add('E-Doc Service', EDocService.ToString());
        EDocument2.Copy(EDocument);
        if not EDocument2.HasFilter() then
            EDocument2.SetRecFilter();
        if EDocument2.FindSet() then
            repeat
                Dimensions.Add(StrSubstNo(EDocTelemetryIdLbl, EDocument2.SystemId), EDocument2.ToString());
            until EDocument2.Next() = 0;
    end;

    procedure GetTelemetryDimensions(EDocService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status"; var Dimensions: Dictionary of [Text, Text])
    begin
        Clear(Dimensions);
        Dimensions.Add('Category', EDocTelemetryCategoryLbl);
        Dimensions.Add('E-Doc Service', EDocService.ToString());
        Dimensions.Add('E-Doc Service Status', EDocumentServiceStatus.ToString());
    end;

    procedure GetEDocTok(): Text
    begin
        exit(EDocTok);
    end;

    local procedure GetDocSendingProfileForCustVend(CustomerNo: Code[20]; VendorNo: Code[20]) DocumentSendingProfile: Record "Document Sending Profile";
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if CustomerNo <> '' then begin
            if Customer.Get(CustomerNo) then
                if DocumentSendingProfile.Get(Customer."Document Sending Profile") then
                    exit;
        end else
            if Vendor.Get(VendorNo) then
                if DocumentSendingProfile.Get(Vendor."Document Sending Profile") then
                    exit;

        DocumentSendingProfile.SetRange(Default, true);
        if not DocumentSendingProfile.FindFirst() then
            Clear(DocumentSendingProfile);
    end;

    local procedure GetPostedRecord(var EDocument: Record "E-Document"; var RelatedRecord: Variant): Boolean
    var
        RelatedRecordRef: RecordRef;
    begin
        if GetRelatedRecord(EDocument, RelatedRecordRef) then begin
            RelatedRecord := RelatedRecordRef;
            exit(true);
        end;
        exit(FindPostedRecord(EDocument, RelatedRecord));
    end;

    local procedure GetRelatedRecord(var EDocument: Record "E-Document"; var RelatedRecordRef: RecordRef): Boolean
    var
        RelatedRecordID: RecordID;
    begin
        RelatedRecordID := EDocument."Document Record ID";
        if RelatedRecordID.TableNo = 0 then
            exit(false);
        RelatedRecordRef := RelatedRecordID.GetRecord();
        exit(RelatedRecordRef.Get(RelatedRecordID));
    end;

    local procedure FindPostedRecord(var EDocument: Record "E-Document"; var RelatedRecord: Variant): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        GLEntry: Record "G/L Entry";
    begin
        case EDocument."Document Type" of
            EDocument."Document Type"::"General Journal":
                begin
                    GLEntry.SetCurrentKey("Document No.", "Posting Date");
                    GLEntry.SetRange("Document No.", EDocument."Document No.");
                    GLEntry.SetRange("Posting Date", EDocument."Posting Date");
                    if GLEntry.FindFirst() then begin
                        RelatedRecord := GLEntry;
                        exit(true);
                    end;
                end;
            EDocument."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(EDocument."Document No.") then begin
                    RelatedRecord := SalesInvoiceHeader;
                    exit(true);
                end;
            EDocument."Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(EDocument."Document No.") then begin
                    RelatedRecord := SalesCrMemoHeader;
                    exit(true);
                end;
            EDocument."Document Type"::"Purchase Invoice":
                if PurchInvHeader.Get(EDocument."Document No.") then begin
                    RelatedRecord := PurchInvHeader;
                    exit(true);
                end;
            EDocument."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(EDocument."Document No.") then begin
                    RelatedRecord := PurchCrMemoHdr;
                    exit(true);
                end;
        end;
        exit(false);
    end;

    local procedure GetRelatedRecordCaption(var EDocument: Record "E-Document"; var RelatedRecordRef: RecordRef): Text
    var
        GenJournalLine: Record "Gen. Journal Line";
        RecCaption: Text;
    begin
        if RelatedRecordRef.IsEmpty() then
            exit('');

        case RelatedRecordRef.Number of
            Database::"Sales Header":
                RecCaption := GetRecordCaption(RelatedRecordRef);
            Database::"Sales Invoice Header":
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
            Database::"Sales Cr.Memo Header":
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
            Database::"Purchase Header":
                RecCaption := GetRecordCaption(RelatedRecordRef);
            Database::"Purch. Inv. Header":
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
            Database::"Purch. Cr. Memo Hdr.":
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
            Database::"G/L Entry":
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
            Database::"Gen. Journal Line":
                begin
                    RelatedRecordRef.SetTable(GenJournalLine);
                    if GenJournalLine."Document Type" <> GenJournalLine."Document Type"::" " then
                        RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef))
                    else
                        RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, EDocument."Document Type", GetRecordCaption(RelatedRecordRef));
                end;
            else
                RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, RelatedRecordRef.Caption, GetRecordCaption(RelatedRecordRef));
        end;
        exit(RecCaption);
    end;

    local procedure GetRecordCaption(var RecRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        KeyNo: Integer;
        FieldNo: Integer;
        RecCaption: Text;
    begin
        for KeyNo := 1 to RecRef.KeyCount do begin
            KeyRef := RecRef.KeyIndex(KeyNo);
            if KeyRef.Active then begin
                for FieldNo := 1 to KeyRef.FieldCount do begin
                    FieldRef := KeyRef.FieldIndex(FieldNo);
                    if RecCaption <> '' then
                        RecCaption := StrSubstNo(RelatedRecordCaptionWithDashTxt, RecCaption, FieldRef.Value)
                    else
                        RecCaption := Format(FieldRef.Value);
                end;
                break;
            end
        end;
        exit(RecCaption);
    end;

    var
        RelatedRecordCaptionWithDashTxt: Label '%1 - %2', Comment = '%1 - Record Text, %2 - Record Caption', Locked = true;
        EDocTelemetryCategoryLbl: Label 'E-Document', Locked = true;
        EDocTelemetryIdLbl: Label 'E-Doc %1', Locked = true;
        EDocTok: Label 'W1 E-Document', Locked = true;
}
