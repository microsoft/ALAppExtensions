// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.History;

pageextension 31256 "Posted Assembly Order Subf CZA" extends "Posted Assembly Order Subform"
{
    layout
    {
        addbefore("Shortcut Dimension 1 Code")
        {
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the General Business Posting Group that applies to the entry.';
                Visible = false;
            }
        }
    }
}
