// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 166 "User Permissions - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "User Permissions" = X,
                  Page "Lookup Permission Set" = X;
}
