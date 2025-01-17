namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Posting;

codeunit 38503 "AP External Events"
{

    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterVendLedgEntryInsert', '', true, true)]
    local procedure OnAfterVendLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean; PreviewMode: Boolean)
    var
        Vendor: Record Vendor;
        Url: Text[250];
        WebClientUrl: Text[250];
        VendorApiUrlTok: Label 'v2.0/companies(%1)/vendors(%2)', Locked = true;
    begin
        if not Vendor.get(VendorLedgerEntry."Vendor No.") then
            exit;
        if PreviewMode then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(VendorApiUrlTok, 1, 250), Vendor.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Vendor Card", Vendor), 1, MaxStrLen(WebClientUrl));
        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Payment then
            EventPurchasePaymentPosted(Vendor.SystemId, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('PurchasePaymentPosted', 'Purchase payment posted', 'This business event is triggered when a vendor payment is posted as part of the Procure to Pay process.', EventCategory::"Accounts Payable", '1.0')]
    local procedure EventPurchasePaymentPosted(VendorId: Guid; Url: Text[250]; WebClientUrl: Text[250])
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
        WebClientUrl: Text[250];
        APIId: Guid;
        PurchaseInvoiceApiUrlTok: Label 'v2.0/companies(%1)/purchaseInvoices(%2)', Locked = true;
        PurchaseMemoApiUrlTok: Label 'v2.0/companies(%1)/purchaseCreditMemos(%2)', Locked = true;
        PurchaseReceiptsApiUrlTok: Label 'v2.0/companies(%1)/purchaseReceipts(%2)', Locked = true;
    begin
        if PreviewMode then
            exit;
        if PurchInvHeader."No." <> '' then begin
            if not IsNullGuid(PurchInvHeader."Draft Invoice SystemId") then
                APIId := PurchInvHeader."Draft Invoice SystemId"
            else
                APIId := PurchInvHeader.SystemId;
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseInvoiceApiUrlTok, 1, 250), APIId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Purchase Invoice", PurchInvHeader), 1, MaxStrLen(WebClientUrl));
            PurchaseInvoicePosted(APIId, PurchInvHeader.SystemId, Url, WebClientUrl);
        end;
        if PurchCrMemoHdr."No." <> '' then begin
            if not IsNullGuid(PurchCrMemoHdr."Draft Cr. Memo SystemId") then
                APIId := PurchCrMemoHdr."Draft Cr. Memo SystemId"
            else
                APIId := PurchCrMemoHdr.SystemId;
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseMemoApiUrlTok, 1, 250), APIId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Purchase Credit Memo", PurchCrMemoHdr), 1, MaxStrLen(WebClientUrl));
            CreditMemoInvoicePosted(APIId, PurchCrMemoHdr.SystemId, Url, WebClientUrl);
        end;
        if PurchRcptHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(PurchaseReceiptsApiUrlTok, 1, 250), PurchRcptHeader.SystemId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Purchase Receipt", PurchRcptHeader), 1, MaxStrLen(WebClientUrl));
            PurchaseReceiptPosted(PurchRcptHeader.SystemId, Url, WebClientUrl);
        end;
    end;

    [ExternalBusinessEvent('PurchaseInvoicePosted', 'Purchase invoice posted', 'This business event is triggered when a vendor invoice is posted as part of the Procure to Pay process.', EventCategory::"Accounts Payable", '1.0')]
    local procedure PurchaseInvoicePosted(PurchaseInvoiceAPIId: Guid; PurchaseInvoiceSystemId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('PurchaseCreditMemoPosted', 'Purchase credit memo posted', 'This business event is triggered when a purchase credit memo is posted.', EventCategory::"Accounts Payable", '1.0')]
    local procedure CreditMemoInvoicePosted(PurchaseCreditMemoAPIId: Guid; PurchaseCreditMemoSystemId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('PurchaseReceiptPosted', 'Purchase receipt posted', 'This business event is triggered when goods from a purchase order are received by the internal warehouse/external logistics company. This can trigger Finance Department to post a purchase invoice.', EventCategory::"Accounts Payable", '1.0')]
    local procedure PurchaseReceiptPosted(PurchaseReceiptId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}