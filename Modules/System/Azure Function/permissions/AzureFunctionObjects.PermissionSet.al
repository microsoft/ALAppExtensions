// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7800 "Azure Function - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Azure Functions" = X,
                codeunit "Azure Functions Authentication" = X,
                codeunit "Azure Functions Code Auth" = X,
                codeunit "Azure Functions OAuth2" = X,
                codeunit "Azure Functions Impl" = X;
}
