// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 421 "Data Compression - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Data Compression Impl." = X,
                  Codeunit "Data Compression" = X;
}
