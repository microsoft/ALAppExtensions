pageextension 11790 "Sales Order Subform CZL" extends "Sales Order Subform"
{
    layout
    {
        addafter("Invoice Discount Amount")
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
        }
        addafter("Bin Code")
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
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
