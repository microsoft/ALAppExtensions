namespace Microsoft.DataMigration.BC;

codeunit 4024 "Hybrid BC Last Upgrade"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin
        W1Management.BeforePerCompanyUpgrade();
    end;

    trigger OnCheckPreconditionsPerDatabase()
    begin
        W1Management.BeforePerDatabaseUpgrade();
    end;

    trigger OnValidateUpgradePerDatabase()
    begin
        W1Management.UpdateStatusRecordsAfterUpgradePerDatabase();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        W1Management.UpdateStatusRecordsAfterUpgradePerCompany();
    end;

    trigger OnUpgradePerDatabase();
    begin
        OnAfterW1Upgrade();
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterW1Upgrade()
    begin
    end;

    var
        W1Management: Codeunit "W1 Management";
}