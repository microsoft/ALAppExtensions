// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4561 "Blob Stor. - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Read';

    IncludedPermissionSets = "Blob Stor. - Objects";

    Permissions =
        tabledata "Blob Storage Account" = r;
}
