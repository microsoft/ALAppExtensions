// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18042 GSTR2IGST
{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            DataItemTableFilter = "GST Component Code" = const('IGST');
            column(Document_No_; "Document No.")
            {
            }
            filter(Document_Type; "Document Type")
            {
            }
            column(GST_Component_Code; "GST Component Code")
            {
            }
            column(Credit_Availed; "Credit Availed")
            {
            }
            column(Eligibility_for_ITC; "Eligibility for ITC")
            {
            }
            filter(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(Transaction_Type; "Transaction Type")
            {
            }
            column(Posting_Date; "Posting Date")
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
