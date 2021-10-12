// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set allows editing of the list of languages.
/// </summary>
PermissionSet 43 "Language - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Language - View";

    Permissions = tabledata Language = IMD;
}
