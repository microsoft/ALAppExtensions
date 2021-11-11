// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 4101 "BLOB Storage - Exec"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "BLOB Storage - Objects";

    Permissions = tabledata "Persistent Blob" = rimd;
}
