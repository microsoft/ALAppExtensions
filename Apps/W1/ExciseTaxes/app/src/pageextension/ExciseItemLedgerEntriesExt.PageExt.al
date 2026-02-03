// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.Inventory.Ledger;

pageextension 7419 "Excise Item Ledger Entries Ext" extends "Item Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Excise Tax Posted"; Rec."Excise Tax Posted")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether excise tax has been posted for this item ledger entry.';
            }
        }
    }
}