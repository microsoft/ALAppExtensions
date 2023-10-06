// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Security.AccessControl;

permissionsetextension 4511 "Email - Edit - SMTP" extends "Email - Edit"
{
    IncludedPermissionSets = "Email SMTP - Read";
}
