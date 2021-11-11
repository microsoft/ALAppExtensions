// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 600 "Data Archive - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Data Archive Implementation" = X,
                  codeunit "Data Archive" = X;
}
