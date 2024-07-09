// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Agent.SalesOrderTaker.Instructions;

permissionset 4333 "SOA Instructions - Read"
{
    Caption = 'Sales Order Taker Agent Instructions - Read';
    Assignable = false;
    IncludedPermissionSets = "SOA - Objects";

    Permissions =
        tabledata "SOA Instruction Phase" = R,
        tabledata "SOA Instruction Phase Step" = R,
        tabledata "SOA Instruction Prompt" = R,
        tabledata "SOA Instruction Task/Policy" = R,
        tabledata "SOA Instruction Template" = R;
}