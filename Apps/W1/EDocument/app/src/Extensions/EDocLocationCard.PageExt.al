// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

pageextension 6104 "E-Doc. Location Card" extends "Location Card"
{
    layout
    {
        addlast(Warehouse)
        {
            group("E-Documents")
            {
                Caption = 'E-Documents';

                field("Transfer Doc. Sending Profile"; Rec."Transfer Doc. Sending Profile")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
