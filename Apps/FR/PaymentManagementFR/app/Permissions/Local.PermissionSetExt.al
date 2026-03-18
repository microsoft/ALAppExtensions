// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 10835 LOCAL extends LOCAL
{
    Permissions = tabledata "Bank Account Buffer FR" = RIMD,
                  tabledata "Payment Address FR" = RIMD,
                  tabledata "Payment Class FR" = RIMD,
                  tabledata "Payment Header FR" = RIMD,
                  tabledata "Payment Header Archive FR" = RIMD,
                  tabledata "Payment Line FR" = RIMD,
                  tabledata "Payment Line Archive FR" = RIMD,
                  tabledata "Payment Post. Buffer FR" = RIMD,
                  tabledata "Payment Status FR" = RIMD,
                  tabledata "Payment Step FR" = RIMD,
                  tabledata "Payment Step Ledger FR" = RIMD;
}