pageextension 11796 "Accounting Manager RC CZL" extends "Accounting Manager Role Center"
{
    actions
    {
        addafter("&Closing Trial Balance")
        {
            action("Balance Sheet CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Sheet';
                Image = PrintReport;
                RunObject = Report "Balance Sheet CZL";
                ToolTip = 'Open the report for balance sheet.';
            }
            action("Income Statement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Income Statement';
                Image = PrintReport;
                RunObject = Report "Income Statement CZL";
                ToolTip = 'Open the report for income statement.';
            }
        }
        addafter("VAT E&xceptions")
        {
            action("VAT &Statement CZL")
            {
                ApplicationArea = VAT;
                Caption = 'VAT &Statement';
                Image = Report;
                RunObject = Report "VAT Statement CZL";
                ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
            }

        }
        addafter("Intrastat &Journal")
        {
            action("Calc. and Pos&t VAT Settlement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Calc. and Pos&t VAT Settlement';
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settl. CZL";
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
            }
        }
    }
}
