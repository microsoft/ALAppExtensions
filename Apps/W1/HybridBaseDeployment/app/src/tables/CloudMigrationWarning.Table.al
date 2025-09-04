namespace Microsoft.DataMigration;

table 40031 "Cloud Migration Warning"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;
    Caption = 'Cloud Migration Warning';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; Message; Text[1024])
        {
            Caption = 'Message';
            ToolTip = 'Specifies the warning message.';
        }
        field(3; "Warning Type"; Enum "Cloud Migration Warning Type")
        {
            Caption = 'Warning Type';
            ToolTip = 'Specifies the type of warning.';
        }
        field(4; Ignored; Boolean)
        {
            Caption = 'Ignored';
            ToolTip = 'Specifies whether the warning has been ignored.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; SystemModifiedAt)
        {
        }
    }
}