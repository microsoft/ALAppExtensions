#if not CLEAN18
#pragma warning disable AL0432, AL0603
codeunit 31117 "Sync.Dep.Fld-StatRepSetup CZL"
{
    Permissions = tabledata "Stat. Reporting Setup" = rimd,
                  tabledata "Statutory Reporting Setup CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Stat. Reporting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    begin
        SyncStatReportingSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stat. Reporting Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    begin
        SyncStatReportingSetup(Rec);
    end;

    local procedure SyncStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stat. Reporting Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get(Rec."Primary Key") then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL."Primary Key" := Rec."Primary Key";
            StatutoryReportingSetupCZL.SystemId := Rec.SystemId;
            StatutoryReportingSetupCZL.Insert(false, true);
        end;
        StatutoryReportingSetupCZL."Transaction Type Mandatory" := Rec."Transaction Type Mandatory";
        StatutoryReportingSetupCZL."Transaction Spec. Mandatory" := Rec."Transaction Spec. Mandatory";
        StatutoryReportingSetupCZL."Transport Method Mandatory" := Rec."Transport Method Mandatory";
        StatutoryReportingSetupCZL."Shipment Method Mandatory" := Rec."Shipment Method Mandatory";
        StatutoryReportingSetupCZL."Tariff No. Mandatory" := Rec."Tariff No. Mandatory";
        StatutoryReportingSetupCZL."Net Weight Mandatory" := Rec."Net Weight Mandatory";
        StatutoryReportingSetupCZL."Country/Region of Origin Mand." := Rec."Country/Region of Origin Mand.";
        StatutoryReportingSetupCZL."Get Tariff No. From" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Tariff No. From");
        StatutoryReportingSetupCZL."Get Net Weight From" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Net Weight From");
        StatutoryReportingSetupCZL."Get Country/Region of Origin" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Country/Region of Origin");
        StatutoryReportingSetupCZL."Intrastat Rounding Type" := Rec."Intrastat Rounding Type";
        StatutoryReportingSetupCZL."No Item Charges in Intrastat" := Rec."No Item Charges in Intrastat";
        StatutoryReportingSetupCZL."Intrastat Declaration Nos." := Rec."Intrastat Declaration Nos.";
        StatutoryReportingSetupCZL."Stat. Value Reporting" := Rec."Stat. Value Reporting";
        StatutoryReportingSetupCZL."Cost Regulation %" := Rec."Cost Regulation %";
        StatutoryReportingSetupCZL."Include other Period add.Costs" := Rec."Include other Period add.Costs";
        StatutoryReportingSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
    end;

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
        StatReportingSetup: Record "Stat. Reporting Setup";
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statutory Reporting Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stat. Reporting Setup");
        StatReportingSetup.ChangeCompany(Rec.CurrentCompany);
        if not StatReportingSetup.Get(Rec."Primary Key") then begin
            StatReportingSetup.Init();
            StatReportingSetup."Primary Key" := Rec."Primary Key";
            StatReportingSetup.SystemId := Rec.SystemId;
            StatReportingSetup.Insert(false, true);
        end;
        StatReportingSetup."Transaction Type Mandatory" := Rec."Transaction Type Mandatory";
        StatReportingSetup."Transaction Spec. Mandatory" := Rec."Transaction Spec. Mandatory";
        StatReportingSetup."Transport Method Mandatory" := Rec."Transport Method Mandatory";
        StatReportingSetup."Shipment Method Mandatory" := Rec."Shipment Method Mandatory";
        StatReportingSetup."Tariff No. Mandatory" := Rec."Tariff No. Mandatory";
        StatReportingSetup."Net Weight Mandatory" := Rec."Net Weight Mandatory";
        StatReportingSetup."Country/Region of Origin Mand." := Rec."Country/Region of Origin Mand.";
        StatReportingSetup."Get Tariff No. From" := Rec."Get Tariff No. From".AsInteger();
        StatReportingSetup."Get Net Weight From" := Rec."Get Net Weight From".AsInteger();
        StatReportingSetup."Get Country/Region of Origin" := Rec."Get Country/Region of Origin".AsInteger();
        StatReportingSetup."Intrastat Rounding Type" := Rec."Intrastat Rounding Type";
        StatReportingSetup."No Item Charges in Intrastat" := Rec."No Item Charges in Intrastat";
        StatReportingSetup."Intrastat Declaration Nos." := Rec."Intrastat Declaration Nos.";
        StatReportingSetup."Stat. Value Reporting" := Rec."Stat. Value Reporting";
        StatReportingSetup."Cost Regulation %" := Rec."Cost Regulation %";
        StatReportingSetup."Include other Period add.Costs" := Rec."Include other Period add.Costs";
        StatReportingSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stat. Reporting Setup");

        UnbindSubscription(SyncLoopingHelper);
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Information");
        CompanyInformation.ChangeCompany(Rec.CurrentCompany);
        if not CompanyInformation.Get() then begin
            CompanyInformation.Init();
            CompanyInformation.Insert();
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Information");

        UnbindSubscription(SyncLoopingHelper);
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"General Ledger Setup");
        GeneralLedgerSetup.ChangeCompany(Rec.CurrentCompany);
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert();
        end;
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"General Ledger Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif