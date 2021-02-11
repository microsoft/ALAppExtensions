table 4073 "GPSOPProcessHoldWorkHist"
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
        field(3; PRCHLDID; text[16])
        {
            Caption = 'Process Hold ID';
            DataClassification = CustomerContent;
        }
        field(4; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(5; USERID; text[16])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(6; HOLDDATE; Date)
        {
            Caption = 'Hold Date';
            DataClassification = CustomerContent;
        }
        field(7; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(8; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(9; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPTYPE, SOPNUMBE, PRCHLDID)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}

