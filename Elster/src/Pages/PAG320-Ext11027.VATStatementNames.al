pageextension 11027 "Elster VAT Statement Names" extends "VAT Statement Names"
{
    layout
    {
        addafter(Description)
        {
            field("Sales VAT Adv. Notification"; "Sales VAT Adv. Notif.")
            {
                ToolTip = 'Specifies that a VAT statement name is used for the calculation of the tax and base amounts for the key figures required by the tax authorities.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}