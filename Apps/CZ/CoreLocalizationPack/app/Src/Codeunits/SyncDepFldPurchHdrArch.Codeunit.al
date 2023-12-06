// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Purchases.Archive;

#pragma warning disable AL0432
codeunit 31465 "Sync.Dep.Fld-PurchHdrArch CZL"
{
    Access = Internal;
    Permissions = tabledata "Purchase Header Archive" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header Archive", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchaseHeaderArchive(var Rec: Record "Purchase Header Archive")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header Archive", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchaseHeaderArchive(var Rec: Record "Purchase Header Archive")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchase Header Archive")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Purchase Header Archive") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Purchase Header Archive");
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL"
        else
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Purchase Header Archive");
    end;

    local procedure IsReplaceVATDateEnabled(): Boolean
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        exit(ReplaceVATDateMgtCZL.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header Archive", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "Purchase Header Archive")
    begin
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header Archive", 'OnAfterValidateEvent', 'VAT Reporting Date', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "Purchase Header Archive")
    begin
        if IsReplaceVATDateEnabled() then
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
    end;
}
#endif
