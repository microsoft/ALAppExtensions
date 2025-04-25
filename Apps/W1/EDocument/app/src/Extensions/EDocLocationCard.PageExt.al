namespace Microsoft.Inventory.Location;

pageextension 6104 "E-Doc. Location Card" extends "Location Card"
{
    layout
    {
        addlast(Warehouse)
        {
            group("E-Documents")
            {
                Caption = 'E-Documents';

                field("Transfer Doc. Sending Profile"; Rec."Tranfer Doc. Sending Profile")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}