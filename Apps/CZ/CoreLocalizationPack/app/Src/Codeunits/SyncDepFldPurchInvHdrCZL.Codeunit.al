// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Utilities;

using Microsoft.Finance.EU3PartyTrade;
using Microsoft.Purchases.History;

#pragma warning disable AL0432
codeunit 31467 "Sync.Dep.Fld-PurchInvHdr CZL"
{
    Access = Internal;
    Permissions = tabledata "Purch. Inv. Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchInvHeader(var Rec: Record "Purch. Inv. Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchInvHeader(var Rec: Record "Purch. Inv. Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purch. Inv. Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Purch. Inv. Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Purch. Inv. Header");
        if not IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec."EU 3-Party Trade CZL"
        else
            Rec."EU 3-Party Trade CZL" := Rec."EU 3 Party Trade";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Purch. Inv. Header");
    end;

    local procedure IsEU3PartyTradeFeatureEnabled(): Boolean
    var
        EU3PartyTradeFeatMgt: Codeunit "EU3 Party Trade Feat Mgt. CZL";
    begin
        exit(EU3PartyTradeFeatMgt.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterValidateEvent', 'EU 3-Party Trade CZL', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTradeCZL(var Rec: Record "Purch. Inv. Header")
    begin
        if not IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec."EU 3-Party Trade CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterValidateEvent', 'EU 3 Party Trade', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTrade(var Rec: Record "Purch. Inv. Header")
    begin
        if IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3-Party Trade CZL" := Rec."EU 3 Party Trade";
    end;
}
#endif
