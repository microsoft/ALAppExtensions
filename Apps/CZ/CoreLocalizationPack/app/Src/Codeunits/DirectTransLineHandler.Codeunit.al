codeunit 31477 "Direct Trans. Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLine(var DirectTransLine: Record "Direct Trans. Line"; TransferLine: Record "Transfer Line")
    begin
        DirectTransLine."Tariff No. CZL" := TransferLine."Tariff No. CZL";
        DirectTransLine."Statistic Indication CZL" := TransferLine."Statistic Indication CZL";
        DirectTransLine."Country/Reg. of Orig. Code CZL" := TransferLine."Country/Reg. of Orig. Code CZL";
    end;
}