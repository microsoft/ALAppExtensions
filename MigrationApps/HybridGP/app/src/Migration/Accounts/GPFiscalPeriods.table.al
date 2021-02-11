table 4092 "GP Fiscal Periods"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PERIODID; Integer)
        {
            Caption = 'Fiscal Period';
            DataClassification = CustomerContent;
        }
        field(2; YEAR1; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
        }
        field(3; PERIODDT; Date)
        {
            Caption = 'Period Start Date';
            DataClassification = CustomerContent;
        }
        field(4; PERDENDT; Date)
        {
            Caption = 'Period End Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PERIODID, YEAR1)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}