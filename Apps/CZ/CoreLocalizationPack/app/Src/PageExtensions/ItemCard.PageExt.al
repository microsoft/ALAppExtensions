pageextension 31008 "Item Card CZL" extends "Item Card"
{
    layout
    {
        addafter("Country/Region of Origin Code")
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
            }
            field("Specific Movement CZL"; Rec."Specific Movement CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
            }
        }
    }
}
