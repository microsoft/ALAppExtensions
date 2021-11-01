table 11726 "Registration Log Detail CZL"
{
    Caption = 'Registration Log Detail';

    fields
    {
        field(1; "Log Entry No."; Integer)
        {
            Caption = 'Log Entry No.';
            TableRelation = "Registration Log CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Field Name"; Enum "Reg. Log Detail Field CZL")
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(10; "Account Type"; Enum "Reg. Log Account Type CZL")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(11; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(21; "Response"; Text[150])
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
        field(22; "Current Value"; Text[150])
        {
            Caption = 'Current Value';
            DataClassification = CustomerContent;
        }
        field(23; Status; Enum "Reg. Log Detail Field Status CZL")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Log Entry No.", "Field Name")
        {
            Clustered = true;
        }
    }
}