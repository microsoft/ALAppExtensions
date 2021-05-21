table 20253 "Tax Rate Value"
{
    Caption = 'Tax Configuration Value';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Config ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Config ID';
        }
        field(2; "Column ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column ID';
        }
        field(3; "Column Name"; Text[200])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column Name';
        }
        field(4; Value; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
        }
        field(5; "ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'ID';
        }
        field(6; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(7; "Value To"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value To';
        }
        field(8; "Decimal Value"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Decimal Value';
        }
        field(9; "Decimal Value To"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Decimal Value To';
        }
        field(10; "Date Value"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Date Value';
        }
        field(11; "Date Value To"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Date Value To';
        }
        field(12; "Column Type"; Enum "Column Type")
        {
            Caption = 'Column Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Tax Rate ID"; Text[2000])
        {
            Caption = 'Tax Rate ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Tax Type", "Config ID", ID, "Column ID")
        {
            Clustered = true;
        }
    }
}