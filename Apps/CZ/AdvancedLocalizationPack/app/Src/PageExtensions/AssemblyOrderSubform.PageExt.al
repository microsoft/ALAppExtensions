pageextension 31254 "Assembly Order Subform CZA" extends "Assembly Order Subform"
{
    layout
    {
        addbefore("Shortcut Dimension 1 Code")
        {
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the General Business Posting Group that applies to the entry.';
                Visible = false;
            }
        }
    }
}
