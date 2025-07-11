// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4561 "Ext. Blob Stor. - Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'Blob Storage - Read';

    IncludedPermissionSets = "Ext. Blob Stor. - Objects";

    Permissions =
        tabledata "Ext. Blob Storage Account" = r;
}
