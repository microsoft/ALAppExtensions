#pragma warning disable AL0603
codeunit 11740 "Copy Document Mgt. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterTransfldsFromSalesToPurchLine', '', false, false)]
    local procedure TariffNoOnAfterTransfldsFromSalesToPurchLine(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        ToPurchaseLine."Tariff No. CZL" := FromSalesLine."Tariff No. CZL";
        ToPurchaseLine."Country/Reg. of Orig. Code CZL" := FromSalesLine."Country/Reg. of Orig. Code CZL";
        ToPurchaseLine."Net Weight" := FromSalesLine."Net Weight";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyFieldsFromOldSalesHeader', '', false, false)]
    local procedure CopyCreditMemoTypeFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header")
    begin
        if ToSalesHeader.IsCreditDocType() then
            ToSalesHeader."Credit Memo Type CZL" := OldSalesHeader."Credit Memo Type CZL"
        else
            Clear(ToSalesHeader."Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry', '', false, false)]
    local procedure UpdateBankInfoOnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry(var ToSalesHeader: Record "Sales Header"; FromDocType: Option)
    begin
        if (ToSalesHeader.IsCreditDocType() and not
                (FromDocType in ["Sales Document Type From"::"Return Order",
                                "Sales Document Type From"::"Credit Memo",
                                "Sales Document Type From"::"Posted Credit Memo"])) or
           (not ToSalesHeader.IsCreditDocType() and
                (FromDocType in ["Sales Document Type From"::"Return Order",
                                "Sales Document Type From"::"Credit Memo",
                                "Sales Document Type From"::"Posted Credit Memo"]))
        then begin
            ToSalesHeader."Specific Symbol CZL" := '';
            ToSalesHeader."Variable Symbol CZL" := '';
            ToSalesHeader."Constant Symbol CZL" := '';
            ToSalesHeader.UpdateBankInfoCZL('', '', '', '', '', '', '');
        end;
    end;
}
