// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9100 "SharePoint API - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "URI - Objects",
                             "SharePoint Auth. - Objects";

    Permissions = Codeunit "SharePoint Client" = X,
                  Codeunit "SharePoint Client Impl." = X,
                  Codeunit "SharePoint File" = X,
                  Codeunit "SharePoint Folder" = X,
                  Codeunit "SharePoint Http Content" = X,
                  Codeunit "SharePoint List" = X,
                  Codeunit "SharePoint List Item" = X,
                  Codeunit "SharePoint List Item Atch." = X,
                  Codeunit "SharePoint Operation Response" = X,
                  Codeunit "SharePoint Request Helper" = X,
                  Codeunit "SharePoint Uri Builder" = X,
                  Codeunit "SharePoint Diagnostics" = X,
                  Table "SharePoint File" = X,
                  Table "SharePoint Folder" = X,
                  Table "SharePoint List" = X,
                  Table "SharePoint List Item" = X,
                  Table "SharePoint List Item Atch" = X;

}
