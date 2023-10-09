// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18063 GSTR2IMPGQuery
{
    QueryType = Normal;
    OrderBy = ascending(Document_No_);

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
            filter(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Invoice);
            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
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
            column(GST_Group_Type; "GST Group Type")
            {

            }
            filter(GST_Component_Code; "GST Component Code")
            {
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {
            }
            column(Buyer_Seller_Reg__No_; "Buyer/Seller Reg. No.")
            {

            }
            column(Document_No_; "Document No.")
            {

            }
            column(GST__; "GST %")
            {

            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
            dataitem(Detailed_GST_Ledger_Entry_Info; "Detailed GST Ledger Entry Info")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = Detailed_GST_Ledger_Entry."Entry No.";
                column(Bill_of_Entry_No_; "Bill of Entry No.")
                {
                }
                column(Bill_of_Entry_Date; "Bill of Entry Date")
                {
                }
                column(Without_Bill_Of_Entry; "Without Bill Of Entry")
                {
                }
                column(Purchase_Invoice_Type; "Purchase Invoice Type")
                {
                    ColumnFilter = Purchase_Invoice_Type = filter(<> "Debit Note");
                }

            }
        }
    }
}
