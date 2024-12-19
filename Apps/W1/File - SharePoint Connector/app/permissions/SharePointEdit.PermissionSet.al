// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 80302 "SharePoint - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'SharePoint - Edit';

    IncludedPermissionSets = "SharePoint - Read";

    Permissions =
        tabledata "SharePoint Account" = imd;
}
