// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9862 "Permission Sets - Objects"
{
    Access = Internal;
    Assignable = false;
    Permissions =
        table "Permission Lookup Buffer" = X,
        table "PermissionSet Buffer" = X,
        table "Permission Set Relation Buffer" = X,
        codeunit "Permission Impl." = X,
        codeunit "Permission Set Copy Impl." = X,
        codeunit "Permission Set Relation Impl." = X,
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