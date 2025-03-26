// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.History;

pageextension 31255 "Posted Assembly Order CZA" extends "Posted Assembly Order"
{
    layout
    {
        addlast(Posting)
        {
#if not CLEAN27
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the General Business Posting Group that applies to the entry.';
                ObsoleteState = Pending;
                ObsoleteTag = '27.0';
                ObsoleteReason = 'Replaced by "Gen. Bus. Post. Group" field in Posted Assembly Header Name table.';
                Visible = false;
                Enabled = false;
            }
#endif
        }
    }
}
