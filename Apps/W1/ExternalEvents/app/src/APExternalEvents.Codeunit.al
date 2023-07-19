Codeunit 38503 "AP External Events"
{

    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterVendLedgEntryInsert', '', true, true)]
    local procedure OnAfterVendorLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean)
    var
        Vendor: Record Vendor;
        Url: Text[250];
        VendorApiUrlTok: Label 'v2.0/companies(%1)/vendors(%2)', Locked = true;
    begin
        if not Vendor.get(VendorLedgerEntry."Vendor No.") then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(VendorApiUrlTok, 1, 250), Vendor.SystemId);
        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Payment then
            EventPurchasePaymentPosted(Vendor.SystemId, Url);
    end;

    [ExternalBusinessEvent('PurchasePaymentPosted', 'Purchase payment posted', 'This business event is triggered when a vendor payment is posted as part of the Procure to Pay process.', EventCategory::"Accounts Payable")]
    local procedure EventPurchasePaymentPosted(VendorId: Guid; Url: text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePosting', '', true, true)]
    local procedure OnAfterFinalizePosting(
        var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header";
        var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PreviewMode: Boolean; CommitIsSupressed: Boolean)

    var
        Url: Text[250];
        PurchaseInvoiceApiUrlTok: Label 'v2.0/companies(%1)/purchaseInvoices(%2)', Locked = true;
        PurchaseMemoApiUrlTok: Label 'v2.0/companies(%1)/purchaseCreditMemos(%2)', Locked = true;
        PurchaseReceiptsApiUrlTok: Label 'v2.0/companies(%1)/purchaseReceipts(%2)', Locked = true;
    begin
        if PurchInvHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseInvoiceApiUrlTok, 1, 250), PurchInvHeader.SystemId);
            MyBusinessEventPurchaseInvoicePosted(PurchInvHeader.SystemId, Url);
        end;
        if PurchCrMemoHdr."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseMemoApiUrlTok, 1, 250), PurchCrMemoHdr.SystemId);
            EventCreditMemoInvoicePosted(PurchCrMemoHdr.SystemId, Url);
        end;
        if PurchRcptHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseReceiptsApiUrlTok, 1, 250), PurchRcptHeader.SystemId);
            EventPurchaseReceivedPosted(PurchRcptHeader.SystemId, Url);
        end;
    end;

    [ExternalBusinessEvent('PurchaseInvoicePosted', 'Purchase invoice posted', 'This business event is triggered when a vendor invoice is posted as part of the Procure to Pay process.', EventCategory::"Accounts Payable")]
    local procedure MyBusinessEventPurchaseInvoicePosted(PurchaseInvoiceId: Guid; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('PurchaseCreditMemoPosted', 'Purchase credit memo posted', 'This business event is triggered when a purchase credit memo is posted.', EventCategory::"Accounts Payable")]
    local procedure EventCreditMemoInvoicePosted(PurchaseInvoiceId: Guid; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('PurchaseReceiptPosted', 'Purchase receipt posted', 'This business event is triggered when goods from a purchase order are received by the internal warehouse/external logistics company. This can trigger Finance Department to post a purchase invoice.', EventCategory::"Accounts Payable")]
    local procedure EventPurchaseReceivedPosted(PurchaseInvoiceId: Guid; Url: text[250])
    begin
    end;
}