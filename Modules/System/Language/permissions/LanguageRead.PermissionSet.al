// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 54 "Language - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Language - Objects";

    Permissions = tabledata Language = R,
                  tabledata "Page Data Personalization" = R, // Page.Run requires this
                  tabledata "User Personalization" = r,
                  tabledata "Windows Language" = r;
}
