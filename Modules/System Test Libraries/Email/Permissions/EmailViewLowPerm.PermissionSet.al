// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 134684 "Email View Low Perm"
{
    Assignable = true;
    IncludedPermissionSets = "Email - Admin";

    // Direct permissions needed for tests
    // Include Test Tables, but exclude Test Email Account Table
    Permissions = tabledata "Test Email Connector Setup" = RIMD,
                  tabledata "Sent Email" = RIMD,
                  tabledata "Email Outbox" = RIMD,
                  tabledata "Email Recipient" = RIMD;
}