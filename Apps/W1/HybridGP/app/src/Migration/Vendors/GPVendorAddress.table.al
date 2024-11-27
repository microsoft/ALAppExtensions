namespace Microsoft.DataMigration.GP;

using Microsoft.Sales.Customer;

table 4049 "GP Vendor Address"
{
    Permissions = tabledata "Ship-to Address" = rim;
    DataClassification = CustomerContent;

    fields
    {
        field(1; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; ADRSCODE; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(3; VNDCNTCT; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(4; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(7; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(8; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(9; ZIPCODE; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(12; PHNUMBR1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(15; FAXNUMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; VENDORID, ADRSCODE)
        {
            Clustered = true;
        }
    }
}