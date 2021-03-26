pageextension 18466 "Subcon ProdOrder Line Ext" extends "Released Prod. Order Lines"
{
    layout
    {
        addafter("Cost Amount")
        {
            field("Subcontracting Order No."; Rec."Subcontracting Order No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting order number.';
            }
            field("Subcontractor Code"; Rec."Subcontractor Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting vendor number the order belongs to.';
            }
        }
    }
}