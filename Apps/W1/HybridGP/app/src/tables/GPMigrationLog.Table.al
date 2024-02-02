table 41006 "GP Migration Log"
{
    Caption = 'GP Migration Log';
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
        field(5; "Log Text"; Text[500])
        {
            Caption = 'Log Text';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    procedure InsertLog(MigrationArea: Text[50]; ContextValue: Text[50]; LogText: Text[500])
    var
        GPMigrationLog: Record "GP Migration Log";
    begin
        GPMigrationLog."Company Name" := CopyStr(CompanyName(), 1, 30);
        GPMigrationLog."Migration Area" := MigrationArea;
        GPMigrationLog.Context := ContextValue;
        GPMigrationLog."Log Text" := LogText;
        GPMigrationLog.Insert();
    end;
}