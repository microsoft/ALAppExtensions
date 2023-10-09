#if not CLEAN22
pageextension 31008 "Item Card CZL" extends "Item Card"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        addafter("Country/Region of Origin Code")
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Specific Movement CZL"; Rec."Specific Movement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Specific Movement (Obsolete)';
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
}

#endif