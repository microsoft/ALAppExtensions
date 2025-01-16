// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4582 "Ext. SharePoint - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'SharePoint - Edit';

    IncludedPermissionSets = "Ext. SharePoint - Read";

    Permissions =
        tabledata "Ext. SharePoint Account" = imd;
}
