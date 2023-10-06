// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 27002 "BANKDEPOSIT-POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post Bank Deposits';

    Permissions = tabledata "Accounting Period" = r,
                  tabledata "Analysis View" = rimd,
                  tabledata "Analysis View Entry" = rim,
                  tabledata "Analysis View Filter" = r,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "Bank Comment Line" = RIMD,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata Currency = r,
                  tabledata "Currency Exchange Rate" = r,
                  tabledata "Cust. Ledger Entry" = rim,
                  tabledata Customer = r,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Date Compr. Register" = r,
                  tabledata "Detailed Cust. Ledg. Entry" = ri,
                  tabledata "Dimension Combination" = R,
                  tabledata "Dimension Value Combination" = R,
                  tabledata "G/L Account" = r,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RID,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "General Ledger Setup" = r,
                  tabledata "General Posting Setup" = r,
                  tabledata "Posted Deposit Header" = Ri,
                  tabledata "Posted Deposit Line" = Ri,
                  tabledata "Reversal Entry" = RIMD,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Entry" = Ri,
                  tabledata "VAT Posting Setup" = R;
}
