// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Ledger;

table 18632 "Fixed Asset Block"
{
    Caption = 'Fixed Asset Block';
    LookupPageID = "Fixed Asset Blocks";

    fields
    {
        field(1; "FA Class Code"; Code[10])
        {
            Caption = 'FA Class Code';
            TableRelation = "FA Class";
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                FixedAssetBlock: Record "Fixed Asset Block";
            begin
                FixedAssetBlock.Reset();
                FixedAssetBlock.SetRange(Code, Code);
                if not FixedAssetBlock.IsEmpty() then
                    Error(FABlockErr);
            end;
        }
        field(3; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Depreciation %"; Decimal)
        {
            Caption = 'Depreciation %';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateDeprPercent()
            end;
        }
        field(5; "Add. Depreciation %"; Decimal)
        {
            Caption = 'Add. Depreciation %';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(6; "No. of Assets"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("FA Depreciation Book" where(
                "FA Book Type" = filter("Income Tax"),
                "FA Block Code" = field("Code"),
                "Disposal Date" = filter('')));
            Caption = 'No. of Assets';
            Editable = false;
        }
        field(7; "Book Value"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA Block Code" = field("Code"),
                "FA Book Type" = filter("Income Tax"),
                "FA Posting Category" = filter(' '),
                "FA Posting Type" = filter(
                    "Acquisition Cost" |
                    Depreciation |
                    "Proceeds on Disposal" |
                    "Write-Down" |
                    Appreciation |
                    "Salvage Value")));
            Caption = 'Book Value';
            Editable = false;
        }
        field(8; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(9; "No. of Assets at Date"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("FA Depreciation Book" where(
                "FA Book Type" = filter("Income Tax"),
                "FA Block Code" = field("Code"),
                "Disposal Date" = field("Date Filter")));
            Caption = 'No. of Assets at Date';
        }
    }

    keys
    {
        key(Key1; "FA Class Code", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "FA Class Code")
        {
        }
    }

    trigger OnDelete()
    var
        FALedgEntry: Record "FA Ledger Entry";
    begin
        FALedgEntry.Reset();
        FALedgEntry.SetCurrentKey("FA Block Code");
        FALedgEntry.SetRange("FA Block Code", Code);
        if FALedgEntry.FindFirst() then
            Error(FALedgEntryErr, FALedgEntry.TableCaption, Code);
    end;

    var
        FALedgEntryErr: Label '%1 exists for the block %2.', Comment = '%1 = Table Caption, %2 = Code';
        FABlockErr: Label 'The record already exists.';

    local procedure UpdateDeprPercent()
    var
        FADeprBook: Record "FA Depreciation Book";
    begin
        FADeprBook.Reset();
        FADeprBook.SetRange("FA Book Type", FADeprBook."FA Book Type"::"Income Tax");
        FADeprBook.SetRange("FA Block Code", "Code");
        if FADeprBook.FindSet() then
            repeat
                FADeprBook.UpdateDeprPercent();
            until FADeprBook.Next() = 0;
    end;
}
