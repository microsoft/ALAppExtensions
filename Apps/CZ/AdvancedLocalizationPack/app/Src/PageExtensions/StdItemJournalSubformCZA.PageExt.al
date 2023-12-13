// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

pageextension 31262 "Std. Item Journal Subform CZA" extends "Standard Item Journal Subform"
{
    layout
    {
        addafter("Location Code")
        {
            field("New Location Code CZA"; Rec."New Location Code CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies the code of the location that you are transferring items to.';
            }
        }
    }
}
