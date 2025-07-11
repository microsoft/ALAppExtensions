// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18062 GSTR2IMPGCess
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_No_; "Document No.")
            {
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Document_Line_No_; "Document Line No.")
            {
            }
            column(GST__; "GST %")
            {
            }
            column(Credit_Availed; "Credit Availed")
            {

            }
            column(GST_Component_Code; "GST Component Code")
            {
                ColumnFilter = GST_Component_Code = const('CESS');
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {

            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }


        }

    }

}
