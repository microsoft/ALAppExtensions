// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Ledger;

#pragma warning disable AL0432
codeunit 31175 "Sync.Dep.Fld-VATEntry CZL"
{
    Access = Internal;
    Permissions = tabledata "VAT Entry" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATEntry(var Rec: Record "VAT Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATEntry(var Rec: Record "VAT Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Entry")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Entry") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Entry");
        if not Rec.IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL"
        else
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Entry");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "VAT Entry")
    begin
        if not Rec.IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterValidateEvent', 'VAT Reporting Date', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "VAT Entry")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
    end;
}
#endif
