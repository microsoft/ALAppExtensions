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

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeGetPurchHeader', '', false, false)]
    local procedure SetPurchaseHeaderArchiveOnBeforeGetPurchHeader(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        // This function should be removed at the same time as the DivideAmount function in Purchase Line table
        PurchaseHeader.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseHeader.SetRange("No.", PurchaseLine."Document No.");
        if not PurchaseHeader.IsEmpty() then
            exit;

        PurchaseHeaderArchive.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseHeaderArchive.SetRange("No.", PurchaseLine."Document No.");
        if not PurchaseHeaderArchive.FindFirst() then
            exit;

        PurchaseHeader.TransferFields(PurchaseHeaderArchive);
    end;
}