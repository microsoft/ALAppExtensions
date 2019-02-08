tableextension 13651 "OIOUBL-Item Charge" extends "Item Charge"
{
    fields
    {
        field(13630; "OIOUBL-Charge Category"; Option)
        {
            Caption = 'Charge Category';
            OptionMembers = "General Rebate","General Fine","Freight Charge",Duty,Tax;
            OptionCaption = '"General Rebate","General Fine","Freight Charge",Duty,Tax';
        }
    }
}