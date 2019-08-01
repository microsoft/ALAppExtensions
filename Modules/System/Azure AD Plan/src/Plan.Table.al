table 9004 Plan
{
    Caption = 'Subscription Plan';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; "Plan ID"; Guid)
        {
            Caption = 'Plan ID';
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(3; "Role Center ID"; Integer)
        {
            Caption = 'Role Center ID';
        }
    }

    keys
    {
        key(Key1; "Plan ID")
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
    }
}