// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3713 "Translation - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Translation Implementation" = X,
                  Codeunit Translation = X,
                  Page Translation = X,
                  Table Translation = X;
}
