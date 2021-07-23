// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 8901 "Email - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Email - Edit';

    IncludedPermissionSets = "Email - Read";

    Permissions = tabledata "Email Connector Logo" = imd,
                  tabledata "Email Error" = imd,
                  tabledata "Email Outbox" = imd,
                  tabledata "Sent Email" = imd,
                  tabledata "Email Message" = imd,
                  tabledata "Email Message Attachment" = imd,
                  tabledata "Email Recipient" = imd,
                  tabledata "Email Related Record" = id,
                  tabledata "Tenant Media" = imd;
}
