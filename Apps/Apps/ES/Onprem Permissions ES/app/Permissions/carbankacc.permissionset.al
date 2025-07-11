// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 10700 "CAR-BANK ACC"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cartera Bank account';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bank Account Ledger Entry" = R,
                  tabledata "Bank Account Posting Group" = R,
                  tabledata "Bank Account Statement" = R,
                  tabledata "Bank Account Statement Line" = R,
                  tabledata "Bill Group" = R,
                  tabledata "Cartera Doc." = R,
                  tabledata "Check Ledger Entry" = R,
                  tabledata "Closed Bill Group" = R,
                  tabledata "Closed Cartera Doc." = R,
                  tabledata "Closed Payment Order" = R,
                  tabledata "Payment Order" = R,
                  tabledata "Posted Bill Group" = R,
                  tabledata "Posted Cartera Doc." = R,
                  tabledata "Posted Payment Order" = R;
}
