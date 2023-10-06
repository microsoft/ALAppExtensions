#if not CLEAN22
#pragma warning disable AL0432
codeunit 31299 "Sync.Dep.Fld-StatIndication CZ"
{
    Access = Internal;
    Permissions = tabledata "Statistic Indication CZL" = rimd,
                  tabledata "Statistic Indication CZ" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameStatisticIndicationCZL(var Rec: Record "Statistic Indication CZL"; var xRec: Record "Statistic Indication CZL")
    var
        StatisticIndicationCZ: Record "Statistic Indication CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZ");
        StatisticIndicationCZ.ChangeCompany(Rec.CurrentCompany);
        if StatisticIndicationCZ.Get(xRec."Tariff No.", xRec.Code) then
            StatisticIndicationCZ.Rename(Rec."Tariff No.", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatisticIndicationCZL(var Rec: Record "Statistic Indication CZL")
    var
        StatisticIndicationCZ: Record "Statistic Indication CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZ");
        StatisticIndicationCZ.ChangeCompany(Rec.CurrentCompany);
        if not StatisticIndicationCZ.Get(Rec."Tariff No.", Rec.Code) then begin
            StatisticIndicationCZ.Init();
            StatisticIndicationCZ."Tariff No." := Rec."Tariff No.";
            StatisticIndicationCZ.Code := Rec.Code;
            StatisticIndicationCZ.Description := Rec.Description;
            StatisticIndicationCZ."Description EN" := Rec."Description EN";
            StatisticIndicationCZ.SystemId := Rec.SystemId;
            StatisticIndicationCZ.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatisticIndicationCZL(var Rec: Record "Statistic Indication CZL")
    var
        StatisticIndicationCZ: Record "Statistic Indication CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZ");
        StatisticIndicationCZ.ChangeCompany(Rec.CurrentCompany);
        if not StatisticIndicationCZ.Get(Rec."Tariff No.", Rec.Code) then begin
            StatisticIndicationCZ.Init();
            StatisticIndicationCZ."Tariff No." := Rec."Tariff No.";
            StatisticIndicationCZ.Code := Rec.Code;
            StatisticIndicationCZ.SystemId := Rec.SystemId;
            StatisticIndicationCZ.Insert(false, true);
        end;
        StatisticIndicationCZ.Description := Rec.Description;
        StatisticIndicationCZ."Description EN" := Rec."Description EN";
        StatisticIndicationCZ.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteStatisticIndicationCZL(var Rec: Record "Statistic Indication CZL")
    var
        StatisticIndicationCZ: Record "Statistic Indication CZ";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZ");
        StatisticIndicationCZ.ChangeCompany(Rec.CurrentCompany);
        if StatisticIndicationCZ.Get(Rec."Tariff No.", Rec.Code) then
            StatisticIndicationCZ.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZ", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameStatisticIndicationCZ(var Rec: Record "Statistic Indication CZ"; var xRec: Record "Statistic Indication CZ")
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZL");
        StatisticIndicationCZL.ChangeCompany(Rec.CurrentCompany);
        if StatisticIndicationCZL.Get(xRec."Tariff No.", xRec.Code) then
            StatisticIndicationCZL.Rename(Rec."Tariff No.", Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZ", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatisticIndicationCZ(var Rec: Record "Statistic Indication CZ")
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZL");
        StatisticIndicationCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatisticIndicationCZL.Get(Rec."Tariff No.", Rec.Code) then begin
            StatisticIndicationCZL.Init();
            StatisticIndicationCZL."Tariff No." := Rec."Tariff No.";
            StatisticIndicationCZL.Code := Rec.Code;
            StatisticIndicationCZL.Description := Rec.Description;
            StatisticIndicationCZL."Description EN" := Rec."Description EN";
            StatisticIndicationCZL.SystemId := Rec.SystemId;
            StatisticIndicationCZL.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZ", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatisticIndicationCZ(var Rec: Record "Statistic Indication CZ")
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZL");
        StatisticIndicationCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatisticIndicationCZL.Get(Rec."Tariff No.", Rec.Code) then begin
            StatisticIndicationCZL.Init();
            StatisticIndicationCZL."Tariff No." := Rec."Tariff No.";
            StatisticIndicationCZL.Code := Rec.Code;
            StatisticIndicationCZL.SystemId := Rec.SystemId;
            StatisticIndicationCZL.Insert(false, true);
        end;
        StatisticIndicationCZL.Description := Rec.Description;
        StatisticIndicationCZL."Description EN" := Rec."Description EN";
        StatisticIndicationCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistic Indication CZ", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteStatisticIndicationCZ(var Rec: Record "Statistic Indication CZ")
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statistic Indication CZ") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statistic Indication CZL");
        StatisticIndicationCZL.ChangeCompany(Rec.CurrentCompany);
        if StatisticIndicationCZL.Get(Rec."Tariff No.", Rec.Code) then
            StatisticIndicationCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statistic Indication CZL");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#pragma warning restore AL0432
#endif