page 31076 "Commodities CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Commodities';
    PageType = List;
    SourceTable = "Commodity CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of commodities.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of commodities.';
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
    actions
    {
        area(navigation)
        {
            action("Commodity Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Commodity Setup';
                Image = SetupLines;
                RunObject = Page "Commodity Setup CZL";
                RunPageLink = "Commodity Code" = FIELD(Code);
                RunPageView = SORTING("Commodity Code", "Valid From");
                ToolTip = 'The function opens the page for commodity limit amount setup.';
            }
        }
    }
}
