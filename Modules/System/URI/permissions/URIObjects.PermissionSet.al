// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3060 "URI - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Uri Builder Impl." = X,
                  Codeunit "Uri Builder" = X,
                  Codeunit Uri = X;
}
