// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18071 GSTR2CessAmt
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_No_; "Document No.")
            {
            }
            filter(Document_Type; "Document Type")
            {
            }
            column(GST_Component_Code; "GST Component Code")
            {
                ColumnFilter = GST_Component_Code = const('Cess');
            }
            filter(Entry_Type; "Entry Type")
            {
            }
            column(GST_Group_Type; "GST Group Type")
            {

            }

            column(GST__; "GST %")
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
            column(Credit_Availed; "Credit Availed")
            {

            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {

            }

            column(GST_Vendor_Type; "GST Vendor Type")
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


        }
    }
}
