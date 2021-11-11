// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 218 "System Initialization - Obj."
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "System Initialization Impl." = X,
                  Codeunit "System Initialization" = X;
}
