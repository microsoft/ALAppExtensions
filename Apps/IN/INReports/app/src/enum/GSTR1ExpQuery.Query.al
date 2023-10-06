// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18027 GSTR1ExpQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            filter(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Invoice);
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
            filter(GST_Customer_Type; "GST Customer Type")
            {
                ColumnFilter = GST_Customer_Type = const(Export);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
            {
            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
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
                column(Bill_Of_Export_No_; "Bill Of Export No.")
                {

                }
                column(Bill_Of_Export_Date; "Bill Of Export Date")
                {

                }

            }
        }
    }
}
