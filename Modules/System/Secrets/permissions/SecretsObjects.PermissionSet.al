// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3800 "Secrets - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "App Key Vault Secret Pr. Impl." = X,
                  Codeunit "App Key Vault Secret Provider" = X,
                  Codeunit "In Memory Secret Prov Impl." = X,
                  Codeunit "In Memory Secret Provider" = X;
}
