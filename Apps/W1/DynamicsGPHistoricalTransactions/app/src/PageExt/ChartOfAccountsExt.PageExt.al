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
                    Image = Archive;
                    RunObject = Page "Hist. Gen. Journal Lines";
                    ToolTip = 'View all GP GL detail transactions.';
                }
                action("GP Accounts")
                {
                    ApplicationArea = All;
                    Caption = 'Detail by Account';
                    Image = Archive;
                    RunObject = Page "Hist. G/L Account List";
                    ToolTip = 'View GP GL detail by account.';
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
                Visible = GPGLDetailDataExists;

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
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
    begin
        if HistGenJournalLine.ReadPermission() then
            GPGLDetailDataExists := not HistGenJournalLine.IsEmpty();
    end;

    var
        GPGLDetailDataExists: Boolean;
}