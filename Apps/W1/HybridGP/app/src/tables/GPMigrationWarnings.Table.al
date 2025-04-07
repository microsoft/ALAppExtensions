#pragma warning disable AA0247
table 41006 "GP Migration Warnings"
{
    Caption = 'GP Migration Warnings';
    DataPerCompany = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(3; "Migration Area"; Text[50])
        {
            Caption = 'Migration Area';
        }
        field(4; Context; Text[50])
        {
            Caption = 'Context';
        }
        field(5; "Warning Text"; Text[500])
        {
            Caption = 'Warning Text';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    procedure InsertWarning(MigrationArea: Text[50]; ContextValue: Text[50]; WarningText: Text[500])
    var
        GPMigrationWarnings: Record "GP Migration Warnings";
    begin
        GPMigrationWarnings."Company Name" := CopyStr(CompanyName(), 1, 30);
        GPMigrationWarnings."Migration Area" := MigrationArea;
        GPMigrationWarnings.Context := ContextValue;
        GPMigrationWarnings."Warning Text" := WarningText;
        GPMigrationWarnings.Insert();
    end;
}
