// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Utilities;

using Microsoft.CRM.Contact;

#pragma warning disable AL0432
codeunit 31152 "Sync.Dep.Fld-Contact CZL"
{
    Access = Internal;
    Permissions = tabledata "Contact" = rimd;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertContact(var Rec: Record Contact)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyContact(var Rec: Record Contact)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Contact)
    var
        PreviousRecord: Record Contact;
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

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterValidateEvent', 'Registration No. CZL', false, false)]
    local procedure SyncOnAfterValidateRegistrationNoCZL(var Rec: Record Contact)
    begin
        Rec."Registration Number" := Rec."Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterValidateEvent', 'Registration Number', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record Contact)
    begin
        Rec."Registration No. CZL" := Rec.GetRegistrationNoTrimmedCZL();
    end;
}
#endif
