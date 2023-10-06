// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 17140 "D365 READ - Payment and Reconciliation Formats (DK)" extends "D365 READ"
{
    Permissions = tabledata FIKUplift = R;
}
