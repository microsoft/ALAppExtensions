// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using System.Security.User;

codeunit 31313 "Item Jnl.CheckLine Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if CalledFromAdjustment then
            exit;
        if ItemJnlLine.Correction and
           (ItemJnlLine."Document Type" in [
            ItemJnlLine."Document Type"::"Purchase Receipt",
            ItemJnlLine."Document Type"::"Sales Shipment",
            ItemJnlLine."Document Type"::"Transfer Shipment"])
        then
            exit;
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckItemJournalLine(ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure CheckUnitOfMeasureCodeOnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    begin
        if (ItemJnlLine.Quantity <> 0) and
           (ItemJnlLine."Item Charge No." = '') and
           not (ItemJnlLine."Value Entry Type" in [ItemJnlLine."Value Entry Type"::Revaluation, ItemJnlLine."Value Entry Type"::Rounding]) and
           not ItemJnlLine.Adjustment
        then
            ItemJnlLine.TestField("Unit of Measure Code", ErrorInfo.Create());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnCheckDatesOnAfterCalcShouldShowError', '', false, false)]
    local procedure OnCheckDatesOnAfterCalcShouldShowError(var ShouldShowError: Boolean; CalledFromAdjustment: Boolean)
    begin
        ShouldShowError := ShouldShowError and (not CalledFromAdjustment);
    end;
}
