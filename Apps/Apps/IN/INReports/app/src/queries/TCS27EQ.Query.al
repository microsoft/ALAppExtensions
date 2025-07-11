// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.TCS.TCSBase;

query 18061 "TCS 27 EQ"
{
    QueryType = Normal;

    elements
    {
        dataitem(TCS_Entry; "TCS Entry")
        {
            column(Posting_Date; "Posting Date")
            {
            }
            column(Invoice_Amount; "Invoice Amount")
            {
            }
            column(Surcharge_Amount; "Surcharge Amount")
            {
            }
            column(eCESS_Amount; "eCESS Amount")
            {
            }
            column(TCS_Amount; "TCS Amount")
            {
            }
            column(TCS__; "TCS %")
            {
            }
            column(Customer_P_A_N__No_; "Customer P.A.N. No.")
            {
            }
            column(Customer_No_; "Customer No.")
            {
            }
            column(T_C_A_N__No_; "T.C.A.N. No.")
            {
            }
            column(Assessee_Code; "Assessee Code")
            {
            }
        }
    }
}
