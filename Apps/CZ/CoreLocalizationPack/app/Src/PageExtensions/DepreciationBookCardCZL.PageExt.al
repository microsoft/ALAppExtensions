// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

pageextension 11783 "Depreciation Book Card CZL" extends "Depreciation Book Card"
{
    layout
    {
        addlast(General)
        {
            field("Mark Reclass. as Correct. CZL"; Rec."Mark Reclass. as Correct. CZL")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies to post reclassification as corrections.';
            }
        }
    }
}
