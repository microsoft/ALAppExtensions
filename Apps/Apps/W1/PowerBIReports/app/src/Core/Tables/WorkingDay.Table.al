namespace Microsoft.PowerBIReports;

table 36952 "Working Day"
{
    Access = Internal;
    Caption = 'Power BI Working Day';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Day Number"; Integer)
        {
            Caption = 'Day Number';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 6;
            Editable = false;
        }
        field(2; "Day Name"; Text[50])
        {
            Caption = 'Day Name';
            DataClassification = CustomerContent;
        }
        field(3; Working; Boolean)
        {
            Caption = 'Working';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Day Number")
        {
            Clustered = true;
        }
    }
}