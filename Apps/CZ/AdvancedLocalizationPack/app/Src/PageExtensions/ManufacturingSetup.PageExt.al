pageextension 31251 "Manufacturing Setup CZA" extends "Manufacturing Setup"
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
