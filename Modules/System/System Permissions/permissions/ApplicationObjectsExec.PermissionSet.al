// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 64 "Application Objects - Exec"
{
    Access = Internal;
    Assignable = false;

    Permissions = table * = X,
                  report * = X,
                  codeunit * = X,
                  page * = X,
                  xmlport * = X,
                  query * = X;
}