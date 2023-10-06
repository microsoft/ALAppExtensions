#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Utilities;

codeunit 4710 "Sync DepFld Enum Auth Type"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"VAT Report Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLEntry(var Rec: Record "VAT Report Setup")
    begin
        SyncDeprecateFieldForEnumAuthType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Report Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLEntry(var Rec: Record "VAT Report Setup")
    begin
        SyncDeprecateFieldForEnumAuthType(Rec);
    end;

#pragma warning disable AL0432
    local procedure SyncDeprecateFieldForEnumAuthType(var VATReportSetup: Record "VAT Report Setup")
    var
        xVATReportSetup: Record "VAT Report Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if not SyncDepFldUtilities.IsFieldSynchronizationDisabled() then
            if SyncDepFldUtilities.GetPreviousRecord(VATReportSetup, PreviousRecordRef) then begin // OnModify
                PreviousRecordRef.SetTable(xVATReportSetup);
                SyncFields(VATReportSetup."Authentication Type", VATReportSetup."VAT Group Authentication Type", xVATReportSetup."Authentication Type", xVATReportSetup."VAT Group Authentication Type");
            end else // OnInsert
                SyncFields(VATReportSetup."Authentication Type", VATReportSetup."VAT Group Authentication Type");
    end;

    // Very specific Data Type, not adding it to "Sync.Dep.Fld-Utilities"
    local procedure SyncFields(var ObsoleteFieldValue: Enum "VAT Group Authentication Type OnPrem"; var ValidFieldValue: Enum "VAT Group Auth Type OnPrem")
    begin
        if ObsoleteFieldValue.AsInteger() = ValidFieldValue.AsInteger() then
            exit;

        if ValidFieldValue.AsInteger() <> 0 then
            ObsoleteFieldValue := "VAT Group Authentication Type OnPrem".FromInteger(ValidFieldValue.AsInteger());
        if ObsoleteFieldValue.AsInteger() <> 0 then
            ValidFieldValue := "VAT Group Auth Type OnPrem".FromInteger(ObsoleteFieldValue.AsInteger());
    end;

    local procedure SyncFields(var ObsoleteFieldValue: Enum "VAT Group Authentication Type OnPrem"; var ValidFieldValue: Enum "VAT Group Auth Type OnPrem";
                               PrevObsoleteFieldValue: Enum "VAT Group Authentication Type OnPrem"; PrevValidFieldValue: Enum "VAT Group Auth Type OnPrem")
    begin
        if ObsoleteFieldValue.AsInteger() = ValidFieldValue.AsInteger() then
            exit;

        if (ObsoleteFieldValue.AsInteger() = PrevObsoleteFieldValue.AsInteger()) and (ValidFieldValue.AsInteger() = PrevValidFieldValue.AsInteger()) then
            exit;

        if ValidFieldValue.AsInteger() <> PrevValidFieldValue.AsInteger() then
            ObsoleteFieldValue := "VAT Group Authentication Type OnPrem".FromInteger(ValidFieldValue.AsInteger())
        else
            if ObsoleteFieldValue.AsInteger() <> PrevObsoleteFieldValue.AsInteger() then
                ValidFieldValue := "VAT Group Auth Type OnPrem".FromInteger(ObsoleteFieldValue.AsInteger())
            else
                ObsoleteFieldValue := "VAT Group Authentication Type OnPrem".FromInteger(ValidFieldValue.AsInteger());
    end;
#pragma warning restore
}
#endif