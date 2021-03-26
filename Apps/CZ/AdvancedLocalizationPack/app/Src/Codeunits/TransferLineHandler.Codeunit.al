codeunit 31228 "Transfer Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterGetTransHeader', '', false, false)]
    local procedure SetGenBusPostingGroupsOnAfterGetTransHeader(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        TransferLine."Gen.Bus.Post.Group Ship CZA" := TransferHeader."Gen.Bus.Post.Group Ship CZA";
        TransferLine."Gen.Bus.Post.Group Receive CZA" := TransferHeader."Gen.Bus.Post.Group Receive CZA";
    end;
}