pageextension 11799 "Accountant Role Center CZL" extends "Accountant Role Center"
{
    actions
    {
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
                ApplicationArea = VAT;
                Caption = 'Calc. and Pos&t VAT Settlement';
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settl. CZL";
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
            }
        }
    }
}
