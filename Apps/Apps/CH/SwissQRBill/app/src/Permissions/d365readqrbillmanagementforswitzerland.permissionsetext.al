// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 11506 "D365 READ - QR-Bill Management for Switzerland" extends "D365 READ"
{
    Permissions = tabledata "Swiss QR-Bill Billing Detail" = R,
                  tabledata "Swiss QR-Bill Billing Info" = R,
                  tabledata "Swiss QR-Bill Buffer" = R,
                  tabledata "Swiss QR-Bill Layout" = R,
                  tabledata "Swiss QR-Bill Reports" = R,
                  tabledata "Swiss QR-Bill Setup" = R;
}
