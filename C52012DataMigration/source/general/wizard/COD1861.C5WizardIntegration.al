// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1861 "C5 Wizard Integration"
{
    var
        C5DataMigrationMgt: Codeunit "C5 Data Migration Mgt.";
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        DataMigratorDescTxt: Label 'Import from Microsoft Dynamics C5 2012';
        Instructions1Txt: Label '1. Make sure the company you are importing to does not already contain customers, vendors, or items, if you want to import these entities.';
        Instructions2Txt: Label '2. Open Microsoft Dynamics C5 2012, and export your database. (General > Setup > Administration > Multi > Export Database).';
        Instructions3Txt: Label '3. Send the export folder to a compressed (zipped) folder.';
        Instructions4Txt: Label '4. Return to this assisted setup guide, choose Next, and then import the zipped folder.';
        ThatsItTxt: Label 'To check the status of the data migration, go to the %1 page.', Comment = '%1=Page Name';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnRegisterDataMigrator', '', true, true)]
    local procedure OnRegisterDataMigratorRegisterC5DataMigrator(var DataMigratorRegistration: Record "Data Migrator Registration")
    begin
        DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 250));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnGetInstructions', '', true, true)]
    local procedure OnGetInstructionsGetC5Instructions(var DataMigratorRegistration: Record "Data Migrator Registration";var Instructions: Text;var Handled: Boolean)
    var
        CRLF: Text[2];
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        Instructions := Instructions1Txt + CRLF + Instructions2Txt + CRLF + Instructions3Txt + CRLF + Instructions4Txt;
        SendTraceTag('00001K5', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), Verbosity::Normal, 'C5 Migration was selected.', DataClassification::SystemMetadata);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnDataImport', '', true, true)]
    local procedure OnDataImportImportC5Data(var DataMigratorRegistration: Record "Data Migrator Registration";var Handled: Boolean)
    begin
      if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
        exit;

      Handled := C5DataMigrationMgt.ImportC5Data();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnSelectDataToApply', '', true, true)]
    local procedure OnSelectDataToApplyCreateDataMigrationEntites(var DataMigratorRegistration: Record "Data Migrator Registration";var DataMigrationEntity: Record "Data Migration Entity";var Handled: Boolean)
    BEGIN
      IF DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() THEN
        EXIT;
      Handled := C5DataMigrationMgt.CreateDataMigrationEntites(DataMigrationEntity);
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnApplySelectedData', '', true, true)]
    local procedure OnApplySelectedDataApplyC5Data(var DataMigratorRegistration: Record "Data Migrator Registration";var DataMigrationEntity: Record "Data Migration Entity";var Handled: Boolean)
    begin
      if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
        exit;

      Handled := C5DataMigrationMgt.ApplySelectedData(DataMigrationEntity);

      SendTelemetryForSelectedEntities(DataMigrationEntity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnShowThatsItMessage', '', true, true)]
    local procedure OnShowThatsItMessageShowC5ThatsItMessage(var DataMigratorRegistration: Record "Data Migrator Registration";var Message: Text)
    var
      DataMigrationOverview: Page "Data Migration Overview";
    begin
      if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
        exit;

      Message := StrSubstNo(ThatsItTxt, DataMigrationOverview.Caption());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnEnableTogglingDataMigrationOverviewPage', '', true, true)]
    local procedure OnEnableTogglingDataMigrationOverviewPage(var DataMigratorRegistration: Record "Data Migrator Registration";var EnableTogglingOverviewPage: Boolean)
    begin
      if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
        exit;

      EnableTogglingOverviewPage := true;
    end;

    local procedure SendTelemetryForSelectedEntities(var DataMigrationEntity: Record "Data Migration Entity")
    var
      EntitiesToMigrateMessage: Text;
    begin
        DataMigrationEntity.SetRange(Selected, true);
        DataMigrationEntity.SetRange("Table ID", Database::Vendor);

        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('vendor: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Customer);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('customer: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::"G/L Account");
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('gl_acc: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Item);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('item: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::"C5 LedTrans");
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('C5_ledger_entries: %1; ', DataMigrationEntity."No. of Records");

        SendTraceTag('00001I1', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), Verbosity::Normal, EntitiesToMigrateMessage, DataClassification::SystemMetadata);
    end;

    local procedure GetCurrentCodeUnitNumber(): Integer
    begin;
      exit(codeunit::"C5 Wizard Integration");
    end;
}

