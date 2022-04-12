/// <summary>
/// Page Shpfy Tag Factbox (ID 30103).
/// </summary>
page 30103 "Shpfy Tag Factbox"
{
    Caption = 'Shopify Tags';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Shpfy Tag";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Tag; Rec.Tag)
                {
                    ApplicationArea = All;
                    Caption = 'Tag';
                    ToolTip = 'Specifies the tags of a product that are used for filtering and search.';
                }
            }
        }
    }
}