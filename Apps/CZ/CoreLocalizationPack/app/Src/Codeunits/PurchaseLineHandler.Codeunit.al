codeunit 11784 "Purchase Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure TariffNoOnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item)
    begin
        PurchLine."Tariff No. CZL" := Item."Tariff No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure StatisticIndicationOnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item)
    begin
        PurchLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
    end;
}