#if not CLEAN18
#pragma warning disable AL0432
codeunit 31203 "Sync.Dep.Fld-ConstSymbol CZL"
{
    Permissions = tabledata "Constant Symbol" = rimd,
                  tabledata "Constant Symbol CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameConstantSymbol(var Rec: Record "Constant Symbol"; var xRec: Record "Constant Symbol")
    var
        ConstantSymbolCZL: Record "Constant Symbol CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol CZL");
        ConstantSymbolCZL.ChangeCompany(Rec.CurrentCompany);
        if ConstantSymbolCZL.Get(xRec.Code) then
            ConstantSymbolCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertConstantSymbol(var Rec: Record "Constant Symbol")
    begin
        SyncConstantSymbol(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyConstantSymbol(var Rec: Record "Constant Symbol")
    begin
        SyncConstantSymbol(Rec);
    end;

    local procedure SyncConstantSymbol(var Rec: Record "Constant Symbol")
    var
        ConstantSymbolCZL: Record "Constant Symbol CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol CZL");
        ConstantSymbolCZL.ChangeCompany(Rec.CurrentCompany);
        if not ConstantSymbolCZL.Get(Rec.Code) then begin
            ConstantSymbolCZL.Init();
            ConstantSymbolCZL.Code := Rec.Code;
            ConstantSymbolCZL.SystemId := Rec.SystemId;
            ConstantSymbolCZL.Insert(false, true);
        end;
        ConstantSymbolCZL.Description := Rec.Description;
        ConstantSymbolCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteConstantSymbol(var Rec: Record "Constant Symbol")
    var
        ConstantSymbolCZL: Record "Constant Symbol CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol CZL");
        ConstantSymbolCZL.ChangeCompany(Rec.CurrentCompany);
        if ConstantSymbolCZL.Get(Rec.Code) then
            ConstantSymbolCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameConstantSymbolCZL(var Rec: Record "Constant Symbol CZL"; var xRec: Record "Constant Symbol CZL")
    var
        ConstantSymbol: Record "Constant Symbol";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol");
        ConstantSymbol.ChangeCompany(Rec.CurrentCompany);
        if ConstantSymbol.Get(xRec.Code) then
            ConstantSymbol.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertConstantSymbolCZL(var Rec: Record "Constant Symbol CZL")
    begin
        SyncConstantSymbolCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyConstantSymbolCZL(var Rec: Record "Constant Symbol CZL")
    begin
        SyncConstantSymbolCZL(Rec);
    end;

    local procedure SyncConstantSymbolCZL(var Rec: Record "Constant Symbol CZL")
    var
        ConstantSymbol: Record "Constant Symbol";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol");
        ConstantSymbol.ChangeCompany(Rec.CurrentCompany);
        if not ConstantSymbol.Get(Rec.Code) then begin
            ConstantSymbol.Init();
            ConstantSymbol.Code := Rec.Code;
            ConstantSymbol.SystemId := Rec.SystemId;
            ConstantSymbol.Insert(false, true);
        end;
        ConstantSymbol.Description := CopyStr(Rec.Description, 1, MaxStrLen(ConstantSymbol.Description));
        ConstantSymbol.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Constant Symbol CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteConstantSymbolCZL(var Rec: Record "Constant Symbol CZL")
    var
        ConstantSymbol: Record "Constant Symbol";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Constant Symbol CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Constant Symbol");
        ConstantSymbol.ChangeCompany(Rec.CurrentCompany);
        if ConstantSymbol.Get(Rec.Code) then
            ConstantSymbol.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Constant Symbol");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif