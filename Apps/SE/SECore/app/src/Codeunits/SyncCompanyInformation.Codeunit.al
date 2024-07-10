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
        CurrentRecordRef: RecordRef;
        CurrentPlusGiroNo: Text[20];
        PreviousPlusGiroNo: Text[20];
    begin
        CurrentRecordRef.Open(Database::"Company Information", false);
        if not CurrentRecordRef.FieldExist(11200) then // field - 11200 "Plus Giro No." 
            exit;
        CurrentPlusGiroNo := CurrentRecordRef.Field(11200).Value;

        if SyncDepFldUtilities.GetPreviousRecord(CompanyInformation, PreviousRecordRef) then begin
            PreviousRecordRef.SetTable(xCompanyInformation);
            PreviousPlusGiroNo := PreviousRecordRef.Field(11200).Value;
            SyncFields(CurrentPlusGiroNo, CompanyInformation."Plus Giro Number", PreviousPlusGiroNo, xCompanyInformation."Plus Giro Number");
        end else
            SyncFields(CurrentPlusGiroNo, CompanyInformation."Plus Giro Number");
    end;

    local procedure SyncRegisteredOfficeOnCompanyInformationTable(var CompanyInformation: Record "Company Information")
    var
        xCompanyInformation: Record "Company Information";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        CurrentRecordRef: RecordRef;
        CurrentRegisteredOffice: Text[20];
        PreviousRegisteredOffice: Text[20];
    begin
        CurrentRecordRef.Open(Database::"Company Information", false);
        if not CurrentRecordRef.FieldExist(11201) then //field 11201 - "Registered Office"
            exit;
        CurrentRegisteredOffice := CurrentRecordRef.Field(11201).Value;

        if SyncDepFldUtilities.GetPreviousRecord(CompanyInformation, PreviousRecordRef) then begin
            PreviousRecordRef.SetTable(xCompanyInformation);
            PreviousRegisteredOffice := PreviousRecordRef.Field(11201).Value; // field 11201 - "Registered Office"
            SyncFields(CurrentRegisteredOffice, CompanyInformation."Registered Office Info", PreviousRegisteredOffice, xCompanyInformation."Registered Office Info");
        end else
            SyncFields(CurrentRegisteredOffice, CompanyInformation."Registered Office Info");
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
