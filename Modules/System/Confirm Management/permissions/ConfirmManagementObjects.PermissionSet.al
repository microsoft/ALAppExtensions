// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 26 "Confirm Management - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Confirm Management Impl." = X,
                  Codeunit "Confirm Management" = X;
}
