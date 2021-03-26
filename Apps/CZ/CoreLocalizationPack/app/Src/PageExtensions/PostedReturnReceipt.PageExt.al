pageextension 31115 "Posted Return Receipt CZL" extends "Posted Return Receipt"
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
        addafter("Ship-to")
        {
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if there is physical transfer of the item.';
            }
        }
    }
}