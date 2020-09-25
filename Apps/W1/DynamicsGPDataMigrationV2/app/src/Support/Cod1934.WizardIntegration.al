codeunit 1934 "MigrationGP Wizard Integration"
{
    var
        MigrationGPMgt: Codeunit "MigrationGP Mgt";
        DataMigratorDescTxt: Label 'Import from Dynamics GP';
        GPDInstruction1Txt: Label '1. In Dynamics GP, from the File menu, choose Maintenance, and then Export Data.';
        GPDInstruction2Txt: Label '2. Choose the records to export, and then save the file.';
        GPDInstruction3Txt: Label '3. In %1, return to this guide and continue.', Comment = '%1=Product Name Short';
        ThatsItTxt: Label 'To check the status of the data migration, go to the %1 page.', Comment = '%1=Page Name';
        GPSelectedTxt: Label 'GP Migration was selected.';
        SupportedGPVersionsTxt: Label 'Note: The export data feature is available in the following\ versions and builds of Dynamics GP and later:\\- Dynamics GP 2018, build 18.00.0483\- Dynamics GP 2016, build 16.00.0720\- Dynamics GP 2015, build 14.00.1136', Locked = true;
        UsingNewFormatTxt: Label 'Using new Account Format.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnRegisterDataMigrator', '', true, true)]
    local procedure OnRegisterDataMigratorRegisterGPDataMigrator(var DataMigratorRegistration: Record "Data Migrator Registration")
    var
        MigrationGPConfig: Record "MigrationGP Config";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsSaaS() then begin
            DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 250));
            MigrationGPConfig.Reset();
            MigrationGPConfig.DeleteAll();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnGetInstructions', '', true, true)]
    local procedure OnGetInstructionsGetGPInstructions(var DataMigratorRegistration: Record "Data Migrator Registration"; var Instructions: Text; var Handled: Boolean)
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        CRLF: Text[2];
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        if HelperFunctions.RunPreMigrationChecks() then begin
            Instructions := GPDInstruction1Txt + CRLF + GPDInstruction2Txt + CRLF + StrSubstNo(GPDInstruction3Txt, ProductName.Short());
            Instructions := Instructions + CRLF + CRLF + CRLF + CRLF + SupportedGPVersionsTxt;
            Session.LogMessage('00001O9', GPSelectedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnSelectDataToApply', '', true, true)]
    local procedure OnSelectDataToApplyCreateDataMigrationEntites(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Handled := MigrationGPMgt.CreateDataMigrationEntites(DataMigrationEntity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnApplySelectedData', '', true, true)]
    local procedure OnApplySelectedDataApplyGPData(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        HelperFunctions.CleanupGenJournalBatches();
        HelperFunctions.CleanupVatPostingSetup();
        Commit();
        MigrationGPMgt.ApplySelectedData(DataMigrationEntity);
        SendTelemetryForSelectedEntities(DataMigrationEntity);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnShowThatsItMessage', '', true, true)]
    local procedure OnShowThatsItMessageShowGPThatsItMessage(var DataMigratorRegistration: Record "Data Migrator Registration"; var Message: Text)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnDataImport', '', true, true)]
    local procedure OnDataImportImportGPData(var DataMigratorRegistration: Record "Data Migrator Registration"; var Handled: Boolean)
    var
        MigrationGPConfig: Record "MigrationGP Config";
        AccountMigrator: Codeunit "MigrationGP Account Migrator";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Handled := RunAccountOptionDialog();
        if Handled = false then
            exit;

        if MigrationGPMgt.ImportGPData() then begin
            AccountMigrator.GetAll();
            Commit();
        end else begin
            AccountMigrator.DeleteAll();
            Handled := false;
            exit;
        end;

        If HelperFunctions.IsUsingNewAccountFormat() then begin
            Session.LogMessage('00007GG', UsingNewFormatTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            Page.RunModal(1940);
            MigrationGPConfig.GetSingleInstance();
            Handled := not MigrationGPConfig.GetAccountValidationError();
        end else
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnHideSelected', '', true, true)]
    local procedure HideSelectedCheckBoxes(var Sender: Record "Data Migrator Registration"; var HideSelectedCheckBoxes: Boolean);
    begin
        if Sender."No." <> GetCurrentCodeUnitNumber() then
            exit;

        HideSelectedCheckBoxes := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1798, 'OnAfterMigrationFinished', '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        MigrationGPConfig: Record "MigrationGP Config";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        DataSyncStatus: Page "Data Sync Status";
        Flag: Boolean;
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        Codeunit.Run(571);
        if MigrationGPConfig.Get() then begin
            if MigrationGPConfig."Updated GL Setup" then begin
                Flag := true;
                HelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
            end;

            if MigrationGPConfig."Post Transactions" then begin
                DataSyncStatus.ParsePosting();
                HelperFunctions.PostGLTransactions();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnMigrationCompleted', '', false, false)]
    local procedure OnAllStepsCompletedSubscriber(DataMigrationStatus: Record "Data Migration Status")
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        if DataMigrationStatus.Status = DataMigrationStatus.Status::Completed then
            HelperFunctions.Cleanup();
    end;

    local procedure SendTelemetryForSelectedEntities(var DataMigrationEntity: Record "Data Migration Entity")
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
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
        exit(codeunit::"MigrationGP Wizard Integration");
    end;

    local procedure RunAccountOptionDialog(): Boolean
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        Commit();
        if Page.RunModal(1937) = "Action"::OK then begin
            MigrationGPConfig.GetSingleInstance();
            if MigrationGPConfig."Chart of Account Option" = MigrationGPConfig."Chart of Account Option"::" " then
                exit(false)
            else
                exit(true);
        end;

        exit(false);
    end;
}