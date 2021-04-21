table 20130 "Script Symbol"
{
    Caption = 'Script Symbol';
    DataClassification = CustomerContent;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; Type; Enum "Symbol Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Symbol Type';
        }
        field(2; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; Name; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(4; Datatype; Enum "Symbol Data Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Datatype';
        }
        field(5; "Value Type"; Option)
        {
            OptionMembers = Normal,Formula;
            DataClassification = SystemMetadata;
            Caption = 'Value Type';
        }
        field(6; "Formula ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Formula ID';
        }
    }

    keys
    {
        key(K0; Type, ID)
        {
            Clustered = True;
        }
    }
}