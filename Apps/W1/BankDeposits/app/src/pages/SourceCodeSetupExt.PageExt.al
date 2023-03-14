pageextension 1701 SourceCodeSetupExt extends "Source Code Setup"
{
    Caption = 'Source Code Setup';

    layout
    {
        addafter("Payment Reconciliation Journal")
        {
            field("Bank Deposit"; "Bank Deposit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code linked to entries that are posted from a bank deposit.';
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