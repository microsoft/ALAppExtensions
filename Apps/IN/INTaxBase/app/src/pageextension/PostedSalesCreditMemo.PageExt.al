pageextension 18562 "Posted Sales Credit Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("Tax Info")
            {
                Caption = 'Tax Information';
            }
        }
    }
}