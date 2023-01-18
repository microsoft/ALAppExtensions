pageextension 18528 "Charge Purch. Ord. Subform Ext" extends "Purchase Order Subform"
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