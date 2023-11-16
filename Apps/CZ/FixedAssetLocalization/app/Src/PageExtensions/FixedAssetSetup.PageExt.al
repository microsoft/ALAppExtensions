// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Setup;

pageextension 31249 "Fixed Asset Setup CZF" extends "Fixed Asset Setup"
{
    layout
    {
        addafter("Default Depr. Book")
        {
            field("Tax Depreciation Book CZF"; Rec."Tax Depreciation Book CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the default tax deprecation book.';
            }
        }
        addlast(General)
        {
            field("Fixed Asset History CZF"; Rec."Fixed Asset History CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies save changes in location and responsibility for asset.';
            }
            field("FA Acquisition As Custom 2 CZF"; Rec."FA Acquisition As Custom 2 CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies to use fixed asset acquisition as custom field 2. This option allows a two-step acquisition process.';
            }
        }
        addlast(Numbering)
        {
            field("Fixed Asset History Nos. CZF"; Rec."Fixed Asset History Nos. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies no. series used as document no. in fixed asset history entries.';

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
        }
    }
    actions
    {
        addafter("Depreciation Tables")
        {
            action(TaxDepreciationGroups)
            {
                Caption = 'Tax Depreciation Groups';
                ApplicationArea = FixedAssets;
                Image = TaxSetup;
                ToolTip = 'Set up Tax Depreciation Groups for Fixes Assets. These groups determine minimal depreciation periods and parameters used for calculating tax depreciation.';
                RunObject = page "Tax Depreciation Groups CZF";
                RunPageMode = View;
            }
        }
    }
}
