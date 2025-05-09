// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;

pageextension 31146 "FA Depr. Books Subform CZF" extends "FA Depreciation Books Subform"
{
    layout
    {
        modify("FA Posting Group")
        {
            trigger OnBeforeValidate()
            begin
                if Rec."FA Posting Group" <> xRec."FA Posting Group" then
                    Rec.CheckDefaultFAPostingGroupCZF();
            end;
        }
        addafter("FA Posting Group")
        {
            field("Tax Deprec. Group Code CZF"; Rec."Tax Deprec. Group Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies group code for tax depreciation of assets.';
            }
        }
        addlast(Control1)
        {
            field("Deprec. Interrupted up to CZF"; Rec."Deprec. Interrupted up to CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the end date of depreciation interruption.';
            }
            field("Keep Deprec. Ending Date CZF"; Rec."Keep Deprec. Ending Date CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies to use the depreciation ending date for depreciation book.';
            }
            field("Sum. Deprec. Entries From CZF"; Rec."Sum. Deprec. Entries From CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the depreciation book, which will be used for summarize of depreciation entries.';
            }
            field("Prorated CZF"; Rec."Prorated CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if the accounting depreciation is tol be calculated according to tax depreciation on a monthly basis.';
            }
        }
    }
}