table 20295 "Use Case Tree Node"
{
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Node Type"; Option)
        {
            Caption = 'Node Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Use Case,Heading,Begin,End';
            OptionMembers = "Use Case",Heading,"Begin","End";
        }
        field(6; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(8; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
        field(9; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            DataClassification = SystemMetadata;
        }
        field(10; "Condition"; Blob)
        {
            Caption = 'Condition';
            DataClassification = SystemMetadata;
        }
        field(11; "Use Case ID"; Guid)
        {
            Caption = 'Use Case ID';
            DataClassification = SystemMetadata;
        }
        field(12; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Is Tax Type Root"; Boolean)
        {
            Caption = 'Is Tax Type Root';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Tax Type"; Code[20])
        {
            Caption = 'Tax Type';
            TableRelation = "Tax Type";
            DataClassification = CustomerContent;
        }
        field(15; "CaseName"; Text[2000])
        {
            Caption = 'CaseName';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "TableName"; Text[30])
        {
            Caption = 'TableName';
            DataClassification = SystemMetadata;
        }
        field(17; "ConditionTxt"; Text[2000])
        {
            Caption = 'CondtionTxt';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Is Tax Type Root") { }
    }
}