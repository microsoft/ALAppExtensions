pageextension 13659 "OIOUBL-Issued Reminder Lines" extends "Issued Reminder Lines"
{
    layout
    {
        addafter("Applies-To Document No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}