#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------\

permissionset 1885 "Sandbox Cleanup - Objects"
{
    ObsoleteReason = 'Replaced by Environment Cleanup module.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
    Access = Internal;
    Assignable = false;


    Permissions = Codeunit "Sandbox Cleanup Impl." = X,
                  Codeunit "Sandbox Cleanup" = X;
}
#endif