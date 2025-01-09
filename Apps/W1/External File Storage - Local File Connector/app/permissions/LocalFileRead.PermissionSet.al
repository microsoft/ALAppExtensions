// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4821 "Local File - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Local File - Read';

    IncludedPermissionSets = "Local File - Objects";

    Permissions =
        tabledata "Local File Account" = r;
}
