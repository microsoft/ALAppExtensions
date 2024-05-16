// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Utilities;

using Microsoft.Purchases.Document;

#pragma warning disable AL0432
codeunit 31159 "Sync.Dep.Fld-PurchHeader CZL"
{
    Access = Internal;
    Permissions = tabledata "Purchase Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchase Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Purchase Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Purchase Header");
        if not Rec.IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec."EU 3-Party Trade CZL"
        else
            Rec."EU 3-Party Trade CZL" := Rec."EU 3 Party Trade";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Purchase Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'EU 3-Party Trade CZL', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTradeCZL(var Rec: Record "Purchase Header")
    begin
        if not Rec.IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec."EU 3-Party Trade CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'EU 3 Party Trade', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTrade(var Rec: Record "Purchase Header")
    begin
        if Rec.IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3-Party Trade CZL" := Rec."EU 3 Party Trade";
    end;
}
#endif
