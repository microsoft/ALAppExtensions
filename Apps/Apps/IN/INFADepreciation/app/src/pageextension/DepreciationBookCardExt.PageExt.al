// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

pageextension 18631 "Depreciation Book Card Ext" extends "Depreciation Book Card"
{
    layout
    {
        addafter("Subtract Disc. in Purch. Inv.")
        {
            field("No. of Days Non Seasonal"; Rec."No. of Days Non Seasonal")
            {
                ToolTip = 'Specifies the maximum number of days in seasonal industry.';
                ApplicationArea = FixedAssets;
            }
            field("No. of Days Seasonal"; Rec."No. of Days Seasonal")
            {
                ToolTip = 'Specifies the maximum number of days in non-seasonal industry.';
                ApplicationArea = FixedAssets;
            }
            field("FA Book Type"; Rec."FA Book Type")
            {
                ToolTip = 'Specifies if the FA Book Type is Income tax.';
                ApplicationArea = FixedAssets;

                trigger OnValidate()
                begin
                    if Rec."FA Book Type" = Rec."FA Book Type"::"Income Tax" then begin
                        DeprThresholdDaysVisible := true;
                        DeprReductionPercentVisible := true;
                    end;
                end;
            }
            field("Depr. Threshold Days"; Rec."Depr. Threshold Days")
            {
                ToolTip = 'Specifies the threshold days for depreciation calculation.';
                ApplicationArea = FixedAssets;
                Visible = DeprThresholdDaysVisible;
            }
            field("Depr. Reduction %"; Rec."Depr. Reduction %")
            {
                ToolTip = 'Specifies the depreciation reduction % for the depreciation book.';
                ApplicationArea = FixedAssets;
                Visible = DeprReductionPercentVisible;
            }
        }
    }

    var
        DeprThresholdDaysVisible: Boolean;
        DeprReductionPercentVisible: Boolean;
}
