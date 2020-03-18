table 1937 "MigrationGP Config"
{
    ReplicateData = false;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Zip File"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Unziped Folder"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Total Items"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Total Accounts"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Total Customers"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(7; "Total Vendors"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Chart of Account Option"; Option)
        {
            OptionMembers = " ",Existing,New;
            DataClassification = SystemMetadata;
        }
        field(9; "Updated GL Setup"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "GL Transactions Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Account Validation Error"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Post Transactions"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(14; "Finish Event Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Dummy)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    procedure SetAccountValidationError();
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."Account Validation Error" := true;
        MigrationGPConfig.Modify();
    end;

    procedure ClearAccountValidationError();
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."Account Validation Error" := false;
        MigrationGPConfig.Modify();
    end;

    procedure GetAccountValidationError(): Boolean;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."Account Validation Error");
    end;
}