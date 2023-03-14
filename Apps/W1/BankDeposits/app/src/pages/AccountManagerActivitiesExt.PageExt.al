pageextension 1705 AccountManagerActivitiesExt extends "Account Manager Activities"
{
    Caption = 'Activities';
    layout
    {
        addlast("Cash Management")
        {
            field("Bank Deposits to Post"; "Bank Deposits to Post")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "Bank Deposits";
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