namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 41004 "Chart of Accounts Ext." extends "Chart of Accounts"
{
    actions
    {
        addlast("A&ccount")
        {
            group(GPHistorical)
            {
                action("GP Historical Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'All Detail Transactions';
                    Image = Transactions;
                    RunObject = Page "Hist. Gen. Journal Lines";
                    ToolTip = 'View all GP GL detail transactions.';
                    Visible = GPHistGLDetailDataAvailable;
                }
                action("GP Accounts")
                {
                    ApplicationArea = All;
                    Caption = 'Detail by Account';
                    Image = Accounts;
                    RunObject = Page "Hist. G/L Account List";
                    ToolTip = 'View GP GL detail by account.';
                    Visible = GPHistAccountDataAvailable;
                }
            }
        }

        addlast(Category_Category5)
        {
            group(Category_GPGLDetail)
            {
                Caption = 'GP Detail Snapshot';
                ShowAs = Standard;
                Image = Archive;
                Visible = GPHistDataAvailable;

                actionref("GP Historical Trx._Promoted"; "GP Historical Trx.")
                {
                }
                actionref("GP Accounts_Promoted"; "GP Accounts")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HistGLAccount: Record "Hist. G/L Account";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
    begin
        if HistGLAccount.ReadPermission() then
            GPHistAccountDataAvailable := not HistGLAccount.IsEmpty();

        if HistGenJournalLine.ReadPermission() then
            GPHistGLDetailDataAvailable := not HistGenJournalLine.IsEmpty();

        GPHistDataAvailable := (GPHistAccountDataAvailable or GPHistGLDetailDataAvailable);
    end;

    var
        GPHistDataAvailable: Boolean;
        GPHistAccountDataAvailable: Boolean;
        GPHistGLDetailDataAvailable: Boolean;
}