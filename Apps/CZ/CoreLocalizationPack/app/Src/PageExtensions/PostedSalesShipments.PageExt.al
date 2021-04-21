pageextension 31112 "Posted Sales Shipments CZL" extends "Posted Sales Shipments"
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
