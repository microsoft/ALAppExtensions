// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Inventory.Ledger;

query 5283 "Item Ledger Entry SAF-T"
{
    QueryType = Normal;
    Access = Internal;
    DataAccessIntent = ReadOnly;
    OrderBy = ascending(Document_Type, Entry_Type, Document_No_);

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            filter(Posting_Date_Filter; "Posting Date") { }
            column(Entry_Type; "Entry Type") { }
            column(Entry_No_; "Entry No.") { }
            column(Document_Type; "Document Type") { }
            column(Document_No_; "Document No.") { }
            column(Source_Type; "Source Type") { }
            column(Source_No_; "Source No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Document_Date; "Document Date") { }
            column(Location_Code; "Location Code") { }
            column(Item_No_; "Item No.") { }
            column(Serial_No_; "Serial No.") { }
            column(Lot_No_; "Lot No.") { }
            column(Unit_of_Measure_Code; "Unit of Measure Code") { }
            column(Qty__per_Unit_of_Measure; "Qty. per Unit of Measure") { }
            column(Quantity; Quantity) { }
            column(Sales_Amount__Actual_; "Sales Amount (Actual)") { }
            column(Purchase_Amount__Actual_; "Purchase Amount (Actual)") { }
        }
    }
}
