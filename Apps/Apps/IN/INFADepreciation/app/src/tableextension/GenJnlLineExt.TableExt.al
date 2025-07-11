// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.FixedAssets.FADepreciation;

tableextension 18636 "Gen. Jnl Line Ext" extends "Gen. Journal Line"
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
                FixedAssetShift.SetRange("FA No.", "Account No.");
                FixedAssetShift.SetRange("Depreciation Book Code", "Depreciation Book Code");
                if Page.RunModal(Page::"Fixed Asset Shifts", FixedAssetShift) = Action::LookupOK then
                    "FA Shift Line No." := FixedAssetShift."Line No.";
            end;
        }
        field(18632; "Shift Type"; Enum "Shift Type")
        {
            Caption = 'Shift Type';
            DataClassification = CustomerContent;
        }
        field(18633; "Industry Type"; Enum "Industry Type")
        {
            Caption = 'Industry Type';
            DataClassification = CustomerContent;
        }
        field(18634; "No. of Days for Shift"; Integer)
        {
            Caption = 'No. of Days for Shift';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}
