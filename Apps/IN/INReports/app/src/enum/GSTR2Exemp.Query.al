// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;

query 18046 GSTR2Exemp
{
    QueryType = Normal;
    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
            }
            column(Document_No_; "Document No.")
            {
            }
            column(Entry_Type; "Entry Type")
            {
            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            filter(Transaction_Type; "Transaction Type")
            {
                ColumnFilter = Transaction_Type = const(Purchase);
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
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {
            }
            column(GST_Exempted_Goods; "GST Exempted Goods")
            {
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
        }
    }
}
