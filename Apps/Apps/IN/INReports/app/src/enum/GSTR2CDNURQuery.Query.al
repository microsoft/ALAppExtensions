// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18057 GSTR2CDNURQuery
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
            column(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Source_No_; "Source No.")
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
                ColumnFilter = GST_Vendor_Type = filter(= 'Unregistered' | 'Import');
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
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
            dataitem(Detailed_GST_Ledger_Entry_Info; "Detailed GST Ledger Entry Info")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = Detailed_GST_Ledger_Entry."Entry No.";
                column(Nature_of_Supply; "Nature of Supply")
                {
                    ColumnFilter = Nature_of_Supply = const(B2B);
                }
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(GST_Reason_Type; "GST Reason Type")
                {
                }
                column(Original_Invoice_Date; "Original Invoice Date")
                {

                }
                column(Purchase_Invoice_Type; "Purchase Invoice Type")
                {
                }
                column(Original_Doc__Type; "Original Doc. Type")
                {

                }
                column(Original_Doc__No_; "Original Doc. No.")
                {

                }
            }
        }
    }
}
