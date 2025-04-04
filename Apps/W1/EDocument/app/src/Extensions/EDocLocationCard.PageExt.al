namespace Microsoft.Inventory.Location;

pageextension 6104 "E-Doc. Location Card" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("E-Document Sending Profile"; "E-Document Sending Profile")
            {
                ApplicationArea = All;
            }

        }
    }
}