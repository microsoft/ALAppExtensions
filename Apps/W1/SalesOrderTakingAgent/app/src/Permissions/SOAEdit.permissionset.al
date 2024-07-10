
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Security.AccessControl;

permissionset 4330 "SOA - Edit"
{
    Caption = 'Sales Order Taker Agent - Edit';
    Assignable = true;
    IncludedPermissionSets = LOGIN,
                             "Webhook - Edit",
                             "D365 SALES",
                             "SOA - Read";
}