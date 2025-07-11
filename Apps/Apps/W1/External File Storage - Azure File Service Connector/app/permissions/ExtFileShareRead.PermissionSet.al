// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4571 "Ext. File Share - Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'File Share - Read';

    IncludedPermissionSets = "Ext. File Share - Objects";

    Permissions =
        tabledata "Ext. File Share Account" = r;
}
