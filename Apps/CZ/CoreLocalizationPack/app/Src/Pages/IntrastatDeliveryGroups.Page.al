#if not CLEAN22
page 31037 "Intrastat Delivery Groups CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Intrastat Delivery Groups (Obsolete)';
    PageType = List;
    SourceTable = "Intrastat Delivery Group CZL";
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the intrastat delivery group.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the descpriton of intrastat delivery group.';
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
                Visible = true;
            }
        }
    }
}
#endif