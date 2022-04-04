// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 8900 "Email - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Email - Objects",
                             "Retention Policy - View",
                             "Upgrade Tags - View",
                             "Telemetry - Exec";

    Permissions = tabledata "Email Connector Logo" = r,
                  tabledata "Email Error" = r,
                  tabledata "Email Outbox" = r,
                  tabledata "Sent Email" = r,
                  tabledata "Email Message" = r,
                  tabledata "Email Message Attachment" = r,
                  tabledata "Email Recipient" = r,
                  tabledata "Email Related Record" = r,
                  tabledata "Email Scenario" = r,
                  tabledata "Email View Policy" = r,
                  tabledata Field = r,
                  tabledata Media = r, // Email Account Wizard requires this
                  tabledata "Media Resources" = r,
                  tabledata "Tenant Media" = r;
}
