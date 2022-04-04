// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 134689 "Email View Perm"
{
    Assignable = true;
    IncludedPermissionSets = "Email - Admin";

    // Direct permissions needed for tests
    // Include Test Tables, but exclude Test Email Account Table
    Permissions =
        tabledata "Test Email Connector Setup" = RIMD,
        tabledata "Test Email Account" = RIMD, // Needed for the Record to get passed in Library Assert
        tabledata "Sent Email" = RIMD,
        tabledata "Email Outbox" = RIMD,
        tabledata "Email Recipient" = RIMD;

}