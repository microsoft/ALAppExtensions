table 20132 "Script Symbol Value"
{
    Caption = 'Script Symbol Value';
    DataClassification = CustomerContent;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; Type; enum "Symbol Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Symbol Type';
        }
        field(3; "Symbol ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Symbol ID';
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
        field(115; "Text Value"; BLOB)
        {
            DataClassification = SystemMetadata;
            Caption = 'Text Value';
        }
        field(117; "Simple Text Value"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Simple Text Value';
        }
        field(118; "Text Value Type"; Option)
        {
            OptionMembers = Text,BLOB;
            DataClassification = SystemMetadata;
            Caption = 'Text Value Type';
        }
        field(501; Initialized; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Initialized';
        }
    }

    keys
    {
        key(K0; Type, "Symbol ID")
        {
            Clustered = True;
        }
    }
}