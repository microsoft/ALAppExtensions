table 4026 "GP Payment Terms"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(2; DUETYPE; Option)
        {
            Caption = 'Due Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Net Days","Date","EOM","None","Next Month","Months","Month/Day","Annual";
        }
        field(3; DUEDTDS; Integer)
        {
            Caption = 'Due Date/Days';
            DataClassification = CustomerContent;
        }
        field(4; DISCTYPE; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Days","Date","EOM","None","Next Month","Months","Month/Day","Annual";
        }
        field(5; DISCDTDS; Integer)
        {
            Caption = 'Discount Date/Days';
            DataClassification = CustomerContent;
        }
        field(6; DSCLCTYP; Option)
        {
            Caption = 'Discount Calculate Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Percent","Amount";
        }
        field(8; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(13; TAX; Boolean)
        {
            Caption = 'Tax';
            DataClassification = CustomerContent;
        }
        field(15; CBUVATMD; Boolean)
        {
            Caption = 'CB_Use_VAT_Mode';
            DataClassification = CustomerContent;
        }
        field(19; USEGRPER; Boolean)
        {
            Caption = 'Use Grace Periods';
            DataClassification = CustomerContent;
        }
        field(20; CalculateDateFrom; Option)
        {
            Caption = 'Calculate Date From';
            DataClassification = CustomerContent;
            OptionMembers = ,"Transaction Date","Discount Date";
        }
        field(21; CalculateDateFromDays; Integer)
        {
            Caption = 'Calculate Date From Days';
            DataClassification = CustomerContent;
        }
        field(22; DueMonth; Option)
        {
            Caption = 'Due Month';
            DataClassification = CustomerContent;
            OptionMembers = ,"January","February","March","April","May","June","July","August","September","October","November","December";
        }
        field(23; DiscountMonth; Option)
        {
            Caption = 'Discount Month';
            DataClassification = CustomerContent;
            OptionMembers = ,"January","February","March","April","May","June","July","August","September","October","November","December";
        }
        field(25; PYMTRMID_New; text[10])
        {
            Caption = 'BC-Friendly Payment Term';
            DataClassification = CustomerContent;
            InitValue = '';
        }
    }

    keys
    {
        key(PK; PYMTRMID)
        {
            Clustered = true;
        }
    }
}

