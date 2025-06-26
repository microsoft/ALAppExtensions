namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Market Catalog Relations (ID 30172).
/// </summary>
page 30172 "Shpfy Market Catalog Relations"
{
    ApplicationArea = All;
    Caption = 'Shopify Market Catalog Relations';
    PageType = ListPart;
    SourceTable = "Shpfy Market Catalog Relation";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Market Name"; Rec."Market Name") { }
            }
        }
    }
}
