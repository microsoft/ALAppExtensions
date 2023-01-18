pageextension 18791 "Charge Sale. Cr. Me. Sbfrm Ext" extends "Sales Cr. Memo Subform"
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
                RunObject = codeunit "Sales Charge Group Management";
            }
        }
    }
}