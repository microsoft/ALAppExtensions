// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Agent.SalesOrderTaker.Instructions;

permissionset 4402 "SOA Instructions - View"
{
    Caption = 'Sales Order Taker Agent Instructions - View';
    Assignable = false;
    IncludedPermissionSets = "SOA Instructions - Read";

    Permissions =
        tabledata "SOA Instruction Phase" = imd,
        tabledata "SOA Instruction Phase Step" = imd,
        tabledata "SOA Instruction Prompt" = imd,
        tabledata "SOA Instruction Task/Policy" = imd,
        tabledata "SOA Instruction Template" = imd;
}