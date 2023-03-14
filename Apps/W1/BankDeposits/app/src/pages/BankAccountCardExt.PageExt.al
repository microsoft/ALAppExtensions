pageextension 1702 BankAccountCardExt extends "Bank Account Card"
{
    Caption = 'Bank Account Card';

    actions
    {
        addafter(Statements)
        {
            action("Bank Deposits")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Deposits';
                Image = DepositSlip;
                RunObject = Page "Posted Bank Deposit List";
                RunPageLink = "Bank Account No." = FIELD("No.");
                RunPageView = SORTING("Bank Account No.");
                ToolTip = 'View the list of posted bank deposits for the bank account.';
                Visible = ShouldSeePostedBankDeposits;
            }
        }
    }

    trigger OnOpenPage()
#if not CLEAN21
    var
        FeatureBankDeposits: Codeunit "Feature Bank Deposits";
#endif
    begin
        ShouldSeePostedBankDeposits := true;
#if not CLEAN21
        ShouldSeePostedBankDeposits := FeatureBankDeposits.ShouldSeePostedBankDeposits()
#endif
    end;

    var
        ShouldSeePostedBankDeposits: Boolean;
}