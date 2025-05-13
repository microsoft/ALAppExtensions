namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Market Catalog Relations (ID 30450).
/// </summary>
page 30450 "Shpfy Market Catalog Relations"
{
    ApplicationArea = All;
    Caption = 'Shopify Market Catalog Relations';
    PageType = List;
    SourceTable = "Shpfy Market Catalog Relation";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shop Code"; Rec."Shop Code") { }
                field("Catalog Title"; Rec."Catalog Title") { }
                field("Market Name"; Rec."Market Name") { }
            }
        }
    }
}
