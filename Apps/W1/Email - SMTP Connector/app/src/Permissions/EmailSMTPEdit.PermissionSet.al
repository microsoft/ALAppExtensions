// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 5521 "Email SMTP - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Edit';

    IncludedPermissionSets = "Email SMTP - Read";

    Permissions = tabledata "SMTP Account" = imd;
}
