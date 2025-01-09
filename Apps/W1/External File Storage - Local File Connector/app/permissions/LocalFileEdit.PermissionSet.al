// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4822 "Local File - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Local File - Edit';

    IncludedPermissionSets = "Local File - Read";

    Permissions =
        tabledata "Local File Account" = imd;
}
