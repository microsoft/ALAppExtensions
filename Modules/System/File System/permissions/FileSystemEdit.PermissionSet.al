// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Environment;

permissionset 70002 "File System - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "File System - Objects";

    Permissions = tabledata "File Account" = r,
        tabledata "File System Connector" = r,
        tabledata "File System Connector Logo" = r,
        tabledata "File Account Scenario" = r,
        tabledata "File Scenario" = r,
        tabledata "File Account Content" = r,
        tabledata Media = r; // File System Account Wizard requires this
}