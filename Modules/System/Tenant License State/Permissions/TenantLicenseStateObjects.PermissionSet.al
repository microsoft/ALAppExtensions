// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2301 "Tenant License State - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Tenant License State Impl." = X,
                  Codeunit "Tenant License State" = X;
}
