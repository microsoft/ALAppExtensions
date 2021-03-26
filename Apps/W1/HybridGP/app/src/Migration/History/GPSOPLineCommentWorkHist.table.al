table 4071 "GPSOPLineCommentWorkHist"
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
        field(3; CMPNTSEQ; Integer)
        {
            Caption = 'Component Sequence';
            DataClassification = CustomerContent;
        }
        field(4; LNITMSEQ; Integer)
        {
            Caption = 'Line Item Sequence';
            DataClassification = CustomerContent;
        }
        field(5; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(6; COMMENT_1; text[52])
        {
            Caption = 'Comment 1';
            DataClassification = CustomerContent;
        }
        field(7; COMMENT_2; text[52])
        {
            Caption = 'Comment 2';
            DataClassification = CustomerContent;
        }
        field(8; COMMENT_3; text[52])
        {
            Caption = 'Comment 3';
            DataClassification = CustomerContent;
        }
        field(9; COMMENT_4; text[52])
        {
            Caption = 'Comment 4';
            DataClassification = CustomerContent;
        }
        field(10; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE, CMPNTSEQ, LNITMSEQ)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
