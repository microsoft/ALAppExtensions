// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;

pageextension 31147 "FA Depreciation Books CZF" extends "FA Depreciation Books"
{
    layout
    {
        addafter("Depreciation Book Code")
        {
            field("Tax Deprec. Group Code CZF"; Rec."Tax Deprec. Group Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies a tax depreciation book that you have set up to assign it to the fixed asset you have entered in the FA No. field.';
                Visible = false;
            }
        }
    }
}
