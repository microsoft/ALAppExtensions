// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18040 "GST Amount GSTR3B"
{
    QueryType = Normal;
    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Entry_Type; "Entry Type")
            {
            }
            column(Document_Type; "Document Type")
            {
            }
            column(Document_No_; "Document No.")
            {
            }
            column(Transaction_No_; "Transaction No.")
            {
            }
            column(Document_Line_No_; "Document Line No.")
            {
            }
            column(Original_Invoice_No_; "Original Invoice No.")
            {
            }
            filter(Source_No_; "Source No.")
            {
            }
            filter(Source_Type; "Source Type")
            {
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Posting_Date; "Posting Date")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
            }
            filter(GST__; "GST %")
            {
            }
            filter(GST_Exempted_Goods; "GST Exempted Goods")
            {
            }
            filter(GST_Customer_Type; "GST Customer Type")
            {
            }
            filter(GST_Component_Code; "GST Component Code")
            {
            }
            filter(Reverse_Charge; "Reverse Charge")
            {
            }
            filter(Liable_to_Pay; "Liable to Pay")
            {
            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {
            }
            column(Entry_No_; "Entry No.")
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
                column(Original_Doc__No_; "Original Doc. No.")
                {
                }
                column(Item_Charge_Assgn__Line_No_; "Item Charge Assgn. Line No.")
                {
                }
                filter(Component_Calc__Type; "Component Calc. Type")
                {
                }
                filter(e_Comm__Merchant_Id; "e-Comm. Merchant Id")
                {
                }
            }
        }
    }
}
