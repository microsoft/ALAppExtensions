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
                field(DefaultLocationCode; Rec."Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location to be used in orders.';
                }
                field(LocationFilter; Rec."Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location(s) for which the inventory must be counted.';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LocationList: Page "Location List";
                        OldText: Text;
                    begin
                        OldText := Text;
                        LocationList.LookupMode(true);
                        if not (LocationList.RunModal() = ACTION::LookupOK) then
                            exit(false);

                        Text := OldText + LocationList.GetSelectionFilter();
                        exit(true);
                    end;
                }
#if not CLEAN22
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ObsoleteReason = 'Replaced by Stock Calculation field.';
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ToolTip = 'Specifies if the location is enabled/disabled for send stock information to Shopify.';
                }
#endif
                field("Stock Calculation"; Rec."Stock Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select the stock calculation used for this location.';
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ShpfyShopLocation: Record "Shpfy Shop Location";
        DisableQst: Label 'One or more lines have %1 specified, but stock synchronization is disabled. Do you want to close the page?', Comment = '%1 the name for location filter';
    begin
        ShpfyShopLocation.SetRange("Shop Code", Rec.GetFilter("Shop Code"));
        ShpfyShopLocation.SetFilter("Location Filter", '<>%1', '');
        ShpfyShopLocation.SetRange("Stock Calculation", ShpfyShopLocation."Stock Calculation"::Disabled);
        if ShpfyShopLocation.IsEmpty() then
            exit(true);
        if not Confirm(StrSubstNo(DisableQst, Rec.FieldCaption("Location Filter"))) then
            exit(false);
    end;
}
