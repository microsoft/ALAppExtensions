page 10672 "SAF-T Grouping Categories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "SAF-T Mapping Category";
    SourceTableView = where ("Mapping Type" = const ("Income Statement"));
    Caption = 'SAF-T Grouping Categories';

    layout
    {
        area(Content)
        {
            repeater(GroupingCategories)
            {
                field(Name; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category of the grouping code that is used for mapping.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the grouping that is used for mapping.';
                }
            }
        }
        area(Factboxes)
        {

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
                ToolTip = 'Show the grouping codes of the selected category.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ImportCodes;
                RunObject = page "SAF-T Groupings";
                RunPageLink = "Mapping Type" = field ("Mapping Type"), "Category No." = field ("No.");
            }
        }
    }
}
