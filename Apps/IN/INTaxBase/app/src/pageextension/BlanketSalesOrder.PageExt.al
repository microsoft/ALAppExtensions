pageextension 18559 "Blanket Sales Order" extends "Blanket Sales Order"
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