// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

using Microsoft.FixedAssets.FADepreciation;

tableextension 18631 "Depreciation Book Ext" extends "Depreciation Book"
{
    fields
    {
        field(18631; "No. of Days Non Seasonal"; Integer)
        {
            Caption = 'No. of Days Non Seasonal';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("FA Book Type", 0);
            end;
        }
        field(18632; "No. of Days Seasonal"; Integer)
        {
            Caption = 'No. of Days Seasonal';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("FA Book Type", 0);
            end;
        }
        field(18633; "FA Book Type"; Enum "Fixed Asset Book Type")
        {
            Caption = 'FA Book Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "FA Book Type" = "FA Book Type"::"Income Tax" then begin
                    TestField("Fiscal Year 365 Days", false);
                    TestField("No. of Days Non Seasonal", 0);
                    TestField("No. of Days Seasonal", 0);
                end;
            end;
        }
        field(18634; "Depr. Threshold Days"; Integer)
        {
            Caption = 'Depr. Threshold Days';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18635; "Depr. Reduction %"; Decimal)
        {
            Caption = 'Depr. Reduction %';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}
