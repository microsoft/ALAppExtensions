// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8703 "Telemetry - Exec"
{
    Assignable = false;

    IncludedPermissionSets = "Telemetry - Objects",
                             "Language - Read",
                             "Environment Info. - Objects";

    Permissions = tabledata "Feature Uptake" = rimd;
}