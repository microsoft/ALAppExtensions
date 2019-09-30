page 10671 "SAF-T Std. Account Categories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "SAF-T Mapping Category";
    SourceTableView = where ("Mapping Type" = filter ("Two Digit Standard Account" | "Four Digit Standard Account"));
    Caption = 'SAF-T Standard Account Categories';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Mapping Type"; "Mapping Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of mapping.';
                }
                field(Name; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category of the standard code that is used for mapping.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the standard account category that is used for mapping.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(MappingCodes)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Mapping Codes';
                ToolTip = 'Show the standard account codes of the certain category.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ImportCodes;
                RunObject = page "SAF-T Standard Accounts";
                RunPageLink = "Mapping Type" = field ("Mapping Type"), "Category No." = field ("No.");
            }
        }
    }
}
