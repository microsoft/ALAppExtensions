codeunit 1918 "MigrationQB Data Loader"
{
    TableNo = "Data Migration Entity";

    trigger OnRun();
    begin
        FillStagingTables(Rec);
    end;

    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        StagingTablesImportStartMsg: Label 'Import to staging tables started.', Locked = true;
        StagingTablesImportFinishMsg: Label 'Import to staging tables finished; duration: %1', Locked = true;

    procedure FillStagingTables(var DataMigrationEntity: Record "Data Migration Entity")
    var
        ItemMigrator: Codeunit "MigrationQB Item Migrator";
        CustomerMigrator: Codeunit "MigrationQB Customer Migrator";
        VendorMigrator: Codeunit "MigrationQB Vendor Migrator";
        DurationAsInt: BigInteger;
        StartTime: DateTime;
        IsOnline: Boolean;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00001OC', StagingTablesImportStartMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());

        IsOnline := HelperFunctions.IsOnlineData();
        ItemMigrator.GetAll(IsOnline);
        CustomerMigrator.GetAll(IsOnline);
        VendorMigrator.GetAll(IsOnline);
        CleanupFiles();

        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00001OD', StrSubstNo(StagingTablesImportFinishMsg, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    procedure CleanupFiles()
    var
        MigrationQBConfig: Record "MigrationQB Config";
        FileManagement: Codeunit "File Management";
    begin
        if MigrationQBConfig.Get() then
            if not MigrationQBConfig.IsOnlineData() then begin
                FileManagement.ServerRemoveDirectory(MigrationQBConfig."Unziped Folder", true);
                FileManagement.DeleteServerFile(MigrationQBConfig."Zip File");
            end;
    end;
}
