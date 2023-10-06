// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration;

using System.Integration;

permissionset 132616 "Page Action Read"
{
    Assignable = true;

    IncludedPermissionSets = "Page Action Provider - Read";

    // Include Test Tables
    Permissions = tabledata "Page Action Provider Test" = RIMD;
}