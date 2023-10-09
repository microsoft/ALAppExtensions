#if not CLEAN22
#pragma warning disable AL0432
codeunit 31295 "Sync.Dep.Fld-StatRepSetup CZ"
{
    Access = Internal;
    Permissions = tabledata "Statutory Reporting Setup CZL" = rimd,
                  tabledata "Intrastat Report Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Statutory Reporting Setup CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    begin
        SyncStatutoryReportingSetupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statutory Reporting Setup CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    begin
        SyncStatutoryReportingSetupCZL(Rec);
    end;

    local procedure SyncStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statutory Reporting Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Intrastat Report Setup");
        IntrastatReportSetup.ChangeCompany(Rec.CurrentCompany);
        if not IntrastatReportSetup.Get() then begin
            IntrastatReportSetup.Init();
            IntrastatReportSetup.Insert(false, true);
        end;
        IntrastatReportSetup."No Item Charges in Int. CZ" := Rec."No Item Charges in Intrastat";
        IntrastatReportSetup."Transaction Type Mandatory CZ" := Rec."Transaction Type Mandatory";
        IntrastatReportSetup."Transaction Spec. Mandatory CZ" := Rec."Transaction Spec. Mandatory";
        IntrastatReportSetup."Transport Method Mandatory CZ" := Rec."Transport Method Mandatory";
        IntrastatReportSetup."Shipment Method Mandatory CZ" := Rec."Shipment Method Mandatory";
        IntrastatReportSetup."Intrastat Rounding Type CZ" := Enum::"Intrastat Rounding Type CZ".FromInteger(Rec."Intrastat Rounding Type");
        IntrastatReportSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Intrastat Report Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIntrastatReportSetup(var Rec: Record "Intrastat Report Setup")
    begin
        SyncIntrastatReportSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIntrastatReportSetup(var Rec: Record "Intrastat Report Setup")
    begin
        SyncIntrastatReportSetup(Rec);
    end;

    local procedure SyncIntrastatReportSetup(var Rec: Record "Intrastat Report Setup")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Intrastat Report Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert(false);
        end;
        StatutoryReportingSetupCZL."No Item Charges in Intrastat" := Rec."No Item Charges in Int. CZ";
        StatutoryReportingSetupCZL."Transaction Type Mandatory" := Rec."Transaction Type Mandatory CZ";
        StatutoryReportingSetupCZL."Transaction Spec. Mandatory" := Rec."Transaction Spec. Mandatory CZ";
        StatutoryReportingSetupCZL."Transport Method Mandatory" := Rec."Transport Method Mandatory CZ";
        StatutoryReportingSetupCZL."Shipment Method Mandatory" := Rec."Shipment Method Mandatory CZ";
        StatutoryReportingSetupCZL."Intrastat Rounding Type" := Rec."Intrastat Rounding Type CZ".AsInteger();
        StatutoryReportingSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
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