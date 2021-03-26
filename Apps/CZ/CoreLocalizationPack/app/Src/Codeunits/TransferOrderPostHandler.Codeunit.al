codeunit 31048 "TransferOrder-Post Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterCheckBeforePost', '', false, false)]
    local procedure CheckMandatoryFieldsOnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")
    begin
        if TransferHeader.IsIntrastatTransactionCZL() and TransferHeader.ShipOrReceiveInventoriableTypeItemsCZL() then
            TransferHeader.CheckIntrastatMandatoryFieldsCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnCheckTransLine', '', false, false)]
    local procedure CheckMandatoryFieldsOnCheckTransLineOnPostReceipt(TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        if TransferHeader.IsIntrastatTransactionCZL() then
            TransferLine.CheckIntrastatMandatoryFieldsCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure CopyFieldsOnBeforePostItemJournalLineOnPostReceipt(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine.CopyFromTransferLineCZL(TransferLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnCheckTransLine', '', false, false)]
    local procedure CheckMandatoryFieldsOnCheckTransLineOnPostShipment(TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        if TransferHeader.IsIntrastatTransactionCZL() then
            TransferLine.CheckIntrastatMandatoryFieldsCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLineOnPostShipment(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine.CopyFromTransferLineCZL(TransferLine);
    end;
}