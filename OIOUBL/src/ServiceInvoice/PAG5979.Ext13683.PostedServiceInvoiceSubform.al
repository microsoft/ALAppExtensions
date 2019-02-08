pageextension 13683 "OIOUBL-Posted Serv Invoice Sub" extends "Posted Service Invoice Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Visible = false;
                ApplicationArea = Service;
                ToolTip = 'Specifies the account code of the customer.';
            }
        }
    }
}