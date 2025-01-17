// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Ledger;

page 6614 "FS Item Avail. by Location"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item Availability by Location';
    EntitySetCaption = 'Items Availability by Location';
    Editable = false;
    EntityName = 'itemAvailabilityByLocation';
    EntitySetName = 'itemsAvailabilitiesByLocation';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    PageType = API;
    SourceTable = "Item Ledger Entry";
    SourceTableTemporary = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'Remaining Quantity';
                }
                field(itemDescription; ItemDescription)
                {
                    Caption = 'Item Description';
                }
                field(locationName; LocationName)
                {
                    Caption = 'Location Name';
                }
            }
        }
    }

    var
        ItemDescription: Text[100];
        LocationName: Text[100];

    trigger OnOpenPage()
    var
        ItemAvailByLocation: Query "FS Item Avail. by Location";
    begin
        ItemAvailByLocation.Open();
        while ItemAvailByLocation.Read() do
            InsertTemporaryRecord(ItemAvailByLocation);
        ItemAvailByLocation.Close();
    end;

    trigger OnAfterGetRecord()
    begin
        ItemDescription := GetItemDescription(Rec."Item No.");
        LocationName := GetLocationName(Rec."Location Code");
    end;

    local procedure InsertTemporaryRecord(var ItemAvailByLocation: Query "FS Item Avail. by Location")
    begin
        Rec.SystemId := CreateGuid();
        Rec."Entry No." := Rec."Entry No." + 1;
        Rec."Location Code" := ItemAvailByLocation.locationCode;
        Rec."Item No." := ItemAvailByLocation.itemNo;
        Rec."Unit of Measure Code" := ItemAvailByLocation.unitOfMeasureCode;
        Rec."Remaining Quantity" := ItemAvailByLocation.remainingQuantity;
        Rec.Insert();
    end;

    local procedure GetItemDescription(No: Code[20]): Text[100]
    var
        Item: Record Item;
    begin
        if Item.Get(No) then
            exit(Item.Description);
    end;

    local procedure GetLocationName(LocCode: Code[10]): Text[100]
    var
        Location: Record Location;
    begin
        if Location.Get(LocCode) then
            exit(Location.Name);
    end;
}