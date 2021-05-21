codeunit 11783 "Sales Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesLine."Tariff No. CZL" := Item."Tariff No.";
        SalesLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        SalesLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            SalesLine."Physical Transfer CZL" := SalesHeader."Physical Transfer CZL";        
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        SalesLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;
}