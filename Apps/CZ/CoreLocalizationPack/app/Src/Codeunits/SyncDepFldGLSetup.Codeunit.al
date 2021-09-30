#if not CLEAN19
#pragma warning disable AL0432
codeunit 31162 "Sync.Dep.Fld-GLSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '19.0';

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "General Ledger Setup")
    var
        PreviousRecord: Record "General Ledger Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Use VAT Date", Rec."Use VAT Date CZL", PreviousRecord."Use VAT Date", PreviousRecord."Use VAT Date CZL");
#if not CLEAN17
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting From", Rec."Allow VAT Posting From CZL", PreviousRecord."Allow VAT Posting From", PreviousRecord."Allow VAT Posting From CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting To", Rec."Allow VAT Posting To CZL", PreviousRecord."Allow VAT Posting To", PreviousRecord."Allow VAT Posting To CZL");
        SyncDepFldUtilities.SyncFields(Rec."Dont Check Dimension", Rec."Do Not Check Dimensions CZL", PreviousRecord."Dont Check Dimension", PreviousRecord."Do Not Check Dimensions CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Posting Debit/Credit", Rec."Check Posting Debit/Credit CZL", PreviousRecord."Check Posting Debit/Credit", PreviousRecord."Check Posting Debit/Credit CZL");
        SyncDepFldUtilities.SyncFields(Rec."Mark Neg. Qty as Correction", Rec."Mark Neg. Qty as Correct. CZL", PreviousRecord."Mark Neg. Qty as Correction", PreviousRecord."Mark Neg. Qty as Correct. CZL");
#endif
#if not CLEAN18
        SyncDepFldUtilities.SyncFields(Rec."Rounding Date", Rec."Rounding Date CZL", PreviousRecord."Rounding Date", PreviousRecord."Rounding Date CZL");
        SyncDepFldUtilities.SyncFields(Rec."Closed Period Entry Pos.Date", Rec."Closed Per. Entry Pos.Date CZL", PreviousRecord."Closed Period Entry Pos.Date", PreviousRecord."Closed Per. Entry Pos.Date CZL");
        SyncDepFldUtilities.SyncFields(Rec."User Checks Allowed", Rec."User Checks Allowed CZL", PreviousRecord."User Checks Allowed", PreviousRecord."User Checks Allowed CZL");
#endif
        DepFieldTxt := Rec."Shared Account Schedule";
        NewFieldTxt := Rec."Shared Account Schedule CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Shared Account Schedule", PreviousRecord."Shared Account Schedule CZL");
        Rec."Shared Account Schedule" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Shared Account Schedule"));
        Rec."Shared Account Schedule CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Shared Account Schedule CZL"));
        DepFieldTxt := Rec."Acc. Schedule Results Nos.";
        NewFieldTxt := Rec."Acc. Schedule Results Nos. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Acc. Schedule Results Nos.", PreviousRecord."Acc. Schedule Results Nos. CZL");
        Rec."Acc. Schedule Results Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Acc. Schedule Results Nos."));
        Rec."Acc. Schedule Results Nos. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Acc. Schedule Results Nos. CZL"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertGeneralLedgerSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncGeneralLedgerSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyGeneralLedgerSetup(var Rec: Record "General Ledger Setup")
    begin
        SyncGeneralLedgerSetup(Rec);
    end;

    local procedure SyncGeneralLedgerSetup(var Rec: Record "General Ledger Setup")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"General Ledger Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert(false);
        end;
#if not CLEAN17
        StatutoryReportingSetupCZL."Company Official Nos." := Rec."Company Officials Nos.";
        StatutoryReportingSetupCZL.Modify(false);
#endif
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
    end;
}
#endif