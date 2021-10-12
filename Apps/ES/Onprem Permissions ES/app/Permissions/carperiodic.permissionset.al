// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 10704 "CAR-PERIODIC"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cartera - Periodic';

    Permissions = tabledata "Bank Acc. Reconciliation" = RIMD,
                  tabledata "Bank Acc. Reconciliation Line" = RIMD,
                  tabledata "Bank Account" = RM,
                  tabledata "Bank Account Ledger Entry" = RM,
                  tabledata "Bank Account Statement" = RI,
                  tabledata "Bank Account Statement Line" = RI,
                  tabledata "Bill Group" = RM,
                  tabledata "Cartera Doc." = RM,
                  tabledata "Check Ledger Entry" = RM,
                  tabledata "Closed Bill Group" = RM,
                  tabledata "Closed Cartera Doc." = RM,
                  tabledata "Closed Payment Order" = RM,
                  tabledata "Payment Order" = RM,
                  tabledata "Posted Bill Group" = RM,
                  tabledata "Posted Cartera Doc." = RM,
                  tabledata "Posted Payment Order" = RM;
}
