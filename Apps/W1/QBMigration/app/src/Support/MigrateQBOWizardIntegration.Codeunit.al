codeunit 1830 "MigrateQBO Wizard Integration"
{
    var
        MigrationQBMgt: Codeunit "MigrationQB Mgt";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        DataMigratorDescTxt: Label 'Import from QuickBooks Online';
        Instruction1Txt: Label '1) Choose Next button to be prompted to sign into QuickBooks Online.';
        Instruction2Txt: Label '2) Enter credentials to sign into QuickBooks.';
        Instruction3Txt: Label '3) Choose the QuickBooks company to import data from, and then choose Authorize.';
        ThatsItTxt: Label 'To check the status of the data migration, go to the %1 page.', Comment = '%1=Page Name';
        MigrationNotSupportedErr: Label 'This migration does not support the "Specific" costing method. Verify your costing method in Inventory Setup.';
        QBSelectedTxt: Label 'QBO Migration was selected.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnRegisterDataMigrator', '', true, true)]
    local procedure OnRegisterDataMigratorRegisterQBDataMigrator(var DataMigratorRegistration: Record "Data Migrator Registration")
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsSaaS() then
            DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 50));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnGetInstructions', '', true, true)]
    local procedure OnGetInstructionsGetQBInstructions(var DataMigratorRegistration: Record "Data Migrator Registration"; var Instructions: Text; var Handled: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
        CRLF: Text[2];
        CostingMethod: Option FIFO,LIFO,Specific,Average,Standard;
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        if InventorySetup.Get() then
            if InventorySetup."Default Costing Method" = CostingMethod::Specific then
                Error(MigrationNotSupportedErr);

        Instructions := Instruction1Txt + CRLF + Instruction2Txt + CRLF + Instruction3Txt;
        Session.LogMessage('00001O9', QBSelectedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());

        Handled := true;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Data Migrator Registration", 'OnValidateSettings', '', true, true)]
    local procedure ValidateSettings(var Sender: Record "Data Migrator Registration")
    begin
        if Sender."No." <> GetCurrentCodeUnitNumber() then
            exit;

        MigrationQBMgt.ResetConfigTable();
        RunAlternateDialogs();
        Commit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnDataImport', '', true, true)]
    local procedure OnDataImportImportQBData(var DataMigratorRegistration: Record "Data Migrator Registration"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnSelectDataToApply', '', true, true)]
    local procedure OnSelectDataToApplyCreateDataMigrationEntites(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Handled := MigrationQBMgt.CreateDataMigrationEntites(DataMigrationEntity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnApplySelectedData', '', true, true)]
    local procedure OnApplySelectedDataApplyQBData(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        HelperFunctions.CleanupGenJournalBatches();
        HelperFunctions.CleanupVatPostingSetup();
        Commit();
        MigrationQBMgt.ApplySelectedData(DataMigrationEntity);
        SendTelemetryForSelectedEntities(DataMigrationEntity);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnShowThatsItMessage', '', true, true)]
    local procedure OnShowThatsItMessageShowQBThatsItMessage(var DataMigratorRegistration: Record "Data Migrator Registration"; var Message: Text)
    var
        DataMigrationOverview: Page "Data Migration Overview";
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Message := StrSubstNo(ThatsItTxt, DataMigrationOverview.Caption());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnEnableTogglingDataMigrationOverviewPage', '', true, true)]
    local procedure OnEnableTogglingDataMigrationOverviewPage(var DataMigratorRegistration: Record "Data Migrator Registration"; var EnableTogglingOverviewPage: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        EnableTogglingOverviewPage := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Migrator Registration", 'OnHideSelected', '', true, true)]
    local procedure HideSelectedCheckBoxes(var Sender: Record "Data Migrator Registration"; var HideSelectedCheckBoxes: Boolean);
    begin
        if Sender."No." <> GetCurrentCodeUnitNumber() then
            exit;

        HideSelectedCheckBoxes := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", 'OnAfterMigrationFinished', '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    begin
        Codeunit.Run(Codeunit::"Categ. Generate Acc. Schedules");
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

        Session.LogMessage('00001OA', EntitiesToMigrateMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    local procedure GetCurrentCodeUnitNumber(): Integer
    begin
        ;
        exit(codeunit::"MigrateQBO Wizard Integration");
    end;

    local procedure RunAlternateDialogs(): Boolean
    begin
        if Page.RunModal(1830) = "Action"::OK then
            exit(true);

        exit(false);
    end;
}
