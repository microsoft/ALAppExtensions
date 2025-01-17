// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31238 "Transfer Route Spec. CZA" extends "Transfer Route Specification"
{
    layout
    {
        addlast(General)
        {
            field("Gen.Bus.Post.Group Ship CZA"; Rec."Gen.Bus.Post.Group Ship CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for items ship.';
            }
            field("Gen.Bus.Post.Group Receive CZA"; Rec."Gen.Bus.Post.Group Receive CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for itemsreceive.';
            }
        }
    }
}
