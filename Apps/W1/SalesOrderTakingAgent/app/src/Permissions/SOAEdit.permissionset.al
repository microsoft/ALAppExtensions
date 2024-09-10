
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

permissionset 4409 "SOA - Edit"
{
    Caption = 'Sales Order Taker Agent - Read';
    Assignable = false;
    IncludedPermissionSets = "SOA - Read";

    Permissions = tabledata "SOA Setup" = IMD;

}