// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4821 "Ext. Local File - Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'Local File - Read';

    IncludedPermissionSets = "Ext. Local File - Objects";

    Permissions =
        tabledata "Ext. Local File Account" = r;
}
