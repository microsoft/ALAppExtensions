// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3916 "Reten. Pol. Delete. Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;

    var
        TooManyRecordsToDeleteLbl: Label 'Reached the maximum number of records that can be deleted at the same time. The maximum number allowed is %1.', Comment = '%1 = integer';
        LimitNumberOfRecordsLbl: Label 'Limited the number of records to delete for table %1, %2 to %3 records. The maximum number of records that can be deleted at the same time is %4, and %5 records were previously deleted in one or more tables.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table, %3, %4, %5 = integer';
        MissingReadPermissionLbl: Label 'Unable to check number of records to delete due to missing read permission for table %1, %2', Comment = '%1 = table number, %2 = table caption';

    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if not RecordRef.ReadPermission then
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(MissingReadPermissionLbl, RecordRef.Number, RecordRef.Caption))
        else
            if not RecordRef.IsEmpty then
                if (RecordRef.Count() > (RetenPolDeletingParam."Max. Number of Rec. To Delete" + NumberOfRecordsToDeleteBuffer())) then begin
                    RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(TooManyRecordsToDeleteLbl, RetenPolDeletingParam."Total Max. Nr. of Rec. to Del."));
                    LimitRecordsToBeDeleted(RecordRef, RetenPolDeletingParam."Skip Event Rec. Limit Exceeded", RetenPolDeletingParam."Max. Number of Rec. To Delete", RetenPolDeletingParam."Total Max. Nr. of Rec. to Del.");
                end;
        // if indirect permissions, raise event
        // if direct permission or no permission, delete
        //  -> if no permission, delete and let error bubble up
        if not RetenPolDeletingParam."Indirect Permission Required" then
            RecordRef.DeleteAll(true);
        RetenPolDeletingParam."Skip Event Indirect Perm. Req." := not RetenPolDeletingParam."Indirect Permission Required";
        RecordRef.Close();
    end;

    local procedure LimitRecordsToBeDeleted(var RecordRef: RecordRef; var SkipOnApplyRetentionPolicyRecordLimitExceeded: Boolean; MaxNumberOfRecordsToDelete: Integer; TotalMaxNumberOfRecordsToDelete: Integer)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(LimitNumberOfRecordsLbl, RecordRef.Number, RecordRef.Caption, MaxNumberOfRecordsToDelete, TotalMaxNumberOfRecordsToDelete, TotalMaxNumberOfRecordsToDelete - MaxNumberOfRecordsToDelete));

        if RecordRef.MarkedOnly() then
            UnmarkRecordsToLimit(RecordRef, MaxNumberOfRecordsToDelete)
        else
            MarkRecordsToLimit(RecordRef, MaxNumberOfRecordsToDelete);

        SkipOnApplyRetentionPolicyRecordLimitExceeded := false;
    end;

    local procedure UnmarkRecordsToLimit(var RecordRef: RecordRef; StartRecordIndex: Integer)
    begin
        RecordRef.FindSet();
        RecordRef.Next(StartRecordIndex);
        RecordRef.MarkedOnly(false);
        repeat
            RecordRef.Mark(false);
        until RecordRef.Next() = 0;
        RecordRef.MarkedOnly(true);
    end;

    local procedure MarkRecordsToLimit(var RecordRef: RecordRef; RecordCount: Integer)
    var
        i: integer;
    begin
        RecordRef.FindSet();
        repeat
            RecordRef.Mark(true);
            i += 1;
            if RecordRef.Next() = 0 then
                i := RecordCount;
        until i >= RecordCount;
        RecordRef.MarkedOnly(true);
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