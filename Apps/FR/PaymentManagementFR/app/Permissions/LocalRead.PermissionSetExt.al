// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 10836 "LOCAL READ" extends "LOCAL READ"
{
    Permissions = tabledata "Bank Account Buffer FR" = R,
                  tabledata "Payment Address FR" = RIMD,
                  tabledata "Payment Class FR" = R,
                  tabledata "Payment Header FR" = R,
                  tabledata "Payment Header Archive FR" = R,
                  tabledata "Payment Line FR" = R,
                  tabledata "Payment Line Archive FR" = R,
                  tabledata "Payment Post. Buffer FR" = R,
                  tabledata "Payment Status FR" = R,
                  tabledata "Payment Step FR" = R,
                  tabledata "Payment Step Ledger FR" = R;
}