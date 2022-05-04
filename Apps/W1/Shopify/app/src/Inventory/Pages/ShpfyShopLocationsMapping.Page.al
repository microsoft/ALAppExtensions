/// <summary>
/// Page Shpfy Shop Locations Mapping (ID 30117).
/// </summary>
page 30117 "Shpfy Shop Locations Mapping"
{
    Caption = 'Shopify Shop Locations';
    InsertAllowed = false;

    PageType = List;
    SourceTable = "Shpfy Shop Location";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec."Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the location.';
                }

                field(Name; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the location.';
                }

                field(LocationFilter; Rec."Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location(s) for which the inventory must be counted.';

                    trigger OnAssistEdit()
                    begin
                        Rec.CreateLocationFilter();
                    end;
                }

                field(DefaultLocationCode; Rec."Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location to be used in orders.';
                }

                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the location is enabled/disabled for send stock information to Shopify.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetLocations)
            {
                ApplicationArea = All;
                Caption = 'Get Shopify Locations';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Get the locations defined in Shopify.';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Shpfy Sync Shop Locations", Shop);
                end;
            }
        }
    }

    var
        Shop: Record "Shpfy Shop";

    trigger OnFindRecord(Which: Text): Boolean
    var
        ShopCode: Text;
    begin
        ShopCode := Rec.GetFilter("Shop Code");
        if ShopCode <> Shop.Code then
            if not Shop.Get(ShopCode) then begin
                Shop.Init();
                Shop.Code := CopyStr(ShopCode, 1, MaxStrLen(Shop.Code));
            end;
        exit(Rec.FindSet());
    end;
}
