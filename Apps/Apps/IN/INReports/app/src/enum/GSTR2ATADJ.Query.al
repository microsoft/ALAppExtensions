// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18020 GSTR2ATADJ
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
            }
            column(Entry_Type; "Entry Type")
            {
                ColumnFilter = Entry_Type = const(Application);
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
            column(Credit_Availed; "Credit Availed")
            {
            }
            column(Document_No_; "Document No.")
            {
            }
            column(GST_Component_Code; "GST Component Code")
            {
            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }
            column(UnApplied; UnApplied)
            {
            }
            column(Reversed; Reversed)
            {
            }
            dataitem(Detailed_GST_Ledger_Entry_Info; "Detailed GST Ledger Entry Info")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = Detailed_GST_Ledger_Entry."Entry No.";
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(Location_State_Code; "Location State Code")
                {
                }
                column(Original_Doc__No_; "Original Doc. No.")
                {
                }
            }

        }
    }
}
