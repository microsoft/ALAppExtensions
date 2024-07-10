
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Warehouse.Activity;

permissionset 4332 "SOA - Read"
{
    Caption = 'Sales Order Taker Agent - Read';
    Assignable = true;
    IncludedPermissionSets = "SOA - Objects";

    Permissions =
        tabledata "Warehouse Activity Line" = R;
}