// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 134686 "Email Edit"
{
    Assignable = true;
    IncludedPermissionSets = "Email - Edit";

    // Include Test Tables
    Permissions =
        tabledata "Test Email Connector Setup" = RIMD,
        tabledata "Test Email Account" = RIMD, // Needed for the Record to get passed in Library Assert
        tabledata "Scheduled Task" = rd;        // Needed for enqueue tests
}