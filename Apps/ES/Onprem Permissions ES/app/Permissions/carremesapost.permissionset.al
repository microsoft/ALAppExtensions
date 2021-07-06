// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 10706 "CAR-REMESA, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post bill group';

    Permissions = tabledata "Accounting Period" = r,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "BG/PO Comment Line" = RIMD,
                  tabledata "BG/PO Post. Buffer" = RIM,
                  tabledata "Bill Group" = RIM,
                  tabledata "Cartera Doc." = RIMD,
                  tabledata "Category Code" = RIMD,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata "Closed Bill Group" = RIM,
                  tabledata "Closed Cartera Doc." = RIM,
                  tabledata Currency = r,
                  tabledata "Cust. Ledger Entry" = rim,
                  tabledata Customer = r,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Doc. Post. Buffer" = RIM,
                  tabledata "G/L Account" = R,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RID,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "General Ledger Setup" = r,
                  tabledata "General Posting Setup" = r,
                  tabledata "Posted Bill Group" = RIM,
                  tabledata "Posted Cartera Doc." = RIMD,
                  tabledata "Reason Code" = R,
                  tabledata "Source Code Setup" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Entry" = Ri,
                  tabledata Vendor = r,
                  tabledata "Vendor Ledger Entry" = rim,
                  tabledata "Vendor Posting Group" = R;
}
