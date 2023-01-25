pageextension 18526 "Charge Purch. Cr. Subform Ext" extends "Purch. Cr. Memo Subform"
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
