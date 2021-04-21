pageextension 31071 "Resource Card CZL" extends "Resource Card"
{
    layout
    {
        addlast(Invoicing)
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the resource''s tariff number.';
            }
        }
    }
}