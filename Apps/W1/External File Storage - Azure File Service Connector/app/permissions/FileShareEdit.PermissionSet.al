// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4572 "File Share - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'File Share - Edit';

    IncludedPermissionSets = "File Share - Read";

    Permissions =
        tabledata "File Share Account" = imd;
}
