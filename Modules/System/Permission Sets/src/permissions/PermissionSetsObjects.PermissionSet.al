// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

permissionset 9862 "Permission Sets - Objects"
{
    Access = Internal;
    Assignable = false;
    Permissions =
        codeunit "Permission Set Relation" = X,
        codeunit "Log Activity Permissions" = X,
        page "Expanded Permissions" = X,
        page "Expanded Permissions Factbox" = X,
        page "Included PermissionSet FactBox" = X,
        page "Metadata Permission Subform" = X,
        page "Permission Lookup List" = X,
        page "Permission Set" = X,
        page "Permission Set Subform" = X,
        page "Permission Set Tree" = X,
        page "Tenant Permission Subform" = X,
        xmlport "Export Permission Sets System" = X,
        xmlport "Export Permission Sets Tenant" = X,
        xmlport "Import Permission Sets" = X;
}