table 20362 "Tax Type Archival Log Entry"
{
    DataClassification = EndUserIdentifiableInformation;
    LookupPageId = "Use Case Archival Log Entries";
    DrillDownPageId = "Use Case Archival Log Entries";
    Access = Public;
    Extensible = true;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Tax Type"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax Type';
        }
        field(3; "Description"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Description';
        }
        field(4; "Log Date-Time"; DateTime)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Log Date-Time';
        }
        field(5; "Major Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Major Version';
        }
        field(6; "Configuration Data"; Blob)
        {
            DataClassification = SystemMetadata;
            Caption = 'Configuration Data';
        }
        field(7; "Active Version"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Active Version';
        }
        field(8; "Changed by"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Changed By';
        }
        field(9; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
            TableRelation = "User Setup";
        }
        field(10; "Minor Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Minor Version';
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