pageextension 13681 "OIOUBL-Posted Srv Cr Memo Sub" extends "Posted Serv. Cr. Memo Subform"
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