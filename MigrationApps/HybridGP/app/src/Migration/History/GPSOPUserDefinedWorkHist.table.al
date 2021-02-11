table 4079 "GPSOPUserDefinedWorkHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; SOPTYPE; Option)
        {
            Caption = 'SOP Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
            DataClassification = CustomerContent;
        }
        field(2; SOPNUMBE; text[22])
        {
            Caption = 'SOP Number';
            DataClassification = CustomerContent;
        }
        field(3; USRDAT01; Date)
        {
            Caption = 'User Defined Date 1';
            DataClassification = CustomerContent;
        }
        field(4; USRDAT02; Date)
        {
            Caption = 'User Defined Date 2';
            DataClassification = CustomerContent;
        }
        field(5; USRTAB01; text[22])
        {
            Caption = 'User Defined Table 1';
            DataClassification = CustomerContent;
        }
        field(6; USRTAB09; text[22])
        {
            Caption = 'User Defined Table 2';
            DataClassification = CustomerContent;
        }
        field(7; USRTAB03; text[22])
        {
            Caption = 'User Defined Table 3';
            DataClassification = CustomerContent;
        }
        field(8; USERDEF1; text[22])
        {
            Caption = 'User Defined 1';
            DataClassification = CustomerContent;
        }
        field(9; USERDEF2; text[22])
        {
            Caption = 'User Defined 2';
            DataClassification = CustomerContent;
        }
        field(10; USRDEF03; text[22])
        {
            Caption = 'User Defined 3';
            DataClassification = CustomerContent;
        }
        field(11; USRDEF04; text[22])
        {
            Caption = 'User Defined 4';
            DataClassification = CustomerContent;
        }
        field(12; USRDEF05; text[22])
        {
            Caption = 'User Defined 5';
            DataClassification = CustomerContent;
        }
        field(13; COMMENT_1; text[52])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(14; COMMENT_2; text[52])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(15; COMMENT_3; text[52])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(16; COMMENT_4; text[52])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(17; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPTYPE, SOPNUMBE)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
