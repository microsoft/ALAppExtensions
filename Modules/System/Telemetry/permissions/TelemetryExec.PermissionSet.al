// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8703 "Telemetry - Exec"
{
    Assignable = false;

    IncludedPermissionSets = "Language - Read";

    Permissions = tabledata Company = r,
                  tabledata "User Personalization" = r;
}