pageextension 11797 "Bookkeeper Role Center CZL" extends "Bookkeeper Role Center"
{
    actions
    {
        addafter("VAT E&xceptions")
        {
            action("VAT State&ment CZL")
            {
                ApplicationArea = VAT;
                Caption = 'VAT State&ment';
                Image = Report;
                RunObject = Report "VAT Statement CZL";
                ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
            }
        }
        addafter("Post Inventor&y Cost to G/L")
        {
            action("Calc. and Pos&t VAT Settlement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Calc. and Pos&t VAT Settlement';
                Ellipsis = true;
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settl. CZL";
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
            }
        }
    }
}
