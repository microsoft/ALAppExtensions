#pragma warning disable AA0247
table 1914 "MigrationQB Vendor"
{
    DataCaptionFields = DisplayName;
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(2; GivenName; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(3; FamilyName; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(4; CompanyName; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; DisplayName; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6; BillAddrLine1; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(7; BillAddrLine2; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(8; BillAddrCity; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(9; BillAddrCountry; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(10; BillAddrState; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(11; BillAddrPostalCode; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(12; BillAddrCountrySubDivCode; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(13; PrimaryPhone; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(14; PrimaryEmailAddr; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(15; WebAddr; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(16; Fax; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(17; ListId; Text[40])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

