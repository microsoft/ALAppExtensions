// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;

pageextension 31248 "Fixed Asset Card CZF" extends "Fixed Asset Card"
{
    layout
    {
        modify(FAPostingGroup)
        {
            trigger OnBeforeValidate()
            begin
                if FADepreciationBook."FA Posting Group" <> FADepreciationBookOld."FA Posting Group" then
                    FADepreciationBook.CheckDefaultFAPostingGroupCZF();
            end;
        }
        addafter("Responsible Employee")
        {
            field("Tax Deprec. Group Code CZF"; Rec."Tax Deprec. Group Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the tax deprecation book.';
                Visible = false;
            }
            field("Classification Code CZF"; Rec."Classification Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the fixed asset''s classification (CZ-CC, CZ-CPA, DNM).';
            }
        }
    }
    actions
    {
        modify(Acquire)
        {
            Visible = false;
        }
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
