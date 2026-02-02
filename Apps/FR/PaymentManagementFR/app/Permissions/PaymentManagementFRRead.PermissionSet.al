// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

permissionset 10839 "Payment Management FR - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Bank Account Buffer FR" = R,
                  tabledata "Payment Address FR" = R,
                  tabledata "Payment Class FR" = R,
                  tabledata "Payment Header Archive FR" = R,
                  tabledata "Payment Header FR" = R,
                  tabledata "Payment Line Archive FR" = R,
                  tabledata "Payment Line FR" = R,
                  tabledata "Payment Post. Buffer FR" = R,
                  tabledata "Payment Status FR" = R,
                  tabledata "Payment Step FR" = R,
                  tabledata "Payment Step Ledger FR" = R;
}
