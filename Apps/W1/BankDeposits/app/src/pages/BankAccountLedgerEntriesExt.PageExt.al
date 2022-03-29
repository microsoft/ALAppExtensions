pageextension 1704 BankAccountLedgerEntriesExt extends "Bank Account Ledger Entries"
{
    Caption = 'Bank Account Ledger Entries';

    actions
    {
        addafter(Dimensions)
        {
            action("Bank Deposit Lines")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Deposit Lines';
                Image = DepositLines;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = Page "Posted Bank Deposit Lines";
                RunPageLink = "Bank Account Ledger Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Bank Account Ledger Entry No.");
                ToolTip = 'View the underlying bank deposit lines.';
                Visible = ShouldSeePostedBankDeposits;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureBankDeposits: Codeunit "Feature Bank Deposits";
    begin
        ShouldSeePostedBankDeposits := FeatureBankDeposits.ShouldSeePostedBankDeposits()
    end;

    var
        ShouldSeePostedBankDeposits: Boolean;
}