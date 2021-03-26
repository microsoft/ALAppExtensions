pageextension 31130 "Transfer Orders CZL" extends "Transfer Orders"
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