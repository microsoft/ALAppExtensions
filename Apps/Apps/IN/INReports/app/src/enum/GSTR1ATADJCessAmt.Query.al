// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18002 GSTR1ATADJCessAmt
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(= 'CESS');
            filter(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Invoice);
            }
            filter(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = filter(= "Application");
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
            filter(UnApplied; UnApplied)
            {
            }
            filter(Reversed; Reversed)
            {
            }
            filter(Document_Line_No_; "Document Line No.")
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
