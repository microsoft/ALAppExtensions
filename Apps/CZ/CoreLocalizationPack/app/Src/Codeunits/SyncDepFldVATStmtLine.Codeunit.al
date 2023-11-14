// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.EU3PartyTrade;

#pragma warning disable AL0432
codeunit 31124 "Sync.Dep.Fld-VATStmtLine CZL"
{
    Access = Internal;
    Permissions = tabledata "VAT Statement Line" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATStatementLine(var Rec: Record "VAT Statement Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATStatementLine(var Rec: Record "VAT Statement Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Statement Line")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Statement Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Statement Line");
        if not IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec.ConvertEU3PartyTradeToEnum()
        else
            Rec.ConvertEnumToEU3PartyTrade(Rec."EU 3 Party Trade");
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Statement Line");
    end;

    local procedure IsEU3PartyTradeFeatureEnabled(): Boolean
    var
        EU3PartyTradeFeatMgt: Codeunit "EU3 Party Trade Feat Mgt. CZL";
    begin
        exit(EU3PartyTradeFeatMgt.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnAfterValidateEvent', 'EU-3 Party Trade CZL', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTradeCZL(var Rec: Record "VAT Statement Line")
    begin
        if not IsEU3PartyTradeFeatureEnabled() then
            Rec."EU 3 Party Trade" := Rec.ConvertEU3PartyTradeToEnum();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnAfterValidateEvent', 'EU 3 Party Trade', false, false)]
    local procedure SyncOnAfterValidateEU3PartyTrade(var Rec: Record "VAT Statement Line")
    begin
        if IsEU3PartyTradeFeatureEnabled() then
            Rec.ConvertEnumToEU3PartyTrade(Rec."EU 3 Party Trade");
    end;
}
#endif