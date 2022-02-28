// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1565 "Priv. Notice - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Privacy Notice - Admin';

    IncludedPermissionSets = "Priv. Notice - View";

    Permissions = tabledata "Privacy Notice" = IMd,
                  tabledata "Privacy Notice Approval" = IMD;
}
