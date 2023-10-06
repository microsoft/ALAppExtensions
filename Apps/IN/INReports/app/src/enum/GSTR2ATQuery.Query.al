// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18041 GSTR2ATQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
            column(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Payment);
            }
            column(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = const("Initial Entry");
            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(GST_on_Advance_Payment; "GST on Advance Payment")
            {
            }
            column(Liable_to_Pay; "Liable to Pay")
            {
            }
            column(Reverse_Charge; "Reverse Charge")
            {
            }
            column(Paid; Paid)
            {
            }
            column(Document_No_; "Document No.")
            {
            }
            column(GST__; "GST %")
            {
            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
            column(GST_Component_Code; "GST Component Code")
            { }
            column(GST_Amount; "GST Amount")
            { }
            dataitem(Detailed_GST_Ledger_Entry_Info; "Detailed GST Ledger Entry Info")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = Detailed_GST_Ledger_Entry."Entry No.";
                column(Location_State_Code; "Location State Code")
                {
                }
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
            }
        }
    }
}
