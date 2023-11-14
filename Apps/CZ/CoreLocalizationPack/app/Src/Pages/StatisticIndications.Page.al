#if not CLEAN22
page 31078 "Statistic Indications CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Statistic Indications (Obsolete)';
    PageType = List;
    SourceTable = "Statistic Indication CZL";
    UsageCategory = Administration;
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the item''s tariff number.';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the statistic indication code for the item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for statistic indication.';
                }
                field("Description EN"; Rec."Description EN")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the english description for statistic indication.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
#endif
