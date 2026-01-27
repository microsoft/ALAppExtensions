namespace Microsoft.DataMigration;

table 40042 "Validation Suite"
{
    Caption = 'Validation Suite';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Code[20])
        {
            Caption = 'Id';
            ToolTip = 'Specifies the identification code for this Validator.';
        }
        field(2; "Migration Type"; Text[250])
        {
            Caption = 'Migration Type';
            ToolTip = 'Specifies the applicable Migration Type for this Validator.';
        }
        field(3; "Codeunit Id"; Integer)
        {
            Caption = 'Codeunit Id';
            ToolTip = 'Specifies the Codeunit Id used to conduct the validation tests.';
        }
        field(5; Description; Text[2048])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of this Validator.';
        }
        field(6; Automatic; Boolean)
        {
            Caption = 'Automatic';
            InitValue = true;
            ToolTip = 'Specifies if the validation tests should be executed automatically after the migration tranforms are completed.';
        }
        field(7; "Errors should fail migration"; Boolean)
        {
            Caption = 'Errors should fail migration';
            InitValue = true;
            ToolTip = 'Specifies whether validation errors should fail the migration or not. Only applies to automatic validation.';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}