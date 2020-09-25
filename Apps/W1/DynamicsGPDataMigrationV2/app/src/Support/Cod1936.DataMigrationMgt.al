codeunit 1936 "MigrationGP Mgt"
{
    var
        DataMigratorDescTxt: Label 'Import from Dynamics GP';
        FileExtensionTok: Label '*.zip', Locked = true;
        FileExtensionFilterTxt: Label '.zip', Locked = true;
        FileTypeTxt: Label 'Zip Files (*.zip)|*.zip', Locked = true;
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';

    procedure ImportGPData(): Boolean
    var
        MigrationGPConfig: Record "MigrationGP Config" temporary;
        FileManagement: Codeunit "File Management";
        MigrationGPDataLoader: Codeunit "MigrationGP Data Loader";
        ServerFile: Text;
        ErrorMsg: Text;
    begin
        ServerFile := CopyStr(FileManagement.UploadFileWithFilter(CopyStr(DataMigratorDescTxt, 1, 50), FileExtensionTok, FileTypeTxt, FileExtensionFilterTxt), 1, MaxStrLen(ServerFile));
        if (ServerFile = '') then
            exit(false);
        if not FileManagement.ServerFileExists(ServerFile) then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;
        MigrationGPConfig.Init();
        MigrationGPConfig."Zip File" := CopyStr(ServerFile, 1, 250);
        if not MigrationGPConfig.Insert() then
            LogInternalError('Could not create the record', DataClassification::SystemMetadata, Verbosity::Error);

        // Trying to process ZIP file and clean up in case of an error.
        if not Codeunit.Run(Codeunit::"MigrationGP Data Reader", MigrationGPConfig) then begin
            ErrorMsg := GetLastErrorText();
            MigrationGPDataLoader.CleanupFiles();
            LogInternalError(ErrorMsg, DataClassification::CustomerContent, Verbosity::Error);
        end;

        exit(true);
    end;

    procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        MigrationGPDataReader: Codeunit "MigrationGP Data Reader";
    begin
        DataMigrationEntity.InsertRecord(Database::"G/L Account", MigrationGPDataReader.GetNumberOfAccounts());
        DataMigrationEntity.InsertRecord(Database::Customer, MigrationGPDataReader.GetNumberOfCustomers());
        DataMigrationEntity.InsertRecord(Database::Vendor, MigrationGPDataReader.GetNumberOfVendors());
        DataMigrationEntity.InsertRecord(Database::Item, MigrationGPDataReader.GetNumberOfItems());
        exit(true);
    end;

    procedure ApplySelectedData(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        MigrationGPConfig: Record "MigrationGP Config";
        MigrationGPDashboardMgt: Codeunit "MigrationGP Dashboard Mgt";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        MigrationGPDataLoader: Codeunit "MigrationGP Data Loader";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        VendorsToMigrateNb: Integer;
        CustomersToMigrateNb: Integer;
        ItemsToMigrateNb: Integer;
        ChartOfAccountToMigrateNb: Integer;
        Flag: boolean;
    begin
        // Try to process data files and delete them in case of error.
        if not Codeunit.Run(Codeunit::"MigrationGP Data Loader", DataMigrationEntity) then begin
            MigrationGPDataLoader.CleanupFiles();
            LogInternalError(GetLastErrorText(), DataClassification::CustomerContent, Verbosity::Error);
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

        MigrationGPDashboardMgt.InitMigrationStatus(ItemsToMigrateNb, CustomersToMigrateNb, VendorsToMigrateNb, ChartOfAccountToMigrateNb);
        Commit(); // commit the dashboard changes so the OnRun call on the migration codeunit will not fail because of this uncommited transaction

        // run the actual migration in a background session
        if ItemsToMigrateNb + CustomersToMigrateNb + VendorsToMigrateNb + ChartOfAccountToMigrateNb > 0 then begin
            Flag := false;
            HelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
            if Flag then begin
                // If we updated the GL Setup table, we need to remember that so we can revert that change when migration is complete
                // See OnAfterMigrationFinishedSubscriber() method in codeunit 1934 
                MigrationGPConfig.GetSingleInstance();
                MigrationGPConfig."Updated GL Setup" := true;
                MigrationGPConfig.Modify();
            end;

            // Need to create the dimensions and their values if using the existing chart of accounts
            if not HelperFunctions.IsUsingNewAccountFormat() then
                HelperFunctions.CreateDimensions();

            DataMigrationFacade.StartMigration(HelperFunctions.GetMigrationTypeTxt(), FALSE);
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnZipFileMissing()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationGP Mgt", 'OnZipFileMissing', '', false, false)]
    local procedure OnZipFileMissingSubscriber()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        Session.LogMessage('00001OB', ZipFileMissingErrorTxt, Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;
}

