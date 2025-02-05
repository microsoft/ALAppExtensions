table 4769 "Contoso GL Account"
{
    TableType = Temporary;
    Access = Internal;
    DataClassification = CustomerContent;
    InherentEntitlements = RIMD;
    InherentPermissions = RIMD;
    ReplicateData = false;

    fields
    {
        field(1; "Account Name"; Text[100])
        {
        }
        field(2; "Account No."; Code[20])
        {
        }
    }

    keys
    {
        key(PK; "Account Name")
        {
            Clustered = true;
        }
    }
}