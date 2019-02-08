pageextension 13668 "OIOUBL-Sales Invoice Subform" extends "Sales Invoice Subform"
{
    layout
    {
        addafter("Line No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer.';
                ApplicationArea = Basic,Suite;
            }
        }
    }
}