namespace Microsoft.Sustainability.Certificate;

using Microsoft.Purchases.Vendor;

pageextension 6221 "Sust. Vendor Card" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("Sust. Cert. No."; Rec."Sust. Cert. No.")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the Sust. Cert. No. of Vendor';
            }
            field("Sust. Cert. Name"; Rec."Sust. Cert. Name")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the Sust. Cert. Name of Vendor';
            }
        }
    }
}