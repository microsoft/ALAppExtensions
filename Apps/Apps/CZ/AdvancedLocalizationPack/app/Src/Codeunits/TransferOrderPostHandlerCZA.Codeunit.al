// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Inventory.Journal;

codeunit 31229 "TransferOrder-Post Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', false, false)]
    local procedure ReceiveSetGenBusPostingGroupsOnAfterCopyFromTransferHeader(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header")
    begin
        TransferShipmentHeader."Gen.Bus.Post.Group Ship CZA" := TransferHeader."Gen.Bus.Post.Group Ship CZA";
        TransferShipmentHeader."Gen.Bus.Post.Group Receive CZA" := TransferHeader."Gen.Bus.Post.Group Receive CZA";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure ShipSetGenBusPostingGroupsOnAfterCopyFromTransferLine(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line")
    begin
        TransferShipmentLine."Gen.Bus.Post.Group Ship CZA" := TransferLine."Gen.Bus.Post.Group Ship CZA";
        TransferShipmentLine."Gen.Bus.Post.Group Receive CZA" := TransferLine."Gen.Bus.Post.Group Receive CZA";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Header", 'OnAfterCopyFromTransferHeader', '', false, false)]
    local procedure ShipSetGenBusPostingGroupsOnAfterCopyFromTransferHeader(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header")
    begin
        TransferReceiptHeader."Gen.Bus.Post.Group Ship CZA" := TransferHeader."Gen.Bus.Post.Group Ship CZA";
        TransferReceiptHeader."Gen.Bus.Post.Group Receive CZA" := TransferHeader."Gen.Bus.Post.Group Receive CZA";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure ReceiveShipSetGenBusPostingGroupsOnAfterCopyFromTransferLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."Gen.Bus.Post.Group Ship CZA" := TransferLine."Gen.Bus.Post.Group Ship CZA";
        TransferReceiptLine."Gen.Bus.Post.Group Receive CZA" := TransferLine."Gen.Bus.Post.Group Receive CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure ShipSetGenBusPostingGroupOnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLine: Record "Transfer Shipment Line"; CommitIsSuppressed: Boolean)
    begin
        ItemJournalLine.Validate("Gen. Bus. Posting Group", TransferShipmentLine."Gen.Bus.Post.Group Ship CZA");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure ValidateGenBusPostingGroupOnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLine: Record "Transfer Receipt Line"; CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line")
    begin
        ItemJournalLine.Validate("Gen. Bus. Posting Group", TransferReceiptLine."Gen.Bus.Post.Group Receive CZA");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert', '', false, false)]
    local procedure CopyFieldsOnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert(TransferHeader: Record "Transfer Header"; var DirectTransHeader: Record "Direct Trans. Header")
    begin
        TransferHeader.CheckGenBusPostGroupEqualityCZA();
        DirectTransHeader."Gen. Bus. Posting Group CZA" := TransferHeader."Gen.Bus.Post.Group Ship CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; DirectTransLine: Record "Direct Trans. Line")
    begin
        ItemJnlLine."Gen. Bus. Posting Group" := DirectTransLine."Gen. Bus. Posting Group CZA";
    end;
}
