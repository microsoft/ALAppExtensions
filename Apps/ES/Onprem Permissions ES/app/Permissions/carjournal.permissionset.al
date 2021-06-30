// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 10702 "CAR-JOURNAL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create movs in cartera jnls.';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bill Group" = Rm,
                  tabledata "Cartera Doc." = Rm,
                  tabledata "Closed Bill Group" = Rm,
                  tabledata "Closed Cartera Doc." = Rm,
                  tabledata "Closed Payment Order" = Rm,
                  tabledata "Comment Line" = R,
                  tabledata Currency = R,
                  tabledata "Cust. Ledger Entry" = Rm,
                  tabledata Customer = R,
                  tabledata "Finance Charge Terms" = R,
                  tabledata "G/L Account" = R,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RI,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = RM,
                  tabledata "General Posting Setup" = R,
                  tabledata "Payment Order" = Rm,
                  tabledata "Payment Terms" = R,
                  tabledata "Posted Bill Group" = Rm,
                  tabledata "Posted Cartera Doc." = Rm,
                  tabledata "Posted Payment Order" = Rm,
                  tabledata "Reason Code" = R,
                  tabledata "Salesperson/Purchaser" = R,
                  tabledata "Source Code Setup" = R,
                  tabledata Vendor = R,
                  tabledata "Vendor Ledger Entry" = Rm;
}
