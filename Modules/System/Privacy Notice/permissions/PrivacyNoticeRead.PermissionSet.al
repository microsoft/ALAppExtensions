// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1564 "Privacy Notice - Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'Privacy Notice - Read';
    
    IncludedPermissionSets = "Privacy Notice - Objects";

    Permissions = tabledata Company = r,
                  tabledata "Privacy Notice" = R,
                  tabledata "Privacy Notice Approval" = R,
                  tabledata "Page Data Personalization" = R; // Page.RunModal requires this
}
