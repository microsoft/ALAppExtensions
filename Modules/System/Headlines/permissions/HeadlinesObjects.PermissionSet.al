// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1472 "Headlines - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Headlines Impl." = X,
                  Codeunit Headlines = X;
}
