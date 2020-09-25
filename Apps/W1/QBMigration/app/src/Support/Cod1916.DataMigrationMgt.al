codeunit 1916 "MigrationQB Mgt"
{
    var
        DataMigratorDescTxt: Label 'Import from QuickBooks';
        FileExtensionTok: Label '*.zip', Locked = true;
        FileExtensionFilterTxt: Label '.zip', Locked = true;
        FileTypeTxt: Label 'Zip Files (*.zip)|*.zip', Locked = true;
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';

    procedure ImportQBData(): Boolean
    var
        MigrationQBConfig: Record "MigrationQB Config" temporary;
        FileManagement: Codeunit "File Management";
        MigrationQBDataLoader: Codeunit "MigrationQB Data Loader";
        ServerFile: Text;
    begin
        ServerFile := CopyStr(FileManagement.UploadFileWithFilter(CopyStr(DataMigratorDescTxt, 1, 50), FileExtensionTok, FileTypeTxt, FileExtensionFilterTxt), 1, MaxStrLen(ServerFile));
        if (ServerFile = '') then
            exit(false);
        if not FileManagement.ServerFileExists(ServerFile) then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;
        MigrationQBConfig.Init();
        MigrationQBConfig."Zip File" := CopyStr(ServerFile, 1, 250);
        MigrationQBConfig.Insert();

        // Trying to process ZIP file and clean up in case of an error.
        if not Codeunit.Run(Codeunit::"MigrationQB Data Reader", MigrationQBConfig) then begin
            MigrationQBDataLoader.CleanupFiles();
            Error(GetLastErrorText());
        end;

        exit(true);
    end;

    procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        MigrationQBDataReader: Codeunit "MigrationQB Data Reader";
    begin
        DataMigrationEntity.InsertRecord(Database::"G/L Account", MigrationQBDataReader.GetNumberOfAccounts());
        DataMigrationEntity.InsertRecord(Database::Customer, MigrationQBDataReader.GetNumberOfCustomers());
        DataMigrationEntity.InsertRecord(Database::Vendor, MigrationQBDataReader.GetNumberOfVendors());
        DataMigrationEntity.InsertRecord(Database::Item, MigrationQBDataReader.GetNumberOfItems());
        exit(true);
    end;

    procedure ApplySelectedData(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        MigrationQBDashboardMgt: Codeunit "MigrationQB Dashboard Mgt";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        MigrationQBDataLoader: Codeunit "MigrationQB Data Loader";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        VendorsToMigrateNb: Integer;
        CustomersToMigrateNb: Integer;
        ItemsToMigrateNb: Integer;
        ChartOfAccountToMigrateNb: Integer;
        ErrorMsg: Text;
    begin
        // Try to process data files and delete them in case of error.
        if not Codeunit.Run(Codeunit::"MigrationQB Data Loader", DataMigrationEntity) then begin
            ErrorMsg := GetLastErrorText();
            MigrationQBDataLoader.CleanupFiles();
            Error(ErrorMsg);
        end;

        if DataMigrationEntity.Get(Database::Vendor) then
            if DataMigrationEntity.Selected then
                VendorsToMigrateNb := DataMigrationEntity."No. of Records";

        if DataMigrationEntity.Get(Database::Customer) then
            if DataMigrationEntity.Selected then
                CustomersToMigrateNb := DataMigrationEntity."No. of Records";

        if DataMigrationEntity.Get(Database::Item) then
            if DataMigrationEntity.Selected then
                ItemsToMigrateNb := DataMigrationEntity."No. of Records";

        if DataMigrationEntity.Get(Database::"G/L Account") then
            if DataMigrationEntity.Selected then
                ChartOfAccountToMigrateNb := DataMigrationEntity."No. of Records";

        MigrationQBDashboardMgt.InitMigrationStatus(ItemsToMigrateNb, CustomersToMigrateNb, VendorsToMigrateNb, ChartOfAccountToMigrateNb);
        // commit the dashboard changes so the OnRun call on the migration codeunit will not fail because of this uncommited transaction
        Commit();

        if (ItemsToMigrateNb + CustomersToMigrateNb + VendorsToMigrateNb + ChartOfAccountToMigrateNb > 0) then
            DataMigrationFacade.StartMigration(HelperFunctions.GetMigrationTypeTxt(), false);

        exit(true);
    end;

    procedure ResetConfigTable()
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.DeleteAll();
        Commit();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnZipFileMissing()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationQB Mgt", 'OnZipFileMissing', '', false, false)]
    local procedure OnZipFileMissingSubscriber()
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        Session.LogMessage('00001OB', ZipFileMissingErrorTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;
}

