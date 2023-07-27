pageextension 11792 "Sales Quote Subform CZL" extends "Sales Quote Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
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
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        ForceTotalsCalculation();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ForceTotalsCalculation();
    end;
}
