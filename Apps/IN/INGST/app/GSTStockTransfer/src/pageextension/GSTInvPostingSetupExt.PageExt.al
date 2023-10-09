// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Inventory.Item;

pageextension 18390 "GST Inv. Posting Setup Ext" extends "Inventory Posting Setup"
{
    layout
    {
        addafter("Inventory Account")
        {
            field("Unrealized Profit Account"; Rec."Unrealized Profit Account")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of general ledger account to which to post unrealized profit for items in this combination.';
            }
        }
    }
}
