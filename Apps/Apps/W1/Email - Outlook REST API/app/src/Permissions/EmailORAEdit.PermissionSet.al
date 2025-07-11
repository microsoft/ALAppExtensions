// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 4507 "Email ORA - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - Outlook REST API - Edit';

    IncludedPermissionSets = "Email ORA - Read";

    Permissions = tabledata "Email - Outlook Account" = imd,
                  tabledata "Email - Outlook API Setup" = IMD;
}
