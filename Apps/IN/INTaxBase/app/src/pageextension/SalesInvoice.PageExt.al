pageextension 18556 "Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group("Tax Info")
            {
                Caption = 'Tax Information';
            }
        }
    }
}