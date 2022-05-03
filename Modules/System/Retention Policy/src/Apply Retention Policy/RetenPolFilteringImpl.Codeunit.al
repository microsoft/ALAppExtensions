// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3915 "Reten. Pol. Filtering Impl." implements "Reten. Pol. Filtering"
{
    Access = Internal;
    Permissions = tabledata "Retention Policy Log Entry" = r; // read through RecRef

    var
        RetentionPolicySetupNotFoundLbl: Label 'The retention policy setup for table %1 was not found.', Comment = '%1 = a id of a table (integer)';
        FutureExpirationDateWarningLbl: Label 'The expiration date %1 for table %2, %3, must be at least two days before the current date.', Comment = '%1 = a date, %2 = a id of a table (integer),%3 = the caption of the table.';
        AllRecordsFilterInfoLbl: Label 'Applying filters: Table ID: %1, All Records, Expiration Date: %2.', Comment = '%1 = a id of a table (integer), %2 = a date';
        MissingReadPermissionLbl: Label 'The user does not have Read permission for table %1, %2.', Comment = '%1 = table number, %2 = table caption';
        NoRecordsToDeleteLbl: Label 'There are no records to delete for table ID %1, %2.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';
        MinExpirationDateErr: Label 'The expiration date for table %1, %2 must be at least %3 days before the current date. Please update the retention policy.', Comment = '%1 = table number, %2 = table caption, %3 = integer';

    procedure HasReadPermission(TableId: Integer): Boolean
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableId);
        exit(RecordRef.ReadPermission())
    end;

    procedure Count(RecordRef: RecordRef): Integer
    begin
        exit(RecordRef.Count())
    end;

    procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        ExpirationDate: Date;
    begin
        if not RetentionPeriod.Get(RetentionPolicySetup."Retention Period") then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstno(RetentionPolicySetupNotFoundLbl, RetentionPolicySetup."Table Id"));
            exit(false);
        end;

        ExpirationDate := CalculateExpirationDate(RetentionPeriod);
        if ExpirationDate >= Yesterday() then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstno(FutureExpirationDateWarningLbl, Format(ExpirationDate, 0, 9), RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
            exit(false);
        end;
        ValidateExpirationDate(ExpirationDate, RetentionPolicySetup."Table ID", RetentionPolicySetup."Table Caption");
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(AllRecordsFilterInfoLbl, RetentionPolicySetup."Table Id", Format(ExpirationDate, 0, 9)));

        RecordRef.Open(RetentionPolicySetup."Table ID");
        if not RecordRef.ReadPermission() then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(MissingReadPermissionLbl, RecordRef.Number, RecordRef.Caption));
            exit(false);
        end;
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(RetentionPolicySetup."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value");
        if not RecordRef.IsEmpty then
            exit(true);

        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(NoRecordsToDeleteLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
        exit(false);
    end;

    procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        RecordRef.Open(RetentionPolicySetup."Table ID");
        if not RecordRef.ReadPermission() then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(MissingReadPermissionLbl, RecordRef.Number, RecordRef.Caption));
            exit(false);
        end;

        // Pass 1: Mark Records to delete
        MarkRecordRefWithRecordsToDelete(RetentionPolicySetup, RecordRef, RetenPolFilteringParam);
        // Pass 2: UnMark Records to keep
        UnMarkRecordRefWithRecordsToKeep(RetentionPolicySetup, RecordRef, RetenPolFilteringParam);
        // Delete remaining Marked records
        RecordRef.MarkedOnly(true);

        if not RecordRef.IsEmpty then
            exit(true);

        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(NoRecordsToDeleteLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
        exit(false);
    end;

    local procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"): Date
    var
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        RetentionPeriodInterface := RetentionPeriod."Retention Period";
        exit(RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, Today()));
    end;

    local procedure ValidateExpirationDate(ExpirationDate: Date; TableId: Integer; TableCaption: Text)
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        MinExpirationDate: Date;
    begin
        if ExpirationDate > Today() then // a future expiration date means keep forever
            exit;
        MinExpirationDate := RetenPolAllowedTables.CalcMinimumExpirationDate(TableId);
        if ExpirationDate > MinExpirationDate then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(MinExpirationDateErr, TableId, TableCaption, RetenPolAllowedTables.GetMandatoryMinimumRetentionDays(TableId)));
    end;

    local procedure MarkRecordRefWithRecordsToDelete(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary)
    begin
        SetMarksOnRecordRef(RetentionPolicySetup, RecordRef, true, RetenPolFilteringParam);
    end;

    local procedure UnMarkRecordRefWithRecordsToKeep(RetentionPolicySetup: Record "Retention Policy Setup"; RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary)
    begin
        SetMarksOnRecordRef(RetentionPolicySetup, RecordRef, false, RetenPolFilteringParam);
    end;

    local procedure SetMarksOnRecordRef(RetentionPolicySetup: Record "Retention Policy Setup"; RecordRef: RecordRef; MarkValue: boolean; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary);
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        ExpirationDate: Date;
    begin
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table ID");
        RetentionPolicySetupLine.SetRange(Enabled, true);
        if RetentionPolicySetupLine.FindSet(false, false) then
            repeat
                if RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period") then begin
                    ExpirationDate := CalculateExpirationDate(RetentionPeriod);
                    if MarkValue then begin
                        RetentionPolicySetupLine.CalcFields("Table Caption");
                        ValidateExpirationDate(ExpirationDate, RetentionPolicySetupLine."Table ID", RetentionPolicySetupLine."Table Caption");
                    end;
                    // set filter for Table Filter in filtergroup 10
                    SetRetentionPolicyLineTableFilter(RetentionPolicySetupLine, RecordRef, 10);
                    // set filter for date in filtergroup 11
                    if MarkValue then
                        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(RetentionPolicySetupLine."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value")
                    else begin
                        // if ExpirationDate is >= today - 1, don't set filter and remove all records from temp
                        if ExpirationDate < Yesterday() then
                            ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(RetentionPolicySetupLine."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value");
                        // only go through marked records to unmark
                        RecordRef.MarkedOnly(true);
                    end;

                    if RecordRef.FindSet(false, false) then
                        repeat
                            RecordRef.Mark := MarkValue;
                        until RecordRef.Next() = 0;
                end;
                RecordRef.MarkedOnly(false);
                ClearFilterGroupOnRecRef(RecordRef, 10);
                ClearFilterGroupOnRecRef(RecordRef, 11);
            until RetentionPolicySetupLine.Next() = 0;
    end;

    local procedure SetRetentionPolicyLineTableFilter(var RetentionPolicySetupLine: Record "Retention Policy Setup Line"; var RecordRef: RecordRef; FilterGroup: Integer);
    begin
        RecordRef.FilterGroup := FilterGroup;
        RecordRef.SetView(RetentionPolicySetupLine.GetTableFilterView());
    end;

    local procedure ClearFilterGroupOnRecRef(var RecordRef: RecordRef; FilterGroup: Integer)
    begin
        RecordRef.FilterGroup := FilterGroup;
        RecordRef.SetView('');
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Apply");
    end;

    local procedure Yesterday(): Date
    begin
        Exit(CalcDate('<-1D>', Today()))
    end;
}