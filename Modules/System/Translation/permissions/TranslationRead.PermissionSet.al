// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 3711 "Translation - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Translation - Objects",
                             "Language - Read";

    Permissions = tabledata Translation = r;
}
