pageextension 18560 "Sales Quote" extends "Sales Quote"
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