codeunit 139640 "AR Subscribers"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        OnAfterFinalizePostingSalesInvoiceCalled: Boolean;
        OnAfterCustLedgEntryInsertCalled: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePosting', '', true, true)]
    local procedure OnAfterFinalizePostingSalesInvoice
        (var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header";
        var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var

    begin
        OnAfterFinalizePostingSalesInvoiceCalled := true;
    end;

    procedure GetOnAfterFinalizePostingSalesInvoiceCalled(): Boolean
    begin
        Exit(OnAfterFinalizePostingSalesInvoiceCalled);
    end;

    procedure ClearOnAfterFinalizePostingSalesInvoiceCalled()
    begin
        OnAfterFinalizePostingSalesInvoiceCalled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCustLedgEntryInsertInclPreviewMode', '', true, true)]
    local procedure OnAfterCustLedgEntryInsertInclPreviewMode(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean; PreviewMode: Boolean)
    begin
        OnAfterCustLedgEntryInsertCalled := true;
    end;

    procedure GetOnAfterCustLedgEntryInsertCalled(): Boolean
    begin
        Exit(OnAfterCustLedgEntryInsertCalled);
    end;

    procedure ClearOnAfterCustLedgEntryInsertCalled()
    begin
        OnAfterCustLedgEntryInsertCalled := false;
    end;

}