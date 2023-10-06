// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Setup;

using Microsoft.FixedAssets.FADepreciation;

pageextension 18632 "Fixed Asset Classes Ext" extends "FA Classes"
{
    actions
    {
        addlast(Navigation)
        {
            action("&Blocks")
            {
                Caption = '&Blocks';
                ApplicationArea = FixedAssets;
                Image = Category;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Fixed Asset Blocks";
                RunPageLink = "FA Class Code" = field(Code);
                ToolTip = 'Specifies the blocks assigned to Fixed Asset Class.';
            }
        }
    }
}
