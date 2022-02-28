#if not CLEAN18
#pragma warning disable AL0432
#endif
pageextension 31215 "Reconciliation CZL" extends Reconciliation
{
    layout
    {
        modify("No.")
        {
            Visible = false;
        }
#if not CLEAN18
        modify(Type)
        {
            Visible = false;
        }
#endif        
        addafter("No.")
        {
            field("Account Type CZL"; Rec."Account Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account type that is being reconciled.';
            }
            field("Account No. CZL"; Rec."Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account no. that is being reconciled.';
            }
        }
    }
}
