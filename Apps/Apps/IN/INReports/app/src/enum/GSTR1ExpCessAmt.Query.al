// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18024 GSTR1ExpCessAmt
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(= 'CESS');
            column(Document_No_; "Document No.")
            {
            }
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
            filter(Posting_Date; "Posting Date")
            {
            }
            filter(GST_Customer_Type; "GST Customer Type")
            {
                ColumnFilter = GST_Customer_Type = const(Export);
            }
            filter(Document_Line_No_; "Document Line No.")
            {
            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
            {
            }
            column(GST_Component_Code; "GST Component Code")
            {
            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }
        }
    }
}
