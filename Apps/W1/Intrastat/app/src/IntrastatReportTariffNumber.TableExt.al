// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;

tableextension 4819 "Intrastat Report Tariff Number" extends "Tariff Number"
{
    fields
    {
        modify("Supplementary Units")
        {
            trigger OnAfterValidate()
            begin
                if not "Supplementary Units" then begin
                    Validate("Suppl. Conversion Factor", 0);
                    Validate("Suppl. Unit of Measure", '');
                end;
            end;
        }
        field(4810; "Suppl. Conversion Factor"; Decimal)
        {
            Caption = 'Conversion Factor';

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUOM: Record "Item Unit of Measure";
            begin
                if "Suppl. Conversion Factor" <> 0 then
                    TestField("Supplementary Units", true);

                if not SkipValidationLogic then
                    if "Suppl. Unit of Measure" <> '' then
                        if Confirm(StrSubstNo(UpdateItemsQst, FieldCaption("Suppl. Conversion Factor"))) then begin
                            Item.SetRange("Tariff No.", "No.");
                            if Item.FindSet() then
                                repeat
                                    if ItemUOM.Get(Item."No.", "Suppl. Unit of Measure") then
                                        IntrastatReportMgt.UpdateItemUOM(ItemUOM, Rec);
                                until Item.Next() = 0;
                        end;
            end;
        }
        field(4811; "Suppl. Unit of Measure"; Text[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUOM: Record "Item Unit of Measure";
                FA: Record "Fixed Asset";
            begin
                if "Suppl. Unit of Measure" <> '' then
                    TestField("Supplementary Units", true);

                if not SkipValidationLogic then
                    if Confirm(StrSubstNo(UpdateItemsQst, FieldCaption("Suppl. Unit of Measure"))) then begin
                        Item.SetRange("Tariff No.", "No.");
                        if Item.FindSet() then
                            repeat
                                if "Suppl. Unit of Measure" <> '' then begin
                                    if not ItemUOM.Get(Item."No.", "Suppl. Unit of Measure") then begin
                                        ItemUOM.Init();
                                        ItemUOM.Validate("Item No.", Item."No.");
                                        ItemUOM.Validate(Code, "Suppl. Unit of Measure");
                                        ItemUOM.Insert(true);
                                    end;

                                    IntrastatReportMgt.UpdateItemUOM(ItemUOM, Rec);
                                end;
                                Item.Validate("Supplementary Unit of Measure", "Suppl. Unit of Measure");
                                Item.Modify(true);
                            until Item.Next() = 0;

                        FA.SetRange("Tariff No.", "No.");
                        if not FA.IsEmpty then
                            FA.ModifyAll("Supplementary Unit of Measure", "Suppl. Unit of Measure");
                    end;
            end;
        }
    }

    procedure SetSkipValidationLogic(SkipValidationLogic2: Boolean)
    begin
        SkipValidationLogic := SkipValidationLogic2;
    end;

    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        UpdateItemsQst: Label 'You have modified %1.\Do you want to update related items?', Comment = '%1=Changed Field Name';
        SkipValidationLogic: Boolean;
}