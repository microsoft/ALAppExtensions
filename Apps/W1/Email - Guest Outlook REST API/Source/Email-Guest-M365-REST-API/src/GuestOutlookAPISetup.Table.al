table 89000 "LGS Guest Outlook - API Setup"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; ClientId; guid)
        {
            Caption = 'Client Id';
            DataClassification = CustomerContent;
        }
        field(3; ClientSecret; guid)
        {
            Caption = 'Client Secret';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}
