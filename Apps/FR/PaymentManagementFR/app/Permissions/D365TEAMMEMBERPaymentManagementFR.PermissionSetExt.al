// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 10834 "D365 TEAM MEMBER - Payment Management FR" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Payment Management FR - RM",
                             "Payment Mgt FR - Objects X";
}