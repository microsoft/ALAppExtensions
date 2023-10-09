// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Inventory.Ledger;

query 5280 "Qty. Item Ledger Entry SAF-T"
{
    QueryType = Normal;
    Access = Internal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            filter(Posting_Date_Filter; "Posting Date") { }
            column(Location_Code; "Location Code") { }
            column(Item_No_; "Item No.") { }
            column(Lot_No_; "Lot No.") { }
            column(Serial_No_; "Serial No.") { }
            column(Entry_No_; "Entry No.")
            {
                Method = Min;
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}
