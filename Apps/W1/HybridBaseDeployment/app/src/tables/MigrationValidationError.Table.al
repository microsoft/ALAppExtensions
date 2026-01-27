namespace Microsoft.DataMigration;

table 40043 "Migration Validation Error"
{
    Caption = 'Migration Validation Error';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the Entry No. of this validation error.';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
            ToolTip = 'Specifies the Company that was tested.';
        }
        field(3; "Test Code"; Code[30])
        {
            Caption = 'Test Code';
            NotBlank = true;
            TableRelation = "Migration Validation Test";
            ToolTip = 'Specifies the identification code of this test.';
        }
        field(4; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
            NotBlank = true;
            TableRelation = "Migration Validator Registry";
            ToolTip = 'Specifies the Validator used for this test.';
        }
        field(5; "Migration Type"; Text[250])
        {
            Caption = 'Migration Type';
            ToolTip = 'Specifies the applicable Migration Type for the test.';
        }
        field(6; "Entity Type"; Text[50])
        {
            Caption = 'Entity Type';
            NotBlank = true;
            ToolTip = 'Specifies the type of entity that was tested.';
        }
        field(7; Context; Text[250])
        {
            Caption = 'Context';
            ToolTip = 'Specifies the identifying context of the record being tested.';
        }
        field(8; "Test Description"; Text[250])
        {
            Caption = 'Test Description';
            ToolTip = 'Specifies the description of the test.';
        }
        field(9; Expected; Text[250])
        {
            Caption = 'Expected';
            ToolTip = 'Specifies the expected value of the tested field.';
        }
        field(10; Actual; Text[250])
        {
            Caption = 'Actual';
            ToolTip = 'Specifies the actual value of the tested field.';
        }
        field(11; "Is Warning"; Boolean)
        {
            Caption = 'Is Warning';
            ToolTip = 'Specifies if the failed validation test should be considered just a warning.';
        }
        field(12; "Errors should fail migration"; Boolean)
        {
            Caption = 'Indicates if validation errors should fail the migration';
            ToolTip = 'Specifies whether validation errors should fail the migration or not. Only applies to automatic validation.';
            FieldClass = FlowField;
            CalcFormula = exist("Migration Validator Registry" where("Validator Code" = field("Validator Code"),
                                                                     "Migration Type" = field("Migration Type"),
                                                                     "Errors should fail migration" = const(true)));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}