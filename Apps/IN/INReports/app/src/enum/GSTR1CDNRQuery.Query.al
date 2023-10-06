// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Sales.Customer;

query 18018 GSTR1CDNRQuery
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
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
            column(GST_Customer_Type; "GST Customer Type")
            {

            }
            column(Source_No_; "Source No.")
            {
            }
            column(Buyer_Seller_Reg__No_; "Buyer/Seller Reg. No.")
            {

            }
            column(Document_No_; "Document No.")
            {

            }
            column(GST_Without_Payment_of_Duty; "GST Without Payment of Duty")
            {

            }
            column(Original_Invoice_No_; "Original Invoice No.")
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
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
                {
                }
                column(Finance_Charge_Memo; "Finance Charge Memo")
                {
                }
                column(Adv__Pmt__Adjustment; "Adv. Pmt. Adjustment")
                {
                }
                column(Sales_Invoice_Type; "Sales Invoice Type")
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
                    dataitem(Customer; Customer)
                    {
                        SqlJoinType = InnerJoin;
                        DataItemLink = "No." = Detailed_GST_Ledger_Entry."Source No.";
                        column(Name; Name)
                        {

                        }
                    }
                }
            }
        }
    }
}
