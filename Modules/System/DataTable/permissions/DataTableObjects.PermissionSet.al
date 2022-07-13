// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 50000 "DataTable - Objects"
{
    Assignable = false;

    Permissions = Codeunit DataTable = X,
                  Codeunit "DataTable Impl." = X;
}