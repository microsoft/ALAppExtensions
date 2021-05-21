page 1155 "COHUB Group List"
{
    PageType = List;
    SourceTable = "COHUB Group";
    Caption = 'Groups';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Code';
                    ToolTip = 'Specifies the code of the group';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the group description';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ReloadAllCompanies)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reload all companies';
                Image = WorkCenterLoad;
                RunObject = Codeunit "COHUB Reload Companies";
                ToolTip = 'Reload all companies and update the data.';
                Visible = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
            }
        }
    }
}

