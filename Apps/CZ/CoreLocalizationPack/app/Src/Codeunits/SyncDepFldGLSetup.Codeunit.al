#pragma warning disable AL0432
codeunit 31162 "Sync.Dep.Fld-GLSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

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
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Use VAT Date", Rec."Use VAT Date CZL", PreviousRecord."Use VAT Date", PreviousRecord."Use VAT Date CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting From", Rec."Allow VAT Posting From CZL", PreviousRecord."Allow VAT Posting From", PreviousRecord."Allow VAT Posting From CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow VAT Posting To", Rec."Allow VAT Posting To CZL", PreviousRecord."Allow VAT Posting To", PreviousRecord."Allow VAT Posting To CZL");
        SyncDepFldUtilities.SyncFields(Rec."Dont Check Dimension", Rec."Do Not Check Dimensions CZL", PreviousRecord."Dont Check Dimension", PreviousRecord."Do Not Check Dimensions CZL");
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
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"General Ledger Setup", 0) then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert(false);
        end;
        StatutoryReportingSetupCZL."Company Official Nos." := Rec."Company Officials Nos.";
        StatutoryReportingSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL", 0);
    end;
}
