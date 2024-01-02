// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Ledger;

query 5284 "G/L Entry SAF-T"
{
    QueryType = Normal;
    Access = Internal;
    DataAccessIntent = ReadOnly;
    OrderBy = ascending(Document_No_, Posting_Date);

    elements
    {
        dataitem(G_L_Entry; "G/L Entry")
        {
            filter(Posting_Date_Filter; "Posting Date") { }
            filter(Source_Code_Filter; "Source Code") { }
            column(Entry_No_; "Entry No.") { }
            column(Document_Type; "Document Type") { }
            column(Document_No_; "Document No.") { }
            column(External_Document_No_; "External Document No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Document_Date; "Document Date") { }
            column(VAT_Reporting_Date; "VAT Reporting Date") { }
            column(G_L_Account_No_; "G/L Account No.") { }
            column(Source_Code; "Source Code") { }
            column(Source_Type; "Source Type") { }
            column(Source_No_; "Source No.") { }
            column(Description; Description) { }
            column(Transaction_No_; "Transaction No.") { }
            column(User_ID; "User ID") { }
            column(Dimension_Set_ID; "Dimension Set ID") { }
            column(VAT_Bus__Posting_Group; "VAT Bus. Posting Group") { }
            column(VAT_Prod__Posting_Group; "VAT Prod. Posting Group") { }
            column(Last_Modified_DateTime; "Last Modified DateTime") { }
            column(Debit_Amount; "Debit Amount") { }
            column(Credit_Amount; "Credit Amount") { }
        }
    }
}
