pageextension 31103 "Item Charge Asgmt. (Purch) CZL" extends "Item Charge Assignment (Purch)"
{
    layout
    {
        addlast(Control1)
        {
            field("Incl. in Intrastat Amount CZL"; Rec."Incl. in Intrastat Amount CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
            }
            field("Incl. in Intrastat S.Value CZL"; Rec."Incl. in Intrastat S.Value CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat statistical value.';
            }
        }
    }
}