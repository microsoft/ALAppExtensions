// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18058 GSTR2IMPSIGSTAmt
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = filter(<> 'CESS');

            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
            }
            column(Posting_Date; "Posting Date")
            {
            }
            filter(Document_Type; "Document Type")
            {
                ColumnFilter = Document_Type = const(Invoice);
            }
            filter(Entry_Type; "Entry Type")
            {
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {

            }
            column(GST_Component_Code; "GST Component Code")
            {
                ColumnFilter = GST_Component_Code = const('IGST');
            }
            column(Credit_Availed; "Credit Availed")
            {
            }
            column(GST_Group_Type; "GST Group Type")
            {
            }
            column(Document_No_; "Document No.")
            {
            }
            column(GST_Vendor_Type; "GST Vendor Type")
            {
            }
            column(GST__; "GST %")
            {

            }
            column(GST_Amount; "GST Amount")
            {
                Method = Sum;
            }
        }
    }
}
