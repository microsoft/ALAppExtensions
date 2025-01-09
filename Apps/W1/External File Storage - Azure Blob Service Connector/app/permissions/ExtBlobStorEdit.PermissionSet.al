// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4562 "Ext. Blob Stor. - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Edit';

    IncludedPermissionSets = "Ext. Blob Stor. - Read";

    Permissions =
        tabledata "Ext. Blob Storage Account" = imd;
}
