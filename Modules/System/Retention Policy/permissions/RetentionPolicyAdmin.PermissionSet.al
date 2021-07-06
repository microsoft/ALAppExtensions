// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 3902 "Retention Policy - Admin"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Retention Policy - View";

    Permissions = tabledata "Retention Period" = IMD,
                  tabledata "Retention Policy Setup" = IMD,
                  tabledata "Retention Policy Setup Line" = IMD;
}
