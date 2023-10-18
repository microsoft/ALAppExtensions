// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

using Microsoft.FixedAssets.FADepreciation;
using Microsoft.FixedAssets.FixedAsset;

tableextension 18632 "FA Depreciation Book Ext" extends "FA Depreciation Book"
{
    fields
    {
        modify("Depreciation Book Code")
        {
            trigger OnAfterValidate()
            var
                DeprBook: Record "Depreciation Book";
            begin
                if "Depreciation Book Code" <> '' then begin
                    DeprBook.Get("Depreciation Book Code");
                    "FA Book Type" := DeprBook."FA Book Type";
                end;
            end;
        }
        field(18631; "FA Book Type"; Enum "Fixed Asset Book Type")
        {
            Caption = 'FA Book Type';
            DataClassification = CustomerContent;
        }
        field(18632; "FA Block Code"; Code[10])
        {
            Caption = 'FA Block Code';
            DataClassification = CustomerContent;
            TableRelation = "Fixed Asset Block".Code;
        }
    }

    procedure UpdateDeprPercent()
    var
        FixedAssetBlock: Record "Fixed Asset Block";
        FixedAsset: Record "Fixed Asset";
    begin
        if Rec."FA Book Type" <> Rec."FA Book Type"::"Income Tax" then
            exit;

        FixedAsset.Get(Rec."FA No.");
        FixedAsset.TestField("FA Class Code");
        FixedAsset.TestField("FA Block Code");
        FixedAssetBlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");

        if (FixedAssetBlock."FA Class Code" <> FixedAsset."FA Class Code") or (FixedAssetBlock.Code <> FixedAsset."FA Block Code") then
            FixedAssetBlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");

        FixedAssetBlock.TestField("Depreciation %");

        case Rec."Depreciation Method" of
            Rec."Depreciation Method"::"Straight-Line":
                Rec."Straight-Line %" := FixedAssetBlock."Depreciation %";
            Rec."Depreciation Method"::"Declining-Balance 1":
                Rec."Declining-Balance %" := FixedAssetBlock."Depreciation %";
            Rec."Depreciation Method"::"Declining-Balance 2":
                Rec."Declining-Balance %" := FixedAssetBlock."Depreciation %";
            Rec."Depreciation Method"::"DB1/SL":
                begin
                    Rec."Straight-Line %" := FixedAssetBlock."Depreciation %";
                    Rec."Declining-Balance %" := FixedAssetBlock."Depreciation %";
                end;
            Rec."Depreciation Method"::"DB2/SL":
                begin
                    Rec."Straight-Line %" := FixedAssetBlock."Depreciation %";
                    Rec."Declining-Balance %" := FixedAssetBlock."Depreciation %";
                end;
            Rec."Depreciation Method"::"User-Defined":
                Rec.FieldError("Depreciation Method");
        end;
    end;
}
