// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Document;

pageextension 11715 "Physical Invt. Order Subf. CZL" extends "Physical Inventory Order Subf."
{
    layout
    {
        addafter("Unit Cost")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the template for item movement.';
            }
            field("Gen. Bus. Posting Group CZL"; Rec."Gen. Bus. Posting Group")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the trade type to link transactions with the appropriate general ledger account according to the general posting setup.';
            }
        }
    }
}
