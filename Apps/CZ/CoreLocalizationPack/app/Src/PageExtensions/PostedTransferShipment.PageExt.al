pageextension 31131 "Posted Transfer Shipment CZL" extends "Posted Transfer Shipment"
{
    layout
    {
        addlast("Foreign Trade")
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}