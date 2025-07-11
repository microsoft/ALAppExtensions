// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Sales.Receivables;

query 18033 GSTR1B2CSInter
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');
            filter(Document_Type; "Document Type")
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
            filter(Posting_Date; "Posting Date")
            {
            }
            column(GST_Customer_Type; "GST Customer Type")
            {
                ColumnFilter = GST_Customer_Type = const(Unregistered);
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
                    ColumnFilter = Nature_of_Supply = const(B2C);
                }
                column(Buyer_Seller_State_Code; "Buyer/Seller State Code")
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
                    dataitem(Cust__Ledger_Entry; "Cust. Ledger Entry")
                    {
                        DataItemLink = "Document No." = Detailed_GST_Ledger_Entry."Document No.", "Document Type" = Detailed_GST_Ledger_Entry."Document Type";
                        DataItemTableFilter = "GST Jurisdiction Type" = const(Interstate);
                        SqlJoinType = InnerJoin;
                        filter(Amount__LCY_; "Amount (LCY)")
                        {
                            ColumnFilter = Amount__LCY_ = filter(<= 250000);
                        }
                    }
                }
            }
        }
    }
}
