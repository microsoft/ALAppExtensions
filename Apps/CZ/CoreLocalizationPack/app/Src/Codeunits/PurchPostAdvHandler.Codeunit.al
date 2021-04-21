#pragma warning disable AL0432
codeunit 31328 "Purch. Post Adv. Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostLetter_SetInvHeaderOnBeforeInsertPurchInvHeader', '', false, false)]
    local procedure SyncFieldsOnPostLetter_SetInvHeaderOnBeforeInsertPurchInvHeader(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        PurchInvHeader."VAT Date CZL" := PurchInvHeader."VAT Date";
        PurchInvHeader."Original Doc. VAT Date CZL" := PurchInvHeader."Original Document VAT Date";
        PurchInvHeader."Registration No. CZL" := PurchInvHeader."Registration No.";
        PurchInvHeader."Tax Registration No. CZL" := PurchInvHeader."Tax Registration No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostLetter_SetCrMemoHeaderOnBeforeInsertPurchCrMemoHeader', '', false, false)]
    local procedure SyncFieldsOnPostLetter_SetCrMemoHeaderOnBeforeInsertPurchCrMemoHeader(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHdr."VAT Date CZL" := PurchCrMemoHdr."VAT Date";
        PurchCrMemoHdr."Original Doc. VAT Date CZL" := PurchCrMemoHdr."Original Document VAT Date";
    end;
}