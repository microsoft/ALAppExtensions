// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

query 18009 GSTR1B2BQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
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
            column(Posting_Date; "Posting Date")
            {
            }
            filter(GST_Component_Code; "GST Component Code")
            {
            }
            column(Source_No_; "Source No.")
            {
            }
            column(Reverse_Charge; "Reverse Charge")
            {
            }
            column(GST_Customer_Type; "GST Customer Type")
            {
            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
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
                column(Original_Doc__Type; "Original Doc. Type")
                {

                }
                column(Original_Doc__No_; "Original Doc. No.")
                {

                }
                column(Finance_Charge_Memo; "Finance Charge Memo")
                {

                }
                column(e_Comm__Operator_GST_Reg__No_; "e-Comm. Operator GST Reg. No.")
                {

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
