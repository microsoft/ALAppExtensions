// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1860 "C5 Data Migration Mgt."
{
    var
        DataMigratorDescTxt: Label 'Import from Microsoft Dynamics C5 2012';
        C5FileExtensionTok: Label '*.zip', Locked = true;
        C5FileExtensionFilterTxt: Label '.zip', Locked = true;
        C5FileTypeTxt: Label 'Zip Files (*.zip)|*.zip';
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';
        AccountsNotSelectedQst: Label 'You are about to migrate data for one or more entities without migrating general ledger accounts. If you continue, transactions for the entities will not be migrated. To migrate transactions, you must migrate general ledger accounts. Do you want to continue without general ledger accounts?';

    procedure ImportC5Data(): Boolean
    var
        C5SchemaParameters: Record "C5 Schema Parameters" temporary;
        FileManagement: Codeunit "File Management";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        ServerFile: Text;
    begin
        ServerFile := CopyStr(FileManagement.UploadFileWithFilter(
            CopyStr(DataMigratorDescTxt, 1, 50),
            C5FileExtensionTok,
            C5FileTypeTxt,
            C5FileExtensionFilterTxt), 1, MaxStrLen(ServerFile));
        if (ServerFile = '') then
            exit(false);
        if not FileManagement.ServerFileExists(ServerFile) then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;

        C5SchemaParameters.Init();
        C5SchemaParameters."Zip File" := CopyStr(ServerFile, 1, 250);
        C5SchemaParameters.Insert();

        // Trying to process ZIP file and clean up in case of an error.
        if not Codeunit.Run(Codeunit::"C5 Schema Reader", C5SchemaParameters) then begin
            C5HelperFunctions.CleanupFiles();
            Error(GetLastErrorText());
        end;

        exit(true);
    end;

    procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity") :Boolean
    var
        C5SchemaReader: Codeunit "C5 Schema Reader";
    begin
        DataMigrationEntity.InsertRecord(Database::Customer, C5SchemaReader.GetNumberOfCustomers());
        DataMigrationEntity.InsertRecord(Database::Vendor, C5SchemaReader.GetNumberOfVendors());
        DataMigrationEntity.InsertRecord(Database::Item, C5SchemaReader.GetNumberOfItems());
        DataMigrationEntity.InsertRecord(Database::"G/L Account", C5SchemaReader.GetNumberOfAccounts());
        DataMigrationEntity.InsertRecord(Database::"C5 LedTrans", C5SchemaReader.GetNumberOfHistoricalEntries());
        exit(true);
    end;

    procedure ApplySelectedData(var DataMigrationEntity: Record "Data Migration Entity") :Boolean
    var
        DataMigrationStatus: Record "Data Migration Status";
        GeneralLedgerSetup:Record "General Ledger Setup";
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        VendorsToMigrateNb: Integer;
        CustomersToMigrateNb: Integer;
        ItemsToMigrateNb: Integer;
        ChartOfAccountToMigrateNb: Integer;
        LegacyEntriesToMigrateNb: Integer;
    begin
            
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

        if DataMigrationEntity.Get(Database::"C5 LedTrans") then
            if DataMigrationEntity.Selected then
                LegacyEntriesToMigrateNb := DataMigrationEntity."No. of Records";

        if (ChartOfAccountToMigrateNb = 0) and not DataMigrationStatus.Get(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), Database::"G/L Account") then
            if (ItemsToMigrateNb + CustomersToMigrateNb + VendorsToMigrateNb > 0) then
                if not Confirm(AccountsNotSelectedQst) then
                    exit(false);

        with GeneralLedgerSetup do begin
            if not Get() then begin
                Init();
                Insert();
            end;

            if ("LCY Code" = '') or (LegacyEntriesToMigrateNb > 0) then
                Page.RunModal(Page::"C5 Company Settings");
        end;

        C5MigrDashboardMgt.InitMigrationStatus(ItemsToMigrateNb, CustomersToMigrateNb, VendorsToMigrateNb, ChartOfAccountToMigrateNb, LegacyEntriesToMigrateNb);

        // run the actual migration in a background session
        if ItemsToMigrateNb + CustomersToMigrateNb + VendorsToMigrateNb + ChartOfAccountToMigrateNb + LegacyEntriesToMigrateNb > 0 then
            DataMigrationFacade.StartMigration(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), FALSE);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnZipFileMissing()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Data Migration Mgt.", 'OnZipFileMissing', '', false, false)] 
    local procedure OnZipFileMissingSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DC', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, ZipFileMissingErrorTxt, DataClassification::SystemMetadata);
    end;
}

