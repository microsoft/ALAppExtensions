// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4030 "Client Type Mgt. - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Client Type Management" = X,
                  Codeunit "Client Type Mgt. Impl." = X;
}
