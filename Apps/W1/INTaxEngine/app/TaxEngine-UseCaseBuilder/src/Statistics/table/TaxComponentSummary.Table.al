table 20301 "Tax Component Summary"
{
    Caption = 'Tax Component Summary';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Entry No.';
        }
        field(2; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(3; "Use Case"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Use Case';
        }
        field(4; "Component ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Component ID';
        }
        field(5; "Name"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Name';
        }
        field(6; "Component %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Component %';
        }
        field(7; "Base Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Base Amount';
        }
        field(8; "Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount';
        }
        field(9; "Indentation Level"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Indentation Level';
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