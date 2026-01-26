codeunit 148128 "Purch.Post Prepmt. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", 'OnPostVendorEntryOnAfterInitNewLine', '', false, false)]
    local procedure MyProcedure(var GenJnlLine: Record "Gen. Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        GenJnlLine."Original Doc. VAT Date CZL" := PurchHeader."Original Doc. VAT Date CZL";
    end;
}