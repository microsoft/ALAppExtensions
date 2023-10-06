// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18051 GSTR2CompTaxValue

{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(GST_Vendor_Type; "GST Vendor Type")
            {

            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {

            }
            column(GST__; "GST %")
            {
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
        }

    }
}
