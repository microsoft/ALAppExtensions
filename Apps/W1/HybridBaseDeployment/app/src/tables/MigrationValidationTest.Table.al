namespace Microsoft.DataMigration;

table 40044 "Migration Validation Test"
{
    Caption = 'Migration Validation Test';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; "Code"; Code[30])
        {
            Caption = 'Code';
        }
        field(2; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
        }
        field(3; Entity; Text[50])
        {
            Caption = 'Test Description';
        }
        field(4; "Test Description"; Text[2048])
        {
            Caption = 'Test Description';
        }
        field(5; "Fail Count"; Integer)
        {
            Caption = 'Fail Count';
            FieldClass = FlowField;
            CalcFormula = count("Migration Validation Error" where("Validator Code" = field("Validator Code"), "Test Code" = field(Code)));
        }
        field(6; Ignore; Boolean)
        {
            Caption = 'Ignore';
        }
    }
    keys
    {
        key(PK; "Code", "Validator Code")
        {
            Clustered = true;
        }
        key(Key2; Ignore)
        {
        }
    }
}