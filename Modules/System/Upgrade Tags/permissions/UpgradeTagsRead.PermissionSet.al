// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9992 "Upgrade Tags - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata Company = r,
                  tabledata "Intelligent Cloud" = r;
}
