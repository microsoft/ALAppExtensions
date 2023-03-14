pageextension 18799 "Charge Sales Return Subform" extends "Sales Return Order Subform"
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