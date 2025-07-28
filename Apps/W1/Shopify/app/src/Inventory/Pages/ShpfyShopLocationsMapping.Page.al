// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Location;

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
                field("Is Fulfillment Service"; Rec."Is Fulfillment Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is a fulfillment service location.';
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
                field("Default Product Location"; Rec."Default Product Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default product locations will be added to new products in Shopify.';
                }
                field("Stock Calculation"; Rec."Stock Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stock calculation used for this location.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the location is active in Shopify.';
                    Visible = false;
                }
                field("Is Primary"; Rec."Is Primary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this the primary location in Shopify.';
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
            action(CreateFulfillmentService)
            {
                ApplicationArea = All;
                Caption = 'Create Shopify Fulfillment Service';
                Image = CreateInventoryPickup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create Shopify Fulfillment Service';

                trigger OnAction()
                var
                    FullfillmentOrdersAPI: Codeunit "Shpfy Fulfillment Orders API";
                begin
                    FullfillmentOrdersAPI.RegisterFulfillmentService(Shop);
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
        ShopLocation: Record "Shpfy Shop Location";
        DisableQst: Label 'One or more lines have %1 specified, but stock synchronization is disabled. Do you want to close the page?', Comment = '%1 the name for location filter';
    begin
        ShopLocation.SetRange("Shop Code", Rec.GetFilter("Shop Code"));
        ShopLocation.SetFilter("Location Filter", '<>%1', '');
        ShopLocation.SetRange("Stock Calculation", ShopLocation."Stock Calculation"::Disabled);
        if ShopLocation.IsEmpty() then
            exit(true);
        if not Confirm(StrSubstNo(DisableQst, Rec.FieldCaption("Location Filter"))) then
            exit(false);
    end;
}
