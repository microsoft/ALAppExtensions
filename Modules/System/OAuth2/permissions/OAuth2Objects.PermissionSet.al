// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 501 "OAuth2 - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Environment Info. - Objects",
                             "URI - Objects";

    Permissions = Codeunit OAuth2 = X,
                  Codeunit OAuth2Impl = X,
                  Page OAuth2ControlAddIn = X;
}
