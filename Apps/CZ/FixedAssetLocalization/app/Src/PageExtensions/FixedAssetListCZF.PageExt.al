// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;

pageextension 31244 "Fixed Asset List CZF" extends "Fixed Asset List"
{
    actions
    {
        addlast(History)
        {
            action(FAHistoryCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA History Entries';
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "FA History Entries CZF";
                RunPageLink = "FA No." = field("No.");
                RunPageView = sorting("FA No.");
                ToolTip = 'Open fixed asset history entries.';
            }
        }
        addlast(reporting)
        {
            action(FixedAssetHistoryCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset History';
                Image = PrintReport;
                RunObject = Report "Fixed Asset History CZF";
                ToolTip = 'The report prints fixed asset history entries.';
            }
            action(FAAssignmentDiscardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Assignment/Discard';
                Image = PrintAcknowledgement;
                Ellipsis = true;
                RunObject = Report "FA Assignment/Discard CZF";
                ToolTip = 'The report prints fixed assignment/discard protocol.';
            }
            action(FAAnalysisCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis';
                Image = PrintReport;
                RunObject = report "Fixed Asset - Analysis CZF";
                ToolTip = 'Print or preview Fixed Asset - Analysis report.';
            }
            action(FAAnalysisGLAccountCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis G/L Account';
                Image = PrintReport;
                RunObject = report "FA - Analysis G/L Account CZF";
                ToolTip = 'Print or preview FA - Analysis G/L Account report.';
            }
            action(FixedAssetAnalysDepBookCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA - Analysis Depreciation Book';
                Image = PrintReport;
                RunObject = report "Fixed Asset - An. Dep.Book CZF";
                ToolTip = 'Print or preview FA - Analysis Depreciation Book report.';
            }
            action(FAPhysicalInventoryListCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Physical Inventory List';
                Image = PrintReport;
                RunObject = report "FA Physical Inventory List CZF";
                ToolTip = 'Print or preview FA Physical Inventory List report.';
            }
            action(FixedAssetAcquisitionCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Acquisition';
                Image = PrintReport;
                RunObject = Report "Fixed Asset Acquisition CZF";
                ToolTip = 'The report prints fixed asset acquisition.';
            }
            action(FixedAssetDisposalCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Disposal';
                Image = PrintReport;
                RunObject = Report "Fixed Asset Disposal CZF";
                ToolTip = 'The report prints fixed assets disposal.';
            }
            action(FixedAssetCardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Card';
                Image = FixedAssets;
                RunObject = Report "Fixed Asset Card CZF";
                ToolTip = 'The report prints fixed assets card and entries.';
            }
        }
    }
}
