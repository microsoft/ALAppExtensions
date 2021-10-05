// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set allows you to view the language list and set the preferred language for the user
/// </summary>
PermissionSet 535 "Language - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Language - Read";

    Permissions = tabledata "User Personalization" = im;
}
