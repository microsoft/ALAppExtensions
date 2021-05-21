pageextension 31110 "Posted Sales Shipment CZL" extends "Posted Sales Shipment"
{
    layout
    {
        addlast(General)
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}
