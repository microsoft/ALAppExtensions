// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

query 18035 GSTR2B2BQuery
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
            column(GST_Group_Type; "GST Group Type")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Entry_Type; "Entry Type")
            {

            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
            {

            }
            column(GST_Vendor_Type; "GST Vendor Type")
            {
            }
            filter(GST_Component_Code; "GST Component Code")
            {
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {

            }
            column(Reverse_Charge; "Reverse Charge")
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
                column(Nature_of_Supply; "Nature of Supply")
                {
                    ColumnFilter = Nature_of_Supply = const(B2B);
                }
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(Without_Bill_Of_Entry; "Without Bill Of Entry")
                {
                }
                column(Purchase_Invoice_Type; "Purchase Invoice Type")
                {
                    ColumnFilter = Purchase_Invoice_Type = filter(<> "Debit Note");
                }

                dataitem(State; State)
                {
                    DataItemLink = Code = Detailed_GST_Ledger_Entry_Info."Buyer/Seller State Code";
                    SqlJoinType = InnerJoin;
                    column(State_Code__GST_Reg__No__; "State Code (GST Reg. No.)")
                    {

                    }
                    column(Description; Description)
                    {

                    }
                }
            }
        }
    }
}
