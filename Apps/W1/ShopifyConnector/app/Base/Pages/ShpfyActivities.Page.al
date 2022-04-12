/// <summary>
/// Page Shpfy Activities (ID 30100).
/// </summary>
page 30100 "Shpfy Activities"
{
    Caption = 'Shopify Activities';
    PageType = CardPart;
    SourceTable = "Shpfy Cue";
    RefreshOnActivate = true;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            cuegroup(ShopInfo)
            {
                Caption = 'Shopify Shop info';
                field("Unmapped Customers"; Rec."Unmapped Customers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Customers";
                    ToolTip = 'Specifies the number of imported customers that aren''t mapped.';
                }
                field(UnmappedProducts; Rec."Unmapped Products")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Products";
                    ToolTip = 'Specifies the number of imported products that aren''t mapped.';
                }
                field(UnprocessedOrders; Rec."Unprocessed Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Orders";
                    ToolTip = 'Specifies the number of imported orders that aren''t processed.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();
        end;
    end;
}