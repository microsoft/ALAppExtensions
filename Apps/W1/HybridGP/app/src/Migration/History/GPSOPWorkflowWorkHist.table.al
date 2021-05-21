table 4080 "GPSOPWorkflowWorkHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; SOPNUMBE; text[22])
        {
            Caption = 'SOP Number';
            DataClassification = CustomerContent;
        }
        field(2; SOPTYPE; Option)
        {
            Caption = 'SOP Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
            DataClassification = CustomerContent;
        }
        field(3; ORD; Integer)
        {
            Caption = 'Ord';
            DataClassification = CustomerContent;
        }
        field(4; Effective_Date; Date)
        {
            Caption = 'Effective Date';
            DataClassification = CustomerContent;
        }
        field(5; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(6; SOPSTATUS; Option)
        {
            Caption = 'SOP Status';
            OptionMembers = "New","New ","Ready to Pick","Unconfirmed Pick","Ready to Pack","Unconfirmed Pack","Shipped","Ready to Post","In Process","Complete",;
            DataClassification = CustomerContent;
        }
        field(7; USERID; text[16])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(8; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE, ORD)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
