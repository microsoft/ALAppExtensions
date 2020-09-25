codeunit 1938 "MigrationGP Data Loader"
{
    TableNo = "Data Migration Entity";

    trigger OnRun();
    begin
        FillStagingTables(Rec);
    end;

    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        StagingTablesImportStartMsg: Label 'File import to staging tables started.', Locked = true;
        StagingTablesImportFinishMsg: Label 'File import to staging tables finished; duration: %1', Locked = true;

    procedure FillStagingTables(var DataMigrationEntity: Record "Data Migration Entity")
    var
        ItemMigrator: Codeunit "MigrationGP Item Migrator";
        CustomerMigrator: Codeunit "MigrationGP Customer Migrator";
        VendorMigrator: Codeunit "MigrationGP Vendor Migrator";
        DurationAsInt: BigInteger;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00001OC', StagingTablesImportStartMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());

        ItemMigrator.GetAll();
        CustomerMigrator.GetAll();
        VendorMigrator.GetAll();
        CleanupFiles();

        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00001OD', StrSubstNo(StagingTablesImportFinishMsg, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    procedure CleanupFiles()
    var
        MigrationGPConfig: Record "MigrationGP Config";
        FileManagement: Codeunit "File Management";
    begin
        if MigrationGPConfig.Get() then begin
            FileManagement.ServerRemoveDirectory(MigrationGPConfig."Unziped Folder", true);
            FileManagement.DeleteServerFile(MigrationGPConfig."Zip File");
        end;
    end;

}
