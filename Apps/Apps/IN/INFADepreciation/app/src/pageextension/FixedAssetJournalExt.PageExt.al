// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Journal;

pageextension 18635 "Fixed Asset Journal Ext" extends "Fixed Asset Journal"
{
    layout
    {
        addafter("FA Reclassification Entry")
        {
            field("FA Shift Line No."; Rec."FA Shift Line No.")
            {
                Visible = false;
                ToolTip = 'Specifies the line number of FA shift being used in journal entry.';
                ApplicationArea = FixedAssets;
            }
        }
    }
}
