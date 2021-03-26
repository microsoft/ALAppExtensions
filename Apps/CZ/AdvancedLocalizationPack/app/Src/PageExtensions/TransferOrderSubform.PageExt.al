pageextension 31240 "Transfer Order Subform CZA" extends "Transfer Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Gen.Bus.Post.Group Ship CZA"; Rec."Gen.Bus.Post.Group Ship CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for items ship.';
            }
            field("Gen.Bus.Post.Group Receive CZA"; Rec."Gen.Bus.Post.Group Receive CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for items receive.';
            }
        }
    }
}
