pageextension 18527 "Charge Purch. Inv. Subform Ext" extends "Purch. Invoice Subform"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Explode Charge Group")
            {
                Caption = 'Explode Charge Group';
                ApplicationArea = Basic, Suite;
                Image = Insert;
                ToolTip = 'Insert the charge group lines.';
                RunObject = codeunit "Purch. Charge Group Management";
            }
        }
    }
}
