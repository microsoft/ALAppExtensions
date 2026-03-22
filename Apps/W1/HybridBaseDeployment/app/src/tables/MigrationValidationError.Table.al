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
            TableRelation = "Validation Suite Line";
            ToolTip = 'Specifies the identification code of this test.';
        }
        field(4; "Validation Suite Id"; Code[20])
        {
            Caption = 'Validation Suite Id';
            NotBlank = true;
            TableRelation = "Validation Suite";
            ToolTip = 'Specifies the Validation Suite used for this test.';
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
        field(7; "Entity Display Name"; Text[2048])
        {
            Caption = 'Entity Display Name';
            ToolTip = 'Specifies the identifying name of the entity record being tested.';
        }
        field(8; "Test Description"; Text[2048])
        {
            Caption = 'Test Description';
            ToolTip = 'Specifies the description of the test.';
        }
        field(9; Expected; Text[2048])
        {
            Caption = 'Expected';
            ToolTip = 'Specifies the expected value of the tested field.';
        }
        field(10; Actual; Text[2048])
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
            CalcFormula = exist("Validation Suite" where(Id = field("Validation Suite Id"),
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
        key(Key2; "Company Name", "Migration Type", "Is Warning")
        {
        }
        key(Key3; "Validation Suite Id", "Test Code")
        {
        }
    }
}