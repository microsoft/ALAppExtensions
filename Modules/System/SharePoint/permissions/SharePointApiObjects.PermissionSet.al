// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9100 "SharePoint API - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "SharePoint Auth. - Objects";

    Permissions = Codeunit "SharePoint Client" = X;
}
