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
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
    end;
}
#endif