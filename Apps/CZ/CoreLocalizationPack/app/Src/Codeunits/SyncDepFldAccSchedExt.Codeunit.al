#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31304 "Sync.Dep.Fld-AccSchedExt CZL"
{
    Access = Internal;
    Permissions = tabledata "Acc. Schedule Extension" = rimd,
                  tabledata "Acc. Schedule Extension CZL" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameAccScheduleExtension(var Rec: Record "Acc. Schedule Extension"; var xRec: Record "Acc. Schedule Extension")
    var
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension CZL");
        AccScheduleExtensionCZL.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleExtensionCZL.Get(xRec.Code) then
            AccScheduleExtensionCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertAccScheduleExtension(var Rec: Record "Acc. Schedule Extension")
    begin
        SyncAccScheduleExtension(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyAccScheduleExtension(var Rec: Record "Acc. Schedule Extension")
    begin
        SyncAccScheduleExtension(Rec);
    end;

    local procedure SyncAccScheduleExtension(var AccScheduleExtension: Record "Acc. Schedule Extension")
    var
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if AccScheduleExtension.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension CZL");
        AccScheduleExtensionCZL.ChangeCompany(AccScheduleExtension.CurrentCompany);
        if not AccScheduleExtensionCZL.Get(AccScheduleExtension.Code) then begin
            AccScheduleExtensionCZL.Init();
            AccScheduleExtensionCZL.Code := AccScheduleExtension.Code;
            AccScheduleExtensionCZL.SystemId := AccScheduleExtension.SystemId;
            AccScheduleExtensionCZL.Insert(false, true);
        end;
        AccScheduleExtensionCZL.Description := AccScheduleExtension.Description;
        AccScheduleExtensionCZL."Source Table" := AccScheduleExtension."Source Table";
        AccScheduleExtensionCZL."Source Type" := AccScheduleExtension."Source Type";
        AccScheduleExtensionCZL."Source Filter" := AccScheduleExtension."Source Filter";
        AccScheduleExtensionCZL."G/L Account Filter" := AccScheduleExtension."G/L Account Filter";
        AccScheduleExtensionCZL."G/L Amount Type" := AccScheduleExtension."G/L Amount Type";
        AccScheduleExtensionCZL."Amount Sign" := AccScheduleExtension."Amount Sign";
        AccScheduleExtensionCZL.Description := AccScheduleExtension.Description;
        AccScheduleExtensionCZL."Entry Type" := AccScheduleExtension."Entry Type";
        AccScheduleExtensionCZL.Prepayment := AccScheduleExtension.Prepayment;
        AccScheduleExtensionCZL."Reverse Sign" := AccScheduleExtension."Reverse Sign";
        AccScheduleExtensionCZL."VAT Amount Type" := AccScheduleExtension."VAT Amount Type";
        AccScheduleExtensionCZL."VAT Bus. Post. Group Filter" := AccScheduleExtension."VAT Bus. Post. Group Filter";
        AccScheduleExtensionCZL."VAT Prod. Post. Group Filter" := AccScheduleExtension."VAT Prod. Post. Group Filter";
        AccScheduleExtensionCZL."Location Filter" := AccScheduleExtension."Location Filter";
        AccScheduleExtensionCZL."Bin Filter" := AccScheduleExtension."Bin Filter";
        AccScheduleExtensionCZL."Posting Group Filter" := AccScheduleExtension."Posting Group Filter";
        AccScheduleExtensionCZL."Posting Date Filter" := AccScheduleExtension."Posting Date Filter";
        AccScheduleExtensionCZL."Due Date Filter" := AccScheduleExtension."Due Date Filter";
        AccScheduleExtensionCZL."Document Type Filter" := AccScheduleExtension."Document Type Filter";
        AccScheduleExtensionCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteAccScheduleExtension(var Rec: Record "Acc. Schedule Extension")
    var
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension CZL");
        AccScheduleExtensionCZL.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleExtensionCZL.Get(Rec.Code) then
            AccScheduleExtensionCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameAccScheduleExtensionCZL(var Rec: Record "Acc. Schedule Extension CZL"; var xRec: Record "Acc. Schedule Extension CZL")
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension");
        AccScheduleExtension.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleExtension.Get(xRec.Code) then begin
            AccScheduleExtension.Rename(Rec.Code);
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertAccScheduleExtensionCZL(var Rec: Record "Acc. Schedule Extension CZL")
    begin
        if NavApp.IsInstalling() then
            exit;
        SyncAccScheduleExtensionCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyAccScheduleExtensionCZL(var Rec: Record "Acc. Schedule Extension CZL")
    begin
        SyncAccScheduleExtensionCZL(Rec);
    end;

    local procedure SyncAccScheduleExtensionCZL(var AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL")
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if AccScheduleExtensionCZL.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension");
        AccScheduleExtension.ChangeCompany(AccScheduleExtensionCZL.CurrentCompany);
        if not AccScheduleExtension.Get(AccScheduleExtensionCZL.Code) then begin
            AccScheduleExtension.Init();
            AccScheduleExtension.Code := AccScheduleExtensionCZL.Code;
            AccScheduleExtension.SystemId := AccScheduleExtensionCZL.SystemId;
            AccScheduleExtension.Insert(false, true);
        end;
        AccScheduleExtension.Description := AccScheduleExtensionCZL.Description;
        AccScheduleExtension."Source Table" := AccScheduleExtensionCZL."Source Table";
        AccScheduleExtension."Source Type" := AccScheduleExtensionCZL."Source Type";
        AccScheduleExtension."Source Filter" := AccScheduleExtensionCZL."Source Filter";
        AccScheduleExtension."G/L Account Filter" := AccScheduleExtensionCZL."G/L Account Filter";
        AccScheduleExtension."G/L Amount Type" := AccScheduleExtensionCZL."G/L Amount Type";
        AccScheduleExtension."Amount Sign" := AccScheduleExtensionCZL."Amount Sign";
        AccScheduleExtension.Description := AccScheduleExtensionCZL.Description;
        AccScheduleExtension."Entry Type" := AccScheduleExtensionCZL."Entry Type";
        AccScheduleExtension.Prepayment := AccScheduleExtensionCZL.Prepayment;
        AccScheduleExtension."Reverse Sign" := AccScheduleExtensionCZL."Reverse Sign";
        AccScheduleExtension."VAT Amount Type" := AccScheduleExtensionCZL."VAT Amount Type";
        AccScheduleExtension."VAT Bus. Post. Group Filter" := AccScheduleExtensionCZL."VAT Bus. Post. Group Filter";
        AccScheduleExtension."VAT Prod. Post. Group Filter" := AccScheduleExtensionCZL."VAT Prod. Post. Group Filter";
        AccScheduleExtension."Location Filter" := AccScheduleExtensionCZL."Location Filter";
        AccScheduleExtension."Bin Filter" := AccScheduleExtensionCZL."Bin Filter";
        AccScheduleExtension."Posting Group Filter" := AccScheduleExtensionCZL."Posting Group Filter";
        AccScheduleExtension."Posting Date Filter" := AccScheduleExtensionCZL."Posting Date Filter";
        AccScheduleExtension."Due Date Filter" := AccScheduleExtensionCZL."Due Date Filter";
        AccScheduleExtension."Document Type Filter" := AccScheduleExtensionCZL."Document Type Filter";
        AccScheduleExtension.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Extension CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteAccScheduleExtensionCZL(var Rec: Record "Acc. Schedule Extension CZL")
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Acc. Schedule Extension CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Acc. Schedule Extension");
        AccScheduleExtension.ChangeCompany(Rec.CurrentCompany);
        if AccScheduleExtension.Get(Rec.Code) then begin
            AccScheduleExtension.Delete(false);
            SyncLoopingHelper.RestoreFieldSynchronization(Database::"Acc. Schedule Extension");
        end;
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif