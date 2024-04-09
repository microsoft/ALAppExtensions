// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Transfer;

#pragma warning disable AL0432
codeunit 31048 "TransferOrder-Post Handler CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnCheckTransLine', '', false, false)]
    local procedure CheckMandatoryFieldsOnCheckTransLineOnPostShipment(TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        if TransferHeader.IsIntrastatTransactionCZL() then
            TransferLine.CheckIntrastatMandatoryFieldsCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure CopyFieldsOnBeforePostItemJournalLineOnPostReceipt(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine.CopyFromTransferLineCZL(TransferLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLineOnPostShipment(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine.CopyFromTransferLineCZL(TransferLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert', '', false, false)]
    local procedure CopyFieldsOnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert(TransferHeader: Record "Transfer Header"; var DirectTransHeader: Record "Direct Trans. Header")
    begin
        DirectTransHeader."Intrastat Exclude CZL" := TransferHeader."Intrastat Exclude CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; DirectTransHeader: Record "Direct Trans. Header"; DirectTransLine: Record "Direct Trans. Line")
    begin
        ItemJnlLine."Tariff No. CZL" := DirectTransLine."Tariff No. CZL";
        ItemJnlLine."Net Weight CZL" := DirectTransLine."Net Weight";
        // recalc to base UOM
        if ItemJnlLine."Net Weight CZL" <> 0 then
            if DirectTransLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Net Weight CZL" := Round(ItemJnlLine."Net Weight CZL" / DirectTransLine."Qty. per Unit of Measure", 0.00001);
        ItemJnlLine."Country/Reg. of Orig. Code CZL" := DirectTransLine."Country/Reg. of Orig. Code CZL";
        ItemJnlLine."Statistic Indication CZL" := DirectTransLine."Statistic Indication CZL";
        ItemJnlLine."Intrastat Transaction CZL" := DirectTransHeader.IsIntrastatTransactionCZL();
    end;
}
#pragma warning restore AL0432
#endif
