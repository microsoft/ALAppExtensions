// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4581 "Ext. SharePoint - Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'SharePoint - Read';

    IncludedPermissionSets = "Ext. SharePoint - Objects";

    Permissions =
        tabledata "Ext. SharePoint Account" = r;
}
