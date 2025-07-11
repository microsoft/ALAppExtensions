// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18073 GSTR2IMPGBaseAmt
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_No_; "Document No.")
            {
            }
            filter(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Invoice);
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = const("Initial Entry");
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_Vendor_Type; "GST Vendor Type")
            {

            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {

            }
            column(GST__; "GST %")
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

                column(Purchase_Invoice_Type; "Purchase Invoice Type")
                {
                    ColumnFilter = Purchase_Invoice_Type = filter(<> "Debit Note");
                }
            }

        }
    }
}
