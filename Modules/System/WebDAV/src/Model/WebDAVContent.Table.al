table 5678 "WebDAV Content"
{
    Access = Public;
    DataClassification = SystemMetadata; // Data classification is SystemMetadata as the table is temporary
    Caption = 'WebDAV Content';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; Name; Text[250])
        {
            Caption = 'Title';
        }
        field(11; "Full Url"; Text[2048])
        {
            Caption = 'Full Url';
        }
        field(12; "Relative Url"; Text[2048])
        {
            Caption = 'Relative Url';
        }
        field(13; Level; Integer)
        {
            Caption = 'Level';
        }
        field(20; "Is Collection"; Boolean)
        {
            Caption = 'Is Collection';
        }
        field(22; "Content Type"; Text[2048])
        {
            Caption = 'Content Type';
        }
        field(23; "Content Length"; Integer)
        {
            Caption = 'Content Length';
        }
        field(30; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
        }

        field(31; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
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