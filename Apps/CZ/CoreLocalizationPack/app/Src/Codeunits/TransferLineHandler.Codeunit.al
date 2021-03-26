codeunit 31046 "Transfer Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var TransferLine: Record "Transfer Line"; Item: Record Item)
    begin
        TransferLine."Tariff No. CZL" := Item."Tariff No.";
        TransferLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        TransferLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
    end;
}