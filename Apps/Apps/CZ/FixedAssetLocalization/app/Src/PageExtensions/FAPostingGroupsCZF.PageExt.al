// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;

pageextension 31168 "FA Posting Groups CZF" extends "FA Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("Acq. Cost Bal. Acc. Disp. CZF"; Rec."Acq. Cost Bal. Acc. Disp. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the general ledger account for acquisition cost balance account on disposal.';
                Visible = false;
            }
            field("Book Value Bal. Acc. Disp. CZF"; Rec."Book Value Bal. Acc. Disp. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the general ledger account for book value balance account on disposal.';
                Visible = false;
            }
        }
    }
    actions
    {
        addfirst("P&osting Gr.")
        {
            action(ExtendedPostingGroupsCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = '&Extended Posting Groups';
                Image = Splitlines;
                RunObject = Page "FA Extended Posting Groups CZF";
                RunPageLink = "FA Posting Group Code" = field(Code);
                ToolTip = 'Allows the setup extended postig group.';
            }
        }
    }
}
