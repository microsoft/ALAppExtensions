#if not CLEAN23
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Foundation.Company;

using Microsoft.Utilities;

codeunit 11290 "Sync Company Information"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Company Information" = rm;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyCompanyInformation(var Rec: Record "Company Information")
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        if Rec.IsTemporary() then
            exit;

        if SyncDepFldUtilities.IsFieldSynchronizationDisabled() then
            exit;

        SyncPlusGiroOnCompanyInformationTable(Rec);
        SyncRegisteredOfficeOnCompanyInformationTable(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertCompanyInformation(var Rec: Record "Company Information")
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        if Rec.IsTemporary() then
            exit;

        if SyncDepFldUtilities.IsFieldSynchronizationDisabled() then
            exit;

        SyncPlusGiroOnCompanyInformationTable(Rec);
        SyncRegisteredOfficeOnCompanyInformationTable(Rec);
    end;

    local procedure SyncPlusGiroOnCompanyInformationTable(var CompanyInformation: Record "Company Information")
    var
        xCompanyInformation: Record "Company Information";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(CompanyInformation, PreviousRecordRef) then begin
            PreviousRecordRef.SetTable(xCompanyInformation);
            SyncFields(CompanyInformation."Plus Giro No.", CompanyInformation."Plus Giro Number", xCompanyInformation."Plus Giro No.", xCompanyInformation."Plus Giro Number");
        end else
            SyncFields(CompanyInformation."Plus Giro No.", CompanyInformation."Plus Giro Number");
    end;

    local procedure SyncRegisteredOfficeOnCompanyInformationTable(var CompanyInformation: Record "Company Information")
    var
        xCompanyInformation: Record "Company Information";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(CompanyInformation, PreviousRecordRef) then begin
            PreviousRecordRef.SetTable(xCompanyInformation);
            SyncFields(CompanyInformation."Registered Office", CompanyInformation."Registered Office Info", xCompanyInformation."Registered Office", xCompanyInformation."Registered Office Info");
        end else
            SyncFields(CompanyInformation."Registered Office", CompanyInformation."Registered Office Info");
    end;

    procedure SyncFields(var ObsoleteFieldValue: Text[20]; var ValidFieldValue: Text[20]; PrevObsoleteFieldValue: Text[20]; PrevValidFieldValue: Text[20])
    begin
        if ObsoleteFieldValue = ValidFieldValue then
            exit;

        if (ObsoleteFieldValue = PrevObsoleteFieldValue) and (ValidFieldValue = PrevValidFieldValue) then
            exit;

        if ValidFieldValue <> PrevValidFieldValue then
            ObsoleteFieldValue := ValidFieldValue
        else
            if ObsoleteFieldValue <> PrevObsoleteFieldValue then
                ValidFieldValue := ObsoleteFieldValue
            else
                ObsoleteFieldValue := ValidFieldValue;
    end;

    procedure SyncFields(var ObsoleteFieldValue: Text[20]; var ValidFieldValue: Text[20])
    begin
        if ObsoleteFieldValue = ValidFieldValue then
            exit;

        if ValidFieldValue <> '' then
            ObsoleteFieldValue := ValidFieldValue;
        if ObsoleteFieldValue <> '' then
            ValidFieldValue := ObsoleteFieldValue;
    end;
}
#endif
