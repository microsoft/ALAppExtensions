// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.RoleCenters;

pageextension 31143 "Finance Manager RC CZF" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Group45)
        {
            action(FAHistoryCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset History';
                RunObject = report "Fixed Asset History CZF";
                ToolTip = 'Print or preview Fixed Asset History report.';
            }
            action(FAAssignmentDiscardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Assignment/Discard';
                RunObject = report "FA Assignment/Discard CZF";
                ToolTip = 'Print or preview Fixed Asset Assignment/Discard report.';
            }
            action(FAAnalysisCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis';
                RunObject = report "Fixed Asset - Analysis CZF";
                ToolTip = 'Print or preview Fixed Asset - Analysis report.';
            }
            action(FAAnalysisGLAccountCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis G/L Account';
                RunObject = report "FA - Analysis G/L Account CZF";
                ToolTip = 'Print or preview FA - Analysis G/L Account report.';
            }
            action(FixedAssetAnalysDepBookCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis Depreciation Book';
                RunObject = report "Fixed Asset - An. Dep.Book CZF";
                ToolTip = 'Print or preview FA - Analysis Depreciation Book report.';
            }
            action(FAPhysicalInventoryListCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Physical Inventory List';
                RunObject = report "FA Physical Inventory List CZF";
                ToolTip = 'Print or preview FA Physical Inventory List report.';
            }
            action(FixedAssetCardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Card';
                RunObject = report "Fixed Asset Card CZF";
                ToolTip = 'Print or preview Fixed Asset Card report.';
            }
            action(FixedAssetBookValue1CZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Book Value 01';
                RunObject = report "Fixed Asset - Book Value 1 CZF";
                ToolTip = 'Print or preview Fixed Asset - Book Value 1 report.';
            }
        }
    }
}
