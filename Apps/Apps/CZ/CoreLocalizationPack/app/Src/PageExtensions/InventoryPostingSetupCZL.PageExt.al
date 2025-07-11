// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

pageextension 31164 "Inventory Posting Setup CZL" extends "Inventory Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Consumption Account CZL"; Rec."Consumption Account CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the production consumption account for inventory posting.';
            }
            field("Change In Inv.Of WIP Acc. CZL"; Rec."Change In Inv.Of WIP Acc. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies balancing accout when a change has been made to the work in process (WIP) inventory account. This account is used for inventory posting.';
            }
            field("Change In Inv.OfProd. Acc. CZL"; Rec."Change In Inv.OfProd. Acc. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies balancing accout when a change has been made to the product inventory account. This account is used for inventory posting.';
            }
        }
    }
}
