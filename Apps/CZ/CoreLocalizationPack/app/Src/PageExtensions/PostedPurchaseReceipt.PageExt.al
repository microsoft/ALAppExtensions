pageextension 31111 "Posted Purchase Receipt CZL" extends "Posted Purchase Receipt"
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
