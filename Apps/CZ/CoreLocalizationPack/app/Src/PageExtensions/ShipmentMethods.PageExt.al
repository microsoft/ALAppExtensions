pageextension 31065 "Shipment Methods CZL" extends "Shipment Methods"
{
    layout
    {
        addafter(Description)
        {
            field("Intrastat Deliv. Grp. Code CZL"; Rec."Intrastat Deliv. Grp. Code CZL")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the Intrastat Delivery Group Code.';
            }
            field("Incl. Item Charges (S.Val) CZL"; Rec."Incl. Item Charges (S.Val) CZL")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat statistical value.';
            }
            field("Adjustment % CZL"; Rec."Adjustment % CZL")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the adjustment percentage for the shipment method. This percentage is used to calculate an adjustment value for the Intrastat journal.';

            }
            field("Incl. Item Charges (Amt.) CZL"; Rec."Incl. Item Charges (Amt.) CZL")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
                Visible = false;
            }
        }
    }
}