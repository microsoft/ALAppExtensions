// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18022 GSTR1CDNURQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
            column(Document_Type; "Document Type")
            {
            }
            filter(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = filter(= "Initial Entry");
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Sales);
            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {
                ColumnFilter = GST_Jurisdiction_Type = const(Interstate);
            }
            column(GST_Customer_Type; "GST Customer Type")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Source_No_; "Source No.")
            {
            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
            {
            }
            column(Document_No_; "Document No.")
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
                column(Finance_Charge_Memo; "Finance Charge Memo")
                {
                }
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(Location_State_Code; "Location State Code")
                {
                }
                column(Sales_Invoice_Type; "Sales Invoice Type")
                {
                }
            }
        }
    }
}
