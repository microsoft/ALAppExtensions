// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.TDS.TDSBase;

query 18059 "TDS 27Q"
{
    QueryType = Normal;

    elements
    {
        dataitem(TDS_Entry; "TDS Entry")
        {
            column(Posting_Date; "Posting Date")
            {
            }
            column(Section; Section)
            {
            }
            column(Invoice_Amount; "Invoice Amount")
            {
            }
            column(Surcharge_Amount; "Surcharge Amount")
            {
            }
            column(TDS_Paid; "TDS Paid")
            {
            }
            column(TDS_Amount; "TDS Amount")
            {
            }
            column(eCess_Amount; "eCess Amount")
            {
            }
            column(TDS__; "TDS %")
            {
            }
            column(Nature_of_Remittance; "Nature of Remittance")
            {
            }
            column(Deductee_PAN_No_; "Deductee PAN No.")
            {
            }
            column(Vendor_No_; "Vendor No.")
            {
            }
            column(T_A_N__No_; "T.A.N. No.")
            {
            }
            column(Assessee_Code; "Assessee Code")
            {
            }
            column(TDS_Base_Amount; "TDS Base Amount")
            {
            }
        }
    }
}
