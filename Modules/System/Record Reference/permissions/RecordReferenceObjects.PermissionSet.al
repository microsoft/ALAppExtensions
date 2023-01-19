// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3917 "Record Reference - Objects"
{
    Assignable = false;
    Access = internal;

    Permissions = codeunit "Record Reference" = X,
                  codeunit "Record Reference Impl." = X,
                  codeunit "Record Reference Default Impl." = X;
}