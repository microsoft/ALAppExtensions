// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18055 GSTR2HSNSUM
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
            }
            filter(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = const("Initial Entry");
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            filter(Posting_Date; "Posting Date")
            {
            }
            column(HSN_SAC_Code; "HSN/SAC Code")
            {
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
            dataitem(Detailed_GST_Ledger_Entry_Info; "Detailed GST Ledger Entry Info")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = Detailed_GST_Ledger_Entry."Entry No.";
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(UOM; UOM)
                {
                }
                dataitem(HSN_SAC; "HSN/SAC")
                {
                    DataItemLink = Code = Detailed_GST_Ledger_Entry."HSN/SAC Code", "GST Group Code" = Detailed_GST_Ledger_Entry."GST Group Code";
                    SqlJoinType = InnerJoin;

                    column(Description; Description)
                    {
                    }
                }
            }
        }
    }
}
