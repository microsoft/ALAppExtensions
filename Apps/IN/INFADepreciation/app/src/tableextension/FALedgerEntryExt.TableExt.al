// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Ledger;

using Microsoft.FixedAssets.FADepreciation;

tableextension 18634 "FA Ledger Entry Ext" extends "FA Ledger Entry"
{
    fields
    {
        field(18631; "FA Block Code"; Code[10])
        {
            Caption = 'FA Block Code';
            DataClassification = CustomerContent;
            TableRelation = "Fixed Asset Block".Code where("FA Class Code" = field("FA Class Code"));
        }
        field(18632; "FA Book Type"; Enum "Fixed Asset Book Type")
        {
            Caption = 'FA Book Type';
            DataClassification = CustomerContent;
        }
        field(18633; "Add. Depreciation"; Boolean)
        {
            Caption = 'Add. Depreciation';
            DataClassification = CustomerContent;
        }
        field(18634; "Add. Depreciation Amount"; Decimal)
        {
            Caption = 'Add. Depreciation Amount';
            DataClassification = CustomerContent;
        }
        field(18635; "Depr. Reduction Applied"; Boolean)
        {
            Caption = 'Depr. Reduction Applied';
            DataClassification = CustomerContent;
        }
        field(18636; CWIP; Boolean)
        {
            Caption = 'CWIP';
            DataClassification = CustomerContent;
        }
        field(18637; "Shift Type"; enum "Shift Type")
        {
            Caption = 'Shift Type';
            DataClassification = CustomerContent;
        }
        field(18638; "Industry Type"; enum "Industry Type")
        {
            Caption = 'Industry Type';
            DataClassification = CustomerContent;
        }
        field(18639; "Shift Entry"; Boolean)
        {
            Caption = 'Shift Entry';
            DataClassification = CustomerContent;
        }
        field(18640; "No. of Days for Shift"; Integer)
        {
            Caption = 'No. of Days for Shift';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("FA Book Type", 0);
            end;
        }
        field(18641; "FA Shift Line No"; Integer)
        {
            Caption = 'FA Shift Line No.';
            DataClassification = CustomerContent;
        }
    }
}
