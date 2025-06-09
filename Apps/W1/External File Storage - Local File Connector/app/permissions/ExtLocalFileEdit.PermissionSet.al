// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4822 "Ext. Local File - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Local File - Edit';

    IncludedPermissionSets = "Ext. Local File - Read";

    Permissions =
        tabledata "Ext. Local File Account" = imd;
}
