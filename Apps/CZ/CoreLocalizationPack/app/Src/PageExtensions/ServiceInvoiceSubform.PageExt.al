pageextension 31005 "Service Invoice Subform CZL" extends "Service Invoice Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
        addlast(Control1)
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
        }
    }
}
