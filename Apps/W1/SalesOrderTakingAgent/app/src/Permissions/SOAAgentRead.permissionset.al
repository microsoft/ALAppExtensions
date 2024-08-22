
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Warehouse.Activity;
using Microsoft.Service.Document;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Transfer;
using Microsoft.Warehouse.Structure;
using Microsoft.Warehouse.Document;

permissionset 4407 "SOA Agent - Read"
{
    Caption = 'Sales Order Taker Agent - Read';
    Assignable = true;
    IncludedPermissionSets = "SOA Agent - Objects";

    Permissions =
        tabledata "Bin Type" = R,
        tabledata "Planning Assignment" = R,
        tabledata "Service Line" = R,
        tabledata "Warehouse Activity Line" = R,
        tabledata "Warehouse Shipment Line" = R,
        tabledata "Transfer Line" = R;
}