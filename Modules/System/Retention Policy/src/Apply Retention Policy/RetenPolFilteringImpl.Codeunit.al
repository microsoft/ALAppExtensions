// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3915 "Reten. Pol. Filtering Impl." implements "Reten. Pol. Filtering"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Retention Policy Log Entry" = r; // read through RecRef

    var
        RetentionPolicySetupNotFoundLbl: Label 'The retention policy setup for table %1 was not found.', Comment = '%1 = a id of a table (integer)';
        FutureExpirationDateWarningLbl: Label 'The expiration date %1 for table %2, %3, must be at least two days before the current date.', Comment = '%1 = a date, %2 = a id of a table (integer),%3 = the caption of the table.';
        AllRecordsFilterInfoLbl: Label 'Applying filters: Table ID: %1, All Records, Expiration Date: %2.', Comment = '%1 = a id of a table (integer), %2 = a date';
        NoRecordsToDeleteLbl: Label 'There are no records to delete for table ID %1, %2.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';
        OldestRecordYoungerThanExpirationLbl: Label 'The oldest record in table ID %1, %2 is younger than the earliest expiration date. There are no records to delete.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';
        MinExpirationDateErr: Label 'The expiration date for table %1, %2 must be at least %3 days before the current date. Please update the retention policy.', Comment = '%1 = table number, %2 = table caption, %3 = integer';
        RecordReferenceIndirectPermission: Interface "Record Reference";

    procedure HasReadPermission(TableId: Integer): Boolean
    var
        RecordReference: Codeunit "Record Reference";
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableId);
        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);
        exit(RecordReferenceIndirectPermission.ReadPermission(RecordRef))
    end;

    procedure Count(RecordRef: RecordRef): Integer
    begin
        exit(RecordReferenceIndirectPermission.Count(RecordRef))
    end;

    procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordReference: Codeunit "Record Reference";
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
        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(RetentionPolicySetup."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value");
        if not RecordReferenceIndirectPermission.IsEmpty(RecordRef) then
            exit(true);
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(NoRecordsToDeleteLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
        exit(false);
    end;

    procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        ApplyRetentionPolicyImpl: Codeunit "Apply Retention Policy Impl.";
        RecordReference: Codeunit "Record Reference";
        TotalRecords: Integer;
        YoungestExpirationDate, OldestRecordDate, CurrDate : Date;
        NumberOfDays, i : Integer;
    begin
        RecordRef.Open(RetentionPolicySetup."Table ID");
        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);

        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table Id");
        RetentionPolicySetupLine.SetRange(Enabled, true);
        if RetentionPolicySetupLine.IsEmpty then
            exit(false);

        YoungestExpirationDate := GetYoungestExpirationDate(RetentionPolicySetup);
        if YoungestExpirationDate >= Yesterday() then
            YoungestExpirationDate := Yesterday();
        OldestRecordDate := GetOldestRecordDate(RetentionPolicySetup);
        NumberOfDays := YoungestExpirationDate - OldestRecordDate;

        if NumberOfDays <= 0 then begin
            RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(OldestRecordYoungerThanExpirationLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
            exit(false);
        end;

        CurrDate := OldestRecordDate;
        for i := 1 to NumberOfDays do begin
            CurrDate := CalcDate('<+1D>', CurrDate);
            RecordRef.MarkedOnly(false);

            // Pass 1: Mark Records to delete
            MarkRecordRefWithRecordsToDelete(RetentionPolicySetup, RecordRef, RetenPolFilteringParam, CurrDate);
            // Pass 2: UnMark Records to keep
            UnMarkRecordRefWithRecordsToKeep(RetentionPolicySetup, RecordRef, RetenPolFilteringParam, CurrDate);

            // if max records exceeded, exit loop
            RecordRef.MarkedOnly(true);
            TotalRecords := Count(RecordRef);
            if TotalRecords >= ApplyRetentionPolicyImpl.MaxNumberOfRecordsToDelete() then begin
                RetenPolFilteringParam."Expired Record Expiration Date" := CurrDate;
                exit(true);
            end;
        end;
        RetenPolFilteringParam."Expired Record Expiration Date" := CurrDate;

        if not RecordReferenceIndirectPermission.IsEmpty(RecordRef) then
            exit(true);

        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(NoRecordsToDeleteLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Caption"));
        exit(false);
    end;

    local procedure GetYoungestExpirationDate(RetentionPolicySetup: Record "Retention Policy Setup") YoungestExpirationDate: Date
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
        ExpirationDate: Date;
    begin
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table Id");
        RetentionPolicySetupLine.SetRange(Enabled, true);
        if RetentionPolicySetupLine.FindSet(false) then
            repeat
                if RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period") then
                    ExpirationDate := CalculateExpirationDate(RetentionPeriod);
                if ExpirationDate >= YoungestExpirationDate then
                    YoungestExpirationDate := ExpirationDate;
            until RetentionPolicySetupLine.Next() = 0;
    end;

    local procedure GetOldestRecordDate(RetentionPolicySetup: Record "Retention Policy Setup"): Date
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        CurrDate, OldestDate : Date;
        ViewStringTxt: Label 'sorting (field%1) where(field%1=1(<>''''))', Locked = true;
        PrevDateFieldNo: Integer;
    begin
        RecordRef.Open(RetentionPolicySetup."Table Id");
        RetentionPolicySetupLine.SetCurrentKey("Date Field No.");
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table ID");
        RetentionPolicySetupLine.SetRange(Enabled, true);
        if RetentionPolicySetupLine.FindSet(false) then
            repeat
                if RetentionPolicySetupLine."Date Field No." <> PrevDateFieldNo then begin
                    RecordRef.SetView(StrSubstNo(ViewStringTxt, RetentionPolicySetupLine."Date Field No."));
                    RecordReferenceIndirectPermission.FindFirst(RecordRef);

                    FieldRef := RecordRef.Field(RetentionPolicySetupLine."Date Field No.");

                    if FieldRef.Type = FieldType::DateTime then
                        CurrDate := DT2Date(FieldRef.Value())
                    else
                        CurrDate := FieldRef.Value();

#pragma warning disable AA0205
                    if OldestDate = 0D then
#pragma warning restore AA0205
                        OldestDate := CurrDate;
                    if CurrDate < OldestDate then
                        OldestDate := CurrDate;
                end;
                PrevDateFieldNo := RetentionPolicySetupLine."Date Field No.";
            until RetentionPolicySetupLine.Next() = 0;
        exit(OldestDate);
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

    local procedure MarkRecordRefWithRecordsToDelete(RetentionPolicySetup: Record "Retention Policy Setup"; var RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary; CurrDate: Date)
    begin
        SetMarksOnRecordRef(RetentionPolicySetup, RecordRef, true, RetenPolFilteringParam, CurrDate);
    end;

    local procedure UnMarkRecordRefWithRecordsToKeep(RetentionPolicySetup: Record "Retention Policy Setup"; RecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary; CurrDate: Date)
    begin
        SetMarksOnRecordRef(RetentionPolicySetup, RecordRef, false, RetenPolFilteringParam, CurrDate);
    end;

    local procedure SetMarksOnRecordRef(RetentionPolicySetup: Record "Retention Policy Setup"; RecordRef: RecordRef; MarkValue: Boolean; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary; CurrDate: Date);
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        ExpirationDate: Date;
    begin
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table ID");
        RetentionPolicySetupLine.SetRange(Enabled, true);
        if RetentionPolicySetupLine.FindSet(false) then
            repeat
                if not RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period") then
                    exit;
                ExpirationDate := CalculateExpirationDate(RetentionPeriod);
                RetentionPolicySetupLine.CalcFields("Table Caption");
                ValidateExpirationDate(ExpirationDate, RetentionPolicySetupLine."Table ID", RetentionPolicySetupLine."Table Caption");

                // set filter for Table Filter in filtergroup 10
                SetRetentionPolicyLineTableFilter(RetentionPolicySetupLine, RecordRef, 10);

                if MarkValue then begin
                    if (ExpirationDate < Yesterday()) and (CurrDate <= ExpirationDate) then
                        ExpirationDate := CurrDate;
                    // set filter for date in filtergroup 11
                    ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(RetentionPolicySetupLine."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value");
                    SetMarks(RecordRef, true);
                end else
                    if (ExpirationDate <= CurrDate) or (ExpirationDate >= yesterday()) then begin
                        // if ExpirationDate is >= today - 1, don't set filter and remove all records from temp
                        if ExpirationDate < Yesterday() then
                            // set filter for date in filtergroup 11
                            ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(RetentionPolicySetupLine."Date Field No.", ExpirationDate, RecordRef, 11, RetenPolFilteringParam."Null Date Replacement value");
                        SetMarks(RecordRef, false);
                    end;

                ClearFilterGroupOnRecRef(RecordRef, 10);
                ClearFilterGroupOnRecRef(RecordRef, 11);
            until RetentionPolicySetupLine.Next() = 0;
    end;

    local procedure SetMarks(var RecordRef: RecordRef; MarkValue: Boolean)
    begin
        if RecordReferenceIndirectPermission.FindSet(RecordRef, true) then
            repeat
                RecordRef.Mark := MarkValue;
            until RecordReferenceIndirectPermission.Next(RecordRef) = 0;
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
        exit(CalcDate('<-1D>', Today()))
    end;
}