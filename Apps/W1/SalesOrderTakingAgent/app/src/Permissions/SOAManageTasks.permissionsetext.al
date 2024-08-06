
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;

permissionsetextension 4409 "SOA - Manage Tasks" extends "Agent - Manage Tasks"
{
    IncludedPermissionSets = "SOA - Edit";
}