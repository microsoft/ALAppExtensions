// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set allows the editing of translations from the Translations page. The table is internal but the page is editable.
/// </summary>
PermissionSet 3712 "Translation - Edit"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Translation - Read",
                             "Language - View";

    Permissions = tabledata Translation = imd;
}
