codeunit 11783 "Sales Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure TariffNoOnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine."Tariff No. CZL" := Item."Tariff No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure StatisticIndicationOnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        SalesLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;
}