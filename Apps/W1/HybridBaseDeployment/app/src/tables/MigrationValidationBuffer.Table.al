namespace Microsoft.DataMigration;

table 40046 "Migration Validation Buffer"
{
    Caption = 'Migration Validation Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "No."; Text[100])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Parent No."; Text[100])
        {
            Caption = 'Parent No.';
        }
        field(3; "Text 1"; Text[250])
        {
            Caption = 'Text 1';
        }
        field(4; "Text 2"; Text[250])
        {
            Caption = 'Text 2';
        }
        field(5; "Text 3"; Text[250])
        {
            Caption = 'Text 3';
        }
        field(6; "Text 4"; Text[250])
        {
            Caption = 'Text 4';
        }
        field(7; "Integer 1"; Integer)
        {
            Caption = 'Integer 1';
        }
        field(8; "Integer 2"; Integer)
        {
            Caption = 'Integer 2';
        }
        field(9; "Integer 3"; Integer)
        {
            Caption = 'Integer 3';
        }
        field(10; "Integer 4"; Integer)
        {
            Caption = 'Integer 4';
        }
        field(11; "Boolean 1"; Boolean)
        {
            Caption = 'Boolean 1';
        }
        field(12; "Boolean 2"; Boolean)
        {
            Caption = 'Boolean 2';
        }
        field(13; "Boolean 3"; Boolean)
        {
            Caption = 'Boolean 3';
        }
        field(14; "Boolean 4"; Boolean)
        {
            Caption = 'Boolean 4';
        }
        field(15; "Decimal 1"; Decimal)
        {
            Caption = 'Decimal 1';
        }
        field(16; "Decimal 2"; Decimal)
        {
            Caption = 'Decimal 2';
        }
        field(17; "Decimal 3"; Decimal)
        {
            Caption = 'Decimal 3';
        }
        field(18; "Decimal 4"; Decimal)
        {
            Caption = 'Decimal 4';
        }
        field(19; "Date 1"; Date)
        {
            Caption = 'Date 1';
        }
        field(20; "Date 2"; Date)
        {
            Caption = 'Date 2';
        }
        field(21; "Date 3"; Date)
        {
            Caption = 'Date 3';
        }
        field(22; "Date 4"; Date)
        {
            Caption = 'Date 4';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Parent No.")
        {
        }
    }
}