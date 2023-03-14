tableextension 31048 "Acc. Schedule Extension CZZ" extends "Acc. Schedule Extension CZL"
{
    fields
    {
        field(60; "Advance Payments CZZ"; Option)
        {
            Caption = 'Advance Payments';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
        }
    }
}