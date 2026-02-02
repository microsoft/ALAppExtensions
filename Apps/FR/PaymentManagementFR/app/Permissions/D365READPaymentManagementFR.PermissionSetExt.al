// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 10833 "D365 READ - Payment Management FR" extends "D365 READ"
{
    IncludedPermissionSets = "Payment Management FR - Read",
                             "Payment Mgt FR - Objects X";
}