// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2200 "Azure Key Vault - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Azure Key Vault Impl." = X,
                  Codeunit "Azure Key Vault" = X;
}
