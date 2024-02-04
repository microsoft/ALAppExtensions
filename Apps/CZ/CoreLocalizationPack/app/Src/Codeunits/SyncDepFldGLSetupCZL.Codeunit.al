// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
#pragma warning disable AL0432
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Utilities;

codeunit 31162 "Sync.Dep.Fld-GLSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "General Ledger Setup" = rimd,
                  tabledata "VAT Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertGeneralLedgerSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyGeneralLedgerSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "General Ledger Setup")
    var
        VATSetup: Record "VAT Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"General Ledger Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Setup");
        VATSetup.ChangeCompany(Rec.CurrentCompany);
        if not VATSetup.Get() then begin
            VATSetup.Init();
            VATSetup.Insert(false);
        end;
        VATSetup."Allow VAT Date From" := Rec."Allow VAT Posting From CZL";
        VATSetup."Allow VAT Date To" := Rec."Allow VAT Posting To CZL";
        VATSetup.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Setup");
    end;
}
#endif