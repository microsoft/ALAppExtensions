table 4024 "GP Configuration"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Updated GL Setup"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "GL Transactions Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Account Validation Error"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Finish Event Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Last Error Message"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(7; "PreMigration Cleanup Completed"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(8; "Dimensions Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(9; "Payment Terms Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(10; "Item Tracking Codes Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(11; "Locations Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(12; "CheckBooks Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(13; "Open Purchase Orders Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
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
}