// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Environment;

permissionset 70003 "File System - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'File System - Edit';

    IncludedPermissionSets = "File System - Read";

    Permissions = tabledata "File System Connector Logo" = imd,
                  tabledata "Tenant Media" = imd;
}