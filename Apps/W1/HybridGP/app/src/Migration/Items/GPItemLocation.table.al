table 4016 "GP Item Location"
{
    ReplicateData = false;
    Description = 'IV_Location_SETP';
    Extensible = false;


    fields
    {
        field(1; LOCNCODE; Text[11])
        {
            Description = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(2; LOCNDSCR; Text[31])
        {
            Description = 'Location Description';
            DataClassification = CustomerContent;
        }
        field(4; ADDRESS1; Text[61])
        {
            Description = 'Address 1';
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS2; Text[61])
        {
            Description = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(7; CITY; Text[35])
        {
            Description = 'City';
            DataClassification = CustomerContent;
        }
        field(8; STATE; Text[29])
        {
            Description = 'State';
            DataClassification = CustomerContent;
        }
        field(9; ZIPCODE; Text[11])
        {
            Description = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(11; PHONE1; Text[21])
        {
            Description = 'Phone 1';
            DataClassification = CustomerContent;
        }
        field(12; PHONE2; Text[21])
        {
            Description = 'Phone 2';
            DataClassification = CustomerContent;
        }
        field(14; FAXNUMBR; Text[21])
        {
            Description = 'Fax Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(LocationCode; LOCNCODE)
        {
            Clustered = true;
        }
    }
}