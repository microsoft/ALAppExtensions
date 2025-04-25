// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using System.Security.User;

pageextension 11799 "Location Card CZL" extends "Location Card"
{
    actions
    {
        addafter(Dimensions)
        {
            action(IncDecQtyPerLocCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Increase/Decrease Quantity per Location';
                Image = UserSetup;
                ToolTip = 'Edit user permission settings to increase/decrease the quantity per location.';
                RunObject = Page "Inc./Dec. Qty. per Loc. CZL";
                RunPageLink = Code = field(Code);
            }
        }
    }
}