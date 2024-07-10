// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Agent.SalesOrderTaker.Instructions;

permissionset 4335 "SOA Instructions - Edit"
{
    Caption = 'Sales Order Taker Agent Instructions - Edit';
    Assignable = false;
    IncludedPermissionSets = "SOA Instructions - Read";

    Permissions =
        tabledata "SOA Instruction Phase" = IMD,
        tabledata "SOA Instruction Phase Step" = IMD,
        tabledata "SOA Instruction Prompt" = IMD,
        tabledata "SOA Instruction Task/Policy" = IMD,
        tabledata "SOA Instruction Template" = IMD;
}