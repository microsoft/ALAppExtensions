/// <summary>
/// Page Shpfy Tags (ID 30104).
/// </summary>
page 30104 "Shpfy Tags"
{
    Caption = 'Shopify Tags';
    PageType = List;
    SourceTable = "Shpfy Tag";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Tag; Rec.Tag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tags of a product that are used for filtering and search.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Evaluate(Rec."Parent Table No.", Rec.GetFilter("Parent Table No."));
        Evaluate(Rec."Parent Id", Rec.GetFilter("Parent Id"));
    end;
}