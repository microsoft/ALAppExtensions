// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;

query 18000 GSTR2NonGSTExemp
{
    QueryType = Normal;

    elements
    {
        dataitem(Purch__Inv__Header; "Purch. Inv. Header")
        {
            filter(Posting_Date; "Posting Date")
            {
            }
            filter(GST_Vendor_Type; "GST Vendor Type")
            {
            }
            dataitem(Purch__Inv__Line; "Purch. Inv. Line")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Document No." = Purch__Inv__Header."No.";
                column(GST_Group_Code; "GST Group Code")
                {
                    ColumnFilter = GST_Group_Code = const('');
                }
                column(HSN_SAC_Code; "HSN/SAC Code")
                {
                    ColumnFilter = HSN_SAC_Code = const('');
                }
                dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
                {
                    SqlJoinType = InnerJoin;
                    DataItemLink = "Document No." = Purch__Inv__Header."No.";
                    DataItemTableFilter = "Document Type" = const(Invoice);
                    column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
                    {
                    }
                    filter(Location_GST_Reg__No_; "Location GST Reg. No.")
                    {
                    }
                    column(Amount; Amount)
                    {
                    }
                }

            }
        }
    }
}
