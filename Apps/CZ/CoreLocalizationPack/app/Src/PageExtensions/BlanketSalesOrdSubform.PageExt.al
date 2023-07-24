pageextension 11778 "Blanket Sales Ord. Subform CZL" extends "Blanket Sales Order Subform"
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
#if not CLEAN22
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
#endif
            field("Net Weight CZL"; Rec."Net Weight")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
    }
}
