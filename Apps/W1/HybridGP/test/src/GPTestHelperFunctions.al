codeunit 139700 "GP Test Helper Functions"
{
    procedure InitializeMigration()
    var
        GPCloudMigration: Codeunit "GP Cloud Migration";
    begin
        GPCloudMigration.InitializeForTesting();
    end;

    procedure MigrationConfiguredForTable(TableNo: Integer): Boolean
    var
        DataMigrationEntity: Record "Data Migration Entity";
    begin
        DataMigrationEntity.SetRange("Table ID", TableNo);
        exit(DataMigrationEntity.FindFirst());
    end;

    procedure CreateConfigurationSettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        CompanyNameText: Text[30];
    begin
        CompanyNameText := CompanyName();

        if not GPCompanyMigrationSettings.Get(CompanyNameText) then begin
            GPCompanyMigrationSettings.Name := CompanyNameText;
            GPCompanyMigrationSettings.Insert(true);
        end;

        if not GPCompanyAdditionalSettings.Get(CompanyNameText) then begin
            GPCompanyAdditionalSettings.Name := CompanyNameText;
            GPCompanyAdditionalSettings.Insert(true);
        end;
    end;

    procedure DeleteAllSettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        GPCompanyMigrationSettings.DeleteAll();
        GPCompanyAdditionalSettings.DeleteAll();
    end;
}