table 4093 "GP Customer"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; CUSTNMBR; Text[75])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(2; CUSTNAME; Text[65])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(3; STMTNAME; Text[65])
        {
            Caption = '';
            DataClassification = CustomerContent;
        }
        field(4; ADDRESS1; Text[61])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS2; Text[61])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(6; CITY; Text[35])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(7; CNTCPRSN; Text[61])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(8; PHONE1; Text[21])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(9; SALSTERR; Text[15])
        {
            Caption = 'Sales Territory';
            DataClassification = CustomerContent;
        }
        field(10; CRLMTAMT; Decimal)
        {
            Caption = 'Credit Limit Amount';
            DataClassification = CustomerContent;
        }
        field(11; PYMTRMID; Text[21])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(12; SLPRSNID; Text[15])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(13; SHIPMTHD; Text[15])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
        }
        field(14; COUNTRY; Text[61])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(15; AMOUNT; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(16; STMTCYCL; Boolean)
        {
            Caption = 'Statement Cycle';
            DataClassification = CustomerContent;
        }
        field(17; FAX; Text[30])
        {
            Caption = 'Fax Number';
            DataClassification = CustomerContent;
        }
        field(18; ZIPCODE; Text[11])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
        }
        field(19; STATE; Text[29])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(20; INET1; Text[80])
        {
            Caption = 'Internet Information 1';
            DataClassification = CustomerContent;
        }
        field(21; INET2; Text[80])
        {
            Caption = 'Internet Information 2';
            DataClassification = CustomerContent;
        }
        field(22; TAXSCHID; Text[15])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(23; UPSZONE; Text[3])
        {
            Caption = 'UPS Zone';
            DataClassification = CustomerContent;
        }
        field(24; TAXEXMT1; Text[25])
        {
            Caption = 'Tax Exempt 1';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; CUSTNMBR)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

