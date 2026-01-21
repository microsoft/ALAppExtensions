namespace Microsoft.DataMigration;

table 40042 "Migration Validator Registry"
{
    Caption = 'Migration Validator Registry';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
        }
        field(2; "Migration Type"; Text[250])
        {
            Caption = 'Migration Type';
        }
        field(3; "Codeunit Id"; Integer)
        {
            Caption = 'Codeunit Id';
        }
        field(5; Description; Text[2048])
        {
            Caption = 'Description';
        }
        field(6; Automatic; Boolean)
        {
            Caption = 'Automatic';
            InitValue = true;
        }
        field(7; "Errors should fail migration"; Boolean)
        {
            Caption = 'Errors should fail migration';
            InitValue = true;
        }
    }
    keys
    {
        key(PK; "Validator Code")
        {
            Clustered = true;
        }
    }
}