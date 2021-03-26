pageextension 31100 "Employee Ledger Entries CZL" extends "Employee Ledger Entries"
{
    layout
    {
        addlast(Group)
        {
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
                Visible = false;
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
        }
    }
}
