// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

permissionset 2716 "Page Summary Provider - Obj."
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Page Summary Provider" = X,
                  codeunit "Page Summary Settings" = X,
                  page "Page Summary Settings" = X,
                  table "Page Summary Settings" = X;
}
