pageextension 31252 "Assembly Setup CZA" extends "Assembly Setup"
{
    layout
    {
        addlast(General)
        {
            field("Default Gen.Bus.Post. Grp. CZA"; Rec."Default Gen.Bus.Post. Grp. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default general bussines posting group.';
            }
        }
    }
}
