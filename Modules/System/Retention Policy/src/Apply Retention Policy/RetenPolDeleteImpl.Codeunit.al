// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3916 "Reten. Pol. Delete. Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TooManyRecordsToDeleteLbl: Label 'Reached the maximum number of records that can be deleted at the same time. The maximum number allowed is %1.', Comment = '%1 = integer';
        LimitNumberOfRecordsLbl: Label 'Limited the number of records to delete for table %1, %2 to %3 records. The maximum number of records that can be deleted at the same time is %4, and %5 records were previously deleted in one or more tables.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table, %3, %4, %5 = integer';
        MissingReadPermissionLbl: Label 'Unable to check number of records to delete due to missing read permission for table %1, %2', Comment = '%1 = table number, %2 = table caption';
        MaxNumberofRecToDeleteNegLbl: Label 'Max. Number of Rec. To Delete is less than 0.';

    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RecordReference: Codeunit "Record Reference";
        RecordReferenceIndirectPermission: Interface "Record Reference";
    begin
        if RetenPolDeletingParam."Max. Number of Rec. To Delete" < 0 then begin
            RetentionPolicyLog.LogWarning(LogCategory(), MaxNumberofRecToDeleteNegLbl);
            exit;
        end;

        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);

        if not RecordRef.ReadPermission then
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(MissingReadPermissionLbl, RecordRef.Number, RecordRef.Caption))
        else
            if not RecordReferenceIndirectPermission.IsEmpty(RecordRef) then
                if (RecordReferenceIndirectPermission.Count(RecordRef) > (RetenPolDeletingParam."Max. Number of Rec. To Delete" + NumberOfRecordsToDeleteBuffer())) then begin
                    RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(TooManyRecordsToDeleteLbl, RetenPolDeletingParam."Total Max. Nr. of Rec. to Del."));
                    LimitRecordsToBeDeleted(RecordRef, RecordReferenceIndirectPermission, RetenPolDeletingParam."Skip Event Rec. Limit Exceeded", RetenPolDeletingParam."Max. Number of Rec. To Delete", RetenPolDeletingParam."Total Max. Nr. of Rec. to Del.");
                end;
        if not RetenPolDeletingParam."Indirect Permission Required" then
            RecordReferenceIndirectPermission.DeleteAll(RecordRef, true);
        RetenPolDeletingParam."Skip Event Indirect Perm. Req." := not RetenPolDeletingParam."Indirect Permission Required";
        RecordRef.Close();
    end;

    local procedure LimitRecordsToBeDeleted(var RecordRef: RecordRef; RecordReferenceIndirectPermission: Interface "Record Reference"; var SkipOnApplyRetentionPolicyRecordLimitExceeded: Boolean; MaxNumberOfRecordsToDelete: Integer; TotalMaxNumberOfRecordsToDelete: Integer)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(LimitNumberOfRecordsLbl, RecordRef.Number, RecordRef.Caption, MaxNumberOfRecordsToDelete, TotalMaxNumberOfRecordsToDelete, TotalMaxNumberOfRecordsToDelete - MaxNumberOfRecordsToDelete));
        FilterRecordsToLimit(RecordRef, RecordReferenceIndirectPermission, MaxNumberOfRecordsToDelete);
        SkipOnApplyRetentionPolicyRecordLimitExceeded := false;
    end;

    local procedure FilterRecordsToLimit(var RecordRef: RecordRef; RecordReferenceIndirectPermission: Interface "Record Reference"; StartRecordIndex: Integer)
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: integer;
    begin
        RecordReferenceIndirectPermission.FindSet(RecordRef);
        RecordReferenceIndirectPermission.Next(RecordRef, StartRecordIndex);

        RecordRef.FilterGroup := 15;
        KeyRef := RecordRef.KeyIndex(RecordRef.CurrentKeyIndex());
        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);
            FieldRef.SetFilter('<%1', FieldRef.Value);
        end;
        RecordRef.FilterGroup := 0;
    end;

    local procedure NumberOfRecordsToDeleteBuffer(): Integer
    begin
        exit(999)
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Apply");
    end;
}