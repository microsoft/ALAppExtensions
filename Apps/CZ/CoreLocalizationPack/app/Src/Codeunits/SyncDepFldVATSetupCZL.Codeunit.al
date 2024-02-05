// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
#pragma warning disable AL0432
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Utilities;

codeunit 31166 "Sync.Dep.Fld-VATSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "General Ledger Setup" = rimd,
                  tabledata "VAT Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATSetup(var Rec: Record "VAT Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATSetup(var Rec: Record "VAT Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"General Ledger Setup");
        GeneralLedgerSetup.ChangeCompany(Rec.CurrentCompany);
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert(false);
        end;
        GeneralLedgerSetup."Allow VAT Posting From CZL" := Rec."Allow VAT Date From";
        GeneralLedgerSetup."Allow VAT Posting To CZL" := Rec."Allow VAT Date To";
        GeneralLedgerSetup.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"General Ledger Setup");
    end;
}
#endif