pageextension 11779 "Blanket Purch.Ord. Subform CZL" extends "Blanket Purchase Order Subform"
{
    layout
    {
        addafter("Allow Invoice Disc.")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
            field("Net Weight CZL"; Rec."Net Weight")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
#if CLEAN19
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Tax Group Code")
        {
            Visible = false;
        }
#endif
    }
}
