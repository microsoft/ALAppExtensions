table 4076 "GPSOPTrackingNumbersWorkHist"
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
        field(3; Tracking_Number; text[42])
        {
            Caption = 'Tracking Number';
            DataClassification = CustomerContent;
        }
        field(4; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE, Tracking_Number)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
