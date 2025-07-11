// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.History;

pageextension 31176 "Posted Invt. Shipments CZL" extends "Posted Invt. Shipments"
{
    layout
    {
        addlast(Control1)
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
                Editable = false;
            }
        }
    }
}
