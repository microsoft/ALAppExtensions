// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Journal;

using Microsoft.FixedAssets.FADepreciation;
using Microsoft.Inventory.Location;

tableextension 18633 "FA Journal Line Ext" extends "FA Journal Line"
{
    fields
    {
        field(18631; "FA Shift Line No."; Integer)
        {
            Caption = 'FA Shift Line No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                FixedAssetShift: Record "Fixed Asset Shift";
            begin
                FixedAssetShift.Reset();
                FixedAssetShift.SetRange("FA No.", "FA No.");
                FixedAssetShift.SetRange("Depreciation Book Code", "Depreciation Book Code");
                if Page.RunModal(Page::"Fixed Asset Shifts", FixedAssetShift) = Action::LookupOK then
                    "FA Shift Line No." := FixedAssetShift."Line No.";
            end;
        }
        field(18632; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(18633; "Shift Type"; Enum "Shift Type")
        {
            Caption = 'Shift Type';
            DataClassification = CustomerContent;
        }
        field(18634; "Industry Type"; Enum "Industry Type")
        {
            Caption = 'Industry Type';
            DataClassification = CustomerContent;
        }
        field(18635; "No. of Days for Shift"; Integer)
        {
            Caption = 'No. of Days for Shift';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}
