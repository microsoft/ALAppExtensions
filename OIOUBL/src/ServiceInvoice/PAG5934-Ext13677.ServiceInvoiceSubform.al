pageextension 13677 "OIOUBL-Service Invoice Subform" extends "Service Invoice Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Service;
                Visible = false;
                ToolTip = 'Specifies the account code of the customer.';
            }
        }
    }
}