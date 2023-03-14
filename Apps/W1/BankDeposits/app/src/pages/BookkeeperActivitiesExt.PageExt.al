pageextension 1707 BookkeeperActivitiesExt extends "Bookkeeper Activities"
{
    Caption = 'Activities';
    layout
    {
        addafter("Non-Applied Payments")
        {
            field("Bank Deposits to Post"; "Bank Deposits to Post")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "Bank Deposit List";
                ToolTip = 'Specifies bank deposits that are ready to be posted.';
                Visible = BankDepositFeatureEnabled;
            }
        }
    }

    trigger OnOpenPage()
#if not CLEAN21
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
#endif
    begin
        BankDepositFeatureEnabled := true;
#if not CLEAN21
        BankDepositFeatureEnabled := BankDepositFeatureMgt.IsEnabled();
#endif
    end;

    var
        BankDepositFeatureEnabled: Boolean;
}