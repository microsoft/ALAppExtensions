pageextension 31005 "Service Invoice Subform CZL" extends "Service Invoice Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
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
