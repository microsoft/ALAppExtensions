// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Sustainability.ExciseTax;

table 7413 "Excise Tax Item/FA Rate"
{
    Caption = 'Excise Tax Item/FA Rate';
    DataClassification = CustomerContent;
    LookupPageId = "Excise Tax Item/FA Rates";
    DrillDownPageId = "Excise Tax Item/FA Rates";

    fields
    {
        field(1; "Excise Tax Type Code"; Code[20])
        {
            Caption = 'Excise Tax Type Code';
            TableRelation = "Excise Tax Type".Code;
            NotBlank = true;
        }
        field(2; "Source Type"; Enum "Excise Source Type")
        {
            Caption = 'Source Type';
            NotBlank = true;
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Item)) Item
            else
            if ("Source Type" = const("Fixed Asset")) "Fixed Asset";

            trigger OnLookup()
            begin
                case "Source Type" of
                    "Source Type"::Item:
                        LookupItem();
                    "Source Type"::"Fixed Asset":
                        LookupFixedAsset();
                end;
            end;

            trigger OnValidate()
            begin
                if "Source No." <> '' then
                    ValidateSourceNo();
            end;
        }
        field(4; "Excise Duty"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Excise Duty';
            DecimalPlaces = 2 : 5;
            MinValue = 0;
        }
        field(5; "Effective From Date"; Date)
        {
            Caption = 'Effective From Date';
            NotBlank = true;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Excise Tax Type Code", "Source Type", "Source No.", "Effective From Date")
        {
            Clustered = true;
        }
        key(Key2; "Excise Tax Type Code")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("Excise Tax Type Code");
        TestField("Source Type");
        TestField("Effective From Date");
        if "Source No." <> '' then
            ValidateSourceNo();
    end;

    trigger OnModify()
    begin
        TestField("Excise Tax Type Code");
        TestField("Source Type");
        TestField("Effective From Date");
        if "Source No." <> '' then
            ValidateSourceNo();
    end;

    var
        ItemDoesNotExistErr: Label 'Item %1 does not exist.', Comment = '%1 = Item No.';
        FixedAssetDoesNotExistErr: Label 'Fixed Asset %1 does not exist.', Comment = '%1 = Fixed Asset No.';

    local procedure ValidateSourceNo()
    var
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
    begin
        case "Source Type" of
            "Source Type"::Item:
                if not Item.Get("Source No.") then
                    Error(ItemDoesNotExistErr, "Source No.");
            "Source Type"::"Fixed Asset":
                if not FixedAsset.Get("Source No.") then
                    Error(FixedAssetDoesNotExistErr, "Source No.");
        end;
    end;

    local procedure LookupItem()
    var
        Item: Record Item;
    begin
        if Page.RunModal(Page::"Item List", Item) = Action::LookupOK then
            "Source No." := Item."No.";
    end;

    local procedure LookupFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        if Page.RunModal(Page::"Fixed Asset List", FixedAsset) = Action::LookupOK then
            "Source No." := FixedAsset."No.";
    end;

    procedure GetEffectiveExciseDuty(TaxTypeCode: Code[20]; SourceType: Enum "Excise Source Type"; SourceNo: Code[20]; EffectiveDate: Date; var ExciseDuty: Decimal): Boolean
    begin
        if FindExciseDuty(TaxTypeCode, SourceType, SourceNo, EffectiveDate, ExciseDuty) then
            exit(true);

        if FindExciseDuty(TaxTypeCode, SourceType, '', EffectiveDate, ExciseDuty) then
            exit(true);
    end;

    local procedure FindExciseDuty(TaxTypeCode: Code[20]; SourceType: Enum "Excise Source Type"; SourceNo: Code[20]; EffectiveDate: Date; var ExciseDuty: Decimal): Boolean
    var
        ExciseTaxItemFARate: Record "Excise Tax Item/FA Rate";
    begin
        ExciseTaxItemFARate.SetCurrentKey("Excise Tax Type Code", "Source Type", "Source No.", "Effective From Date");
        ExciseTaxItemFARate.SetRange("Excise Tax Type Code", TaxTypeCode);
        ExciseTaxItemFARate.SetRange("Source Type", SourceType);
        ExciseTaxItemFARate.SetRange("Source No.", SourceNo);
        ExciseTaxItemFARate.SetFilter("Effective From Date", '<=%1', EffectiveDate);
        if not ExciseTaxItemFARate.FindLast() then
            exit(false);

        ExciseDuty := ExciseTaxItemFARate."Excise Duty";
        exit(true);
    end;

    procedure ConvertSustSourceTypeToExciseSourceType(SustSourceType: Enum "Sust. Excise Jnl. Source Type"): Enum "Excise Source Type"
    begin
        case SustSourceType of
            "Sust. Excise Jnl. Source Type"::Item:
                exit("Excise Source Type"::Item);
            "Sust. Excise Jnl. Source Type"::"Fixed Asset":
                exit("Excise Source Type"::"Fixed Asset");
        end;

        exit("Excise Source Type"::" ");
    end;
}