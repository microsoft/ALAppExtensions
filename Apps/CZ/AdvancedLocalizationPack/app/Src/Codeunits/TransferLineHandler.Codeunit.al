// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Inventory.Item;

codeunit 31228 "Transfer Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterGetTransHeader', '', false, false)]
    local procedure SetGenBusPostingGroupsOnAfterGetTransHeader(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        TransferLine."Gen.Bus.Post.Group Ship CZA" := TransferHeader."Gen.Bus.Post.Group Ship CZA";
        TransferLine."Gen.Bus.Post.Group Receive CZA" := TransferHeader."Gen.Bus.Post.Group Receive CZA";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure SetTransferOrderLineNoOnAfterCopyFromTransferLine(TransferLine: Record "Transfer Line"; var TransferShipmentLine: Record "Transfer Shipment Line")
    begin
        TransferShipmentLine."Transfer Order Line No. CZA" := TransferLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Entry Relation", 'OnAfterSetOrderInfo', '', false, false)]
    local procedure SetOrderLineNoOnAfterSetOrderInfo(ItemEntryRelation: Record "Item Entry Relation"; var OrderLineNo: Integer)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        if ItemEntryRelation."Source Type" <> Database::"Transfer Shipment Line" then
            exit;

        if TransferShipmentLine.Get(ItemEntryRelation."Source ID", ItemEntryRelation."Source Ref. No.") then
            if TransferShipmentLine."Transfer Order Line No. CZA" <> 0 then
                OrderLineNo := TransferShipmentLine."Transfer Order Line No. CZA";
    end;
}
