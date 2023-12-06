// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Inventory.Item;
using System.IO;

table 31068 "Stockkeeping Unit Template CZL"
{
    Caption = 'Stockkeeping Unit Template';
    LookupPageId = "Stockkeeping Unit Templ. CZL";

    fields
    {
        field(1; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
            DataClassification = CustomerContent;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location;
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Description := GetDefaultDescription();
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Configuration Template Code"; Code[10])
        {
            Caption = 'Configuration Template Code';
            TableRelation = "Config. Template Header" where("Table ID" = const(5700));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalcFields("Configuration Template Descr.")
            end;
        }
        field(11; "Configuration Template Descr."; Text[100])
        {
            Caption = 'Configuration Template Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Config. Template Header".Description where(Code = field("Configuration Template Code")));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Item Category Code", "Location Code")
        {
            Clustered = true;
        }
    }
    procedure GetDefaultDescription(): Text[100]
    var
        ItemCategory: Record "Item Category";
        Location: Record Location;
        StockkeepingUnitTemplateDescTxt: Label '%1 on %2', Comment = '%1 = Item Category Description, %2 = Location Name';
        AllItemsTxt: Label 'All Items';
    begin
        if "Location Code" = '' then
            exit('');
        Location.Get("Location Code");
        if "Item Category Code" <> '' then
            ItemCategory.Get("Item Category Code")
        else
            ItemCategory.Description := CopyStr(AllItemsTxt, 1, MaxStrLen(ItemCategory.Description));
        exit(CopyStr(StrSubstNo(StockkeepingUnitTemplateDescTxt, ItemCategory.Description, Location.Name), 1, 100));
    end;
}
