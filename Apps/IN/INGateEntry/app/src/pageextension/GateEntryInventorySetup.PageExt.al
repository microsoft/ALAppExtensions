// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

pageextension 18601 "Gate Entry Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Inward Gate Entry Nos."; Rec."Inward Gate Entry Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series from which numbers are assigned to new Gate Entry Inward documents.';
            }
            field("Outward Gate Entry Nos."; Rec."Outward Gate Entry Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series from which numbers are assigned to new Gate Entry Outward documents.';
            }
        }
    }
}
