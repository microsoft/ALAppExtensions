// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Journal;

pageextension 31214 "Recur. Fixed Asset Journal CZF" extends "Recurring Fixed Asset Journal"
{
    layout
    {
        addbefore(Amount)
        {
            field("Correction CZF"; Rec.Correction)
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the entry as a corrective entry. You can use the field if you need to post a corrective entry to an account.';
                Visible = false;
            }
        }
        addafter("Maintenance Code")
        {
            field("Reason Code CZF"; Rec."Reason Code")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the reason code on the entry.';
            }
        }
    }
}
