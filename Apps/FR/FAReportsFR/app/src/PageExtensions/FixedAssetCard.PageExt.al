#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.FixedAssets.FixedAsset;

pageextension 10801 "Fixed Asset Card" extends "Fixed Asset Card"
{
    actions
    {
        addafter("FA Book Val. - Appr. & Write-D")
        {
            action("Projected Value (Derogatory) FR")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Projected Value (Derogatory)';
                Image = "Report";
                RunObject = Report "FA-Proj. Value (Derogatory) FR";
                ToolTip = 'View the calculated future derogatory depreciation and book value. You can view the report for one derogatory depreciation book at a time.';
            }
        }
        addfirst(Category_Report)
        {
            actionref("Projected Value (Derogatory)_PromotedFR"; "Projected Value (Derogatory) FR")
            {
            }
        }
    }
}
#endif