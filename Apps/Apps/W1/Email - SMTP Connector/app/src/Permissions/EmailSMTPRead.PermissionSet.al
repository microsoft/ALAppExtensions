// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 5523 "Email SMTP - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Read';

    IncludedPermissionSets = "Email SMTP - Objects";

    Permissions = tabledata "SMTP Account" = r;
}
