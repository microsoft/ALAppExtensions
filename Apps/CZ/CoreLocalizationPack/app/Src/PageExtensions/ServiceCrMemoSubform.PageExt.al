pageextension 31004 "Service Cr. Memo Subform CZL" extends "Service Credit Memo Subform"
{
    layout
    {
        addafter("Appl.-from Item Entry")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
    }
}
