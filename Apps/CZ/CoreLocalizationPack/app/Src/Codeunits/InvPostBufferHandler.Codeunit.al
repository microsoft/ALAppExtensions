codeunit 31307 "Inv. Post. Buffer Handler CZL"
{
    Access = Internal;

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnBeforeInvPostBufferModify', '', false, false)]
    local procedure UpdateExtendedAmountsOnBeforeInvPostBufferModify(var InvoicePostBuffer: Record "Invoice Post. Buffer"; FromInvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."Ext. Amount CZL" += FromInvoicePostBuffer."Ext. Amount CZL";
        InvoicePostBuffer."Ext. Amount Incl. VAT CZL" += FromInvoicePostBuffer."Ext. Amount Incl. VAT CZL";
    end;
#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnUpdateOnBeforeModify', '', false, false)]
    local procedure UpdateExtendedAmountsOnUpdateOnBeforeModify(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; FromInvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."Ext. Amount CZL" += FromInvoicePostingBuffer."Ext. Amount CZL";
        InvoicePostingBuffer."Ext. Amount Incl. VAT CZL" += FromInvoicePostingBuffer."Ext. Amount Incl. VAT CZL";
    end;
}