// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

permissionset 10837 "Payment Management FR - Full"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Payment Management FR - RM";

    Permissions = tabledata "Bank Account Buffer FR" = ID,
                  tabledata "Payment Address FR" = ID,
                  tabledata "Payment Class FR" = ID,
                  tabledata "Payment Header Archive FR" = ID,
                  tabledata "Payment Header FR" = ID,
                  tabledata "Payment Line Archive FR" = ID,
                  tabledata "Payment Line FR" = ID,
                  tabledata "Payment Post. Buffer FR" = ID,
                  tabledata "Payment Status FR" = ID,
                  tabledata "Payment Step FR" = ID,
                  tabledata "Payment Step Ledger FR" = ID;
}
