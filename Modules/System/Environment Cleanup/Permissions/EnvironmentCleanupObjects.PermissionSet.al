// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1886 "Environment Cleanup - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Environment Cleanup Impl" = X,
                  Codeunit "Environment Cleanup" = X;
}
