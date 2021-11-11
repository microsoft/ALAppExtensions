// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 41 "Filter Tokens - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Filter Tokens Impl." = X,
                  Codeunit "Filter Tokens" = X;
}
