// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Security.AccessControl;

permissionsetextension 4512 "Email - Admin - SMTP" extends "Email - Admin"
{
    IncludedPermissionSets = "Email SMTP - Edit";
}
