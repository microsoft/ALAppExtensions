pageextension 11798 "Small Business Owner RC CZL" extends "Small Business Owner RC"
{
    actions
    {
        addafter("VAT E&xceptions")
        {
            action("V&AT Statement CZL")
            {
                ApplicationArea = VAT;
                Caption = 'V&AT Statement';
                Image = Report;
                RunObject = Report "VAT Statement CZL";
                ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
            }
        }
        addafter("Post Inve&ntory Cost to G/L")
        {
            action("Calc. and Post VAT Settlem&ent CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Calc. and Post VAT Settlem&ent';
                Ellipsis = true;
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settl. CZL";
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
            }
        }
    }
}
