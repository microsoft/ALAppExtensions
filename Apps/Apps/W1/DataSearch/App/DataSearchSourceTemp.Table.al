namespace Microsoft.Foundation.DataSearch;

table 2683 "Data Search Source Temp"
{
    Caption = 'Data Search Source Temp';
    TableType = Temporary;
    ObsoleteState = Pending;
    ObsoleteReason = 'Not needed anymore';
    ObsoleteTag = '24.0';
    fields
    {
        field(1; Description; Text[150])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Description)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
