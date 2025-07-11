// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31228 "Posted Direct Trans. Sub. CZA" extends "Posted Direct Transfer Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group.';
            }
        }
    }
}
