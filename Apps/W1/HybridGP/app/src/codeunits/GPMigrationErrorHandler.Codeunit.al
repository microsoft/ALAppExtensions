codeunit 40112 "GP Migration Error Handler"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateErrorOverviewOnInsert(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    begin
        UpdateErrorOverview(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateErrorOverviewOnModify(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    begin
        UpdateErrorOverview(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateErrorOverviewOnDelete(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
    begin
        ErrorOccured := true;
        if GPMigrationErrorOverview.Get(Rec.Id, CompanyName()) then begin
            GPMigrationErrorOverview."Error Dismissed" := true;
            GPMigrationErrorOverview.Modify();
        end;
    end;

    local procedure UpdateErrorOverview(var DataMigrationError: Record "Data Migration Error")
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
        Exists: Boolean;
    begin
        ErrorOccured := true;
        GPMigrationErrorOverview.ReadIsolation := IsolationLevel::ReadUncommitted;
        Exists := GPMigrationErrorOverview.Get(DataMigrationError.Id, CompanyName());
        if not Exists then begin
            GPMigrationErrorOverview.Id := DataMigrationError.Id;
            GPMigrationErrorOverview."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(GPMigrationErrorOverview."Company Name"));
            GPMigrationErrorOverview.Insert();
        end;

        GPMigrationErrorOverview.TransferFields(DataMigrationError);
        GPMigrationErrorOverview.SetFullExceptionMessage(DataMigrationError.GetFullExceptionMessage());
        GPMigrationErrorOverview.SetLastRecordUnderProcessingLog(DataMigrationError.GetLastRecordsUnderProcessingLog());
        GPMigrationErrorOverview.SetExceptionCallStack(DataMigrationError.GetExceptionCallStack());
        GPMigrationErrorOverview.Modify();
    end;

    procedure ClearErrorOccured()
    begin
        Clear(ErrorOccured);
    end;

    procedure GetErrorOccured(): Boolean
    begin
        exit(ErrorOccured);
    end;

    internal procedure ErrorOccuredDuringLastUpgrade(): Boolean
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
        GPUpgradeSettings: Record "GP Upgrade Settings";
    begin
        GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
        GPMigrationErrorOverview.SetRange("Company Name", CompanyName());
        GPMigrationErrorOverview.SetFilter(SystemModifiedAt, '>%1', GPUpgradeSettings."Data Upgrade Started");
        exit(not GPMigrationErrorOverview.IsEmpty());
    end;

    var
        ErrorOccured: Boolean;
}