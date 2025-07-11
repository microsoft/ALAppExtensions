// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Sales.Receivables;

query 5281 "Cust. Ledger Entry SAF-T"
{
    QueryType = Normal;
    Access = Internal;
    DataAccessIntent = ReadOnly;
    OrderBy = ascending(Document_No_);

    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            filter(Posting_Date_Filter; "Posting Date") { }
            filter(Document_Type_Filter; "Document Type") { }
            column(Entry_No_; "Entry No.") { }
            column(Document_Type; "Document Type") { }
            column(Document_No_; "Document No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Document_Date; "Document Date") { }
            column(Customer_No_; "Customer No.") { }
            column(Payment_Method_Code; "Payment Method Code") { }
            column(Description; Description) { }
            column(Transaction_No_; "Transaction No.") { }
            column(User_ID; "User ID") { }
            column(Dimension_Set_ID; "Dimension Set ID") { }
            column(Currency_Code; "Currency Code") { }
            column(Customer_Posting_Group; "Customer Posting Group") { }

            dataitem(Detailed_Cust__Ledg__Entry; "Detailed Cust. Ledg. Entry")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Cust. Ledger Entry No." = CustLedgerEntry."Entry No.", "Posting Date" = CustLedgerEntry."Posting Date";
                DataItemTableFilter = "Ledger Entry Amount" = const(true);

                column(Amount; Amount)
                {
                    Method = Sum;
                }
                column(Amount__LCY_; "Amount (LCY)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
