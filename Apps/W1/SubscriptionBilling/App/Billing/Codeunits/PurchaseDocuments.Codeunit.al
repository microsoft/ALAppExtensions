namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 8066 "Purchase Documents"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeDeleteEvent, '', false, false)]
    local procedure PurchaseHeaderOnBeforeDeleteEvent(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        BillingLine: Record "Billing Line";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        if not (Rec."Document Type" in [Enum::"Purchase Document Type"::Invoice, Enum::"Purchase Document Type"::"Credit Memo"]) then
            exit;

        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then begin
            PurchaseLine.SetRange("Document Type", Rec."Document Type");
            PurchaseLine.SetRange("Document No.", Rec."No.");
            if PurchaseLine.FindSet() then
                repeat
                    ResetServiceCommitmentAndDeleteBillingLinesForPurchaseLine(PurchaseLine);
                until PurchaseLine.Next() = 0;
        end else
            if AutoResetServiceCommitmentAndDeleteBillingLinesForPurchaseInvoice(Rec."No.") then begin
                PurchaseLine.SetRange("Document Type", Rec."Document Type");
                PurchaseLine.SetRange("Document No.", Rec."No.");
                if PurchaseLine.FindSet() then
                    repeat
                        ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(PurchaseLine);
                    until PurchaseLine.Next() = 0;
            end else begin
                BillingLine.SetRange("Document Type", BillingLine."Document Type"::Invoice);
                BillingLine.SetRange("Document No.", Rec."No.");
                ResetPurchaseDocumentFieldsForBillingLines(BillingLine);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure PurchaseLineOnAfterDeleteEvent(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        BillingLine: Record "Billing Line";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if not (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo"]) then
            exit;

        if (not Rec.IsLineAttachedToBillingLine()) or
            (Rec."Recurring Billing from" = 0D) or
            (Rec."Recurring Billing to" = 0D)
        then
            exit;

        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
            ResetServiceCommitmentAndDeleteBillingLinesForPurchaseLine(Rec)
        else
            if AutoResetServiceCommitmentAndDeleteBillingLinesForPurchaseInvoice(Rec."Document No.") then
                ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(Rec)
            else begin
                FilterBillingLinePerPurchaseLine(BillingLine, Rec);
                ResetPurchaseDocumentFieldsForBillingLines(BillingLine);
            end;
    end;

    local procedure ResetServiceCommitmentAndDeleteBillingLinesForPurchaseLine(PurchaseLine: Record "Purchase Line")
    var
        BillingLine: Record "Billing Line";
    begin
        FilterBillingLinePerPurchaseLine(BillingLine, PurchaseLine);
        if BillingLine.FindFirst() then begin
            BillingLine.FindFirstBillingLineForServiceCommitment(BillingLine);
            BillingLine.ResetServiceCommitmentNextBillingDate();
            BillingLine.DeleteAll(false);
        end;
    end;

    local procedure FilterBillingLinePerPurchaseLine(var BillingLine: Record "Billing Line"; PurchaseLine: Record "Purchase Line")
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
    end;

    local procedure ResetPurchaseDocumentFieldsForBillingLines(var BillingLine: Record "Billing Line")
    begin
        if not BillingLine.IsEmpty then begin
            BillingLine.ModifyAll("Document Type", BillingLine."Document Type"::None, false);
            BillingLine.SetRange("Document Type", BillingLine."Document Type"::None);
            BillingLine.ModifyAll("Document No.", '', false);
            BillingLine.ModifyAll("Document Line No.", 0, false);
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforeDeleteAfterPosting, '', false, false)]
    local procedure PurchasePostOnBeforePurchaseLineDeleteAll(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchaseLine: Record "Purchase Line";
        BillingLine: Record "Billing Line";
    begin
        if not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo"]) then
            exit;
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter("Recurring Billing from", '<>%1', 0D);
        PurchaseLine.SetFilter("Recurring Billing to", '<>%1', 0D);

        if PurchaseLine.FindSet() then
            repeat
                FilterBillingLinePerPurchaseLine(BillingLine, PurchaseLine);
                MoveBillingLineToBillingLineArchive(BillingLine, PurchaseHeader, PurchInvHeader, PurchCrMemoHdr);
                BillingLine.DeleteAll(false);
            until PurchaseLine.Next() = 0;
    end;

    local procedure MoveBillingLineToBillingLineArchive(var BillingLine: Record "Billing Line"; var PurchaseHeader: Record "Purchase Header"; var PurchaseInvoiceHeader: Record "Purch. Inv. Header"; var PurchaseCrMemoHeader: Record "Purch. Cr. Memo Hdr.")
    var
        BillingLineArchive: Record "Billing Line Archive";
        PostedDocumentNo: Code[20];
    begin
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Invoice:
                PostedDocumentNo := PurchaseInvoiceHeader."No.";
            PurchaseHeader."Document Type"::"Credit Memo":
                PostedDocumentNo := PurchaseCrMemoHeader."No.";
        end;
        if BillingLine.FindSet() then
            repeat
                BillingLineArchive.Init();
                BillingLineArchive.TransferFields(BillingLine);
                BillingLineArchive."Document No." := PostedDocumentNo;
                BillingLineArchive."Entry No." := 0;
                BillingLineArchive.Insert(false);
                OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive(BillingLineArchive, BillingLine);
            until BillingLine.Next() = 0;
    end;

    local procedure AutoResetServiceCommitmentAndDeleteBillingLinesForPurchaseInvoice(DocumentNo: Code[20]): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLine.SetRange("Document No.", DocumentNo);
        BillingLine.SetRange(Partner, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Billing Template Code", '');
        exit(not BillingLine.IsEmpty());
    end;

    local procedure ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(PurchaseLine: Record "Purchase Line")
    var
        BillingLine: Record "Billing Line";
    begin
        FilterBillingLinePerPurchaseLine(BillingLine, PurchaseLine);
        if BillingLine.FindFirst() then begin
            BillingLine.ResetServiceCommitmentNextBillingDate();
            BillingLine.DeleteAll(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeVendLedgEntryInsert, '', false, false)]
    local procedure TransferRecurringBillingMark(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        RecurringBilling: Boolean;
        SubscriptionBillingTok: Label 'Subscription Billing', Locked = true;
        MessageTok: Label 'Subscription Billing Vendor Ledger Entry Created', Locked = true;
    begin
        RecurringBilling := GetRecurringBillingField(VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.");
        if not RecurringBilling then
            exit;

        VendorLedgerEntry."Recurring Billing" := RecurringBilling;

        Session.LogMessage('0000NN4', MessageTok, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SubscriptionBillingTok);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive(var BillingLineArchive: Record "Billing Line Archive"; BillingLine: Record "Billing Line")
    begin
    end;

    internal procedure GetRecurringBillingField(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]): Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        case DocumentType of
            "Gen. Journal Document Type"::Invoice:
                if PurchInvHeader.Get(DocumentNo) then
                    exit(PurchInvHeader."Recurring Billing");
            "Gen. Journal Document Type"::"Credit Memo":
                if PurchCrMemoHeader.Get(DocumentNo) then
                    exit(PurchCrMemoHeader."Recurring Billing");
            else
                exit(false);
        end;
        exit(false);
    end;

    internal procedure IsInvoiceCredited(DocumentNo: Code[20]): Boolean
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        if DocumentNo = '' then
            exit(false);
        exit(BillingLineArchive.IsInvoiceCredited("Service Partner"::Vendor, DocumentNo));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Line", OnAfterInitFromPurchLine, '', false, false)]
    local procedure PurchInvLineCopyContractNoOnAfterInitFromPurchLine(PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchLine."Document Type"), PurchLine."Document No.", PurchLine."Line No.");
        if not BillingLine.FindFirst() then
            exit;
        PurchInvLine."Contract No." := BillingLine."Contract No.";
        PurchInvLine."Contract Line No." := BillingLine."Contract Line No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Line", OnAfterInitFromPurchLine, '', false, false)]
    local procedure PurchCrMemoLineCopyContractNoOnAfterInitFromPurchLine(PurchLine: Record "Purchase Line"; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchLine."Document Type"), PurchLine."Document No.", PurchLine."Line No.");
        if not BillingLine.FindFirst() then
            exit;
        PurchCrMemoLine."Contract No." := BillingLine."Contract No.";
        PurchCrMemoLine."Contract Line No." := BillingLine."Contract Line No.";
    end;
}
