// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9150 "SharePoint Auth. - Objects"
{
    Assignable = false;

    Permissions = codeunit "SharePoint Authorization Code" = X,
                  codeunit "SharePoint Auth." = X,
                  codeunit "SharePoint Auth. - Impl." = X;
}