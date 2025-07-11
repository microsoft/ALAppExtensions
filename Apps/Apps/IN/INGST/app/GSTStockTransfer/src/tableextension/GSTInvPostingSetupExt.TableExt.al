// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;

tableextension 18390 "GST Inv. Posting Setup Ext" extends "Inventory Posting Setup"
{
    fields
    {
        field(18390; "Unrealized Profit Account"; Code[20])
        {
            Caption = 'Unrealized Profit Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
    }
}
