// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4572 "Ext. File Share - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'File Share - Edit';

    IncludedPermissionSets = "Ext. File Share - Read";

    Permissions =
        tabledata "Ext. File Share Account" = imd;
}
