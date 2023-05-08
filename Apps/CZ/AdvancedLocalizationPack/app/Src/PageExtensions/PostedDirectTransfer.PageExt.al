pageextension 31227 "Posted Direct Transfer CZA" extends "Posted Direct Transfer"
{
    layout
    {
        addafter("Transfer-to Code")
        {
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Location;
                Editable = false;
                ToolTip = 'Specifies general bussiness posting group.';
            }
        }
    }
}
