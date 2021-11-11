// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8702 "Table Information - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Table Information Cache Impl." = X,
                  Codeunit "Table Information Cache" = X,
                  Page "Company Size Cache Part" = X,
                  Page "Table Information Cache Part" = X,
                  Page "Table Information" = X,
                  Table "Company Size Cache" = X,
                  Table "Table Information Cache" = X;
}
