// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN24
#pragma warning disable AL0432
namespace Microsoft.Utilities;

using System.Security.User;

codeunit 31161 "Sync.Dep.Fld-UserSetup CZL"
{
    Access = Internal;
    Permissions = tabledata "User Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "User Setup")
    var
        PreviousRecord: Record "User Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting From CZL", Rec."Allow VAT Date From", PreviousRecord."Allow VAT Posting From CZL", PreviousRecord."Allow VAT Date From");
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting To CZL", Rec."Allow VAT Date To", PreviousRecord."Allow VAT Posting To CZL", PreviousRecord."Allow VAT Date To");
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'Allow VAT Posting From CZL', false, false)]
    local procedure SyncOnAfterValidateAllowVATPostingFromCZL(var Rec: Record "User Setup")
    begin
        Rec."Allow VAT Date From" := Rec."Allow VAT Posting From CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'Allow VAT Posting To CZL', false, false)]
    local procedure SyncOnAfterValidateAllowVATPostingToCZL(var Rec: Record "User Setup")
    begin
        Rec."Allow VAT Date To" := Rec."Allow VAT Posting To CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'Allow VAT Date From', false, false)]
    local procedure SyncOnAfterValidateAllowVATDateFrom(var Rec: Record "User Setup")
    begin
        Rec."Allow VAT Posting From CZL" := Rec."Allow VAT Date From";
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'Allow VAT Date To', false, false)]
    local procedure SyncOnAfterValidateAllowVATDateTo(var Rec: Record "User Setup")
    begin
        Rec."Allow VAT Posting To CZL" := Rec."Allow VAT Date To";
    end;
}
#pragma warning restore AL0432
#endif