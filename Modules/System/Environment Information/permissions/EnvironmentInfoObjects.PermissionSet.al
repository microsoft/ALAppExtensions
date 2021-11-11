// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 417 "Environment Info. - Objects"
{
    Assignable = false;

    IncludedPermissionSets = "Server Settings - Objects";

    Permissions = Codeunit "Environment Information Impl." = X,
                  Codeunit "Environment Information" = X,
                  Codeunit "Tenant Information Impl." = X,
                  Codeunit "Tenant Information" = X;
}
