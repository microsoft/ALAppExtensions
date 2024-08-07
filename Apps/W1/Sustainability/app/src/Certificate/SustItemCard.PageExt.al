namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;

pageextension 6222 "Sust. Item Card" extends "Item Card"
{
    layout
    {
        addbefore("Posting Details")
        {
            group("Sustainability")
            {
                Visible = Rec.Type = Rec.Type::Inventory;
                Caption = 'Sustainability';
                field("GHG Credit"; Rec."GHG Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GHG Credit of Item';
                }
                field("Carbon Credit Per UOM"; Rec."Carbon Credit Per UOM")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = Rec."GHG Credit";
                    ToolTip = 'Specifies the Carbon Credit Per UOM of Item';
                }
                field("Sust. Cert. No."; Rec."Sust. Cert. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sust. Cert. No. of Item';
                }
                field("Sust. Cert. Name"; Rec."Sust. Cert. Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sust. Cert. Name of Item';
                }
            }
        }
    }
}