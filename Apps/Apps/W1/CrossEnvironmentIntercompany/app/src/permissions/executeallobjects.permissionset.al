// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

permissionset 30401 "Execute All Objects"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  page * = X,
                  table * = X,
                  query * = X,
                  report * = X,
                  xmlport * = X;
}
