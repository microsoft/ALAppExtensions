pageextension 1706 AccReceivableActivitiesExt extends "Acc. Receivable Activities"
{
    Caption = 'Activities';
    layout
    {
        addlast(content)
        {
            cuegroup(BankDeposits)
            {
                Visible = BankDepositFeatureEnabled;
                Caption = 'Bank Deposits';
                field("Bank Deposits to Post"; "Bank Deposits to Post")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Deposits to Post';
                    DrillDownPageID = "Bank Deposit List";
                    ToolTip = 'Specifies the bank deposits that will be posted.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureEnabled := BankDepositFeatureMgt.IsEnabled();
    end;

    var
        BankDepositFeatureEnabled: Boolean;

}