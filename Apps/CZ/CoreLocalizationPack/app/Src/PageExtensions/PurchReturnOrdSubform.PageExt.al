pageextension 31001 "Purch. Return Ord. Subform CZL" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = PurchReturnOrder;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = PurchReturnOrder;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
        }
    }
}
