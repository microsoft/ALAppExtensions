// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4110 "Base64 Convert - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Base64 Convert Impl." = X,
                  Codeunit "Base64 Convert" = X;
}
