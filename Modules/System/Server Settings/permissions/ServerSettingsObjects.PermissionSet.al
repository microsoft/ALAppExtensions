// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3703 "Server Settings - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Server Setting Impl." = X,
                  Codeunit "Server Setting" = X;
}
