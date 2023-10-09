// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;
permissionset 4509 "Email ORA - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - Outlook REST API - Read';

    IncludedPermissionSets = "Email ORA - Objects";

    Permissions = tabledata "Email - Outlook Account" = r,
                    tabledata "Email - Outlook API Setup" = R;
}
