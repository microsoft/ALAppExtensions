// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;

pageextension 31169 "FA Allocations CZF" extends "FA Allocations"
{
    layout
    {
        addafter("Allocation %")
        {
            field("Reason/Maintenance Code CZF"; Rec."Reason/Maintenance Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the reason code on the entry.';
            }
        }
    }
}
