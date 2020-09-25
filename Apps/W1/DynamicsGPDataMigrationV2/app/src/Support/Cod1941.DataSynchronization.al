codeunit 1941 "MigrationGP Data Sync"
{

    trigger OnRun();
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        SetupStatus: Option " ","Completed","In Progress","Error","Missing Permission";
    begin
        if AssistedCompanySetupStatus.Get(CompanyName()) then begin
            SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatus(CopyStr(CompanyName(), 1, 30));
            if SetupStatus = SetupStatus::Completed then
                InitiateGPMigration()
            else
                Session.LogMessage('000029K', CompanyFailedToMigrateMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
        end;
    end;

    var
        CompanyFailedToMigrateMsg: Label 'Migration did not start because the company setup is still in process.', Locked = true;

    local procedure InitiateGPMigration()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        Dimension: Record Dimension;
        DataMigrationStatus: Record "Data Migration Status";
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPCustomer: Record "MigrationGP Customer";
        MigrationGPVendor: Record "MigrationGP Vendor";
        MigrationGPItem: Record "MigrationGP Item";
        MigrationGPConfig: Record "MigrationGP Config";
        DimensionValue: Record "Dimension Value";
        PaymentTerms: Record "Payment Terms";
        PaymentTermTranslation: Record "Payment Term Translation";
        O365PaymentTerms: Record "O365 Payment Terms";
        ItemTrackingCode: Record "Item Tracking Code";
        MigrationGPMgt: Codeunit "MigrationGP Mgt";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        Flag: Boolean;
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::Existing;
        MigrationGPConfig."Post Transactions" := true;

        Flag := false;
        HelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
        if Flag then
            // If we updated the GL Setup table, we need to remember that so we can revert that change when migration is complete
            // See OnAfterMigrationFinishedSubscriber() method in codeunit 1934 
            MigrationGPConfig."Updated GL Setup" := true;
        MigrationGPConfig.Modify();

        HelperFunctions.CleanupBeforeSynchronization();
        DataMigrationEntity.DeleteAll();
        MigrationGPMgt.CreateDataMigrationEntites(DataMigrationEntity);

        if not Dimension.IsEmpty() then
            Dimension.DeleteAll();
        if not DimensionValue.IsEmpty() then
            DimensionValue.DeleteAll();
        HelperFunctions.CreateDimensions();

        if not PaymentTerms.IsEmpty() then
            PaymentTerms.DeleteAll();
        if not PaymentTermTranslation.IsEmpty() then
            PaymentTermTranslation.DeleteAll();
        if not O365PaymentTerms.IsEmpty() then
            O365PaymentTerms.DeleteAll();
        HelperFunctions.CreatePaymentTerms();

        if not ItemTrackingCode.IsEmpty() then
            ItemTrackingCode.DeleteAll();
        HelperFunctions.CreateItemTrackingCodes();

        DataMigrationStatus.Reset();
        DataMigrationStatus.SetRange("Migration Type", HelperFunctions.GetMigrationTypeTxt());
        if not DataMigrationStatus.IsEmpty() then
            DataMigrationStatus.DeleteAll();

        CreateDataMigrationStatusRecords(Database::"G/L Account", MigrationGPAccount.Count(), 1931, 1931);
        CreateDataMigrationStatusRecords(Database::"Customer", MigrationGPCustomer.Count(), 1932, 1932);
        CreateDataMigrationStatusRecords(Database::"Vendor", MigrationGPVendor.Count(), 1934, 1933);
        CreateDataMigrationStatusRecords(Database::"Item", MigrationGPItem.Count(), 1936, 1940);

        DataMigrationFacade.StartMigration(HelperFunctions.GetMigrationTypeTxt(), FALSE);
    end;

    local procedure CreateDataMigrationStatusRecords(DestinationTableID: Integer; NumberOfRecords: Integer; StagingTableID: Integer; CodeunitToRun: Integer)
    var
        DataMigrationStatus: Record "Data Migration Status";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        DataMigrationStatus.Init();
        DataMigrationStatus.Validate("Migration Type", HelperFunctions.GetMigrationTypeTxt());
        DataMigrationStatus.Validate("Destination Table ID", DestinationTableID);
        DataMigrationStatus.Validate("Total Number", NumberOfRecords);
        DataMigrationStatus.Validate(Status, DataMigrationStatus.Status::Pending);
        DataMigrationStatus.Validate("Source Staging Table ID", StagingTableID);
        DataMigrationStatus.Validate("Migration Codeunit To Run", CodeunitToRun);
        DataMigrationStatus.Insert()
    end;
}
