pageextension 31122 "Posted Purch. CM Subform CZL" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        addlast(Control1)
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
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
        }
        addafter("FA Posting Type")
        {
            field("Maintenance Code CZL"; Rec."Maintenance Code")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies a maintenance code.';
                Visible = false;
            }
        }
    }
}
