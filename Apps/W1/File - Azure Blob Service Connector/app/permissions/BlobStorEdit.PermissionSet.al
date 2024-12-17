// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 80102 "Blob Stor. - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Edit';

    IncludedPermissionSets = "Blob Stor. - Read";

    Permissions =
        tabledata "Blob Storage Account" = imd;
}
