codeunit 11785 "Service Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFieldsOnAfterAssignItemValues(var ServiceLine: Record "Service Line"; Item: Record Item)
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceLine."Tariff No. CZL" := Item."Tariff No.";
        ServiceLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        ServiceLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
        if ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.") then
            ServiceLine."Physical Transfer CZL" := ServiceHeader."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var ServiceLine: Record "Service Line"; Resource: Record Resource)
    begin
        ServiceLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;
}