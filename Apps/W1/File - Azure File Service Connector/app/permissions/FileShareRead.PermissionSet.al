// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 80201 "File Share - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'File Share - Read';

    IncludedPermissionSets = "File Share - Objects";

    Permissions =
        tabledata "File Share Account" = r;
}
