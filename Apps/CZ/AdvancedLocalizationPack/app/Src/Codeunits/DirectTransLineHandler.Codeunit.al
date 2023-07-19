codeunit 31478 "Direct Trans. Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLine(var DirectTransLine: Record "Direct Trans. Line"; TransferLine: Record "Transfer Line")
    begin
        TransferLine.CheckGenBusPostGroupEqualityCZA();
        DirectTransLine."Gen. Bus. Posting Group CZA" := TransferLine."Gen.Bus.Post.Group Ship CZA";
    end;
}