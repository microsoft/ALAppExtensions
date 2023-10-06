// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18044 GSTR2IMPSQuery
{
    QueryType = Normal;
    OrderBy = ascending(Document_No_);

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
            column(Document_Type; "Document Type")
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
            column(Credit_Availed; "Credit Availed")
            {
            }
            column(Reverse_Charge; "Reverse Charge")
            {

            }
            column(UnApplied; UnApplied)
            {
            }

            column(Entry_Type; "Entry Type")
            {

            }

            column(Eligibility_for_ITC; "Eligibility for ITC")
            {

            }
            column(GST_Group_Type; "GST Group Type")
            {

            }
            column(GST_Vendor_Type; "GST Vendor Type")
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

                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {

                }
                column(Location_State_Code; "Location State Code")
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
