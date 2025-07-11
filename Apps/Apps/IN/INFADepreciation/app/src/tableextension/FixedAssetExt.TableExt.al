// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FixedAsset;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FADepreciation;

tableextension 18635 "Fixed Asset Ext" extends "Fixed Asset"
{
    fields
    {
        field(18631; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
            DataClassification = CustomerContent;
        }
        field(18632; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group".Code;
            DataClassification = CustomerContent;
        }
        field(18633; "VAT Product Posting Group"; Code[10])
        {
            Caption = 'VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(18634; "FA Block Code"; Code[10])
        {
            Caption = 'FA Block Code';
            TableRelation = "Fixed Asset Block".Code where("FA Class Code" = field("FA Class Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                FABlockCodeOnValidate();
            end;
        }
        field(18635; "Add. Depr. Applicable"; Boolean)
        {
            Caption = 'Add. Depr. Applicable';
            DataClassification = CustomerContent;
        }
    }

    var
        DeleteFALineErr: Label 'Delete the FA Lines for book type Income Tax before deleting the block code.';

    local procedure FABlockCodeOnValidate()
    var
        FaDeprBook2: Record "FA Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
    begin
        if (xRec."FA Block Code" <> '') and (Rec."FA Block Code" = '') then begin
            FaDeprBook2.Reset();
            FaDeprBook2.SetRange("FA No.", "No.");
            FaDeprBook2.SetRange("FA Book Type", FaDeprBook2."FA Book Type"::"Income Tax");
            FaDeprBook2.SetRange("FA Block Code", xRec."FA Block Code");
            if not FaDeprBook2.IsEmpty() then
                Error(DeleteFALineErr);
        end;
        if (xRec."FA Block Code" <> "FA Block Code") then begin
            FADeprBook.SetCurrentKey("FA No.");
            FADeprBook.SetRange("FA No.", "No.");
            if FADeprBook.FindSet() then
                FADeprBook.ModifyAll("FA Block Code", "FA Block Code");
        end;
    end;
}
