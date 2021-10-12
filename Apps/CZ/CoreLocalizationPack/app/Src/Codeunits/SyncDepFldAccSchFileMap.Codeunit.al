#if not CLEAN17
#pragma warning disable AL0432
codeunit 31191 "Sync.Dep.Fld-AccSchFileMap CZL"
{
    Permissions = tabledata "Statement File Mapping" = rimd,
                  tabledata "Acc. Schedule File Mapping CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Statement File Mapping", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameStatementFileMapping(var Rec: Record "Statement File Mapping"; var xRec: Record "Statement File Mapping")
    var
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statement File Mapping") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule File Mapping CZL");
        AccScheduleFileMappingCZL.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleFileMappingCZL.Get(xRec."Schedule Name", xRec."Schedule Line No.", xRec."Schedule Column Layout Name", xRec."Schedule Column No.", xRec."Excel Cell") then
            AccScheduleFileMappingCZL.Rename(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule File Mapping CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statement File Mapping", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatementFileMapping(var Rec: Record "Statement File Mapping")
    begin
        SyncStatementFileMapping(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statement File Mapping", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatementFileMapping(var Rec: Record "Statement File Mapping")
    begin
        SyncStatementFileMapping(Rec);
    end;

    local procedure SyncStatementFileMapping(var Rec: Record "Statement File Mapping")
    var
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statement File Mapping") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule File Mapping CZL");
        AccScheduleFileMappingCZL.ChangeCompany(Rec.CurrentCompany);
        if not AccScheduleFileMappingCZL.Get(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell") then begin
            AccScheduleFileMappingCZL.Init();
            AccScheduleFileMappingCZL."Schedule Name" := Rec."Schedule Name";
            AccScheduleFileMappingCZL."Schedule Line No." := Rec."Schedule Line No.";
            AccScheduleFileMappingCZL."Schedule Column Layout Name" := Rec."Schedule Column Layout Name";
            AccScheduleFileMappingCZL."Schedule Column No." := Rec."Schedule Column No.";
            AccScheduleFileMappingCZL."Excel Cell" := Rec."Excel Cell";
            AccScheduleFileMappingCZL.SystemId := Rec.SystemId;
            AccScheduleFileMappingCZL.Insert(false, true);
        end;
        AccScheduleFileMappingCZL."Excel Row No." := Rec."Excel Row No.";
        AccScheduleFileMappingCZL."Excel Column No." := Rec."Excel Column No.";
        AccScheduleFileMappingCZL.Split := Rec.Split;
        AccScheduleFileMappingCZL.Offset := Rec.Offset;
        AccScheduleFileMappingCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule File Mapping CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statement File Mapping", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteStatementFileMapping(var Rec: Record "Statement File Mapping")
    var
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statement File Mapping") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule File Mapping CZL");
        AccScheduleFileMappingCZL.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleFileMappingCZL.Get(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell") then
            AccScheduleFileMappingCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule File Mapping CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule File Mapping CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameAccScheduleFileMappingCZL(var Rec: Record "Acc. Schedule File Mapping CZL"; var xRec: Record "Acc. Schedule File Mapping CZL")
    var
        StatementFileMapping: Record "Statement File Mapping";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule File Mapping CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statement File Mapping");
        StatementFileMapping.ChangeCompany(Rec.CurrentCompany);
        if StatementFileMapping.Get(xRec."Schedule Name", xRec."Schedule Line No.", xRec."Schedule Column Layout Name", xRec."Schedule Column No.", xRec."Excel Cell") then
            StatementFileMapping.Rename(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statement File Mapping");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule File Mapping CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertAccScheduleFileMappingCZL(var Rec: Record "Acc. Schedule File Mapping CZL")
    begin
        SyncAccScheduleFileMappingCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule File Mapping CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyAccScheduleFileMappingCZL(var Rec: Record "Acc. Schedule File Mapping CZL")
    begin
        SyncAccScheduleFileMappingCZL(Rec);
    end;

    local procedure SyncAccScheduleFileMappingCZL(var Rec: Record "Acc. Schedule File Mapping CZL")
    var
        StatementFileMapping: Record "Statement File Mapping";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule File Mapping CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statement File Mapping");
        StatementFileMapping.ChangeCompany(Rec.CurrentCompany);
        if not StatementFileMapping.Get(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell") then begin
            StatementFileMapping.Init();
            StatementFileMapping."Schedule Name" := Rec."Schedule Name";
            StatementFileMapping."Schedule Line No." := Rec."Schedule Line No.";
            StatementFileMapping."Schedule Column Layout Name" := Rec."Schedule Column Layout Name";
            StatementFileMapping."Schedule Column No." := Rec."Schedule Column No.";
            StatementFileMapping."Excel Cell" := Rec."Excel Cell";
            StatementFileMapping.SystemId := Rec.SystemId;
            StatementFileMapping.Insert(false, true);
        end;
        StatementFileMapping."Excel Row No." := Rec."Excel Row No.";
        StatementFileMapping."Excel Column No." := Rec."Excel Column No.";
        StatementFileMapping.Split := Rec.Split;
        StatementFileMapping.Offset := Rec.Offset;
        StatementFileMapping.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statement File Mapping");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule File Mapping CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteAccScheduleFileMappingCZL(var Rec: Record "Acc. Schedule File Mapping CZL")
    var
        StatementFileMapping: Record "Statement File Mapping";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule File Mapping CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statement File Mapping");
        StatementFileMapping.ChangeCompany(Rec.CurrentCompany);
        if StatementFileMapping.Get(Rec."Schedule Name", Rec."Schedule Line No.", Rec."Schedule Column Layout Name", Rec."Schedule Column No.", Rec."Excel Cell") then
            StatementFileMapping.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statement File Mapping");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif