pageextension 31136 "Posted Transfer Receipts CZL" extends "Posted Transfer Receipts"
{
    layout
    {
        addlast(Control1)
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                Visible = false;
            }
        }
    }
}