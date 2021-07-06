#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31304 "Sync.Dep.Fld-AccSchedExt CZL"
{
    Access = Internal;

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

    local procedure SyncAccScheduleExtension(var Rec: Record "Acc. Schedule Extension")
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
        if not AccScheduleExtensionCZL.Get(Rec.Code) then begin
            AccScheduleExtensionCZL.Init();
            AccScheduleExtensionCZL.Code := Rec.Code;
            AccScheduleExtensionCZL.Insert(false);
        end;
        AccScheduleExtensionCZL.Description := Rec.Description;
        AccScheduleExtensionCZL."Source Table" := Rec."Source Table";
        AccScheduleExtensionCZL."Source Type" := Rec."Source Type";
        AccScheduleExtensionCZL."Source Filter" := Rec."Source Filter";
        AccScheduleExtensionCZL."G/L Account Filter" := Rec."G/L Account Filter";
        AccScheduleExtensionCZL."G/L Amount Type" := Rec."G/L Amount Type";
        AccScheduleExtensionCZL."Amount Sign" := Rec."Amount Sign";
        AccScheduleExtensionCZL.Description := Rec.Description;
        AccScheduleExtensionCZL."Entry Type" := Rec."Entry Type";
        AccScheduleExtensionCZL.Prepayment := Rec.Prepayment;
        AccScheduleExtensionCZL."Reverse Sign" := Rec."Reverse Sign";
        AccScheduleExtensionCZL."VAT Amount Type" := Rec."VAT Amount Type";
        AccScheduleExtensionCZL."VAT Bus. Post. Group Filter" := Rec."VAT Bus. Post. Group Filter";
        AccScheduleExtensionCZL."VAT Prod. Post. Group Filter" := Rec."VAT Prod. Post. Group Filter";
        AccScheduleExtensionCZL."Location Filter" := Rec."Location Filter";
        AccScheduleExtensionCZL."Bin Filter" := Rec."Bin Filter";
        AccScheduleExtensionCZL."Posting Group Filter" := Rec."Posting Group Filter";
        AccScheduleExtensionCZL."Posting Date Filter" := Rec."Posting Date Filter";
        AccScheduleExtensionCZL."Due Date Filter" := Rec."Due Date Filter";
        AccScheduleExtensionCZL."Document Type Filter" := Rec."Document Type Filter";
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

    local procedure SyncAccScheduleExtensionCZL(var Rec: Record "Acc. Schedule Extension CZL")
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
        if not AccScheduleExtension.Get(Rec.Code) then begin
            AccScheduleExtension.Init();
            AccScheduleExtension.Code := Rec.Code;
            AccScheduleExtension.Insert(false);
        end;
        AccScheduleExtension.Description := Rec.Description;
        AccScheduleExtension."Source Table" := Rec."Source Table";
        AccScheduleExtension."Source Type" := Rec."Source Type";
        AccScheduleExtension."Source Filter" := Rec."Source Filter";
        AccScheduleExtension."G/L Account Filter" := Rec."G/L Account Filter";
        AccScheduleExtension."G/L Amount Type" := Rec."G/L Amount Type";
        AccScheduleExtension."Amount Sign" := Rec."Amount Sign";
        AccScheduleExtension.Description := Rec.Description;
        AccScheduleExtension."Entry Type" := Rec."Entry Type";
        AccScheduleExtension.Prepayment := Rec.Prepayment;
        AccScheduleExtension."Reverse Sign" := Rec."Reverse Sign";
        AccScheduleExtension."VAT Amount Type" := Rec."VAT Amount Type";
        AccScheduleExtension."VAT Bus. Post. Group Filter" := Rec."VAT Bus. Post. Group Filter";
        AccScheduleExtension."VAT Prod. Post. Group Filter" := Rec."VAT Prod. Post. Group Filter";
        AccScheduleExtension."Location Filter" := Rec."Location Filter";
        AccScheduleExtension."Bin Filter" := Rec."Bin Filter";
        AccScheduleExtension."Posting Group Filter" := Rec."Posting Group Filter";
        AccScheduleExtension."Posting Date Filter" := Rec."Posting Date Filter";
        AccScheduleExtension."Due Date Filter" := Rec."Due Date Filter";
        AccScheduleExtension."Document Type Filter" := Rec."Document Type Filter";
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