// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4102 "BLOB Storage - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Persistent Blob Impl." = X,
                  Codeunit "Persistent Blob" = X,
                  Codeunit "Temp Blob Impl." = X,
                  Codeunit "Temp Blob List Impl." = X,
                  Codeunit "Temp Blob List" = X,
                  Codeunit "Temp Blob" = X,
                  Table "Persistent Blob" = X,
                  Table "Temp Blob" = X;
}
