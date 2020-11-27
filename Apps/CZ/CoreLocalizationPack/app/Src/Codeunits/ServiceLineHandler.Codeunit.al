codeunit 11785 "Service Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure TariffNoOnAfterAssignItemValues(var ServiceLine: Record "Service Line"; Item: Record Item)
    begin
        ServiceLine."Tariff No. CZL" := Item."Tariff No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure StatisticIndicationOnAfterAssignItemValues(var ServiceLine: Record "Service Line"; Item: Record Item)
    begin
        ServiceLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var ServiceLine: Record "Service Line"; Resource: Record Resource)
    begin
        ServiceLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;
}