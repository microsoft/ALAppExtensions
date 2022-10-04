// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9070 "SharePoint Auth. - Objects"
{
    Assignable = false;

    Permissions = Codeunit "SharePoint Authorization Code" = X,
                  Codeunit "SharePoint Auth." = X,
                  Codeunit "SharePoint Auth. - Impl." = X;
}