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
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureEnabled := BankDepositFeatureMgt.IsEnabled()
    end;

    var
        BankDepositFeatureEnabled: Boolean;
}