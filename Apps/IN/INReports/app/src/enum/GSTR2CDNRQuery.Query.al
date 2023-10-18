// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18047 GSTR2CDNRQuery
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
            column(Source_No_; "Source No.")
            {
            }
            column(Credit_Availed; "Credit Availed")
            {
            }
            column(Entry_Type; "Entry Type")
            {
            }
            column(Original_Invoice_No_; "Original Invoice No.")
            {

            }

            column(GST_Vendor_Type; "GST Vendor Type")
            {
            }
            filter(GST_Component_Code; "GST Component Code")
            {
            }
            column(Reverse_Charge; "Reverse Charge")
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
                column(Adv__Pmt__Adjustment; "Adv. Pmt. Adjustment")
                {
                }
                column(Finance_Charge_Memo; "Finance Charge Memo")
                {

                }

                column(GST_Reason_Type; "GST Reason Type")
                {

                }

                column(Purchase_Invoice_Type; "Purchase Invoice Type")
                {
                }
                column(Original_Doc__Type; "Original Doc. Type")
                {

                }

            }
        }
    }
}
