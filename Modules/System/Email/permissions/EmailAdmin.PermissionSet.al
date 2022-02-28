// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 8902 "Email - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Email - Admin';

    IncludedPermissionSets = "Email - Edit";

    Permissions = tabledata "Email Scenario" = imd,
                  tabledata "Email View Policy" = imd;
}
