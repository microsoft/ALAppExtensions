// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Utilities;

using Microsoft.Purchases.Vendor;

#pragma warning disable AL0432
codeunit 31151 "Sync.Dep.Fld-Vendor CZL"
{
    Access = Internal;
    Permissions = tabledata "Vendor" = rimd;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVendor(var Rec: Record Vendor)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVendor(var Rec: Record Vendor)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Vendor)
    var
        PreviousRecord: Record Vendor;
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Registration No. CZL";
        NewFieldTxt := Rec."Registration Number";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Registration No. CZL", PreviousRecord."Registration Number");
        Rec."Registration No. CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Registration No. CZL"));
        Rec."Registration Number" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Registration Number"));
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Registration No. CZL', false, false)]
    local procedure SyncOnAfterValidateRegistrationNoCZL(var Rec: Record Vendor)
    begin
        Rec."Registration Number" := Rec."Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Registration Number', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record Vendor)
    begin
        Rec."Registration No. CZL" := Rec.GetRegistrationNoTrimmedCZL();
    end;
}
#endif
