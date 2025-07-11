namespace Microsoft.Integration.MDM;

table 7234 "Master Data Mgt. Subscriber"
{
    Caption = 'Master Data Mgt. Subscriber';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = OrganizationIdentifiableInformation;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Company Name")
        {
        }
    }

}