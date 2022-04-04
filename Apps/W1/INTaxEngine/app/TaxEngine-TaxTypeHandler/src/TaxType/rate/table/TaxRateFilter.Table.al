table 20254 "Tax Rate Filter"
{
    Caption = 'Tax Rate Filter';

    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax Type';
        }
        field(2; "ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; "Column ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Column ID';
        }
        field(4; "Column Name"; Text[100])
        {
            DataClassification = SystemMetadata;
            Caption = 'Column Name';
        }
        field(5; "Value"; Text[2000])
        {
            DataClassification = SystemMetadata;
            Caption = 'Value';
        }
        field(6; "Is Range Column"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Range Column';
        }
        field(7; "Column Type"; Enum "Column Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Range Column';
        }
        field(8; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            InitValue = "Text";
            OptionMembers = Option,Text,Integer,Decimal,Boolean,Date;
            OptionCaption = 'Option,Text,Integer,Decimal,Boolean,Date';
        }
        field(9; "Conditional Operator"; Enum "Conditional Operator")
        {
            DataClassification = SystemMetadata;
            Caption = 'Conditional Operator';
        }
        field(10; "Attribute ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
        }
        field(11; "Linked Attribute ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Linked Attribute ID';
        }
    }

    keys
    {
        key(Key1; "Tax Type", ID)
        {
            Clustered = true;
        }
    }
}