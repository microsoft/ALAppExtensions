pageextension 13667 "OIOUBL-Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter("Allow Item Charge Assignment")
        {
            field("OIOUBL-Amount Including VAT"; "Amount Including VAT")
            {
                Tooltip = 'Specifies the amount including VAT for the whole document. The field may be filled automatically.';
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
        }

        addafter("Line No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer.';
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
        }
    }
}