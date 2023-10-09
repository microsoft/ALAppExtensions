// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.FixedAssets.Ledger;

query 5285 "FA Ledger Entry SAF-T"
{
    QueryType = Normal;
    Access = Internal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(FA_Ledger_Entry; "FA Ledger Entry")
        {
            filter(Posting_Date_Filter; "Posting Date") { }
            column(Entry_No_; "Entry No.") { }
            column(FA_Posting_Type; "FA Posting Type") { }
            column(FA_Posting_Date; "FA Posting Date") { }
            column(FA_No_; "FA No.") { }
            column(Description; Description) { }
            column(G_L_Entry_No_; "G/L Entry No.") { }
            column(Amount__LCY_; "Amount (LCY)") { }
        }
    }
}
