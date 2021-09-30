table 20131 "Script Symbol Member Value"
{
    Caption = 'Script Symbol Member Value';
    DataClassification = CustomerContent;
    Access = Public;
    Extensible = false;
    fields
    {
        field(3; "Symbol ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Symbol ID';
        }
        field(10; "Member ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Member ID';
        }
        field(50; Datatype; Enum "Symbol Data Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Datatype';
        }
        field(101; "Number Value"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Number Value';
        }
        field(102; "Option Value"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Option Value';
        }
        field(103; "Boolean Value"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Boolean Value';
        }
        field(104; "Date Value"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Value';
        }
        field(105; "Time Value"; Time)
        {
            DataClassification = SystemMetadata;
            Caption = 'Time Value';
        }
        field(112; "Guid Value"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Guid Value';
        }
        field(113; "RecordID Value"; RecordID)
        {
            DataClassification = CustomerContent;
            Caption = 'RecordID Value';
        }
        field(114; "DateTime Value"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'DateTime Value';
        }
        field(115; "String Value"; BLOB)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Value';
        }
        field(117; "Simple String Value"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Simple String Value';
        }
        field(118; "String Value Type"; Option)
        {
            OptionMembers = Text,BLOB;
            DataClassification = SystemMetadata;
            Caption = 'String Value Type';
        }
    }

    keys
    {
        key(K0; "Symbol ID", "Member ID")
        {
            Clustered = True;
        }
    }
}