// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 10701 "CAR-BANK ACC, EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cartera - Bank Account, Edit';

    Permissions = tabledata "Bank Account" = RIMD,
                  tabledata "Bank Account Ledger Entry" = Rm,
                  tabledata "Bank Account Posting Group" = R,
                  tabledata "Bank Account Statement" = R,
                  tabledata "Bank Account Statement Line" = R,
                  tabledata "Bill Group" = Rm,
                  tabledata "Cartera Doc." = Rm,
                  tabledata "Check Ledger Entry" = Rm,
                  tabledata "Closed Bill Group" = Rm,
                  tabledata "Closed Cartera Doc." = Rm,
                  tabledata "Closed Payment Order" = Rm,
                  tabledata "Comment Line" = RIMD,
                  tabledata Currency = R,
                  tabledata "Payment Order" = Rm,
                  tabledata "Post Code" = R,
                  tabledata "Posted Bill Group" = Rm,
                  tabledata "Posted Cartera Doc." = Rm,
                  tabledata "Posted Payment Order" = Rm,
                  tabledata "Salesperson/Purchaser" = R;
}
