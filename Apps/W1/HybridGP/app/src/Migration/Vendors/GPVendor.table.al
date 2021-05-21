table 4096 "GP Vendor"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; VENDORID; Text[75])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor ID';
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(2; VENDNAME; Text[65])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
        }
        field(3; SEARCHNAME; Text[65])
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(4; VNDCHKNM; Text[65])
        {
            Caption = 'Vendor Check Name';
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS1; Text[61])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(6; ADDRESS2; Text[61])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(7; CITY; Text[35])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(8; VNDCNTCT; Text[61])
        {
            Caption = 'Vendor Contact';
            DataClassification = CustomerContent;
        }
        field(9; PHNUMBR1; Text[21])
        {
            Caption = 'Phone Number';
            DataClassification = CustomerContent;
        }
        field(10; PYMTRMID; Text[21])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(11; SHIPMTHD; Text[15])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
        }
        field(12; COUNTRY; Text[61])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(13; PYMNTPRI; Text[3])
        {
            Caption = 'Payment Priority';
            DataClassification = CustomerContent;
        }
        field(14; AMOUNT; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(15; FAXNUMBR; Text[30])
        {
            Caption = 'Fax Number';
            DataClassification = CustomerContent;
        }
        field(16; ZIPCODE; Text[11])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
        }
        field(17; STATE; Text[29])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(18; INET1; Text[200])
        {
            Caption = 'Internet Information 1';
            DataClassification = CustomerContent;
        }
        field(19; INET2; Text[200])
        {
            Caption = 'Internet Information 2';
            DataClassification = CustomerContent;
        }
        field(20; TAXSCHID; Text[15])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(21; UPSZONE; Text[3])
        {
            Caption = 'UPS Zone';
            DataClassification = CustomerContent;
        }
        field(22; TXIDNMBR; Text[11])
        {
            Caption = 'Tax ID Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; VENDORID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

