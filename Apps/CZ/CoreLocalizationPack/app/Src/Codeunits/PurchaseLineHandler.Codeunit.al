codeunit 11784 "Purchase Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchLine."Tariff No. CZL" := Item."Tariff No.";
        PurchLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        PurchLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
        if PurchaseHeader.Get(PurchLine."Document Type", PurchLine."Document No.") then
            PurchLine."Physical Transfer CZL" := PurchaseHeader."Physical Transfer CZL";
    end;
}