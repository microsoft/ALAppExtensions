#if not CLEAN18
#pragma warning disable AL0432, AL0603, AA0072
codeunit 31299 "Sync.Dep.Fld-TaxDeprGroup CZF"
{
    Access = Internal;
    Permissions = tabledata "Depreciation Group" = rimd,
                  tabledata "Tax Depreciation Group CZF" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameDepreciationGroup(var Rec: Record "Depreciation Group"; var xRec: Record "Depreciation Group")
    var
        DepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Depreciation Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Tax Depreciation Group CZF");
        DepreciationGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if DepreciationGroupCZF.Get(xRec.Code, xRec."Starting Date") then
            DepreciationGroupCZF.Rename(Rec.Code, Rec."Starting Date");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Tax Depreciation Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertDepreciationGroup(var Rec: Record "Depreciation Group")
    begin
        SyncDepreciationGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Group", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyDepreciationGroup(var Rec: Record "Depreciation Group")
    begin
        SyncDepreciationGroup(Rec);
    end;

    local procedure SyncDepreciationGroup(var Rec: Record "Depreciation Group")
    var
        DepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Depreciation Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Tax Depreciation Group CZF");
        DepreciationGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if not DepreciationGroupCZF.Get(Rec.Code, Rec."Starting Date") then begin
            DepreciationGroupCZF.Init();
            DepreciationGroupCZF.Code := Rec.Code;
            DepreciationGroupCZF."Starting Date" := Rec."Starting Date";
            DepreciationGroupCZF.SystemId := Rec.SystemId;
            DepreciationGroupCZF.Insert(false, true);
        end;
        DepreciationGroupCZF.Description := Rec.Description;
        DepreciationGroupCZF."Depreciation Group" := Rec."Depreciation Group";
        DepreciationGroupCZF."Depreciation Type" := Rec."Depreciation Type";
        DepreciationGroupCZF."No. of Depreciation Years" := Rec."No. of Depreciation Years";
        DepreciationGroupCZF."No. of Depreciation Months" := Rec."No. of Depreciation Months";
        DepreciationGroupCZF."Min. Months After Appreciation" := Rec."Min. Months After Appreciation";
        DepreciationGroupCZF."Straight First Year" := Rec."Straight First Year";
        DepreciationGroupCZF."Straight Next Years" := Rec."Straight Next Years";
        DepreciationGroupCZF."Straight Appreciation" := Rec."Straight Appreciation";
        DepreciationGroupCZF."Declining First Year" := Rec."Declining First Year";
        DepreciationGroupCZF."Declining Next Years" := Rec."Declining Next Years";
        DepreciationGroupCZF."Declining Appreciation" := Rec."Declining Appreciation";
        DepreciationGroupCZF."Declining Depr. Increase %" := Rec."Declining Depr. Increase %";
        DepreciationGroupCZF.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Tax Depreciation Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Group", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteDepreciationGroup(var Rec: Record "Depreciation Group")
    var
        DepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Depreciation Group") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Tax Depreciation Group CZF");
        DepreciationGroupCZF.ChangeCompany(Rec.CurrentCompany);
        if DepreciationGroupCZF.Get(Rec.Code, Rec."Starting Date") then
            DepreciationGroupCZF.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Tax Depreciation Group CZF");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Depreciation Group CZF", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameTaxDepreciationGroupCZF(var Rec: Record "Tax Depreciation Group CZF"; var xRec: Record "Tax Depreciation Group CZF")
    var
        DepreciationGroup: Record "Depreciation Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Tax Depreciation Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Depreciation Group");
        DepreciationGroup.ChangeCompany(Rec.CurrentCompany);
        if DepreciationGroup.Get(xRec.Code, xRec."Starting Date") then
            DepreciationGroup.Rename(Rec.Code, Rec."Starting Date");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Depreciation Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Depreciation Group CZF", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertTaxDepreciationGroupCZF(var Rec: Record "Tax Depreciation Group CZF")
    begin
        SyncDepreciationGroupCZF(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Depreciation Group CZF", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyTaxDepreciationGroupCZF(var Rec: Record "Tax Depreciation Group CZF")
    begin
        SyncDepreciationGroupCZF(Rec);
    end;

    local procedure SyncDepreciationGroupCZF(var Rec: Record "Tax Depreciation Group CZF")
    var
        DepreciationGroup: Record "Depreciation Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if DataUpgradeMgt.IsUpgradeInProgress() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Tax Depreciation Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Depreciation Group");
        DepreciationGroup.ChangeCompany(Rec.CurrentCompany);
        if not DepreciationGroup.Get(Rec.Code, Rec."Starting Date") then begin
            DepreciationGroup.Init();
            DepreciationGroup.Code := Rec.Code;
            DepreciationGroup."Starting Date" := Rec."Starting Date";
            DepreciationGroup.SystemId := Rec.SystemId;
            DepreciationGroup.Insert(false, true);
        end;
        DepreciationGroup.Description := Rec.Description;
        DepreciationGroup."Depreciation Group" := Rec."Depreciation Group";
        DepreciationGroup."Depreciation Type" := Rec."Depreciation Type".AsInteger();
        DepreciationGroup."No. of Depreciation Years" := Rec."No. of Depreciation Years";
        DepreciationGroup."No. of Depreciation Months" := Rec."No. of Depreciation Months";
        DepreciationGroup."Min. Months After Appreciation" := Rec."Min. Months After Appreciation";
        DepreciationGroup."Straight First Year" := Rec."Straight First Year";
        DepreciationGroup."Straight Next Years" := Rec."Straight Next Years";
        DepreciationGroup."Straight Appreciation" := Rec."Straight Appreciation";
        DepreciationGroup."Declining First Year" := Rec."Declining First Year";
        DepreciationGroup."Declining Next Years" := Rec."Declining Next Years";
        DepreciationGroup."Declining Appreciation" := Rec."Declining Appreciation";
        DepreciationGroup."Declining Depr. Increase %" := Rec."Declining Depr. Increase %";
        DepreciationGroup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Depreciation Group");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Depreciation Group CZF", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteTaxDepreciationGroupCZF(var Rec: Record "Tax Depreciation Group CZF")
    var
        DepreciationGroup: Record "Depreciation Group";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Tax Depreciation Group CZF") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Depreciation Group");
        DepreciationGroup.ChangeCompany(Rec.CurrentCompany);
        if DepreciationGroup.Get(Rec.Code, Rec."Starting Date") then
            DepreciationGroup.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Depreciation Group");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif