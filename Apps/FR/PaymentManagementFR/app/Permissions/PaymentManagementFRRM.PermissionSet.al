// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

permissionset 10840 "Payment Management FR - RM"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Payment Management FR - Read";

    Permissions = tabledata "Bank Account Buffer FR" = RM,
                  tabledata "Payment Address FR" = RM,
                  tabledata "Payment Class FR" = RM,
                  tabledata "Payment Header Archive FR" = RM,
                  tabledata "Payment Header FR" = RM,
                  tabledata "Payment Line Archive FR" = RM,
                  tabledata "Payment Line FR" = RM,
                  tabledata "Payment Post. Buffer FR" = RM,
                  tabledata "Payment Status FR" = RM,
                  tabledata "Payment Step FR" = RM,
                  tabledata "Payment Step Ledger FR" = RM;
}
