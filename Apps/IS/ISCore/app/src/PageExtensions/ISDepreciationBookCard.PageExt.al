// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

pageextension 14603 "IS Depreciation Book Card" extends "Depreciation Book Card"
{
    layout
    {
        addafter("Allow Changes in Depr. Fields")
        {
            field("Revalue in Year Prch."; Rec."Revalue in Year Prch.")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if depreciation and appreciation are possible. The default value is No.';
#if not CLEAN24
                Visible = IsISCoreAppEnabled;
                Enabled = IsISCoreAppEnabled;
#endif
            }
            field("Residual Val. %"; Rec."Residual Val. %")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the percentage of the appreciated acquisition price to use when revaluing fixed assets.';
#if not CLEAN24
                Visible = IsISCoreAppEnabled;
                Enabled = IsISCoreAppEnabled;
#endif
            }
        }
    }
}
