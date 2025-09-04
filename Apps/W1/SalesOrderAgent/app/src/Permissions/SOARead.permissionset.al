
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Inventory.Planning;
using System.Agents;
using Microsoft.Inventory.Transfer;
using Microsoft.Service.Document;
using Microsoft.Service.Item;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.Structure;

permissionset 4407 "SOA - Read"
{
    Caption = 'Sales Order Agent - Read';
    Assignable = true;
    IncludedPermissionSets = "SOA - Objects";

    Permissions =
        tabledata "Bin Type" = R,
        tabledata "Planning Assignment" = R,
        tabledata "Service Line" = R,
        tabledata "Warehouse Activity Line" = R,
        tabledata "Warehouse Shipment Line" = R,
        tabledata "Transfer Line" = R,
        tabledata "Service Item Group" = R,
        tabledata Agent = r;
}