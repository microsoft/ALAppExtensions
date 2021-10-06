#if not CLEAN17
#pragma warning disable AL0432
codeunit 31127 "Sync.Dep.Fld-CurrNomValue CZP"
{
    Permissions = tabledata "Currency Nominal Value" = rimd,
                  tabledata "Currency Nominal Value CZP" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCurrencyNominalValue(var Rec: Record "Currency Nominal Value"; var xRec: Record "Currency Nominal Value")
    var
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value CZP");
        CurrencyNominalValueCZP.ChangeCompany(Rec.CurrentCompany);
        if CurrencyNominalValueCZP.Get(xRec."Currency Code", xRec.Value) then
            CurrencyNominalValueCZP.Rename(Rec."Currency Code", Rec.Value);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCurrencyNominalValue(var Rec: Record "Currency Nominal Value")
    begin
        SyncCurrencyNominalValue(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCurrencyNominalValue(var Rec: Record "Currency Nominal Value")
    begin
        SyncCurrencyNominalValue(Rec);
    end;

    local procedure SyncCurrencyNominalValue(var Rec: Record "Currency Nominal Value")
    var
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value CZP");
        CurrencyNominalValueCZP.ChangeCompany(Rec.CurrentCompany);
        if not CurrencyNominalValueCZP.Get(Rec."Currency Code", Rec.Value) then begin
            CurrencyNominalValueCZP.Init();
            CurrencyNominalValueCZP."Currency Code" := Rec."Currency Code";
            CurrencyNominalValueCZP."Nominal Value" := Rec.Value;
            CurrencyNominalValueCZP.SystemId := Rec.SystemId;
            CurrencyNominalValueCZP.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCurrencyNominalValue(var Rec: Record "Currency Nominal Value")
    var
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value CZP");
        CurrencyNominalValueCZP.ChangeCompany(Rec.CurrentCompany);
        if CurrencyNominalValueCZP.Get(Rec."Currency Code", Rec.Value) then
            CurrencyNominalValueCZP.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value CZP");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value CZP", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCurrencyNominalValueCZP(var Rec: Record "Currency Nominal Value CZP"; var xRec: Record "Currency Nominal Value CZP")
    var
        CurrencyNominalValue: Record "Currency Nominal Value";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value");
        CurrencyNominalValue.ChangeCompany(Rec.CurrentCompany);
        if CurrencyNominalValue.Get(xRec."Currency Code", xRec."Nominal Value") then
            CurrencyNominalValue.Rename(Rec."Currency Code", Rec."Nominal Value");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCurrencyNominalValueCZP(var Rec: Record "Currency Nominal Value CZP")
    begin
        SyncCurrencyNominalValueCZP(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value CZP", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCurrencyNominalValueCZP(var Rec: Record "Currency Nominal Value CZP")
    begin
        SyncCurrencyNominalValueCZP(Rec);
    end;

    local procedure SyncCurrencyNominalValueCZP(var Rec: Record "Currency Nominal Value CZP")
    var
        CurrencyNominalValue: Record "Currency Nominal Value";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value");
        CurrencyNominalValue.ChangeCompany(Rec.CurrentCompany);
        if not CurrencyNominalValue.Get(Rec."Currency Code", Rec."Nominal Value") then begin
            CurrencyNominalValue.Init();
            CurrencyNominalValue."Currency Code" := Rec."Currency Code";
            CurrencyNominalValue.Value := Rec."Nominal Value";
            CurrencyNominalValue.SystemId := Rec.SystemId;
            CurrencyNominalValue.Insert(false, true);
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Nominal Value CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCurrencyNominalValueCZP(var Rec: Record "Currency Nominal Value CZP")
    var
        CurrencyNominalValue: Record "Currency Nominal Value";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Currency Nominal Value CZP") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Currency Nominal Value");
        CurrencyNominalValue.ChangeCompany(Rec.CurrentCompany);
        if CurrencyNominalValue.Get(Rec."Currency Code", Rec."Nominal Value") then
            CurrencyNominalValue.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Currency Nominal Value");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif