// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;

query 18065 GSTR1NonGSTExempCrMemo
{
    QueryType = Normal;

    elements
    {
        dataitem(Sales_Cr_Memo_Header; "Sales Cr.Memo Header")
        {
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_Customer_Type; "GST Customer Type")
            {
            }
            dataitem(Sales_Cr_Memo_Line; "Sales Cr.Memo Line")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Document No." = Sales_Cr_Memo_Header."No.";
                DataItemTableFilter = "GST Group Code" = filter(= '');

                column(GST_Group_Code; "GST Group Code")
                {
                    ColumnFilter = GST_Group_Code = filter(= '');
                }
                column(HSN_SAC_Code; "HSN/SAC Code")
                {
                    ColumnFilter = HSN_SAC_Code = filter(= '');
                }
                dataitem(Cust__Ledger_Entry; "Cust. Ledger Entry")
                {
                    SqlJoinType = InnerJoin;
                    DataItemLink = "Document No." = Sales_Cr_Memo_Header."No.";
                    DataItemTableFilter = "Document Type" = const("Credit Memo");
                    column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
                    {
                    }
                    column(Location_GST_Reg__No_; "Location GST Reg. No.")
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

