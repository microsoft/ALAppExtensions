// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 131006 "All Objects"
{
    Access = Public;
    Assignable = true;

    Permissions = table * = X,
                  report * = X,
                  codeunit * = X,
                  page * = X,
                  xmlport * = X,
                  query * = X;
}