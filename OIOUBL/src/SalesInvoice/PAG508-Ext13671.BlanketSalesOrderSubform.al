pageextension 13671 "OIOUBL-BlanketSalesOrderSub" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the account code of the customer.';
                Visible = False;
            }
        }
    }
}