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
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
        }
        field(3; "Test Code"; Code[30])
        {
            Caption = 'Test Code';
            NotBlank = true;
            TableRelation = "Migration Validation Test";
        }
        field(4; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
            NotBlank = true;
            TableRelation = "Migration Validator Registry";
        }
        field(5; "Migration Type"; Text[250])
        {
            Caption = 'Migration Type';
        }
        field(6; "Entity Type"; Text[50])
        {
            Caption = 'Entity Type';
            NotBlank = true;
        }
        field(7; Context; Text[250])
        {
            Caption = 'Context';
        }
        field(8; "Test Description"; Text[250])
        {
            Caption = 'Test Description';
        }
        field(9; Expected; Text[250])
        {
            Caption = 'Expected';
        }
        field(10; Actual; Text[250])
        {
            Caption = 'Actual';
        }
        field(11; "Is Warning"; Boolean)
        {
            Caption = 'Is Warning';
        }
        field(12; "Errors should fail migration"; Boolean)
        {
            Caption = 'Indicates if validation errors should fail the migration';
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