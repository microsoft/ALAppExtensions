namespace Microsoft.DataMigration;

table 40044 "Validation Suite Line"
{
    Caption = 'Validation Suite Line';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; "Code"; Code[30])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the identification code of this test.';
        }
        field(2; "Validation Suite Id"; Code[20])
        {
            Caption = 'Validation Suite Id';
            ToolTip = 'Specifies the Validation Suite used during this test.';
        }
        field(3; Entity; Text[50])
        {
            Caption = 'Entity';
            ToolTip = 'Specifies the type of entity that will be tested.';
        }
        field(4; "Test Description"; Text[2048])
        {
            Caption = 'Test Description';
            ToolTip = 'Specifies the description of the test.';
        }
        field(5; "Fail Count"; Integer)
        {
            Caption = 'Fail Count';
            ToolTip = 'Specifies the total number of validation errors related to this test.';
            FieldClass = FlowField;
            CalcFormula = count("Migration Validation Error" where("Validation Suite Id" = field("Validation Suite Id"), "Test Code" = field(Code)));
        }
        field(6; Ignore; Boolean)
        {
            Caption = 'Ignore';
            ToolTip = 'Specifies that this test can be ignored or not. Ignored tests will not log any validation failures.';
        }
    }
    keys
    {
        key(PK; "Code", "Validation Suite Id")
        {
            Clustered = true;
        }
        key(Key2; Ignore)
        {
        }
    }
}