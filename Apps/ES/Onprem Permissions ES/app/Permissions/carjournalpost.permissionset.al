// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 10703 "CAR-JOURNAL, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post cartera journals';

    Permissions = tabledata "Accounting Period" = r,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "BG/PO Post. Buffer" = rim,
                  tabledata "Bill Group" = rim,
                  tabledata "Cartera Doc." = rim,
                  tabledata "Cartera Setup" = R,
                  tabledata "Category Code" = R,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata "Closed Bill Group" = rim,
                  tabledata "Closed Cartera Doc." = rim,
                  tabledata "Closed Payment Order" = rim,
                  tabledata Currency = r,
                  tabledata "Cust. Ledger Entry" = rim,
                  tabledata Customer = r,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Doc. Post. Buffer" = rim,
                  tabledata "G/L Account" = R,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RID,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "General Ledger Setup" = r,
                  tabledata "General Posting Setup" = r,
                  tabledata "Payment Order" = rim,
                  tabledata "Posted Bill Group" = rim,
                  tabledata "Posted Cartera Doc." = rim,
                  tabledata "Posted Payment Order" = rim,
                  tabledata "Source Code Setup" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Entry" = Ri,
                  tabledata Vendor = r,
                  tabledata "Vendor Ledger Entry" = rim,
                  tabledata "Vendor Posting Group" = R;
}
