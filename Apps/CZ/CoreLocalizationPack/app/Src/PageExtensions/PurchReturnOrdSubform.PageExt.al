pageextension 31001 "Purch. Return Ord. Subform CZL" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
        {
#if not CLEAN22
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Country/Region of Origin Code (Obsolete)';
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
#endif
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = PurchReturnOrder;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
#if not CLEAN22
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = PurchReturnOrder;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
#endif
        }
    }
}
