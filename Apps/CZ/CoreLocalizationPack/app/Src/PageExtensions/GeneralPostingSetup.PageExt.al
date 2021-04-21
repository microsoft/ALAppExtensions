pageextension 31165 "General Posting Setup CZL" extends "General Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Invt. Rounding Adj. Acc. CZL"; Rec."Invt. Rounding Adj. Acc. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the inventory rounding adjustment account.';
            }
        }
    }
}