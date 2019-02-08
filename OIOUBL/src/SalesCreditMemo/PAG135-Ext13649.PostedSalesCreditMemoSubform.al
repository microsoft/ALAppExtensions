pageextension 13649 "OIOUBL-PostedSalesCrMemoSub" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the credit memo to.';
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}